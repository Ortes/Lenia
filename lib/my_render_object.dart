import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class LeniaAnimationWidget extends StatefulWidget {
  const LeniaAnimationWidget({super.key, required this.shader});

  final ui.FragmentShader shader;

  @override
  State<LeniaAnimationWidget> createState() => _LeniaAnimationWidgetState();
}

class _LeniaAnimationWidgetState extends State<LeniaAnimationWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    setState(() => _time = elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond);
  }

  @override
  Widget build(BuildContext context) {
    return MyRenderObjectWidget(shader: widget.shader, time: _time);
  }
}

class MyRenderObjectWidget extends LeafRenderObjectWidget {
  const MyRenderObjectWidget({
    super.key,
    required this.shader,
    required this.time,
  });

  final double time;
  final ui.FragmentShader shader;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyRenderObject(shader: shader);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MyRenderObject renderObject) {
    renderObject.time = time;
  }
}

class MyRenderObject extends RenderBox {
  MyRenderObject({
    required ui.FragmentShader shader,
  }) : _shader = shader;

  ui.FragmentShader get shader => _shader;
  ui.FragmentShader _shader;

  set shader(ui.FragmentShader value) {
    if (value == shader) {
      return;
    }
    _shader = value;
    markNeedsPaint();
  }

  double get time => _time;
  double _time = 0.0;

  set time(double value) {
    if (value == time) {
      return;
    }
    _time = value;
    markNeedsPaint();
  }

  ui.Image? _image;

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  OffsetLayer updateCompositedLayer({required covariant OffsetLayer? oldLayer}) {
    assert(isRepaintBoundary);
    if (oldLayer != null) {
      _image = oldLayer.toImageSync(oldLayer.offset & size, pixelRatio: 2.625);
    }
    return oldLayer ?? OffsetLayer();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final paint = Paint();
    if (_image == null) {
      paint
        ..color = Colors.red
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
    } else {
      _shader
        ..setFloat(0, _time)
        // TODO: The following cll crash
        ..setImageSampler(0, _image!);
      paint.shader = shader;
    }
    canvas.drawRect(offset & size, paint);
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool get isRepaintBoundary => true;
}
