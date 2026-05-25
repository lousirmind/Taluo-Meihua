import 'package:flutter/material.dart';

class CardFlipWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool flipped;
  final VoidCallback? onFlip;
  final double width;
  final double height;

  const CardFlipWidget({
    super.key,
    required this.front,
    required this.back,
    this.flipped = false,
    this.onFlip,
    this.width = 120,
    this.height = 180,
  });

  @override
  State<CardFlipWidget> createState() => _CardFlipWidgetState();
}

class _CardFlipWidgetState extends State<CardFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.flipped) _controller.value = 1;
  }

  @override
  void didUpdateWidget(CardFlipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped && !oldWidget.flipped) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (!_controller.isCompleted) {
      _controller.forward();
      widget.onFlip?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * 3.14159),
            child: isFront
                ? _buildFace(widget.front, true)
                : _buildFace(widget.back, false),
          );
        },
      ),
    );
  }

  Widget _buildFace(Widget child, bool isFront) {
    // 两面统一补 π 旋转，抵消父级 Transform 在动画终点的旋转
    // 翻转前(animation=0): 父级旋转0 + 本层π → 背面正常显示(对称图案)
    // 翻转后(animation=1): 父级旋转π + 本层π = 2π → 正面正常显示 ✓
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: SizedBox(width: widget.width, height: widget.height, child: child),
    );
  }
}
