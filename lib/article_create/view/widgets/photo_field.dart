import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 사진 항목. 없으면 점선 박스(96) '사진 1장 추가', 있으면 미리보기(160) + [바꾸기][삭제],
/// 올리는 중이면 미리보기 위에 반투명 막 + 스피너 + 진행 바(서버가 진행률을 주지 않아 불확정).
class PhotoField extends StatelessWidget {
  const PhotoField({
    required this.imageUrl,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
    this.error = false,
    super.key,
  });

  /// 업로드된 썸네일 URL. 비어 있으면 아직 사진이 없다.
  final String imageUrl;
  final bool uploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool error;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty && !uploading) {
      return DashedBox(
        height: NbkSize.photoDropZone + NbkSpacing.xxxl * 2,
        color: error ? NbkColors.danger : NbkColors.line,
        onTap: onPick,
        child: Container(
          decoration: BoxDecoration(
            color: error ? NbkColors.dangerTint : NbkColors.surface,
            borderRadius: BorderRadius.circular(NbkRadius.card),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_outlined, size: NbkSize.iconLg, color: NbkColors.text2),
              const SizedBox(height: NbkSpacing.sm),
              const Text(Strings.photoAdd, style: NbkTypography.labelStrong),
              const SizedBox(height: NbkSpacing.xs),
              Text(
                Strings.photoCompressNote,
                style: NbkTypography.caption.copyWith(color: NbkColors.text3),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(NbkRadius.thumbnail),
      child: SizedBox(
        height: NbkSize.photoPreview,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              NbkThumbnail(url: imageUrl, height: NbkSize.photoPreview)
            else
              const ThumbnailPlaceholder(height: NbkSize.photoPreview),
            if (uploading)
              Container(
                color: NbkColors.overlay,
                padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox.square(
                      dimension: NbkSize.iconLg,
                      child: CircularProgressIndicator(color: NbkColors.onDark, strokeWidth: NbkSpacing.xxs),
                    ),
                    const SizedBox(height: NbkSpacing.md),
                    Text(
                      Strings.photoUploading,
                      style: NbkTypography.labelStrong.copyWith(color: NbkColors.onDark),
                    ),
                    const SizedBox(height: NbkSpacing.sm),
                    const LinearProgressIndicator(minHeight: NbkSpacing.xs),
                  ],
                ),
              )
            else
              Positioned(
                top: NbkSpacing.md,
                right: NbkSpacing.md,
                child: Row(
                  children: [
                    _ActionTile(icon: Icons.refresh, tooltip: Strings.change, onTap: onPick),
                    const SizedBox(width: NbkSpacing.sm),
                    _ActionTile(
                      icon: Icons.close,
                      color: NbkColors.danger,
                      tooltip: Strings.delete,
                      onTap: onRemove,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 미리보기 위 흰 네모 아이콘 버튼(바꾸기·삭제)
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = NbkColors.text1,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NbkColors.bg,
      borderRadius: BorderRadius.circular(NbkRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NbkRadius.card),
        child: Tooltip(
          message: tooltip,
          child: SizedBox.square(
            dimension: NbkSize.tapMin,
            child: Icon(icon, size: NbkSize.icon, color: color),
          ),
        ),
      ),
    );
  }
}
