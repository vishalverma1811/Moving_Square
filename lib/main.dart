import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The main entry point for the Square Animation application.
void main() {
  runApp(const MyApp());
}

/// Root widget of the application that configures screen adaptation.
/// 
/// Uses [ScreenUtilInit] to initialize responsive sizing based on a 360x800
/// design layout. Sets up the basic material app theme and structure.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Square Animation',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: const SquareAnimation(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Represents possible positions for the animated square.
/// 
/// - [center]: Centered position in the available space
/// - [topLeft]: Top-left corner position
/// - [topRight]: Top-right corner position
enum Position { center, topLeft, topRight }

 
/// Displays a square that can be animated to different corners using buttons,
/// with proper state management and animation controls.
class SquareAnimation extends StatefulWidget {
  const SquareAnimation({super.key});

  @override
  State<SquareAnimation> createState() => _SquareAnimationState();
}

class _SquareAnimationState extends State<SquareAnimation> {
  /// The size of the square in logical pixels
  static const squareSize = 50.0;

  /// Current position of the square
  Position currentPosition = Position.center;

  /// Flag indicating if an animation is currently in progress
  bool isAnimating = false;


  /// Handles animation state management and validates position transitions:
  /// - From [Position.center] to either corner
  /// - From corners back to center
  
  void moveTo(Position target) {
    if (isAnimating) return;

    Position newPosition = currentPosition;

    switch (currentPosition) {
      case Position.center:
      // Allow movement to either corner from center
        if (target == Position.topLeft || target == Position.topRight) {
          newPosition = target;
        }
        break;
      case Position.topLeft:
      // Only allow moving back to center from left
        if (target == Position.topRight) {
          newPosition = Position.center;
        }
        break;
      // Only allow moving back to center from right
      case Position.topRight:
        if (target == Position.topLeft) {
          newPosition = Position.center;
        }
        break;
    }

    if (newPosition == currentPosition) return;

    setState(() {
      isAnimating = true;
      currentPosition = newPosition;
    });

    /// The duration for the position animation
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(0.024.sh),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double left;
                  double top;
                  // Calculate position based on current state
                  switch (currentPosition) {
                    case Position.center:
                      left = (constraints.maxWidth - squareSize) / 2;
                      top = (constraints.maxHeight - squareSize) / 2;
                      break;
                    case Position.topLeft:
                      left = 0;
                      top = 0;
                      break;
                    case Position.topRight:
                      left = constraints.maxWidth - squareSize;
                      top = 0;
                      break;
                  }
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        left: left,
                        top: top,
                        child: Container(
                          width: squareSize,
                          height: squareSize,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            border: Border.all(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height:0.02.sh),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Disable if animating or already at target
                ElevatedButton(
                  onPressed: isAnimating || currentPosition == Position.topLeft
                      ? null
                      : () => moveTo(Position.topLeft),
                  child: const Text('Left'),
                ),
                SizedBox(width: 0.02.sh),
                ElevatedButton(
                  // Disable if animating or already at target
                  onPressed: isAnimating || currentPosition == Position.topRight
                      ? null
                      : () => moveTo(Position.topRight),
                  child: const Text('Right'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}