import 'package:flutter/material.dart';
import 'package:morse_trainer/morse_trainer.dart';

import '../../../i18n/l10n_extension.dart';

/// Localised titles, reasons and icons for daily-plan steps. The plan
/// carries reason codes only; prose lives in the ARBs.
abstract final class PlanLabels {
  static String title(S s, PlanStep step) => switch (step.kind) {
    PlanStepKind.review => s.learnPlanStepReview,
    PlanStepKind.focus => s.learnPlanStepFocus,
    PlanStepKind.course => s.learnPlanStepCourse(step.lesson),
    PlanStepKind.send => s.learnPlanStepSend,
    PlanStepKind.intro => s.learnPlanStepIntro,
    PlanStepKind.recognition => s.learnPlanStepRecognition,
    PlanStepKind.comprehension => s.comprehensionTitle,
    PlanStepKind.qso => s.goalsQso,
  };

  static IconData icon(PlanStepKind kind) => switch (kind) {
    PlanStepKind.review => Icons.replay,
    PlanStepKind.focus => Icons.center_focus_strong_outlined,
    PlanStepKind.course => Icons.school_outlined,
    PlanStepKind.send => Icons.touch_app_outlined,
    PlanStepKind.intro => Icons.flag_outlined,
    PlanStepKind.recognition => Icons.hearing,
    PlanStepKind.comprehension => Icons.hearing_outlined,
    PlanStepKind.qso => Icons.cell_tower_outlined,
  };

  static String reason(S s, PlanStep step) {
    final symbols = step.pool.take(6).join(' ');
    return switch (step.reason) {
      PlanReason.dueReview => s.learnPlanReasonDueReview(symbols),
      PlanReason.confusions => s.learnPlanReasonConfusions(symbols),
      PlanReason.weakSymbols => s.learnPlanReasonWeak(symbols),
      PlanReason.courseChallenge => s.learnPlanReasonChallenge(step.charBudget),
      PlanReason.courseExtended => s.learnPlanReasonExtended(step.charBudget),
      PlanReason.courseConsolidate => s.learnPlanReasonConsolidate,
      PlanReason.courseOutdated => s.learnPlanReasonOutdated(step.lesson),
      PlanReason.sendRhythm => s.learnPlanReasonSend(step.charBudget),
      PlanReason.firstLesson => s.learnPlanReasonFirstLesson,
      PlanReason.recognition => s.learnPlanReasonRecognition(symbols),
      PlanReason.courseGuided => s.learnPlanReasonGuided(step.charBudget),
      PlanReason.sendOptional => s.learnPlanReasonSendOptional(step.charBudget),
      PlanReason.goalListening => s.goalsPlanListening,
      PlanReason.goalExchange => s.goalsPlanExchange,
    };
  }
}
