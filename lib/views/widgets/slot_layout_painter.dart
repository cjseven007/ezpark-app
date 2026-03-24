import 'dart:math';
import 'package:ezpark/models/parking_slot.dart';
import 'package:ezpark/models/slot_point.dart';
import 'package:flutter/material.dart';

class SlotLayoutPainter extends CustomPainter {
  final List<ParkingSlot> slots;
  final double imageWidth;
  final double imageHeight;
  final double padding;

  SlotLayoutPainter({
    required this.slots,
    required this.imageWidth,
    required this.imageHeight,
    this.padding = 16,
  });

  static Rect computeContentBounds(List<ParkingSlot> slots) {
    if (slots.isEmpty) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final slot in slots) {
      if (slot.points.isNotEmpty) {
        for (final p in slot.points) {
          minX = min(minX, p.x);
          minY = min(minY, p.y);
          maxX = max(maxX, p.x);
          maxY = max(maxY, p.y);
        }
      } else {
        minX = min(minX, slot.x);
        minY = min(minY, slot.y);
        maxX = max(maxX, slot.x + slot.w);
        maxY = max(maxY, slot.y + slot.h);
      }
    }

    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }

    final width = max(1.0, maxX - minX);
    final height = max(1.0, maxY - minY);

    return Rect.fromLTWH(minX, minY, width, height);
  }

  Path _buildPathFromPoints(
    List<SlotPoint> points,
    Rect bounds,
    Size size,
    double scale,
    double dx,
    double dy,
  ) {
    final path = Path();

    if (points.isEmpty) return path;

    final first = points.first;
    path.moveTo(
      dx + (first.x - bounds.left) * scale,
      dy + (first.y - bounds.top) * scale,
    );

    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      path.lineTo(
        dx + (p.x - bounds.left) * scale,
        dy + (p.y - bounds.top) * scale,
      );
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (slots.isEmpty) return;

    final bounds = computeContentBounds(slots);

    final availW = max(1.0, size.width - padding * 2);
    final availH = max(1.0, size.height - padding * 2);

    final sx = availW / bounds.width;
    final sy = availH / bounds.height;
    final scale = min(sx, sy);

    final contentW = bounds.width * scale;
    final contentH = bounds.height * scale;

    final dx = (size.width - contentW) / 2;
    final dy = (size.height - contentH) / 2;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fill = Paint()..style = PaintingStyle.fill;

    for (final slot in slots) {
      fill.color = (slot.isAvailable ? Colors.green : Colors.red).withValues(
        alpha: 0.12,
      );
      border.color = slot.isAvailable ? Colors.green : Colors.red;

      if (slot.points.isNotEmpty && slot.points.length >= 3) {
        final path = _buildPathFromPoints(
          slot.points,
          bounds,
          size,
          scale,
          dx,
          dy,
        );
        canvas.drawPath(path, fill);
        canvas.drawPath(path, border);
      } else {
        final rect = Rect.fromLTWH(
          dx + (slot.x - bounds.left) * scale,
          dy + (slot.y - bounds.top) * scale,
          slot.w * scale,
          slot.h * scale,
        );

        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SlotLayoutPainter oldDelegate) {
    return oldDelegate.slots != slots ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.padding != padding;
  }
}
