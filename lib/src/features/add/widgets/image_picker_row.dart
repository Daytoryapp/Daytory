import 'dart:io';
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerRow extends StatefulWidget {
  const ImagePickerRow({super.key, required this.onChanged, this.maxImages = 5});
  final ValueChanged<List<XFile>> onChanged;
  final int maxImages;

  @override
  State<ImagePickerRow> createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  final List<XFile> _images = [];
  final _picker = ImagePicker();

  Future<void> _pick() async {
    final remaining = widget.maxImages - _images.length;
    if (remaining <= 0) return;

    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
    widget.onChanged(List.unmodifiable(_images));
  }

  void _remove(int index) {
    setState(() => _images.removeAt(index));
    widget.onChanged(List.unmodifiable(_images));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_images.length < widget.maxImages)
            GestureDetector(
              onTap: _pick,
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppConstants.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppConstants.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined, size: 24, color: AppConstants.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      '${_images.length}/${widget.maxImages}',
                      style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          for (var i = 0; i < _images.length; i++)
            _ImageThumb(
              xfile: _images[i],
              onRemove: () => _remove(i),
            ),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatefulWidget {
  const _ImageThumb({required this.xfile, required this.onRemove});
  final XFile xfile;
  final VoidCallback onRemove;

  @override
  State<_ImageThumb> createState() => _ImageThumbState();
}

class _ImageThumbState extends State<_ImageThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    widget.xfile.readAsBytes().then((b) {
      if (mounted) setState(() => _bytes = b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        color: AppConstants.surface,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: _bytes != null
                ? Image.memory(_bytes!, width: 80, height: 80, fit: BoxFit.cover)
                : (!kIsWeb
                    ? Image.file(File(widget.xfile.path), width: 80, height: 80, fit: BoxFit.cover)
                    : const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
