import 'package:flutter/material.dart';

/// 경로 이탈 감지 시 표시되는 알림 위젯
class RouteDeviationAlert extends StatelessWidget {
  final VoidCallback onDismiss;

  const RouteDeviationAlert({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 36.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '경로 이탈 감지됨',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '카미노 경로에서 벗어났습니다. 지도를 확인하세요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 경로 이탈 감지 알림을 애니메이션과 함께 표시하는 위젯
class AnimatedRouteDeviationAlert extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onDismiss;

  const AnimatedRouteDeviationAlert({
    Key? key,
    required this.isVisible,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<AnimatedRouteDeviationAlert> createState() =>
      _AnimatedRouteDeviationAlertState();
}

class _AnimatedRouteDeviationAlertState
    extends State<AnimatedRouteDeviationAlert> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedRouteDeviationAlert oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.vertical,
      axisAlignment: -1.0, // 상단에서 시작
      child: FadeTransition(
        opacity: _animation,
        child: RouteDeviationAlert(
          onDismiss: widget.onDismiss,
        ),
      ),
    );
  }
}
