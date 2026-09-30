/// Morse training pedagogy as pure Dart: Koch course, Farnsworth settings,
/// drill generators, alignment-based scoring, spaced repetition, send-practice
/// diagnostics and learner progress.
///
/// No Flutter imports. The app drives a session: pick a drill, play it via
/// morse_io, collect the answer, build a [SessionScore], fold it into
/// [TrainerProgress] and let [KochCourse] decide whether to unlock a lesson.
library;

export 'src/alignment.dart';
export 'src/callsign_drill.dart';
export 'src/char_stats.dart';
export 'src/char_weights.dart';
export 'src/confusion_matrix.dart';
export 'src/drill.dart';
export 'src/koch_course.dart';
export 'src/morse_text.dart';
export 'src/qso_drill.dart';
export 'src/random_groups_drill.dart';
export 'src/send_practice.dart';
export 'src/session_score.dart';
export 'src/session_summary.dart';
export 'src/srs_scheduler.dart';
export 'src/trainer_progress.dart';
export 'src/trainer_settings.dart';
export 'src/trainer_store.dart';
export 'src/word_drill.dart';
export 'src/word_lists.dart';
