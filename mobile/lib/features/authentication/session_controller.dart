import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../shared/models/models.dart';
import 'auth_repository.dart';

sealed class SessionState {
  const SessionState();
}

class SessionUnknown extends SessionState {
  const SessionUnknown();
}

class SessionSignedOut extends SessionState {
  const SessionSignedOut({this.reason});
  final String? reason; // expired | not_eligible | google_link_required
}

/// Google verified on the server, advocate code not yet linked. The link token lives in memory only.
class SessionNeedsAdvocateCode extends SessionState {
  const SessionNeedsAdvocateCode({required this.linkToken, required this.googleEmail, required this.expiresAt});
  final String linkToken;
  final String googleEmail;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.me, {this.offline = false});
  final Me me;
  final bool offline;
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    ref.read(sessionExpiredHookProvider).listener = () => _expire('expired');
    return const SessionUnknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// App start: restore the saved session; the backend re-checks the link and eligibility.
  Future<void> bootstrap() async {
    if (!await _repo.hasTokens()) {
      state = const SessionSignedOut();
      return;
    }
    try {
      state = SessionSignedIn(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized || e.statusCode == 403) {
        await _repo.forget();
        state = SessionSignedOut(reason: _reasonFor(e));
        return;
      }
      final cached = await _repo.cachedMe();
      state = cached != null ? SessionSignedIn(cached, offline: true) : const SessionSignedOut();
    }
  }

  /// Step 1. Throws GoogleSignInError / ApiException for the screen to show.
  Future<void> signInWithGoogle() async {
    final r = await _repo.signInWithGoogle(deviceLabel: 'mobile app');
    if (r.isSignedIn) {
      state = SessionSignedIn(await _repo.me());
    } else {
      state = SessionNeedsAdvocateCode(
        linkToken: r.linkToken!,
        googleEmail: r.googleEmail ?? '',
        expiresAt: DateTime.now().add(Duration(seconds: (r.linkExpiresIn ?? 600) - 15)),
      );
    }
  }

  /// Step 2. On failure the state stays "needs advocate code" so the user can correct the code.
  Future<void> linkAdvocate(String code) async {
    final s = state;
    if (s is! SessionNeedsAdvocateCode) return;
    if (s.isExpired) {
      await useDifferentAccount(reason: 'link_expired');
      throw ApiException(code: 'link_token_expired', message: 'Google sign-in expired', statusCode: 401);
    }
    final r = await _repo.linkAdvocate(s.linkToken, code, deviceLabel: 'mobile app');
    if (r.isSignedIn) state = SessionSignedIn(await _repo.me());
  }

  /// Back to the Google account picker (also used by "Switch Google account").
  Future<void> useDifferentAccount({String? reason}) async {
    if (state is SessionSignedIn) {
      await _repo.logout();
    } else {
      await _repo.forgetGoogleChoice();
    }
    state = SessionSignedOut(reason: reason);
  }

  void update(Me me) => state = SessionSignedIn(me);

  Future<void> logout() async {
    await _repo.logout();
    state = const SessionSignedOut();
  }

  Future<void> _expire(String reason) async {
    if (state is SessionSignedOut) return;
    await _repo.forget();
    state = SessionSignedOut(reason: reason);
  }

  String _reasonFor(ApiException e) => switch (e.code) {
        'advocate_not_eligible' => 'not_eligible',
        'google_link_required' => 'google_link_required',
        _ => 'expired',
      };
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

final currentMeProvider = Provider<Me?>((ref) {
  final s = ref.watch(sessionProvider);
  return s is SessionSignedIn ? s.me : null;
});
