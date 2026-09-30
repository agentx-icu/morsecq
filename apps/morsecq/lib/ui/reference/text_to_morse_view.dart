import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morse_core/morse_core.dart';
import 'package:provider/provider.dart';

import 'morse_pattern_text.dart';
import 'reference_playback_controller.dart';
import 'reference_strings.dart';

/// Text → Morse: the pattern updates as the user types, can be played with
/// the current mark highlighted, and copied to the clipboard.
class TextToMorseView extends StatefulWidget {
  const TextToMorseView({super.key, this.twoPane = false, this.initialText});

  final bool twoPane;
  final String? initialText;

  /// Playback id used with the shared [ReferencePlaybackController].
  static const String playId = 'translator:text';

  static const Key inputKey = Key('translator-text-input');
  static const Key playKey = Key('translator-text-play');
  static const Key copyKey = Key('translator-text-copy');

  @override
  State<TextToMorseView> createState() => _TextToMorseViewState();
}

class _TextToMorseViewState extends State<TextToMorseView> {
  static final RegExp _prosignToken = RegExp(r'<([^<>]+)>');

  late final TextEditingController _text =
      TextEditingController(text: widget.initialText ?? '');
  String _pattern = '';
  String _skipped = '';

  @override
  void initState() {
    super.initState();
    _recompute(_text.text);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) => setState(() => _recompute(value));

  void _recompute(String text) {
    _pattern = MorseEncoder.toPattern(text);
    _skipped = _unsupportedChars(text);
  }

  /// Distinct characters of [text] that have no Morse code, in order of first
  /// appearance. Valid `<AR>`-style prosigns are not reported.
  static String _unsupportedChars(String text) {
    final String stripped = text.replaceAllMapped(
      _prosignToken,
      (Match m) => MorseAlphabet.encodeProsign(m[1]!) == null ? m[0]! : ' ',
    );
    final Set<String> seen = <String>{};
    final StringBuffer out = StringBuffer();
    for (final int rune in stripped.runes) {
      final String ch = String.fromCharCode(rune);
      if (ch.trim().isEmpty || MorseAlphabet.encodeChar(ch) != null) continue;
      if (seen.add(ch)) out.write(ch);
    }
    return out.toString();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: displayMorsePattern(_pattern)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(ReferenceStrings.patternCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final ReferencePlaybackController controller =
        context.watch<ReferencePlaybackController>();
    final ThemeData theme = Theme.of(context);
    final bool playing = controller.isPlayingId(TextToMorseView.playId);
    final int? active = controller.activeMarkFor(TextToMorseView.playId);
    final bool hasPattern = _pattern.isNotEmpty;

    final Widget input = Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        key: TextToMorseView.inputKey,
        controller: _text,
        onChanged: _onChanged,
        minLines: widget.twoPane ? null : 3,
        maxLines: widget.twoPane ? null : 6,
        expands: widget.twoPane,
        textAlignVertical: TextAlignVertical.top,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: ReferenceStrings.textInputLabel,
          hintText: ReferenceStrings.textInputHint,
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
    );

    final Widget output = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  ReferenceStrings.patternOutputLabel,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                key: TextToMorseView.copyKey,
                tooltip: ReferenceStrings.copyPattern,
                icon: const Icon(Icons.copy),
                onPressed: hasPattern ? _copy : null,
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                key: TextToMorseView.playKey,
                onPressed: hasPattern
                    ? () => controller.toggle(TextToMorseView.playId, _text.text)
                    : null,
                icon: Icon(playing ? Icons.stop : Icons.play_arrow),
                label: Text(playing ? ReferenceStrings.stop : ReferenceStrings.play),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: MorsePatternText(
                hasPattern ? _pattern : ReferenceStrings.emptyOutput,
                activeMark: active,
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
          if (_skipped.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ReferenceStrings.skippedChars(_skipped),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.twoPane) {
      return Row(
        children: <Widget>[
          Expanded(child: input),
          const VerticalDivider(width: 1),
          Expanded(child: output),
        ],
      );
    }
    return Column(
      children: <Widget>[
        input,
        const Divider(height: 1),
        Expanded(child: output),
      ],
    );
  }
}
