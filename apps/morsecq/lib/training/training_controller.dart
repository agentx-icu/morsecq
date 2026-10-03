import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'receive_session.dart';
import 'send_session.dart';
import 'training_settings.dart';
import 'training_settings_store.dart';

/// What recording a receive session did to the learner's state.
final class ReceiveOutcome {
  const ReceiveOutcome({
    required this.score,
    required this.passed,
    required this.advanced,
    required this.lesson,
  });

  final SessionScore score;

  /// Whether the Koch unlock rule was met (regardless of [advanced]).
  final bool passed;

  /// Whether the current lesson moved forward.
  final bool advanced;

  /// Lesson after recording.
  final int lesson;
}

/// Learner state for the Learn tab: loads progress and settings, exposes the
/// Koch position, SRS due list and streak, starts sessions and records their
/// results. Pure logic on top of the stores; time and randomness are
/// injected so tests replay deterministically.
final class TrainingController extends ChangeNotifier {
  TrainingController({
    required TrainerStore progressStore,
    required TrainingSettingsStore settingsStore,
    KochCourse? course,
    DateTime Function()? now,
    Random? random,
  }) : _progressStore = progressStore,
       _settingsStore = settingsStore,
       course = course ?? KochCourse(),
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  /// Symbols one send-practice target contains.
  static const int sendTargetChars = 5;

  /// Lesson from which QSO drills are offered (they need most letters).
  static const int qsoFromLesson = 30;

  /// Abbreviations / Q-codes needed before that drill is offered.
  static const int minShorthandWords = 3;

  final TrainerStore _progressStore;
  final TrainingSettingsStore _settingsStore;
  final KochCourse course;
  final DateTime Function() _now;
  final Random _random;

  TrainerProgress _progress = TrainerProgress();
  TrainingSettings _settings = TrainingSettings.defaults;
  TrainingSettings _savedSettings = TrainingSettings.defaults;
  bool _loaded = false;
  bool _disposed = false;
  Object? _loadError;
  Future<void> _writes = Future<void>.value();
  final Map<Object, (Object, StackTrace)> _writeErrors = {};

  bool get isLoaded => _loaded;

  /// Set when [load] could not read the stores; the controller then runs on
  /// defaults and the next save overwrites whatever was unreadable.
  Object? get loadError => _loadError;

  TrainerProgress get progress => _progress;
  TrainingSettings get settings => _settings;
  TrainerSettings get trainerSettings => _settings.trainer;

  DateTime now() => _now();

  // ---------------------------------------------------------------------------
  // Lifecycle

