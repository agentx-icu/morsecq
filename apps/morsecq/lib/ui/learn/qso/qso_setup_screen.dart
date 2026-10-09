import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_io/morse_io.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';
import '../../../training/qso_practice.dart';
import '../../../training/receive_session.dart';
import '../../../training/training_controller.dart';
import '../../../training/training_plan.dart';
import '../../../training/training_settings.dart';
import '../learn_playback.dart';
import '../receive/receive_drill_screen.dart';
import 'qso_readiness_card.dart';
import 'qso_protocol_screen.dart';
import 'qso_screen.dart';

/// Configure a simulated QSO: scenario and the learner's own callsign,
/// name and QTH (controlled single words). Offers to resume an unfinished
/// QSO. Everything runs locally; nothing goes on the wire.
class QsoSetupScreen extends StatefulWidget {
  const QsoSetupScreen({
    super.key,
    required this.controller,
    required this.playback,
    this.initialScenario = QsoScenario.shortExchange,
    this.practiceTiming,
    this.planStepId,
  });

  final TrainingController controller;
  final LearnPlaybackFactory playback;
  final QsoScenario initialScenario;
  final MorseTiming? practiceTiming;
  final String? planStepId;

  @override
  State<QsoSetupScreen> createState() => _QsoSetupScreenState();
}

class _QsoSetupScreenState extends State<QsoSetupScreen> {
  final _call = TextEditingController();
  final _name = TextEditingController();
  final _qth = TextEditingController();
  final _serial = TextEditingController();
  final _park = TextEditingController();
  late QsoScenario _scenario = widget.initialScenario;
  QsoDraft? _draft;
  bool _loaded = false;
  LearnPlayback? _playback;
  TrainingSettings? _playbackSettings;
  Future<LearnPlayback>? _creating;

  TrainingController get _c => widget.controller;

  /// Plays one untaught symbol from the readiness card. The playback is
  /// created on the first tap and rebuilt when the settings changed.
  Future<void> _hear(String char) async {
    final settings = _c.settings;
    var p = _playback;
    if (p != null && _playbackSettings != settings) {
      _playback = null;
      _creating = null;
      p.player.stop();
      await p.dispose();
      p = null;
    }
    if (p == null) {
      final creating = _creating ??= widget.playback.create(settings);
      p = await creating;
      // Several taps may await the same creation (see LessonCard).
      if (identical(_creating, creating)) {
        _creating = null;
        if (!mounted) {
          await p.dispose();
          return;
        }
        setState(() {
          _playback = p;
          _playbackSettings = settings;
        });
      } else if (!identical(_playback, p)) {
        await p.dispose();
        return;
      }
      if (!mounted) return;
    }
    p.player.stop();
    p.player.play(MorseEncoder.encode(char, _c.trainerSettings.toTiming()));
  }

  /// Opens the suggested drill and re-reads readiness on return.
  VoidCallback? _drill(ReceiveDrillKind kind) =>
      _c.availableReceiveKinds.contains(kind)
      ? () async {
          _playback?.player.stop();
          await Navigator.of(context).push(
            MaterialPageRoute<Object?>(
              builder: (_) => ReceiveDrillScreen(
                controller: _c,
                playback: widget.playback,
                session: _c.startReceiveSession(kind),
              ),
            ),
          );
          if (mounted) setState(() {});
        }
      : null;

