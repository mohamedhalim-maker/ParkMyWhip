import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
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
    log('Initializing DeepLinkService', name: 'DeepLinkService', level: 800);
    
    // Listen to Supabase auth state changes
    // When user clicks a VALID password reset link:
    // 1. Supabase intercepts the deep link (parkmywhip://reset-password?token=xxx&type=recovery)
    // 2. Exchanges the token for a session using PKCE flow
    // 3. Triggers PASSWORD_RECOVERY event
    _authStateSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
      (AuthState authState) {
        final event = authState.event;
        final session = authState.session;
        
        log('Auth state changed: event=$event, session=${session != null ? "present" : "null"}', 
            name: 'DeepLinkService', level: 800);

        // Handle password recovery event (only fires if token is valid)
        if (event == AuthChangeEvent.passwordRecovery) {
          if (session != null) {
            log('Valid password recovery session detected', name: 'DeepLinkService', level: 800);
            _isHandlingDeepLink = true;
            _handlePasswordRecovery();
          } else {
            log('Password recovery event without session - invalid token', name: 'DeepLinkService', level: 900);
            _isHandlingDeepLink = true;
            _handlePasswordResetError('Invalid or expired reset token');
          }
        }
      },
      onError: (error) {
        log('Auth state change error: $error', name: 'DeepLinkService', level: 900, error: error);
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
        log('Deep link received: $uri', name: 'DeepLinkService', level: 800);
        
        // Wait a bit for Supabase to process the link
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if Supabase auth state change already handled this
        if (_isHandlingDeepLink) {
          log('Deep link already handled by auth state change', name: 'DeepLinkService', level: 800);
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
            log('Password reset link opened but no session - token is expired', 
                name: 'DeepLinkService', level: 900);
            _handlePasswordResetError('Password reset link has expired');
          } else {
            // This shouldn't happen (auth state change should have caught it)
            // But handle it just in case
            log('Password reset link with session detected via app_links', 
                name: 'DeepLinkService', level: 800);
            _handlePasswordRecovery();
          }
        }
      },
      onError: (error) {
        log('Deep link stream error: $error', name: 'DeepLinkService', level: 900, error: error);
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
        log('App launched with deep link: $uri', name: 'DeepLinkService', level: 800);
        
        // Wait for Supabase to process the link (it needs time to exchange token)
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if auth state change handled it
        if (_isHandlingDeepLink) {
          log('Initial deep link already handled by auth state change', name: 'DeepLinkService', level: 800);
          _isHandlingDeepLink = false;
          return;
        }

        // Check if this is a password reset link
        final isPasswordReset = uri.queryParameters['type'] == 'recovery' || 
                               uri.path.contains('reset-password');
        
        if (isPasswordReset) {
          final session = SupabaseConfig.client.auth.currentSession;
          
          if (session == null) {
            log('App launched with expired password reset link', name: 'DeepLinkService', level: 900);
            _handlePasswordResetError('Password reset link has expired');
          } else {
            log('App launched with valid password reset link', name: 'DeepLinkService', level: 800);
            _handlePasswordRecovery();
          }
        }
      }
    } catch (e) {
      log('Error checking initial link: $e', name: 'DeepLinkService', level: 900, error: e);
    }
  }

  /// Handle successful password recovery
  static void _handlePasswordRecovery() {
    log('Navigating to reset password page', name: 'DeepLinkService', level: 800);
    
    // Use SchedulerBinding to ensure navigation happens after current frame completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final navigatorState = AppRouter.navigatorKey.currentState;
      if (navigatorState != null) {
        navigatorState.pushNamedAndRemoveUntil(
          RoutesName.resetPassword,
          (route) => false,
        );
      } else {
        log('Navigator not ready for reset password page', name: 'DeepLinkService', level: 900);
      }
    });
  }

  /// Handle password reset errors (expired/invalid links)
  static void _handlePasswordResetError(String error) {
    log('Password reset link error: $error. Showing error page.', name: 'DeepLinkService', level: 900);
    
    // Use SchedulerBinding to ensure navigation happens after current frame completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final navigatorState = AppRouter.navigatorKey.currentState;
      if (navigatorState != null) {
        navigatorState.pushNamedAndRemoveUntil(
          RoutesName.resetLinkError,
          (route) => false,
        );
      } else {
        log('Navigator not ready for error page', name: 'DeepLinkService', level: 900);
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
