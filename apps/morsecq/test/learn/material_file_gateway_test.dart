import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/ui/learn/materials/material_file_gateway.dart';
import 'package:share_plus/share_plus.dart' show XFile;

/// The platform save dialog and picker, recorded.
final class _FakePicker extends FilePickerPlatform {
  Uri? saveResult;
  PlatformFile? pickResult;
  final saved = <({String fileName, String mimeType, Uint8List bytes})>[];

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    saved.add((fileName: fileName, mimeType: mimeType, bytes: bytes));
    return saveResult;
  }

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => pickResult;
}

/// A picked file that may not know its length and counts its reads.
final class _FakeFile extends PlatformFile {
  _FakeFile(this.name, this.bytes, {this.knownLength = true});

  @override
  final String name;
  final Uint8List bytes;
  final bool knownLength;
  int reads = 0;

  @override
  Uri get uri => Uri.file('/picked/$name');

  @override
  XFile get xFile => XFile.fromData(bytes, name: name);

  @override
  int? lengthSync() => knownLength ? bytes.length : null;

  @override
  Future<int?> length() async => lengthSync();

  @override
  Future<Uint8List> readAsBytes() async {
    reads++;
    return bytes;
  }

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const gateway = PlatformMaterialFileGateway();
  const share = MethodChannel('dev.fluttercommunity.plus/share');
  final bytes = Uint8List.fromList('CQ CQ DE MORSECQ'.codeUnits);
  late FilePickerPlatform original;
  late _FakePicker picker;

  setUp(() {
    original = FilePickerPlatform.instance;
    picker = _FakePicker();
    FilePickerPlatform.instance = picker;
  });
  tearDown(() {
    FilePickerPlatform.instance = original;
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(share, null);
  });

  test('an empty export is refused before any dialog', () async {
    await expectLater(
      gateway.save(Uint8List(0), fileName: 'a.txt', mimeType: 'text/plain'),
      throwsA(isA<FileSystemException>()),
    );
    expect(picker.saved, isEmpty);
  });

  group('desktop save dialog', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.macOS);

    test('hands over name, type and bytes; a chosen place is a save', () async {
      picker.saveResult = Uri.file('/tmp/a.txt');
      final saved = await gateway.save(
        bytes,
        fileName: 'a.txt',
        mimeType: 'text/plain',
      );
      expect(saved, isTrue);
      expect(picker.saved.single.fileName, 'a.txt');
      expect(picker.saved.single.mimeType, 'text/plain');
      expect(picker.saved.single.bytes, bytes);
    });

    test('a cancelled dialog is not a save', () async {
      final saved = await gateway.save(
        bytes,
        fileName: 'a.txt',
        mimeType: 'text/plain',
      );
      expect(saved, isFalse);
    });
  });

  group('mobile share sheet', () {
    late List<Map<Object?, Object?>> calls;
    late String reply;
    late List<Uint8List?> contentDuringShare;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      calls = [];
      contentDuringShare = [];
      reply = 'com.apple.UIKit.activity.SaveToFiles';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(share, (call) async {
            final args = call.arguments as Map<Object?, Object?>;
            calls.add(args);
            final path = (args['paths']! as List).single as String;
            final file = File(path);
            contentDuringShare.add(
              file.existsSync() ? file.readAsBytesSync() : null,
            );
            return reply;
          });
    });

    test('shares a temporary copy and removes it afterwards', () async {
      final shared = await gateway.save(
        bytes,
        fileName: 'qso.json',
        mimeType: 'application/json',
      );
      expect(shared, isTrue);
      expect(picker.saved, isEmpty, reason: 'no desktop dialog on mobile');
      final path = (calls.single['paths']! as List).single as String;
      expect(path, endsWith('qso.json'));
      expect(calls.single['mimeTypes'], ['application/json']);
      expect(contentDuringShare.single, bytes);
      expect(File(path).parent.existsSync(), isFalse);
    });

    test('a dismissed sheet is not a save and still cleans up', () async {
      reply = '';
      final shared = await gateway.save(
        bytes,
        fileName: 'a.txt',
        mimeType: 'text/plain',
      );
      expect(shared, isFalse);
      final path = (calls.single['paths']! as List).single as String;
      expect(File(path).parent.existsSync(), isFalse);
    });

    test('a failing share still removes the temporary copy', () async {
      String? path;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(share, (call) async {
            final args = call.arguments as Map<Object?, Object?>;
            path = (args['paths']! as List).single as String;
            throw PlatformException(code: 'share-failed');
          });
      await expectLater(
        gateway.save(bytes, fileName: 'a.txt', mimeType: 'text/plain'),
        throwsA(isA<PlatformException>()),
      );
      expect(path, isNotNull);
      expect(File(path!).parent.existsSync(), isFalse);
    });
  });

  group('pick', () {
    test('a cancelled picker returns nothing', () async {
      expect(await gateway.pick(maxBytes: 100), isNull);
    });

    test('returns the name and content within the limit', () async {
      picker.pickResult = _FakeFile('lesson.txt', bytes);
      final picked = await gateway.pick(maxBytes: bytes.length);
      expect(picked!.name, 'lesson.txt');
      expect(picked.bytes, bytes);
    });

    test('a known oversized length is refused without reading', () async {
      final file = _FakeFile('big.wav', bytes);
      picker.pickResult = file;
      await expectLater(
        gateway.pick(maxBytes: bytes.length - 1),
        throwsA(isA<PickedFileTooLarge>().having((e) => e.bytes, 'bytes', 16)),
      );
      expect(file.reads, 0);
    });

    test('an unknown length is checked after reading', () async {
      final file = _FakeFile('big.wav', bytes, knownLength: false);
      picker.pickResult = file;
      await expectLater(
        gateway.pick(maxBytes: bytes.length - 1),
        throwsA(isA<PickedFileTooLarge>()),
      );
      expect(file.reads, 1);
    });
  });
}
