import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Snake extends StatefulWidget {
  Snake({
    Key? key,
    this.rows = 20,
    this.columns = 30,
    this.cellSize = 8.0,
    this.selectAccelerometer = true,
    this.selectUserAccelerometer = false,
    this.selectGyroscope = false,
    this.selectMagnetometer = false,
  }) : super(key: key) {
    assert(10 <= rows);
    assert(10 <= columns);
    assert(5.0 <= cellSize);
  }

  final int rows;
  final int columns;
  final double cellSize;
  final bool selectAccelerometer;
  final bool selectUserAccelerometer;
  final bool selectGyroscope;
  final bool selectMagnetometer;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => SnakeState(rows, columns, cellSize);
}

class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter(this.state, this.cellSize);

  GameState? state;
  double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint("cellSize $cellSize");
    final blackLine = Paint()..color = Colors.black;
    final blackFilled = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
      blackLine,
    );
    for (final p in state!.body) {
      final a = Offset(cellSize * p.x, cellSize * p.y);
      final b = Offset(cellSize * (p.x + 1), cellSize * (p.y + 1));

      canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SnakeState extends State<Snake> {
  SnakeState(int rows, int columns, this.cellSize) {
    state = GameState(rows, columns);
  }

  double cellSize;
  GameState? state;
  dynamic acceleration;
  StreamSubscription<dynamic>? _streamSubscription;
  Timer? _timer;

  String title = "";

  @override
  Widget build(BuildContext context) {
    if (title.isNotEmpty) {
      if ((widget.selectAccelerometer && title != "accelerometer") ||
          (widget.selectUserAccelerometer && title != "userAccelerometer") ||
          (widget.selectGyroscope && title != "gyroscope") ||
          (widget.selectMagnetometer && title != "magnetometer")) {
        loadSensorData();
      }
    }

    return Stack(
      children: [
        CustomPaint(painter: SnakeBoardPainter(state, cellSize)),
        Positioned(
          top: 10,
          right: 10,
          child: Text(
            widget.selectAccelerometer
                ? "Accelerometer"
                : widget.selectGyroscope
                    ? "Gyroscope"
                    : widget.selectMagnetometer
                        ? "Magnetometer"
                        : "User Accelerometer",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: widget.selectAccelerometer
                  ? Colors.red
                  : widget.selectGyroscope
                      ? Colors.blueAccent
                      : widget.selectMagnetometer
                          ? Colors.purple
                          : Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    loadSensorData();
  }

  Future loadSensorData() async {
    debugPrint(
        "snake - loadSensorData() accelerometer ${widget.selectAccelerometer} gyroscope ${widget.selectGyroscope} userAccelerometer ${widget.selectUserAccelerometer} magnetometer ${widget.selectMagnetometer}");

    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    if (widget.selectGyroscope) {
      _streamSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        acceleration = event;
        setState(() {});
      });
      title = "gyroscope";
    } else if (widget.selectMagnetometer) {
      _streamSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
        acceleration = event;
        setState(() {});
      });

      title = "magnetometer";
    } else if (widget.selectUserAccelerometer) {
      _streamSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
        acceleration = event;
        setState(() {});
      });

      title = "userAccelerometer";
    } else {
      _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        acceleration = event;
        setState(() {});
      });

      title = "accelerometer";
    }

    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        _step();
      });
    });
  }

  void _step() {
    final newDirection = acceleration == null
        ? null
        : acceleration!.x.abs() < 1.0 && acceleration!.y.abs() < 1.0
            ? null
            : (acceleration!.x.abs() < acceleration!.y.abs())
                ? math.Point<int>(0, acceleration!.y.sign.toInt())
                : math.Point<int>(-acceleration!.x.sign.toInt(), 0);
    state!.step(newDirection);
  }
}

class GameState {
  GameState(this.rows, this.columns) {
    snakeLength = math.min(rows, columns) - 5;
  }

  int rows;
  int columns;
  late int snakeLength;

  List<math.Point<int>> body = <math.Point<int>>[const math.Point<int>(0, 0)];
  math.Point<int> direction = const math.Point<int>(1, 0);

  void step(math.Point<int>? newDirection) {
    var next = body.last + direction;
    next = math.Point<int>(next.x % columns, next.y % rows);

    body.add(next);
    if (body.length > snakeLength) body.removeAt(0);
    direction = newDirection ?? direction;
  }
}
