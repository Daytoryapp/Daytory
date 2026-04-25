import 'package:date_app/src/models/date_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.log, super.key});

  final DateLog log;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("데이트 상세")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(log.title ?? log.placeName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(DateFormat("yyyy.MM.dd HH:mm").format(log.startedAt)),
          const SizedBox(height: 12),
          _InfoTile(label: "장소", value: log.placeName),
          _InfoTile(label: "비용", value: "${log.totalCost.toInt()}원"),
          _InfoTile(label: "감정", value: "${log.moodScore}점"),
          _InfoTile(label: "메모", value: log.memo),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: log.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "지도 미니뷰 좌표: ${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)}",
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
