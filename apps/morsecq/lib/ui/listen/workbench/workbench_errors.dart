import 'package:morse_dsp/morse_dsp.dart';

import '../../../i18n/l10n_extension.dart';
import 'workbench_controller.dart';

/// Localised reason an import or open failed.
String workbenchFailureText(S s, WorkbenchController? c) =>
    switch (c?.failure) {
      WorkbenchFailure.missingFile => s.workbenchErrorMissing,
      WorkbenchFailure.mismatch => s.workbenchRelinkMismatch,
      WorkbenchFailure.io || null => s.workbenchErrorIo,
      WorkbenchFailure.format => switch (c?.wavError) {
        WavError.notRiff || WavError.notWave => s.workbenchErrorNotWav,
        WavError.unsupportedFormat ||
        WavError.unsupportedBitDepth => s.workbenchErrorFormat,
        WavError.unsupportedChannels => s.workbenchErrorChannels,
        WavError.unsupportedRate => s.workbenchErrorRate,
        WavError.tooLarge => s.workbenchErrorTooLarge,
        WavError.tooLong => s.workbenchErrorTooLong,
        WavError.missingFmt ||
        WavError.missingData ||
        WavError.truncated ||
        null => s.workbenchErrorDamaged,
      },
    };