  Future<void> load() async {
    _ensureActive();
    try {
      final progress = await _progressStore.load();
      final settings = await _settingsStore.load();
      if (_disposed) return;
      _progress = _clampLesson(progress ?? TrainerProgress());
      _settings = settings ?? TrainingSettings.defaults;
      _savedSettings = _settings;
      _loadError = null;
    } on Object catch (error) {
      if (_disposed) return;
      _loadError = error;
      _progress = TrainerProgress();
      _settings = TrainingSettings.defaults;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(TrainingSettings settings) async {
    _ensureActive();
    if (settings == _settings) {
      return;
    }
    _settings = settings;
    final save = _persist(_settingsStore, () async {
      await _settingsStore.save(settings);
      _savedSettings = settings;
    });
    notifyListeners();
    try {
      await save;
    } on Object {
      if (!_disposed && identical(_settings, settings)) {
        _settings = _savedSettings;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> setDailyGoal(int chars) =>
      _commit(_progress.copyWith(dailyGoalChars: chars));

  /// Jumps to [lesson] (clamped); for the lesson picker.
  Future<void> setLesson(int lesson) =>
      _commit(_progress.withLesson(course.clampLesson(lesson)));

  Future<void> resetProgress() async {
    _ensureActive();
    _progress = TrainerProgress();
    final clear = _persist(_progressStore, _progressStore.clear);
    notifyListeners();
    await clear;
  }

  /// Durability barrier used before backgrounding, backup or replacement.
  Future<void> flush() async {
    await _writes;
    if (_writeErrors.isNotEmpty) {
      final (error, stack) = _writeErrors.values.first;
      Error.throwWithStackTrace(error, stack);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Lesson view

  int get currentLesson => _progress.currentLesson;
  int get lessonCount => course.lessonCount;
  bool get isCourseComplete => course.isLastLesson(currentLesson);

  /// Every symbol taught up to and including the current lesson.
  List<String> get learnedChars => course.charsForLesson(currentLesson);

  /// The symbol the current lesson introduces.
  String get newestChar => course.newCharForLesson(currentLesson);

  /// Symbols the SRS wants drilled now, plus learned symbols never tracked.
  List<String> get dueChars => _progress.srs.dueOrNew(learnedChars, _now());

  int get streak => _progress.streakAsOf(_now());
  int get charsToday => _progress.charsOn(_now());
  int get dailyGoal => _progress.dailyGoalChars;
  double get dailyGoalFraction =>
      dailyGoal == 0 ? 1 : (charsToday / dailyGoal).clamp(0.0, 1.0);
  bool get dailyGoalMet => _progress.dailyGoalMet(_now());

  /// Accuracy of [char] over all recorded sessions, or null if never drilled.
  double? accuracyOf(String char) => _progress.charStats[char]?.accuracy;

  /// Drill kinds the learned set can support right now.
  List<ReceiveDrillKind> get availableReceiveKinds {
    final chars = learnedChars;
    return <ReceiveDrillKind>[
      for (final kind in ReceiveDrillKind.values)
        if (kind != ReceiveDrillKind.review && _drillFor(kind, chars) != null)
          kind,
    ];
  }

  // ---------------------------------------------------------------------------
  // Sessions

  /// The Koch lesson drill: weighted random groups over the learned set.
  ReceiveSession startLessonSession() =>
      startReceiveSession(ReceiveDrillKind.groups);

  ReceiveSession startReceiveSession(ReceiveDrillKind kind) {
    if (kind == ReceiveDrillKind.review) {
      return startReviewSession();
    }
    final chars = learnedChars;
    final t = trainerSettings;
    final generator = _generatorFor(kind, chars);
    return ReceiveSession(
      kind: kind,
      generator: generator,
      // QSO scripts are fixed text (names, rigs, <BT>, <SK>), not filtered
      // to the lesson, so their keypad offers every symbol of the course.
      chars: generator is QsoDrill ? course.order : chars,
      timing: t.toTiming(),
      charBudget: t.sessionLengthChars,
      timeBudget: t.sessionLengthSeconds == null
          ? null
          : Duration(seconds: t.sessionLengthSeconds!),
      lesson: currentLesson,
      countsTowardLesson: true,
      random: _random,
      now: _now,
    );
  }

  /// SRS review: due symbols only (falls back to the whole learned set when
  /// nothing is due), weighted by weakness. Never advances the lesson.
  ReceiveSession startReviewSession() {
    final due = dueChars;
    final pool = due.length >= 2 ? due : learnedChars;
    final t = trainerSettings;
    return ReceiveSession(
      kind: ReceiveDrillKind.review,
      generator: RandomGroupsDrill(
        chars: pool,
        groupCount: 1,
        groupSize: t.groupSize,
        weights: _weights(),
      ),
      chars: pool,
      timing: t.toTiming(),
      charBudget: t.sessionLengthChars,
      timeBudget: t.sessionLengthSeconds == null
          ? null
          : Duration(seconds: t.sessionLengthSeconds!),
      lesson: currentLesson,
      random: _random,
      now: _now,
    );
  }

  /// One short target (a word if the learned set allows, else a group).
  SendSession startSendSession() {
    final chars = learnedChars;
    final words = WordDrill.commonWords(
      allowedChars: chars.toSet(),
      wordCount: 1,
    );
    final generator = words.hasCandidates
        ? words
        : RandomGroupsDrill(
            chars: chars,
            groupCount: 1,
            groupSize: sendTargetChars,
            weights: _weights(),
          );
    return SendSession(
      target: generator.generate(_random).text,
      timing: trainerSettings.toTiming(),
      now: _now,
      lesson: currentLesson,
    );
  }

  /// Folds a finished receive session into progress (stats, streak, SRS,
  /// confusion) and, for lesson sessions, applies the Koch unlock rule.
  Future<ReceiveOutcome> recordReceiveSession(ReceiveSession session) async {
    final score = session.finish();
    var next = _progress.recordSession(
      score,
      now: _now(),
      lesson: session.lesson,
    );
    final before = next.currentLesson;
    if (session.countsTowardLesson) {
      next = next.advanceIfPassed(course, score);
    }
    await _commit(next);
    return ReceiveOutcome(
      score: score,
      passed: course.passes(score),
      advanced: next.currentLesson != before,
      lesson: next.currentLesson,
    );
  }

  /// Credits a finished send session to history, streak and the daily goal.
  ///
  /// Sending accuracy is a different skill from copying, so the per-symbol
  /// receive statistics, SRS boxes and confusion matrix are left untouched;
  /// only the history entry (and the streak derived from it) is added.
  Future<SessionScore> recordSendSession(SendSession session) async {
    final score = session.scoreForHistory();
    final now = _now();
    final summary = SessionSummary.fromScore(score, at: now);
    final history = <SessionSummary>[..._progress.history, summary];
    if (history.length > _progress.maxHistory) {
      history.removeRange(0, history.length - _progress.maxHistory);
    }
    await _commit(
      _progress.copyWith(
        history: history,
        streakDays: _streakAfterPracticeOn(now),
        lastPracticeDay: TrainerProgress.dayOf(now),
      ),
    );
    return score;
  }

  // ---------------------------------------------------------------------------
  // Internals

  /// The drill for [kind], falling back to lesson groups when the learned
  /// set cannot support it yet.
  DrillGenerator _generatorFor(ReceiveDrillKind kind, List<String> chars) =>
      _drillFor(kind, chars) ?? _drillFor(ReceiveDrillKind.groups, chars)!;

  /// The drill for [kind] over [chars], or null when [chars] (or the
  /// current lesson) cannot support it. Single source of truth for both
  /// [availableReceiveKinds] and the sessions that are started.
  DrillGenerator? _drillFor(ReceiveDrillKind kind, List<String> chars) {
    final allowed = chars.toSet();
    final t = trainerSettings;
    final lateLessons = currentLesson >= qsoFromLesson;
    switch (kind) {
      case ReceiveDrillKind.groups:
      case ReceiveDrillKind.review:
        return RandomGroupsDrill(
          chars: chars,
          groupCount: 1,
          groupSize: t.groupSize,
          weights: _weights(),
        );
      case ReceiveDrillKind.characters:
        return RandomGroupsDrill(
          chars: chars,
          groupCount: 1,
          groupSize: 1,
          weights: _weights(),
        );
      case ReceiveDrillKind.words:
        final words = WordDrill.commonWords(
          allowedChars: allowed,
          wordCount: 2,
        );
        return words.hasCandidates ? words : null;
      case ReceiveDrillKind.abbreviations:
        final shorthand = WordDrill.radioShorthand(
          allowedChars: allowed,
          wordCount: 2,
        );
        // `K` alone is an abbreviation; a drill of only `K K` is not one.
        return shorthand.candidates.length >= minShorthandWords
            ? shorthand
            : null;
      case ReceiveDrillKind.numbers:
        final numbers = NumberGroupsDrill(
          groupSize: t.groupSize,
          allowedChars: allowed,
        );
        return numbers.canGenerate ? numbers : null;
      case ReceiveDrillKind.callsigns:
        final calls = CallsignDrill(count: 1, allowedChars: allowed);
        return calls.canGenerate ? calls : null;
      case ReceiveDrillKind.confusables:
        final pairs = ConfusableDrill(
          chars: chars,
          confusion: _progress.confusion,
          groupSize: t.groupSize,
        );
        return pairs.canGenerate ? pairs : null;
      case ReceiveDrillKind.qso:
        return lateLessons ? QsoDrill() : null;
      case ReceiveDrillKind.contest:
        final contest = ContestExchangeDrill(allowedChars: allowed);
        return lateLessons && contest.canGenerate ? contest : null;
    }
  }

  CharWeights _weights() => CharWeights.fromStats(
    _progress.charStats,
    recent: course.recentCharsForLesson(currentLesson),
  );

  /// Same rule as `TrainerProgress.recordSession`: same day keeps the streak,
  /// the next day extends it, anything later restarts at 1.
  int _streakAfterPracticeOn(DateTime now) {
    final last = _progress.lastPracticeDay;
    if (last == null) {
      return 1;
    }
    final gap = TrainerProgress.dayOf(now).difference(last).inDays;
    if (gap == 0) {
      return _progress.streakDays;
    }
    return gap == 1 ? _progress.streakDays + 1 : 1;
  }

  TrainerProgress _clampLesson(TrainerProgress progress) {
    final clamped = course.clampLesson(progress.currentLesson);
    return clamped == progress.currentLesson
        ? progress
        : progress.withLesson(clamped);
  }

  Future<void> _commit(TrainerProgress next) async {
    _ensureActive();
    _progress = next;
    // Enqueue before notification: a listener can reset or record another
    // session synchronously, and that later operation must stay later.
    final save = _persist(_progressStore, () => _progressStore.save(next));
    notifyListeners();
    await save;
  }

  void _ensureActive() {
    if (_disposed) throw StateError('training controller disposed');
  }

  Future<void> _persist(Object store, Future<void> Function() operation) {
    final result = _writes.then((_) => operation());
    _writes = result.then<void>(
      (_) {
        _writeErrors.remove(store);
      },
      onError: (Object error, StackTrace stack) {
        _writeErrors[store] = (error, stack);
      },
    );
    return result;
  }
}
