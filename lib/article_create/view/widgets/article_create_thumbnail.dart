import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:uuid/uuid.dart';

// Consumer widget format
class ArticleCreateThumbnail extends StatelessWidget {
  const ArticleCreateThumbnail({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateThumbnail(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final board = ref.watch(articleCreateBoardNavigationProvider);
      final lossCutTextStyle = ref.read(articleCreateLossCutStyle);
      final thumbnail = ref.watch(articleCreateThumbnailNavigationProvider);
      final buttonBackgroundColor = ref.read(colorF6B748);

      final nurbanRepository = ref.read(nurbanRepositoryProvider);
      final freeRepository = ref.read(freeRepositoryProvider);

      log('thumbnail: ArticleCreateThumbnail $thumbnail');

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      final token = storage?.getToken() ?? '__empty__';
      log('article create thumbnail token: $token');

      final btnVisible = thumbnail == '';
      final imageVisible = thumbnail != '';
      log('btnVisible: $btnVisible, imageVisible: $imageVisible');
      // TODO: UI를 Visibiltiy로 감싸고 버튼으로 만들고 이미지 url이 ''이 아니면 이미지 나오게
      return Column(
        children: [
          const SizedBox(
            height: 14,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Visibility(
                  visible: btnVisible,
                  child: SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            buttonBackgroundColor),
                      ),
                      onPressed: () async {
                        final xFileImage = await _getImage();
                        if (xFileImage == null) return;
                        final originalFile = convertToXFileToFile(xFileImage);
                        log('originalFile: ${originalFile.path} '
                            '(${await originalFile.length()} bytes)');
                        final fileImage = await _compressImage(originalFile);
                        log('fileImage: ${fileImage.path} '
                            '(${await fileImage.length()} bytes)');
                        final uuid = const Uuid().v4();
                        log('upload uuid: $uuid');
                        String uploadImage = '';
                        if (board == '너반꿀') {
                          uploadImage =
                              await nurbanRepository.nurbanImageUpload(
                            uuid: uuid,
                            token: token,
                            image: fileImage,
                          );
                        } else if (board == '코인') {
                          uploadImage = await freeRepository.freeImageUpload(
                            uuid: uuid,
                            token: token,
                            image: fileImage,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: '위에 게시판을 선택해주세요!',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            //backgroundColor: ref.read(color000000),
                            //textColor: ref.read(colorFFFFFF),
                            fontSize: 16.0,
                          );
                        }

                        log('uploadImage: $uploadImage');
                        ref
                            .read(articleCreateUuidNavigationProvider.notifier)
                            .select(uuid);
                        ref
                            .read(articleCreateThumbnailNavigationProvider
                                .notifier)
                            .select(uploadImage);
                      },
                      child: const Text(
                        '이미지 선택',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: imageVisible,
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      );
    });
  }

  Future<XFile?> _getImage() async {
    final picker = ImagePicker();
    // Capture a photo.
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
    );

    return photo;
  }

  File convertToXFileToFile(XFile xFile) => File(xFile.path);

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final originalWidth = frame.image.width;
    final originalHeight = frame.image.height;
    frame.image.dispose();
    codec.dispose();

    const maxDimension = 500;
    int targetWidth = originalWidth;
    int targetHeight = originalHeight;

    if (originalWidth > maxDimension || originalHeight > maxDimension) {
      if (originalWidth >= originalHeight) {
        targetWidth = maxDimension;
        targetHeight = (originalHeight * maxDimension / originalWidth).round();
      } else {
        targetHeight = maxDimension;
        targetWidth = (originalWidth * maxDimension / originalHeight).round();
      }
    }

    final dir = file.parent.path;
    final name = const Uuid().v4();
    final targetPath = '$dir/compressed_$name.jpg';

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
    final originalSize = await file.length();
    final compressedSize = await compressedFile.length();

    return compressedSize < originalSize ? compressedFile : file;
  }
}
