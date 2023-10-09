import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      final lossCutTextStyle = ref.read(articleCreateLossCutStyle);
      // TODO(Cross): 여기 해야됨.
      final thumbnail = ref.watch(articleCreateThumbnailNavigationProvider);
      final buttonBackgroundColor = ref.read(colorF6B748);

      final nurbanRepository = ref.read(nurbanRepositoryProvider);

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
                        final fileImage = convertToXFileToFile(xFileImage!);
                        log('fileImage: ${fileImage.path}');
                        final uuid = const Uuid().v4();
                        log('uuid: $uuid');
                        final uploadImage =
                            await nurbanRepository.nurbanImageUpload(
                          uuid: uuid,
                          token: token,
                          image: fileImage,
                        );

                        log('uploadImage: $uploadImage');
                        ref.read(articleCreateThumbnailNavigationProvider.notifier).select(uploadImage);
                      },
                      child: const Text('이미지 선택'),
                    ),
                  ),
                ),
                Visibility(
                  visible: imageVisible,
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
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
      imageQuality: 70,
    );

    return photo;
  }

  File convertToXFileToFile(XFile xFile) => File(xFile.path);
}
