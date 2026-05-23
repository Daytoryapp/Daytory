import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef PhotosChanged = void Function(List<String> keptUrls, List<XFile> newFiles);

class ImagePickerRow extends StatefulWidget {
  const ImagePickerRow({
    super.key,
    required this.onChanged,
    this.maxImages = 5,
    this.initialUrls = const [],
  });
  final PhotosChanged onChanged;
  final int maxImages;
  final List<String> initialUrls;

  @override
  State<ImagePickerRow> createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  // Items are either String (existing URL) or XFile (new)
  late List<Object> _items;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _items = List<Object>.from(widget.initialUrls);
  }

  int get _total => _items.length;

  void _notify() {
    widget.onChanged(
      _items.whereType<String>().toList(),
      _items.whereType<XFile>().toList(),
    );
  }

  Future<void> _pick() async {
    final remaining = widget.maxImages - _total;
    if (remaining <= 0) return;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() => _items.addAll(picked));
    _notify();
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
    _notify();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          if (_total < widget.maxImages)
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
                      '$_total/${widget.maxImages}',
                      style: const TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          if (_items.isNotEmpty)
            Expanded(
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: _onReorder,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    ReorderableDragStartListener(
                      key: ValueKey(i),
                      index: i,
                      child: _ItemThumb(
                        item: _items[i],
                        onRemove: () => _remove(i),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemThumb extends StatefulWidget {
  const _ItemThumb({required this.item, required this.onRemove});
  final Object item;
  final VoidCallback onRemove;

  @override
  State<_ItemThumb> createState() => _ItemThumbState();
}

class _ItemThumbState extends State<_ItemThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is XFile && !kIsWeb) {
      item.readAsBytes().then((b) {
        if (mounted) setState(() => _bytes = b);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    Widget imageWidget;

    if (item is String) {
      imageWidget = CachedNetworkImage(
        imageUrl: item,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    } else if (item is XFile) {
      if (_bytes != null) {
        imageWidget = Image.memory(_bytes!, width: 80, height: 80, fit: BoxFit.cover);
      } else if (!kIsWeb) {
        imageWidget = Image.file(File(item.path), width: 80, height: 80, fit: BoxFit.cover);
      } else {
        imageWidget = const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
    } else {
      imageWidget = const SizedBox();
    }

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
            child: imageWidget,
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