  Future<void> _practiseSymbols() async {
    final session = _c.startQsoSymbolSession(_c.qsoReadiness.unmastered);
    if (session == null) return;
    _playback?.player.stop();
    await Navigator.of(context).push(
      MaterialPageRoute<Object?>(
        builder: (_) => ReceiveDrillScreen(
          controller: _c,
          playback: widget.playback,
          session: session,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _protocol() async {
    _playback?.player.stop();
    await Navigator.of(context).push(
      MaterialPageRoute<Object?>(
        builder: (_) => QsoProtocolScreen(controller: _c),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final station =
        await _c.loadQsoStation() ??
        QsoStation.random(Random(_c.random.nextInt(1 << 30)));
    await _c.recoverFinishedQso();
    final loaded = await _c.loadQsoDraft();
    // Older drafts may hold a finished QSO: commit it, never resume it.
    final draft = loaded != null && loaded.session.isDone ? null : loaded;
    if (loaded != null && loaded.session.isDone) {
      await _c.finishQso(loaded.session, loaded.active);
    }
    if (!mounted) return;
    setState(() {
      _call.text = station.callsign;
      _name.text = station.name;
      _qth.text = station.qth;
      _serial.text = station.serialNumber;
      _park.text = station.parkReference;
      _draft = draft;
      _loaded = true;
    });
  }

  String? _callError(S s) =>
      QsoStation.isValidCallsign(_call.text) ? null : s.learnQsoInvalidCall;

  String? _wordError(S s, TextEditingController c) =>
      QsoStation.isValidWord(c.text) ? null : s.learnQsoInvalidWord;

  bool get _valid =>
      QsoStation.isValidCallsign(_call.text) &&
      switch (_scenario) {
        QsoScenario.shortExchange => true,
        QsoScenario.contestExchange => QsoStation.isValidSerial(_serial.text),
        QsoScenario.potaActivation => QsoStation.isValidPark(_park.text),
        _ =>
          QsoStation.isValidWord(_name.text) &&
              QsoStation.isValidWord(_qth.text),
      };

  Future<void> _open(QsoSession session, {QsoDraft? resumed}) async {
    _playback?.player.stop();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QsoScreen(
          controller: _c,
          playback: widget.playback,
          session: session,
          resumed: resumed,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _start({QsoScenario? scenario}) async {
    final station = QsoStation(
      callsign: _call.text,
      name: _name.text,
      qth: _qth.text,
      serialNumber: _serial.text,
      parkReference: _park.text,
    ).normalized();
    final chosen = scenario ?? _scenario;
    final plan = _c.todayPlan;
    final step = widget.planStepId == null
        ? null
        : plan?.stepById(widget.planStepId!);
    final bound =
        chosen == widget.initialScenario &&
        step?.kind == PlanStepKind.qso &&
        step?.state == PlanStepState.active &&
        step!.pool.length == 1 &&
        step.pool.single == chosen.name;
    final snapshot = bound ? plan!.settingsOf(step) : null;
    final timing = snapshot == null
        ? widget.practiceTiming ?? _c.trainerSettings.toTiming()
        : MorseTiming(
            wpm: snapshot.characterWpm,
            farnsworthWpm: snapshot.effectiveWpm < snapshot.characterWpm
                ? snapshot.effectiveWpm
                : null,
          );
    try {
      await _c.saveQsoStation(station);
      await _c.discardQsoDraft();
    } on Object {
      // The QSO still runs; the station is asked again next time.
    }
    if (!mounted) return;
    await _open(
      QsoSession.start(
        scenario: chosen,
        seed: bound ? step.seed : _c.random.nextInt(1 << 30),
        local: station,
        characterWpm: timing.wpm,
        effectiveWpm: timing.farnsworthWpm ?? timing.wpm,
        planStepId: bound ? step.id : null,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_playback?.dispose());
    _call.dispose();
    _name.dispose();
    _qth.dispose();
    _serial.dispose();
    _park.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final flash = _playback?.flash;
    final body = !_loaded
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Follows the controller: practice recorded from
                      // here (or elsewhere) updates the readiness.
                      AnimatedBuilder(
                        animation: _c,
                        builder: (context, _) => QsoReadinessCard(
                          readiness: _c.qsoReadiness,
                          onHear: (c) => unawaited(_hear(c)),
                          onPractiseShorthand: _drill(
                            ReceiveDrillKind.abbreviations,
                          ),
                          onPractiseSymbols: () =>
                              unawaited(_practiseSymbols()),
                          onPractiseProtocol: () => unawaited(_protocol()),
                          onPractiseExchange:
                              QsoStation.isValidCallsign(_call.text)
                              ? () => unawaited(
                                  _start(scenario: QsoScenario.shortExchange),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_draft != null) ...<Widget>[
                        FilledButton.tonalIcon(
                          key: const ValueKey('qso-resume'),
                          onPressed: () =>
                              _open(_draft!.session, resumed: _draft),
                          icon: const Icon(Icons.restore),
                          label: Text(s.learnQsoResume),
                        ),
                        const SizedBox(height: 16),
                      ],
                      RadioGroup<QsoScenario>(
                        groupValue: _scenario,
                        onChanged: (v) => setState(() => _scenario = v!),
                        child: Column(
                          children: <Widget>[
                            RadioListTile<QsoScenario>(
                              value: QsoScenario.shortExchange,
                              title: Text(s.learnQsoShortExchange),
                              subtitle: Text(s.learnQsoShortExchangeHint),
                            ),
                            RadioListTile<QsoScenario>(
                              value: QsoScenario.respondToCq,
                              title: Text(s.learnQsoRespond),
                              subtitle: Text(s.learnQsoRespondHint),
                            ),
                            RadioListTile<QsoScenario>(
                              value: QsoScenario.callCq,
                              title: Text(s.learnQsoCall),
                              subtitle: Text(s.learnQsoCallHint),
                            ),
                            RadioListTile<QsoScenario>(
                              key: const ValueKey('qso-scenario-contest'),
                              value: QsoScenario.contestExchange,
                              title: Text(s.qsoAdvancedContestTitle),
                              subtitle: Text(s.qsoAdvancedContestHint),
                            ),
                            RadioListTile<QsoScenario>(
                              key: const ValueKey('qso-scenario-pota'),
                              value: QsoScenario.potaActivation,
                              title: Text(s.qsoAdvancedPotaTitle),
                              subtitle: Text(s.qsoAdvancedPotaHint),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _call,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: s.learnQsoYourCall,
                          errorText: _callError(s),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_scenario == QsoScenario.respondToCq ||
                          _scenario == QsoScenario.callCq) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _name,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: s.learnQsoYourName,
                            errorText: _wordError(s, _name),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _qth,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: s.learnQsoYourQth,
                            errorText: _wordError(s, _qth),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      if (_scenario == QsoScenario.contestExchange) ...[
                        const SizedBox(height: 12),
                        TextField(
                          key: const ValueKey('qso-station-serial'),
                          controller: _serial,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: s.qsoAdvancedSerialLabel,
                            errorText: QsoStation.isValidSerial(_serial.text)
                                ? null
                                : s.qsoAdvancedInvalidSerial,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      if (_scenario == QsoScenario.potaActivation) ...[
                        const SizedBox(height: 12),
                        TextField(
                          key: const ValueKey('qso-station-park'),
                          controller: _park,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: s.qsoAdvancedParkLabel,
                            errorText: QsoStation.isValidPark(_park.text)
                                ? null
                                : s.qsoAdvancedInvalidPark,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        s.learnQsoOffline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!_c.qsoReadiness.isReady)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            s.learnQsoExplorePending,
                            key: const ValueKey('qso-explore-label'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const ValueKey('qso-start'),
                        onPressed: _valid ? () => unawaited(_start()) : null,
                        icon: const Icon(Icons.cell_tower),
                        label: Text(s.learnQsoStart),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
    return Scaffold(
      appBar: AppBar(title: Text(s.learnQsoTitle)),
      // Flash-only learners still see the symbol they tapped.
      body: flash == null ? body : FlashOverlay(isOn: flash, child: body),
    );
  }
}
