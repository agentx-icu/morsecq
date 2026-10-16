[English](./README.md)

# morse_trainer

MorseCQ 的训练教学法，**纯 Dart**（不引入 Flutter）：Koch 课程、Farnsworth 设置、练习生成器、
基于序列对齐的评分、间隔重复、发报练习诊断、学习进度、每日计划、模拟通联以及进阶学习（跨次错题本、听懂训练与目标路线）。它只依赖 `morse_core` 的类型
（`MorseTiming`、`MorseAlphabet.kochOrder`）；音频、触觉反馈与持久化属于 `morse_io` 和 App。

给定 `Random` 种子和注入的时钟（`DateTime now` 参数），一切都是确定性的，因此 App 及其测试可以
回放会话。

## 符号，而非码元（code unit）

训练器中的一个 "char" 是 `MorseText.tokenize` 产出的一个摩尔斯符号：一个字母、数字或标点，
**或者**一个带尖括号的规程符号如 `<BT>`，后者算作单个符号。所有接受或返回 char 的 API 都遵循
此约定，因此 `MorseAlphabet.kochOrder` 中的 `<BT>` 可以直接使用。

## 类图

| 关注点 | 类型 | 文件 |
| --- | --- | --- |
| Koch 课程 | `KochCourse`（各课字符集、解锁规则 `passes` / `evaluate` → `LessonVerdict`、`nextLesson`）、`LessonChallengeDrill`（覆盖本课新字符的挑战） | `src/koch_course.dart`、`src/lesson_challenge_drill.dart` |
| 设置 | `TrainerSettings`（字符/Farnsworth wpm、音调、会话长度、`toTiming()`、JSON） | `src/trainer_settings.dart` |
| 练习 | `Drill`、`DrillGenerator` | `src/drill.dart` |
| | `RandomGroupsDrill`（加权的 5 字符组） | `src/random_groups_drill.dart` |
| | `WordDrill`（+ `WordLists.commonWords`、`WordLists.cwAbbreviations`、`WordLists.qCodes`；`WordDrill.radioShorthand` 混合后两者） | `src/word_drill.dart`、`src/word_lists.dart` |
| | `NumberGroupsDrill`（取允许数字组成的数字组） | `src/number_groups_drill.dart` |
| | `ConfusableDrill`（成对对比：混淆矩阵中的易混对 + 码型只差一个点划的邻居） | `src/confusable_drill.dart` |
| | `CallsignDrill`（前缀 + 数字 + 后缀，可选符号过滤） | `src/callsign_drill.dart` |
| | `QsoDrill`（模板化通联，单行或完整 QSO） | `src/qso_drill.dart` |
| | `ContestExchangeDrill`（`呼号 599 序号`，可用缩略数字 `5NN TT7`） | `src/contest_drill.dart` |
| 评分 | `SessionScore`（Needleman-Wunsch 对齐、逐字符统计）、`ConfusionMatrix`、`CharStats`、`SequenceAligner` | `src/session_score.dart`、`src/confusion_matrix.dart`、`src/char_stats.dart`、`src/alignment.dart` |
| 权重 / SRS | `CharWeights`（`w = max(floor, 1 + k(1 - acc))` x 近期加成）、`SrsScheduler`（Leitner 盒 0..4，`dueChars(now)`） | `src/char_weights.dart`、`src/srs_scheduler.dart` |
| 发报练习 | `SendAttempt`、`SendDiagnostics`、`SendIssue`、`SendIssueKind`、`SendThresholds`；`SendTimeline`、`SymbolRhythm`（逐字符节奏详情） | `src/send_practice.dart`、`src/send_timeline.dart` |
| 记分与证据 | `ExerciseCredit`、`ExerciseSource`、`Assistance`（一次练习可以更新什么）、`RecentSymbolEvidence`、`LearnerStage`、`CharMastery`、`SpeedAdvice` | `src/exercise.dart`、`src/recent_practice.dart`、`src/learner_stage.dart`、`src/speed_recommendation.dart` |
| 水平测评 | `PlacementAssessment`、`PlacementResult` | `src/placement_assessment.dart` |
| 每日计划与目标 | `DailyPlan`、`PlanStep`、`PlanInputs`；`LearningGoal`、`LearningRoute`、`RouteMilestone`、`GoalEvidence` | `src/daily_plan.dart`、`src/daily_plan_builder.dart`、`src/learning_goal.dart`、`src/goal_plan_builder.dart` |
| 听懂与错题 | `ListeningExercise`、`ListeningQuestion`、`ListeningAttempt`、`ListeningScore`；`MistakeNotebook`、`MistakeEntry`、`MistakeAttempt`；`TrainerProgress` 上的 `ListeningProgress` | `src/listening_*.dart`、`src/mistake_*.dart`、`src/advanced_progress.dart` |
| 模拟通联 | `QsoSession`、`QsoScenario`、`QsoStage`、`QsoEvaluation`、`QsoReadiness`、`QsoProtocolAttempt` | `src/qso/`、`src/qso_protocol.dart` |
| 信道、素材、中文电码 | `RadioScenario`、`RadioPreset`；`TrainingMaterial`、`MaterialDrill`、`MaterialAnalysis`；`TelegraphDigitsDrill`、`TelegraphRecallCard` | `src/radio_conditions.dart`、`src/material/`、`src/telegraph_practice.dart` |
| 进度 | `TrainerProgress`、`SessionSummary`、`TrainerStore`、`InMemoryTrainerStore` | `src/trainer_progress.dart`、`src/session_summary.dart`、`src/trainer_store.dart` |
| 文本 | `MorseText`（上述所有组件共用的分词器） | `src/morse_text.dart` |

