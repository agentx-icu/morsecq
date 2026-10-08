import 'dart:math';

import 'callsign_drill.dart';
import 'drill.dart';
import 'morse_text.dart';
import 'word_lists.dart';

/// Templated QSO exchanges.
///
/// Templates use `{CALL1}`, `{CALL2}`, `{NAME1}`, `{NAME2}`, `{QTH1}`,
/// `{QTH2}`, `{RST}`, `{RIG}` and `{ANT}` placeholders. One generation
/// resolves every placeholder it meets once, so a full QSO stays consistent.
///
/// With [allowedChars] the drill stays inside the learner's symbol set: a
/// template is *feasible* when its fixed text uses only allowed symbols
/// (prosigns such as `<BT>` count as one symbol) and every slot it uses can
/// be filled from the allowed set — callsigns through a restricted
/// [CallsignDrill], names, QTHs, reports, rigs and antennas from their word
/// lists filtered the same way. Only feasible templates are drawn and only
/// their slots are resolved, so a short phrase stays feasible even while the
/// rig list is still empty. Without [allowedChars] every template is
/// feasible and the drill behaves as it always did.
final class QsoDrill implements DrillGenerator {
  QsoDrill({
    this.full = false,
    CallsignDrill? callsigns,
    List<String> templates = defaultTemplates,
    Set<String>? allowedChars,
  }) : assert(templates.isNotEmpty, 'templates must not be empty'),
       callsigns =
           callsigns ?? CallsignDrill(count: 1, allowedChars: allowedChars),
       templates = List<String>.unmodifiable(templates),
       allowedChars = allowedChars == null
           ? null
           : Set<String>.unmodifiable(
               allowedChars.map(MorseText.normalizeChar),
             ) {
    _pools = <String, List<String>>{
      '{NAME1}': _filter(WordLists.operatorNames),
      '{NAME2}': _filter(WordLists.operatorNames),
      '{QTH1}': _filter(WordLists.qthNames),
      '{QTH2}': _filter(WordLists.qthNames),
      '{RST}': _filter(WordLists.rstReports),
      '{RIG}': _filter(WordLists.rigNames),
      '{ANT}': _filter(WordLists.antennaNames),
    };
    feasibleTemplates = List<String>.unmodifiable(
      this.templates.where(isFeasible),
    );
  }

  /// A drill that grows with the learner: the short [phraseTemplates] plus
  /// the full-script lines while not every line is feasible yet, the lines
  /// alone once they all are.
  factory QsoDrill.progressive({
    required Set<String> allowedChars,
    CallsignDrill? callsigns,
  }) {
    final lines = QsoDrill(allowedChars: allowedChars, callsigns: callsigns);
    if (lines.isComplete) return lines;
    return QsoDrill(
      allowedChars: allowedChars,
      callsigns: callsigns,
      templates: <String>[...phraseTemplates, ...defaultTemplates],
    );
  }

  /// A complete QSO script, in order. Prosigns use the `<XX>` form so
  /// `MorseText` scores them as one symbol.
  static const List<String> defaultTemplates = <String>[
    'CQ CQ CQ DE {CALL1} {CALL1} {CALL1} K',
    '{CALL1} DE {CALL2} {CALL2} KN',
    '{CALL2} DE {CALL1} GM OM TNX FER CALL UR RST {RST} {RST} <BT> '
        'NAME IS {NAME1} {NAME1} <BT> QTH {QTH1} {QTH1} HW? {CALL2} DE {CALL1} KN',
    '{CALL1} DE {CALL2} R R FB {NAME1} TNX FER RPRT UR RST {RST} {RST} ES '
        'NAME HR IS {NAME2} {NAME2} <BT> QTH {QTH2} {QTH2} <BT> RIG IS {RIG} '
        'ES ANT IS {ANT} HW? {CALL1} DE {CALL2} K',
    '{CALL2} DE {CALL1} R FB {NAME2} TNX FER QSO ES INFO 73 ES CUL '
        '{CALL2} DE {CALL1} <SK>',
    '{CALL1} DE {CALL2} TU 73 {NAME1} CUL <SK> EE',
  ];

  /// Short phrases a learner meets long before a whole script is feasible:
  /// a call, a report, a name, a location, a sign-off.
  static const List<String> phraseTemplates = <String>[
    'CQ CQ CQ DE {CALL1} K',
    '{CALL1} DE {CALL2} K',
    'UR RST {RST} {RST}',
    'NAME IS {NAME1}',
    'QTH {QTH1}',
    'R R FB TNX {NAME1}',
    'TNX FER QSO 73 <SK>',
  ];

  static final RegExp _slot = RegExp(r'\{[A-Z0-9]+\}');

  /// When true every template is emitted in order as one long drill; when
  /// false a single random feasible template is used.
  final bool full;

  final CallsignDrill callsigns;
  final List<String> templates;

  /// Symbol set the drill was restricted to (null = unrestricted).
  final Set<String>? allowedChars;

  late final Map<String, List<String>> _pools;

  /// Templates whose fixed text and slots fit [allowedChars], in order.
  late final List<String> feasibleTemplates;

  @override
  String get kind => 'qso';

  /// Every template is feasible (so the full script can be played).
  bool get isComplete => feasibleTemplates.length == templates.length;

  /// False when no template (or, for [full], not every template) fits.
  bool get canGenerate => full ? isComplete : feasibleTemplates.isNotEmpty;

  /// Whether [template]'s fixed symbols are allowed and each of its slots
  /// has at least one candidate.
  bool isFeasible(String template) {
    final allowed = allowedChars;
    if (allowed != null &&
        !MorseText.usesOnly(template.replaceAll(_slot, ' '), allowed)) {
      return false;
    }
    for (final match in _slot.allMatches(template)) {
      final slot = match[0]!;
      final usable = slot == '{CALL1}' || slot == '{CALL2}'
          ? callsigns.canGenerate
          : (_pools[slot]?.isNotEmpty ?? false);
      if (!usable) return false;
    }
    return true;
  }

  @override
  Drill generate(Random random) {
    if (!canGenerate) {
      throw StateError('QsoDrill has no feasible template for the allowed set');
    }
    final chosen = full
        ? templates
        : <String>[feasibleTemplates[random.nextInt(feasibleTemplates.length)]];
    // Each slot is resolved once, in order of first appearance, and only
    // when a chosen template uses it.
    final values = <String, String>{};
    String resolve(Match m) =>
        values.putIfAbsent(m[0]!, () => _resolve(m[0]!, random));
    final text = chosen
        .map((t) => t.replaceAllMapped(_slot, resolve))
        .join(' ');
    return Drill.fromText(text, kind: kind);
  }

  String _resolve(String slot, Random random) {
    if (slot == '{CALL1}' || slot == '{CALL2}') {
      return callsigns.nextCallsign(random);
    }
    final pool = _pools[slot];
    if (pool == null) {
      throw ArgumentError.value(slot, 'slot', 'unknown placeholder');
    }
    return pool[random.nextInt(pool.length)];
  }

  List<String> _filter(List<String> options) {
    final allowed = allowedChars;
    if (allowed == null) return options;
    return List<String>.unmodifiable(
      options.where((o) => MorseText.usesOnly(o, allowed)),
    );
  }
}
