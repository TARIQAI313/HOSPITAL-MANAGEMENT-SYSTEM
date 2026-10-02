import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

/// Extension on BuildContext to provide safe pop and navigation utilities.
extension AppNavigationContext on BuildContext {
  /// Safely pops the current route if there is a previous route in the Navigator stack.
  /// If there is nowhere to pop (e.g. accessed via deep link or `context.go`),
  /// it gracefully navigates to the fallback dashboard instead of failing or closing the app.
  void safePop<T extends Object?>([T? result, String? fallback]) {
    if (canPop()) {
      pop(result);
    } else {
      go(fallback ?? RoutePaths.home);
    }
  }
}

/// A wrapper widget that intercepts Android system back button and gesture navigation.
/// Ensures the user is safely navigated back or to the home dashboard instead of exiting unexpectedly.
class AppBackScope extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  final String fallbackRoute;

  const AppBackScope({
    super.key,
    required this.child,
    this.onBack,
    this.fallbackRoute = RoutePaths.home,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (onBack != null) {
          onBack!();
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(result);
        } else {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}
