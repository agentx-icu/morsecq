import 'package:morse_trainer/morse_trainer.dart';

import 'training_controller.dart';

/// The learner's material library (functional spec §9), one document under
/// the profile's training directory, so local learning exports include it.
extension MaterialStore on TrainingController {
  static const String doc = 'materials';

  Future<List<TrainingMaterial>> loadMaterials() async {
    final json = await readDoc(doc);
    final list = json?['materials'];
    if (list is! List) return <TrainingMaterial>[];
    final out = <TrainingMaterial>[];
    for (final m in list) {
      // A single bad entry must not hide the rest of the library.
      try {
        out.add(TrainingMaterial.fromJson(m as Map<String, Object?>));
      } on Object {
        continue;
      }
    }
    return out;
  }

  Future<void> saveMaterials(List<TrainingMaterial> materials) =>
      writeDoc(doc, <String, Object?>{
        'v': 1,
        'materials': [for (final m in materials) m.toJson()],
      });

  Future<void> upsertMaterial(TrainingMaterial material) =>
      docTransaction(() async {
        final all = await loadMaterials();
        final at = all.indexWhere((m) => m.id == material.id);
        if (at < 0) {
          all.add(material);
        } else {
          all[at] = material;
        }
        await saveMaterials(all);
      });

  Future<void> deleteMaterial(String id) => docTransaction(() async {
    final all = await loadMaterials();
    await saveMaterials(all.where((m) => m.id != id).toList());
  });

  /// Applies [update] to the whole library atomically (imports, merges).
  Future<void> updateMaterials(
    List<TrainingMaterial> Function(List<TrainingMaterial> all) update,
  ) => docTransaction(() async {
    await saveMaterials(update(await loadMaterials()));
  });

  /// A new random material id.
  String newMaterialId() =>
      'm_${now().microsecondsSinceEpoch.toRadixString(36)}_'
      '${random.nextInt(1 << 30).toRadixString(36)}';
}
