// WalletConnect v2 pairing flow, simulated.

class PendingSession {
  const PendingSession({required this.uri, required this.dappName, required this.dappUrl});
  final String uri;
  final String dappName;
  final String dappUrl;
}

class ActiveSession {
  const ActiveSession({
    required this.topic,
    required this.dappName,
    required this.chains,
  });
  final String topic;
  final String dappName;
  final List<String> chains;
}

class WalletConnectService {
  Future<PendingSession?> pairSession(String uri) async {
    if (!uri.startsWith('wc:')) return null;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return PendingSession(
      uri: uri,
      dappName: 'Uniswap',
      dappUrl: 'https://app.uniswap.org',
    );
  }

  Future<ActiveSession> approveSession(PendingSession pending) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ActiveSession(
      topic: 'topic_${DateTime.now().millisecondsSinceEpoch}',
      dappName: pending.dappName,
      chains: const ['eip155:1', 'eip155:137', 'eip155:8453'],
    );
  }

  Future<void> rejectSession(PendingSession pending) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
