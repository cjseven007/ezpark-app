import 'dart:math';
import 'package:ezpark/models/parking_slot.dart';
import 'package:flutter/material.dart';

class SlotLayoutPainter extends CustomPainter {
  final List<ParkingSlot> slots;
  final double imageWidth;
  final double imageHeight;

  // optional: leave some margin around the drawn slots
  final double padding;

  SlotLayoutPainter({
    required this.slots,
    required this.imageWidth,
    required this.imageHeight,
    this.padding = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slots.isEmpty) return;

    // 1) Compute bounds of all slots in "image space"
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final s in slots) {
      minX = min(minX, s.x);
      minY = min(minY, s.y);
      maxX = max(maxX, s.x + s.w);
      maxY = max(maxY, s.y + s.h);
    }

    // Safety clamp: keep within image bounds (if needed)
    minX = minX.clamp(0.0, imageWidth);
    minY = minY.clamp(0.0, imageHeight);
    maxX = maxX.clamp(0.0, imageWidth);
    maxY = maxY.clamp(0.0, imageHeight);

    final boundsW = max(1.0, maxX - minX);
    final boundsH = max(1.0, maxY - minY);

    // 2) Fit bounds into canvas (with padding)
    final availW = max(1.0, size.width - padding * 2);
    final availH = max(1.0, size.height - padding * 2);

    final sx = availW / boundsW;
    final sy = availH / boundsH;
    final scale = min(sx, sy);

    // 3) Center the bounds inside the canvas
    final contentW = boundsW * scale;
    final contentH = boundsH * scale;

    final dx = (size.width - contentW) / 2;
    final dy = (size.height - contentH) / 2;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fill = Paint()..style = PaintingStyle.fill;

    for (final s in slots) {
      // translate slots so minX/minY becomes origin, then scale, then center
      final rect = Rect.fromLTWH(
        dx + (s.x - minX) * scale,
        dy + (s.y - minY) * scale,
        s.w * scale,
        s.h * scale,
      );

      fill.color = (s.isAvailable ? Colors.green : Colors.red).withValues(
        alpha: 0.1,
      );
      border.color = s.isAvailable ? Colors.green : Colors.red;

      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, border);
    }

    // Optional debug: draw a small crosshair at center
    // final p = Paint()..strokeWidth = 1;
    // canvas.drawLine(Offset(size.width/2 - 8, size.height/2), Offset(size.width/2 + 8, size.height/2), p);
    // canvas.drawLine(Offset(size.width/2, size.height/2 - 8), Offset(size.width/2, size.height/2 + 8), p);
  }

  @override
  bool shouldRepaint(covariant SlotLayoutPainter oldDelegate) {
    return oldDelegate.slots != slots ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.padding != padding;
  }
}
