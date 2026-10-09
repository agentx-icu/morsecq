import 'dart:math';

import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';

import 'receive_session.dart';
import 'training_controller.dart';

/// Replays the saved exercise, with its original timing and radio seed.
extension MistakePractice on TrainingController {
  ReceiveSession startMistakeSession(MistakeEntry entry) {
    if (entry.listeningContext != null) {
      throw ArgumentError('semantic mistakes require an information retry');
    }
    final symbols = MorseText.charSet(entry.target);
    return ReceiveSession(
      kind: ReceiveDrillKind.parse(entry.drillKind),
      generator: _MistakeDrill(entry.target, entry.drillKind),
      // A full keypad avoids revealing the answer through a tiny answer set.
      chars: [
        ...course.order,
        ...(symbols.difference(course.order.toSet()).toList()..sort()),
      ],
      timing: MorseTiming(
        wpm: entry.characterWpm,
        farnsworthWpm: entry.effectiveWpm < entry.characterWpm
            ? entry.effectiveWpm
            : null,
      ),
      charBudget: MorseText.symbols(entry.target).length,
      source: entry.conditions == null
          ? ExerciseSource.review
          : ExerciseSource.conditions,
      sourceRef: 'mistake:${entry.id}',
      learnedChars: learnedChars.toSet(),
      conditions: entry.conditions,
      random: random,
      now: now,
    );
  }
}

final class _MistakeDrill implements DrillGenerator {
  const _MistakeDrill(this.text, this.kind);
  final String text;
  @override
  final String kind;

  @override
  Drill generate(Random random) => Drill.fromText(text, kind: kind);
}
