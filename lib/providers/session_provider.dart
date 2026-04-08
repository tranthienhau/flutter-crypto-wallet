import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wallet_connect_service.dart';

final walletConnectServiceProvider = Provider((ref) => WalletConnectService());

class SessionState {
  const SessionState({required this.pending, required this.active});
  final PendingSession? pending;
  final List<ActiveSession> active;

  SessionState copyWith({PendingSession? pending, List<ActiveSession>? active}) {
    return SessionState(
      pending: pending,
      active: active ?? this.active,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._service)
      : super(const SessionState(pending: null, active: []));

  final WalletConnectService _service;

  Future<void> pair(String uri) async {
    final pending = await _service.pairSession(uri);
    state = state.copyWith(pending: pending);
  }

  Future<void> approve() async {
    final pending = state.pending;
    if (pending == null) return;
    final active = await _service.approveSession(pending);
    state = SessionState(
      pending: null,
      active: [...state.active, active],
    );
  }

  Future<void> reject() async {
    final pending = state.pending;
    if (pending == null) return;
    await _service.rejectSession(pending);
    state = state.copyWith(pending: null);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(walletConnectServiceProvider));
});
