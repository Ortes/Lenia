import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lenia/my_render_object.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'widget.g.dart';

@riverpod
Future<FragmentProgram> getShader(GetShaderRef ref) async {
  return FragmentProgram.fromAsset('shaders/shader.frag');
}

class ShaderWidget extends ConsumerWidget {
  const ShaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderAsync = ref.watch(getShaderProvider);
    if (shaderAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (shaderAsync.hasError) {
      throw Exception([shaderAsync.error, shaderAsync.stackTrace]);
    }
    return SafeArea(
      child: ColoredBox(
        color: Colors.blue,
        child: Center(
          child: SizedBox(
            width: 10,
            height: 10,
            child: LeniaAnimationWidget(shader: shaderAsync.value!.fragmentShader()),
          ),
        ),
      ),
    );
  }
}

class CustomPainterWidget extends StatelessWidget {
  const CustomPainterWidget({super.key, required this.shader});

  final FragmentShader shader;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShaderPainter(shader),
    );
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter(this.shader);

  final FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) {
    return oldDelegate.shader != shader;
  }
}
