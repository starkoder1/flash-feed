import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HidingBottomNavBar extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final Duration duration;

  /// If true, the bar hides on scroll.
  /// If false, the bar stays sticky (visible).
  final bool enableHiding;

  /// Optional notifier for scroll direction. When provided, this takes
  /// precedence over the ScrollController for determining hide/show behavior.
  /// Use ScrollDirection.reverse to hide, ScrollDirection.forward to show.
  final ValueNotifier<ScrollDirection>? scrollDirectionNotifier;

  const HidingBottomNavBar({
    super.key,
    required this.child,
    this.controller,
    this.duration = const Duration(milliseconds: 200),
    this.enableHiding = true,
    this.scrollDirectionNotifier,
  });

  @override
  _HidingBottomNavBarState createState() => _HidingBottomNavBarState();
}

class _HidingBottomNavBarState extends State<HidingBottomNavBar>
    with SingleTickerProviderStateMixin {

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
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    widget.controller?.addListener(_scrollListener);
    widget.scrollDirectionNotifier?.addListener(_notifierListener);
  }

  @override
  void didUpdateWidget(HidingBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_scrollListener);
      widget.controller?.addListener(_scrollListener);
    }

    // Handle notifier changes
    if (oldWidget.scrollDirectionNotifier != widget.scrollDirectionNotifier) {
      oldWidget.scrollDirectionNotifier?.removeListener(_notifierListener);
      widget.scrollDirectionNotifier?.addListener(_notifierListener);
    }

    // EDGE CASE HANDLE:
    // If we switched from "Hiding Enabled" to "Hiding Disabled" (Sticky Mode),
    // we must force the bar to show immediately if it was hidden.
    if (!widget.enableHiding && oldWidget.enableHiding) {
      _animationController.reverse(); // Bring it back up
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_scrollListener);
    widget.scrollDirectionNotifier?.removeListener(_notifierListener);
    _animationController.dispose();
    super.dispose();
  }

  void _notifierListener() {
    if (!widget.enableHiding) return;

    final direction = widget.scrollDirectionNotifier!.value;
    _updateAnimationForDirection(direction);
  }

  void _scrollListener() {
    // If hiding is disabled, do nothing (keep it sticky)
    if (!widget.enableHiding) return;

    // If we have a notifier, it takes precedence
    if (widget.scrollDirectionNotifier != null) return;

    if (widget.controller == null || !widget.controller!.hasClients) return;

    final direction = widget.controller!.position.userScrollDirection;
    _updateAnimationForDirection(direction);
  }

  void _updateAnimationForDirection(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      // Scrolling down - hide the bar
      _animationController.forward();
    } else if (direction == ScrollDirection.forward) {
      // Scrolling up - show the bar
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If hiding is disabled, force the child to be rendered directly.
    // This ignores any current animation state and ensures the bar is visible.
    if (!widget.enableHiding) {
      return widget.child;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}