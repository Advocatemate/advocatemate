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
  final String? reason; // e.g. "expired"
}

class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.me, {this.offline = false});
  final Me me;
  final bool offline;
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    ref.read(sessionExpiredHookProvider).listener = () => _expire();
    return const SessionUnknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> bootstrap() async {
    if (!await _repo.hasTokens()) {
      state = const SessionSignedOut();
      return;
    }
    try {
      state = SessionSignedIn(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _repo.forget();
        state = const SessionSignedOut(reason: 'expired');
        return;
      }
      final cached = await _repo.cachedMe();
      state = cached != null ? SessionSignedIn(cached, offline: true) : const SessionSignedOut();
    }
  }

  Future<void> completeLogin() async => state = SessionSignedIn(await _repo.me());

  void update(Me me) => state = SessionSignedIn(me);

  Future<void> logout() async {
    await _repo.logout();
    state = const SessionSignedOut();
  }

  Future<void> _expire() async {
    if (state is SessionSignedOut) return;
    await _repo.forget();
    state = const SessionSignedOut(reason: 'expired');
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

final currentMeProvider = Provider<Me?>((ref) {
  final s = ref.watch(sessionProvider);
  return s is SessionSignedIn ? s.me : null;
});
