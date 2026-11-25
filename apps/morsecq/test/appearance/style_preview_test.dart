import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_core/morse_core.dart';
import 'package:morse_trainer/morse_trainer.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/ui/appearance/style_preview.dart';
import 'package:morsecq/ui/appearance/ui_style.dart';

void main() {
  final course = KochCourse();
  for (final locale in [const Locale('en'), const Locale('zh')]) {
    for (final miniature in [false, true]) {
      testWidgets(
        'lesson preview matches the Koch course: $locale/$miniature',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              home: Scaffold(
                body: SizedBox(
                  width: miniature ? 180 : 296,
                  child: StylePreview(
                    style: UiStyle.white,
                    brightness: Brightness.light,
                    miniature: miniature,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final strings = lookupS(locale);
          expect(
            find.text(strings.learnLessonOf(4, course.lessonCount)),
            findsOneWidget,
          );
          expect(find.text(strings.learnContinueLesson), findsOneWidget);
          for (final char in course.charsForLesson(4)) {
            expect(find.text(char), findsOneWidget);
            expect(
              find.text(MorseEncoder.toPattern(char)),
              miniature ? findsNothing : findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
