import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';

class SignaturePadPlaceholder extends StatefulWidget {
  final ValueChanged<bool> onSigned;

  const SignaturePadPlaceholder({super.key, required this.onSigned});

  @override
  State<SignaturePadPlaceholder> createState() => _SignaturePadPlaceholderState();
}

class _SignaturePadPlaceholderState extends State<SignaturePadPlaceholder> {
  List<Offset?> points = [];

  void _addPoint(PointerEvent event) {
    RenderBox referenceBox = context.findRenderObject() as RenderBox;
    Offset localPosition = referenceBox.globalToLocal(event.position);
    setState(() {
      points.add(localPosition);
      widget.onSigned(true); // Signal that signing has started
    });
  }

  void _endLine(PointerEvent event) {
    setState(() {
      points.add(null);
    });
  }

  void _clear() {
    setState(() {
      points.clear();
      widget.onSigned(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.errorRed,
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            alignment: Alignment.centerRight,
          ),
        ),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.borderLight, width: 2),
          ),
          child: Listener(
            onPointerDown: _addPoint,
            onPointerMove: _addPoint,
            onPointerUp: _endLine,
            child: CustomPaint(
              painter: SignaturePainter(points),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
