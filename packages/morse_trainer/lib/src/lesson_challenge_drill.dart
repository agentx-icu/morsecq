import 'dart:math';

import 'char_weights.dart';
import 'drill.dart';
import 'koch_course.dart';
import 'morse_text.dart';
import 'random_groups_drill.dart';

/// The Koch lesson challenge: weighted random groups over the learned set
/// that are guaranteed to contain each symbol the lesson introduces often
/// enough for [KochCourse.evaluate] to judge it.
///
/// Stateful: one [generate] call is one round of the session. Each
/// required symbol has a session-wide quota (`min(minRequiredAttempts,
/// charBudget ~/ requiredChars.length)`) spread evenly over the planned rounds;
/// before a round the drill computes how many occurrences the session must
/// have reached by its end and, when the random group falls short, replaces
/// positions that hold no required symbol (or a required symbol already
/// ahead of its own target) until the deficit is covered. Natural
/// occurrences count, so most rounds stay ordinary mixed copying: the drill
/// only ever replaces the deficit, never a symbol that happened to come up
/// anyway (at most `quota` positions in the whole session per required
/// symbol, ten of fifty with the defaults). After the planned rounds any
/// remaining deficit is forced at once, so a session that overshoots its
/// budget still covers.
///
/// The guarantee is the session-wide quota, never a per-round pattern: at a
/// group size of 1 the required symbols are served in turn only while both
/// are behind, and the other rounds are random. Deterministic for a given
/// [Random].
final class LessonChallengeDrill implements DrillGenerator {
  LessonChallengeDrill({
    required Iterable<String> chars,
    required Iterable<String> newChars,
    required this.charBudget,
    this.groupSize = 5,
    int minRequiredAttempts = KochCourse.defaultMinNewCharAttempts,
    CharWeights? weights,
  }) : assert(charBudget > 0, 'charBudget must be positive'),
       assert(groupSize > 0, 'groupSize must be positive'),
       assert(minRequiredAttempts >= 0, 'minRequiredAttempts must be >= 0'),
       _inner = RandomGroupsDrill(
         chars: chars,
         groupCount: 1,
         groupSize: groupSize,
         weights: weights,
       ),
       plannedRounds = max(1, (charBudget / groupSize).ceil()) {
    requiredChars = List<String>.unmodifiable(
      newChars
          .map(MorseText.normalizeChar)
          .toSet()
          .where(_inner.chars.contains),
    );
    quota = requiredChars.isEmpty
        ? 0
        : min(minRequiredAttempts, charBudget ~/ requiredChars.length);
  }

  final RandomGroupsDrill _inner;

  /// Symbols that must reach [quota] occurrences over the session (the new
  /// symbols that are in the pool), in the order given.
  late final List<String> requiredChars;

  /// Occurrences each required symbol is guaranteed over [plannedRounds].
  late final int quota;

  /// Symbols the session will play (the challenge's budget).
  final int charBudget;
  final int groupSize;

  /// Rounds the budget spans; the quota is spread over these.
  final int plannedRounds;

  final Map<String, int> _emitted = <String, int>{};
  int _round = 0;

  /// Distinct, normalised symbol pool.
  List<String> get chars => _inner.chars;

  @override
  String get kind => _inner.kind;

  /// Rounds generated so far.
  int get roundsGenerated => _round;

  /// How often [c] has been emitted so far.
  int emittedCount(String c) => _emitted[c] ?? 0;

  /// Occurrences of every required symbol the session must have reached
  /// once [rounds] rounds were generated: the quota spread evenly, whole
  /// from the planned end onwards.
  int targetAfter(int rounds) =>
      rounds >= plannedRounds ? quota : (quota * rounds / plannedRounds).ceil();

  @override
  Drill generate(Random random) {
    final symbols = _inner.weights
        .pickMany(random, chars, groupSize)
        .toList(growable: false);
    if (quota > 0) _enforce(symbols, random);
    for (final s in symbols) {
      _emitted[s] = emittedCount(s) + 1;
    }
    _round++;
    return Drill.fromText(symbols.join(), kind: kind);
  }

  void _enforce(List<String> symbols, Random random) {
    final target = targetAfter(_round + 1);
    final n = requiredChars.length;
    // Rotate who is served first so no symbol always loses the slot race
    // when a group cannot hold every deficit (group size 1, lesson 1).
    for (var k = 0; k < n; k++) {
      final c = requiredChars[(_round + k) % n];
      var deficit = target - _have(symbols, c);
      while (deficit > 0) {
        final candidates = <int>[
          for (var i = 0; i < symbols.length; i++)
            if (_mayReplace(symbols, i, target)) i,
        ];
        if (candidates.isEmpty) break;
        symbols[candidates[random.nextInt(candidates.length)]] = c;
        deficit--;
      }
    }
  }

  /// Occurrences of [c] including the group being built.
  int _have(List<String> symbols, String c) =>
      emittedCount(c) + symbols.where((s) => s == c).length;

  /// A position may be replaced when it holds no required symbol, or a
  /// required symbol that stays at or above [target] without it.
  bool _mayReplace(List<String> symbols, int i, int target) {
    final s = symbols[i];
    if (!requiredChars.contains(s)) return true;
    return _have(symbols, s) > target;
  }
}
