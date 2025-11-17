import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HidingBottomNavBar extends StatefulWidget {
  /// The BottomNavigationBar (or any widget) to hide.
  final Widget child;

  /// The ScrollController to listen to.
  final ScrollController controller;

  /// The duration of the hide/show animation.
  final Duration duration;

  const HidingBottomNavBar({
    super.key,
    required this.child,
    required this.controller,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  _HidingBottomNavBarState createState() => _HidingBottomNavBarState();
}

class _HidingBottomNavBarState extends State<HidingBottomNavBar>
    with TickerProviderStateMixin {
      
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1), // Slides it 100% down
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Listen to the scroll controller
    widget.controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final direction = widget.controller.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      // Scrolling Down: Hide the bar
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward(); // Play animation forward (to hide)
      }
    } else if (direction == ScrollDirection.forward) {
      // Scrolling Up: Show the bar
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse(); // Play animation backward (to show)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}