## App 预期的接线方式

```dart
final course = KochCourse();                     // MorseAlphabet.kochOrder
var progress = await store.load() ?? TrainerProgress();
final settings = TrainerSettings.fromJson(prefsJson);

// 1. Pick a drill for the current lesson, weighted towards weak/new symbols.
final chars = course.charsForLesson(progress.currentLesson);
final weights = CharWeights.fromStats(
  progress.charStats,
  recent: course.recentCharsForLesson(progress.currentLesson),
);
final generator = RandomGroupsDrill.forLength(
  chars: chars,
  totalChars: settings.sessionLengthChars,
  groupSize: settings.groupSize,
  weights: weights,
);
final drill = generator.generate(Random(seed));

// 2. Play it through morse_io at settings.toTiming() / settings.toneHz,
//    collect the trainee's typed copy.

// 3. Score, then fold into progress and let the course decide on unlocking.
final score = SessionScore.evaluate(
  drill.text,
  typedAnswer,
  at: clock.now(),
  elapsed: stopwatch.elapsed,
  lesson: progress.currentLesson,
  drillKind: drill.kind,
);
progress = progress
    .recordSession(score, now: clock.now())      // stats, streak, SRS, confusion
    .advanceIfPassed(course, score);            // see the unlock rule below
await store.save(progress);

// Optional: bias the next drill towards SRS-due symbols.
final due = progress.srs.dueOrNew(chars, clock.now());
```

解锁规则要求至少 50 个符号、严格准确率 90 %，并且本课新引入的每个符号至少尝试十次、准确率 90 %；
用 `LessonChallengeDrill` 保证练习覆盖这些符号。通过最后一课才设置 `courseCompleted`。App 中
`recordExercise(score, summary, credit:)` 按 summary ID 只记录一次练习，只有允许解锁的
`ExerciseCredit` 才会调用 `advanceIfPassed`；辅助练习和自由练习永远不会。

发报练习：把译码器的 mark/间隔以及点长估计喂给 `SendAttempt(...).evaluate()`，然后展示
`SendDiagnostics.issues`（每一项都有 `kind`、`severity` 和 `describe()` 字符串）以及 `measuredWpm`。

`TrainerStore` 是一个接口；由 App 提供文件 / 偏好设置实现。`InMemoryTrainerStore` 通过 JSON
往返序列化，因此测试走的是与真实存储相同的序列化路径。

## 开发

```bash
dart pub get --enforce-lockfile    # at the workspace root
dart analyze packages/morse_trainer
dart test packages/morse_trainer
```

每个文件都保持在 500 行以内（CI 门禁），并遵循工作区的 lint 规则集。
