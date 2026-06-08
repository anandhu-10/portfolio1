import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_state_provider.dart';

class SessionTimeoutListener extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 15), // 15 minutes default inactivity
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    
    final provider = Provider.of<PortfolioStateProvider>(context, listen: false);
    // Only track inactivity if the admin is authenticated
    if (provider.isAdminAuthenticated) {
      _timer = Timer(widget.timeout, _onTimeout);
    }
  }

  void _onTimeout() {
    final provider = Provider.of<PortfolioStateProvider>(context, listen: false);
    if (provider.isAdminAuthenticated) {
      provider.logoutAdmin();
      
      // Show an alert/snackbar indicating logout due to inactivity
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired due to inactivity. Admin panel locked.', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Redirect to home page if on /admin page
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == '/admin') {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PortfolioStateProvider>(context);
    
    // If not authenticated, just return child without listener to save resources
    if (!provider.isAdminAuthenticated) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerHover: (_) => _resetTimer(),
      child: Focus(
        onKeyEvent: (node, event) {
          _resetTimer();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}
