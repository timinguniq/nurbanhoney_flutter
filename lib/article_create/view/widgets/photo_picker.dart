import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// 갤러리에서 사진 한 장을 골라 긴 변 500px·품질 75 로 압축한 파일을 돌려준다. 고르지 않으면 null.
/// 압축 결과가 원본보다 크면 원본을 쓴다(기존 로직 그대로).
Future<File?> pickAndCompressImage() async {
  final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (photo == null) return null;
  final original = File(photo.path);
  log('originalFile: ${original.path} (${await original.length()} bytes)');
  final compressed = await _compress(original);
  log('compressedFile: ${compressed.path} (${await compressed.length()} bytes)');
  return compressed;
}

const _maxDimension = 500;

Future<File> _compress(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final originalWidth = frame.image.width;
  final originalHeight = frame.image.height;
  frame.image.dispose();
  codec.dispose();

  var targetWidth = originalWidth;
  var targetHeight = originalHeight;
  if (originalWidth > _maxDimension || originalHeight > _maxDimension) {
    if (originalWidth >= originalHeight) {
      targetWidth = _maxDimension;
      targetHeight = (originalHeight * _maxDimension / originalWidth).round();
    } else {
      targetHeight = _maxDimension;
      targetWidth = (originalWidth * _maxDimension / originalHeight).round();
    }
  }

  final targetPath = '${file.parent.path}/compressed_${const Uuid().v4()}.jpg';
  final compressed = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 75,
    minWidth: targetWidth,
    minHeight: targetHeight,
    format: CompressFormat.jpeg,
  );
  if (compressed == null) return file;

  final compressedFile = File(compressed.path);
  return await compressedFile.length() < await file.length() ? compressedFile : file;
}
