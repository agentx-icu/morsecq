part of 'qso_screen.dart';

/// Running exchange view kept separate from playback and persistence.
extension _QsoScreenView on _QsoScreenState {
  Widget _running(BuildContext context, S s, LearnPlayback? playback) {
    final theme = Theme.of(context);
    final decoded = _pendingText;
    final canKey = playback != null && !_remotePlaying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(QsoLabels.task(s, _session), style: theme.textTheme.titleMedium),
        Text(
          s.learnQsoSpeed(_session.effectiveWpm.round()),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (_session.scenario.isAdvanced &&
            _session.stage == QsoStage.confirmInfo)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.qsoAdvancedCorrectionHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
        QsoLogView(
          session: _session,
          revealed: _revealed,
          onReveal: _reveal,
          // Hearing a transmission again is a repeat, like AGN.
          onPlay: _remotePlaying
              ? null
              : (text) {
                  _session.repeats++;
                  _playRemote(text);
                  unawaited(_saveDraft());
                },
        ),
        if (_issues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final issue in _issues)
                  Row(
                    children: <Widget>[
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(QsoLabels.issue(s, issue))),
                    ],
                  ),
              ],
            ),
          ),
        if (_hint != null)
          Card(
            key: const ValueKey('qso-hint'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(s.learnQsoHintLabel(_hint!.example)),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          _remotePlaying ? s.learnQsoRemoteSending : s.learnQsoYourTurn,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          label: s.learnQsoDecoded,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              decoded.trim().isEmpty ? s.learnQsoNothingKeyed : decoded,
              key: const ValueKey('qso-decoded'),
              style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (playback == null)
          const Center(child: CircularProgressIndicator())
        else if (_typing)
          TextField(
            key: const ValueKey('qso-typed-reply'),
            controller: _typedText,
            enabled: canKey,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: s.qsoAdvancedTypedReply,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => _typedChanged(),
          )
        else
          KeyerPanel(
            key: _panel,
            session: _keying,
            playback: playback,
            mode: _c.settings.keyerMode,
            enabled: canKey,
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              key: const ValueKey('qso-typed-mode'),
              onPressed: canKey ? _toggleTyping : null,
              icon: Icon(_typing ? Icons.touch_app : Icons.keyboard),
              label: Text(
                _typing ? s.qsoAdvancedKeyedMode : s.qsoAdvancedTypedMode,
              ),
            ),
            OutlinedButton(
              onPressed: canKey ? () => _request('PSE AGN') : null,
              child: Text(s.learnQsoPlayAgain),
            ),
            OutlinedButton(
              onPressed: canKey ? () => _request('QRS') : null,
              child: Text(s.learnQsoSlower),
            ),
            OutlinedButton.icon(
              onPressed: _showHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(s.learnQsoHint),
            ),
          ],
        ),
        if (_session.availableRepeatFields.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(s.qsoAdvancedRepeatTitle, style: theme.textTheme.labelLarge),
          Text(s.qsoAdvancedRepeatHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final field in _session.availableRepeatFields)
                OutlinedButton(
                  key: ValueKey('qso-repeat-${field.keyword}'),
                  onPressed: canKey
                      ? () => _request('${field.keyword}?')
                      : null,
                  child: Text('${field.keyword}?'),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: _pendingText.trim().isNotEmpty || _keying.hasInput
                    ? _clear
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(s.learnQsoClear),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('qso-send'),
                onPressed:
                    canKey &&
                        (_typing
                            ? _typedText.text.trim().isNotEmpty
                            : (_keying.hasInput || _carry.isNotEmpty))
                    ? _send
                    : null,
                icon: const Icon(Icons.send),
                label: Text(s.learnQsoSend),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
