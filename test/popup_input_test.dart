// Test untuk fitur TAMBAHAN di main.dart:
// popup di sudut kanan atas untuk input Nama, NPM, Jurusan, Foto Profile,
// dan tombol Save.
//
// Jalankan dengan:  flutter test test/popup_input_test.dart
//
// Test ini memakai image_picker palsu supaya tidak membuka galeri sungguhan.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first_app/main.dart';

/// Pengganti image_picker: selalu mengembalikan satu file gambar.
class FakeImagePickerPlatform extends ImagePickerPlatform {
  FakeImagePickerPlatform(this.filePath);

  final String filePath;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      XFile(filePath);

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async =>
      PickedFile(filePath);
}

void main() {
  late Directory tempDir;
  late String fotoPath;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    // Buat file gambar PNG 1x1 yang benar-benar valid.
    tempDir = await Directory.systemTemp.createTemp('foto_uji_popup');
    final file = File('${tempDir.path}/foto.png');
    await file.writeAsBytes(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
    ));
    fotoPath = file.path;

    ImagePickerPlatform.instance = FakeImagePickerPlatform(fotoPath);
  });

  tearDown(() async {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('tombol kecil di sudut membuka popup input data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tombol popup ada di halaman utama
    expect(find.text('Input Data'), findsOneWidget);

    await tester.tap(find.text('Input Data'));
    await tester.pumpAndSettle();

    // Isi popup: judul + 4 input + tombol Save
    // (dicari di dalam AlertDialog saja, karena halaman di belakangnya
    //  juga punya tulisan 'NPM')
    final dialog = find.byType(AlertDialog);
    expect(find.text('Input Data Mahasiswa'), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('Nama')),
        findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('NPM')),
        findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('Jurusan')),
        findsOneWidget);
    expect(find.text('Ketuk foto untuk pilih gambar'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
  });

  testWidgets('Save menolak data yang masih kosong',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Input Data'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    expect(find.text('NPM tidak boleh kosong'), findsOneWidget);
    expect(find.text('Jurusan tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('Save menyimpan nama, npm, jurusan, dan foto',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Input Data'));
    await tester.pumpAndSettle();

    // Isi form
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jifran Al Shiraf');
    await tester.enterText(fields.at(1), '2408007010046');
    await tester.enterText(fields.at(2), 'D3 Manajemen Informatika');
    await tester.pumpAndSettle();

    // Pilih foto profile (galeri)
    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih dari Galeri'));
    await tester.pumpAndSettle();

    // Tekan Save
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    // Data tersimpan di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('nama'), 'Jifran Al Shiraf');
    expect(prefs.getString('npm'), '2408007010046');
    expect(prefs.getString('jurusan'), 'D3 Manajemen Informatika');
    expect(prefs.getString('foto'), fotoPath);

    // Kartu data tersimpan muncul di dalam popup
    expect(find.text('NPM: 2408007010046'), findsOneWidget);
    expect(find.text('Jurusan: D3 Manajemen Informatika'), findsOneWidget);
  });
}
