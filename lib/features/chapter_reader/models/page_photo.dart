import 'package:photo_view/photo_view.dart';

class PagePhotoController {
  final PhotoViewController photoController;
  final PhotoViewScaleStateController scaleController;

  PagePhotoController({
    required this.photoController,
    required this.scaleController,
  });

  double get scale => photoController.scale ?? 1.0;

  void reset() {
    scaleController.scaleState = PhotoViewScaleState.initial;
    photoController.scale = 1.0;
  }

  void zoomIn() {
    final currentScale = photoController.scale ?? 1.0;
    photoController.scale = currentScale * 1.25;
  }

  void zoomOut() {
    final currentScale = photoController.scale ?? 1.0;
    photoController.scale = currentScale / 1.25;
  }

  void dispose() {
    photoController.dispose();
    scaleController.dispose();
  }
}
