import 'package:flutter/foundation.dart'; // Contains @immutable
import 'package:connection_notifier/src/core/manager/connection_notifier_manager.dart'
    show ConnectionNotifierManager;
import 'package:rxdart/transformers.dart';
import 'package:meta/meta.dart';

/// A class that provides useful tools for connection management. To be used
/// properly, [initialize] method must be called before using it's data.

@immutable
class ConnectionNotifierTools {
  const ConnectionNotifierTools._(); // Private const constructor

  // All fields are static + final/late final
  static late final ConnectionNotifierManager _connectionNotifierManager;
  static bool _isInitialized = false;
  static Duration _initializationDelay = const Duration(milliseconds: 500);
  static const String _debugPrefix = 'ConnectionNotifier:';

  /// Sets a custom initialization delay (default: 500ms)
  static set initializationDelay(Duration delay) {
    if (_isInitialized) {
      throw StateError('$_debugPrefix Cannot change delay after initialization');
    }
    _initializationDelay = delay;
  }

  /// Initializes with optional delay
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('$_debugPrefix Warning: Already initialized');
      return;
    }

    try {
      _connectionNotifierManager = ConnectionNotifierManager.instance;

      if (_initializationDelay > Duration.zero) {
        await Future.delayed(_initializationDelay);
      }

      await _connectionNotifierManager.initialize();
      _isInitialized = true;
    } catch (e, stack) {
      debugPrint('$_debugPrefix Initialization failed: $e\n$stack');
      rethrow;
    }
  }

  /// Current connection status
  static bool get isConnected {
    if (!_isInitialized) return false;
    return _connectionNotifierManager.isConnected ?? false;
  }

  /// Connection status stream
  static Stream<bool> get onStatusChange {
    if (!_isInitialized) {
      return const Stream<bool>.empty().asBroadcastStream();
    }
    return _connectionNotifierManager.connection.switchMap<bool>(
          (isConnected) => Stream.value(isConnected ?? false).asBroadcastStream(),
    );
  }

  /// Check initialization status
  static bool get isInitialized => _isInitialized;
}