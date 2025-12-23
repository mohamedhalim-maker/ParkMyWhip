import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle Supabase auth state changes and password reset deep links
/// Uses Supabase's built-in PKCE flow + app_links to handle expired tokens
class DeepLinkService {
  static StreamSubscription<AuthState>? _authStateSubscription;
  static StreamSubscription<Uri>? _deepLinkSubscription;
  static final _appLinks = AppLinks();
  static bool _isHandlingDeepLink = false;

  /// Initialize Supabase auth state listener and deep link handler
  /// Supabase automatically handles deep links via PKCE flow when authCallbackUrlHostname is set
  static void initialize() {
    AppLogger.deepLink('Initializing DeepLinkService');
    
    // Listen to Supabase auth state changes
    // When user clicks a VALID password reset link:
    // 1. Supabase intercepts the deep link (parkmywhip://reset-password?token=xxx&type=recovery)
    // 2. Exchanges the token for a session using PKCE flow
    // 3. Triggers PASSWORD_RECOVERY event
    _authStateSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
      (AuthState authState) {
        final event = authState.event;
        final session = authState.session;
        
        AppLogger.deepLink('Auth state changed: event=$event, session=${session != null ? "present" : "null"}');

        // Handle password recovery event (only fires if token is valid)
        if (event == AuthChangeEvent.passwordRecovery) {
          if (session != null) {
            AppLogger.deepLink('Valid password recovery session detected');
            _isHandlingDeepLink = true;
            _handlePasswordRecovery();
          } else {
            AppLogger.warning('Password recovery event without session - invalid token', name: 'DeepLink');
            _isHandlingDeepLink = true;
            _handlePasswordResetError('Invalid or expired reset token');
          }
        }
      },
      onError: (error) {
        AppLogger.error('Auth state change error', name: 'DeepLink', error: error);
        _isHandlingDeepLink = true;
        _handlePasswordResetError(error.toString());
      },
    );

    // Listen to app_links to detect when app is opened via deep link
    // This catches the case when the token is EXPIRED:
    // - Deep link opens the app
    // - Supabase tries to exchange token but fails silently (no PASSWORD_RECOVERY event)
    // - We detect the deep link here and check if session was created
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        AppLogger.deepLink('Deep link received: $uri');
        
        // Wait a bit for Supabase to process the link
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if Supabase auth state change already handled this
        if (_isHandlingDeepLink) {
          AppLogger.deepLink('Deep link already handled by auth state change');
          _isHandlingDeepLink = false;
          return;
        }

        // Check if this is a password reset link
        final isPasswordReset = uri.queryParameters['type'] == 'recovery' || 
                               uri.path.contains('reset-password');
        
        if (isPasswordReset) {
          // Check if we have a valid session
          final session = SupabaseConfig.client.auth.currentSession;
          
          if (session == null) {
            // No session = expired/invalid token
            AppLogger.warning('Password reset link opened but no session - token is expired', name: 'DeepLink');
            _handlePasswordResetError('Password reset link has expired');
          } else {
            // This shouldn't happen (auth state change should have caught it)
            // But handle it just in case
            AppLogger.deepLink('Password reset link with session detected via app_links');
            _handlePasswordRecovery();
          }
        }
      },
      onError: (error) {
        AppLogger.error('Deep link stream error', name: 'DeepLink', error: error);
      },
    );

    // Also check initial link (when app is launched from deep link)
    _checkInitialLink();
  }

  /// Check if app was launched via deep link
  static Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        AppLogger.deepLink('App launched with deep link: $uri');
        
        // Wait for Supabase to process the link (it needs time to exchange token)
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if auth state change handled it
        if (_isHandlingDeepLink) {
          AppLogger.deepLink('Initial deep link already handled by auth state change');
          _isHandlingDeepLink = false;
          return;
        }

        // Check if this is a password reset link
        final isPasswordReset = uri.queryParameters['type'] == 'recovery' || 
                               uri.path.contains('reset-password');
        
        if (isPasswordReset) {
          final session = SupabaseConfig.client.auth.currentSession;
          
          if (session == null) {
            AppLogger.warning('App launched with expired password reset link', name: 'DeepLink');
            _handlePasswordResetError('Password reset link has expired');
          } else {
            AppLogger.deepLink('App launched with valid password reset link');
            _handlePasswordRecovery();
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error checking initial link', name: 'DeepLink', error: e);
    }
  }

  /// Handle successful password recovery
  static void _handlePasswordRecovery() {
    AppLogger.navigation('Navigating to reset password page');
    
    // Use SchedulerBinding to ensure navigation happens after current frame completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final navigatorState = AppRouter.navigatorKey.currentState;
      if (navigatorState != null) {
        navigatorState.pushNamedAndRemoveUntil(
          RoutesName.resetPassword,
          (route) => false,
        );
      } else {
        AppLogger.warning('Navigator not ready for reset password page', name: 'Navigation');
      }
    });
  }

  /// Handle password reset errors (expired/invalid links)
  static void _handlePasswordResetError(String error) {
    AppLogger.warning('Password reset link error: $error. Showing error page.', name: 'DeepLink');
    
    // Use SchedulerBinding to ensure navigation happens after current frame completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final navigatorState = AppRouter.navigatorKey.currentState;
      if (navigatorState != null) {
        navigatorState.pushNamedAndRemoveUntil(
          RoutesName.resetLinkError,
          (route) => false,
        );
      } else {
        AppLogger.warning('Navigator not ready for error page', name: 'Navigation');
      }
    });
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
  }
}
