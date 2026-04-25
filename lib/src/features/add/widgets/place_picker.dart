import 'package:date_app/src/core/constants/app_constants.dart';
import 'package:date_app/src/core/constants/place_constants.dart';
import 'package:date_app/src/models/date_place.dart';
import 'package:flutter/material.dart';

class PlacePicker extends StatefulWidget {
  const PlacePicker({super.key, required this.onSelected, this.initial});
  final ValueChanged<DatePlace> onSelected;
  final DatePlace? initial;

  static Future<DatePlace?> show(BuildContext context, {DatePlace? initial}) {
    return showModalBottomSheet<DatePlace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (context, scrollController) => _PlacePickerContent(
          scrollController: scrollController,
          initial: initial,
        ),
      ),
    );
  }

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PlacePickerContent extends StatefulWidget {
  const _PlacePickerContent({required this.scrollController, this.initial});
  final ScrollController scrollController;
  final DatePlace? initial;

  @override
  State<_PlacePickerContent> createState() => _PlacePickerContentState();
}

class _PlacePickerContentState extends State<_PlacePickerContent> {
  SidoInfo? _selectedSido;
  SigunguInfo? _selectedSigungu;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _selectedSido = PlaceConstants.regions
          .where((s) => s.name == widget.initial!.sido)
          .firstOrNull;
      if (_selectedSido != null) {
        _selectedSigungu = _selectedSido!.sigungus
            .where((sg) => sg.name == widget.initial!.sigungu)
            .firstOrNull;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppConstants.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('장소 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
                  const Spacer(),
                  if (_selectedSido != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedSido = null;
                        _selectedSigungu = null;
                      }),
                      child: const Text('다시 선택'),
                    ),
                ],
              ),
              if (_selectedSido != null) ...[
                const SizedBox(height: 8),
                _Breadcrumb(sido: _selectedSido!.name, sigungu: _selectedSigungu?.name),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Expanded(
          child: _selectedSido == null
              ? _SidoList(
                  scrollController: widget.scrollController,
                  onSelected: (sido) => setState(() => _selectedSido = sido),
                )
              : _SigunguList(
                  scrollController: widget.scrollController,
                  sido: _selectedSido!,
                  onSelected: (sigungu) {
                    Navigator.of(context).pop(
                      PlaceConstants.toDatePlace(_selectedSido!.name, sigungu),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.sido, this.sigungu});
  final String sido;
  final String? sigungu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: sido),
        if (sigungu != null) ...[
          const Icon(Icons.chevron_right, size: 16, color: AppConstants.textSecondary),
          _Chip(label: sigungu!),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.pinkLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppConstants.pink, fontWeight: FontWeight.w600)),
    );
  }
}

class _SidoList extends StatelessWidget {
  const _SidoList({required this.scrollController, required this.onSelected});
  final ScrollController scrollController;
  final ValueChanged<SidoInfo> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: PlaceConstants.regions.length,
      itemBuilder: (context, index) {
        final sido = PlaceConstants.regions[index];
        return ListTile(
          title: Text(sido.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConstants.textPrimary)),
          subtitle: Text('${sido.sigungus.length}개 지역', style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary)),
          trailing: const Icon(Icons.chevron_right, color: AppConstants.textSecondary, size: 18),
          onTap: () => onSelected(sido),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        );
      },
    );
  }
}

class _SigunguList extends StatelessWidget {
  const _SigunguList({required this.scrollController, required this.sido, required this.onSelected});
  final ScrollController scrollController;
  final SidoInfo sido;
  final ValueChanged<SigunguInfo> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: sido.sigungus.length,
      itemBuilder: (context, index) {
        final sigungu = sido.sigungus[index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined, color: AppConstants.pink, size: 20),
          title: Text(sigungu.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConstants.textPrimary)),
          onTap: () => onSelected(sigungu),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        );
      },
    );
  }
}
