import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../shared/widgets/widgets.dart';
import 'google_auth_service.dart';

/// Localised message for any sign-in / verification failure (scenarios C-G and Google errors).
String authErrorMessage(BuildContext context, Object error) {
  final l = context.l10n;
  final e = unwrapError(error);
  if (e is GoogleSignInError) {
    return switch (e.failure) {
      GoogleSignInFailure.cancelled => l.errGoogleCancelled,
      GoogleSignInFailure.notConfigured => l.errGoogleNotConfigured,
      GoogleSignInFailure.unavailable => l.errGoogleUnavailable,
      GoogleSignInFailure.failed => l.errorGeneric,
    };
  }
  if (e is ApiException) {
    return switch (e.code) {
      'invalid_advocate_code' => l.errInvalidAdvocateCode,
      'email_mismatch' => l.errEmailMismatch,
      'advocate_already_linked' => l.errAdvocateAlreadyLinked,
      'google_account_linked_elsewhere' => l.errGoogleLinkedElsewhere,
      'advocate_not_eligible' => l.errAdvocateNotEligible,
      'registry_email_missing' => l.errRegistryEmailMissing,
      'google_email_unverified' => l.errGoogleEmailUnverified,
      'google_signin_not_configured' => l.errGoogleNotConfigured,
      'link_token_expired' || 'link_token_invalid' || 'link_token_used' => l.errLinkExpired,
      _ => e.isNetwork ? l.errorNetwork : e.message,
    };
  }
  return l.errorGeneric;
}
