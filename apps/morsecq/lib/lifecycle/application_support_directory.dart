import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String morseCqFlatpakId = 'io.github.agentx_icu.morsecq';

/// Keeps an existing Flatpak profile accessible after its GTK application ID
/// starts matching the exported desktop entry. path_provider derives its
/// Linux directory from that ID and may already have created the new leaf.
Future<Directory> getMorseCqApplicationSupportDirectory({
  Future<Directory> Function() platformDirectory =
      getApplicationSupportDirectory,
  Map<String, String>? environment,
}) async {
  final directory = await platformDirectory();
  if ((environment ?? Platform.environment)['FLATPAK_ID'] != morseCqFlatpakId ||
      p.basename(directory.path) != morseCqFlatpakId) {
    return directory;
  }

  final previous = Directory(
    p.join(directory.parent.path, 'icu.agentx.morsecq'),
  );
  return await previous.exists() ? previous : directory;
}
