import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class PsychedelicTransitions {
  // Smooth fade transition optimized for 60fps
  static PageRouteBuilder<T> fadeTransition<T>(
    Widget page, {
    Duration duration = DesignTokens.transitionAnimation,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: DesignTokens.curveDefault,
          ),
          child: child,
        );
      },
    );
  }

  // Psychedelic slide transition with glow effect
  static PageRouteBuilder<T> psychedelicSlideTransition<T>(
    Widget page, {
    Duration duration = DesignTokens.transitionAnimation,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Color? glowColor,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: AnimatedContainer(
              duration: duration,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: (glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(0.1 * animation.value),
                    blurRadius: 20 * animation.value,
                    spreadRadius: 5 * animation.value,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Scale transition with psychedelic glow
  static PageRouteBuilder<T> psychedelicScaleTransition<T>(
    Widget page, {
    Duration duration = DesignTokens.transitionAnimation,
    double begin = 0.8,
    double end = 1.0,
    Color? glowColor,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: (glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(0.2 * animation.value),
                    blurRadius: 30 * animation.value,
                    spreadRadius: 8 * animation.value,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Hypnotic rotation transition
  static PageRouteBuilder<T> hypnoticRotationTransition<T>(
    Widget page, {
    Duration duration = DesignTokens.transitionAnimation,
    double turns = 0.1,
    Color? glowColor,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = Tween<double>(
          begin: turns,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveHypnotic,
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: RotationTransition(
              turns: rotationAnimation,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: (glowColor ?? DesignTokens.neonPurple)
                          .withOpacity(0.15 * animation.value),
                      blurRadius: 25 * animation.value,
                      spreadRadius: 6 * animation.value,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  // Combined transition for maximum psychedelic effect
  static PageRouteBuilder<T> psychedelicCombinedTransition<T>(
    Widget page, {
    Duration duration = DesignTokens.transitionAnimation,
    Color? glowColor,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      maintainState: maintainState,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveDefault,
        ));

        final rotationAnimation = Tween<double>(
          begin: 0.02,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveHypnotic,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: RotationTransition(
                turns: rotationAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: (glowColor ?? DesignTokens.neonPurple)
                            .withOpacity(0.2 * animation.value),
                        blurRadius: 35 * animation.value,
                        spreadRadius: 10 * animation.value,
                      ),
                      BoxShadow(
                        color: (glowColor ?? DesignTokens.neonCyan)
                            .withOpacity(0.1 * animation.value),
                        blurRadius: 50 * animation.value,
                        spreadRadius: 15 * animation.value,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension to make transitions easier to use
extension PsychedelicNavigation on NavigatorState {
  Future<T?> pushPsychedelicFade<T>(Widget page, {Color? glowColor}) {
    return push(PsychedelicTransitions.fadeTransition<T>(page));
  }

  Future<T?> pushPsychedelicSlide<T>(Widget page, {Color? glowColor}) {
    return push(PsychedelicTransitions.psychedelicSlideTransition<T>(
      page,
      glowColor: glowColor,
    ));
  }

  Future<T?> pushPsychedelicScale<T>(Widget page, {Color? glowColor}) {
    return push(PsychedelicTransitions.psychedelicScaleTransition<T>(
      page,
      glowColor: glowColor,
    ));
  }

  Future<T?> pushPsychedelicHypnotic<T>(Widget page, {Color? glowColor}) {
    return push(PsychedelicTransitions.hypnoticRotationTransition<T>(
      page,
      glowColor: glowColor,
    ));
  }

  Future<T?> pushPsychedelicCombined<T>(Widget page, {Color? glowColor}) {
    return push(PsychedelicTransitions.psychedelicCombinedTransition<T>(
      page,
      glowColor: glowColor,
    ));
  }
}

// Hero wrapper for smooth transitions
class PsychedelicHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Color? glowColor;

  const PsychedelicHero({
    super.key,
    required this.tag,
    required this.child,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (glowColor ?? DesignTokens.neonPurple).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}