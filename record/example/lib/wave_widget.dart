import 'dart:math';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double frequency;
  final int density;
  final double phase;
  final double normedAmplitude;
  final Color color;

  WavePainter({
    required this.frequency,
    required this.density,
    required this.phase,
    required this.normedAmplitude,
    required this.color,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    var maxAmplitude = size.height / 2.0;
    var mid = size.width / 2;

    for (var x = 0; x < size.width + density; x += density) {
      // Parabolic scaling
      var scaling = -pow(1 / mid * (x - mid), 2) + 1;
      var y = scaling *
          maxAmplitude *
          normedAmplitude *
          sin(pi * 2 * frequency * (x / size.width) + phase);
      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }

    final paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.frequency != frequency ||
        oldDelegate.density != density ||
        oldDelegate.phase != phase ||
        oldDelegate.normedAmplitude != normedAmplitude;
  }
}

class WaveWidget extends StatefulWidget {
  final int amplitude;
  final Color color;

  const WaveWidget({
    Key? key,
    required this.amplitude,
    required this.color,
  }) : super(key: key);

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget>
    with SingleTickerProviderStateMixin {
  late int latestAmp = 0;
  double realAmp = 0.0;
  double phase = 0.0;
  double realPhase = 0.0;

  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );

  @override
  void initState() {
    latestAmp = widget.amplitude;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latestAmp = this.latestAmp;
    final newAmp = widget.amplitude;
    final latestPhase = phase;
    final newPhase = phase - 1.5;
    controller.reset();
    final ani = IntTween(begin: latestAmp, end: newAmp).animate(controller);
    final aniPhase =
        Tween<double>(begin: latestPhase, end: newPhase).animate(controller);
    ani.addListener(() {
      realAmp = pow(10, (ani.value) / 20) + 0.0;
      setState(() {});
    });
    aniPhase.addListener(() {
      realPhase = aniPhase.value;
      setState(() {});
    });
    controller.forward();

    this.latestAmp = newAmp;
    phase = newPhase;
  }

  @override
  Widget build(BuildContext context) {
    print('realPhase = $realPhase');
    print('realAmp = $realAmp');
    final sw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: sw,
      height: 200,
      child: CustomPaint(
        painter: WavePainter(
          phase: realPhase,
          normedAmplitude: realAmp * (1.5 - 0.8),
          color: widget.color,
          frequency: 1.5,
          density: 1,
        ),
      ),
    );
  }
}
