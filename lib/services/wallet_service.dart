// Multi-chain wallet service.
//
// In production this would wrap ethers.js style libs or web3dart for real
// key derivation, RPC calls to Infura/Alchemy, and EIP-1559 gas estimation.
// The POC keeps the surface identical so swapping in real implementations
// is localized to this file.

enum ChainId { ethereum, polygon, base }

extension ChainIdX on ChainId {
  String get label {
    switch (this) {
      case ChainId.ethereum:
        return 'Ethereum';
      case ChainId.polygon:
        return 'Polygon';
      case ChainId.base:
        return 'Base';
    }
  }

  String get symbol {
    switch (this) {
      case ChainId.ethereum:
        return 'ETH';
      case ChainId.polygon:
        return 'MATIC';
      case ChainId.base:
        return 'ETH';
    }
  }
}

class Balance {
  const Balance({
    required this.chain,
    required this.amount,
    required this.usdValue,
  });

  final ChainId chain;
  final double amount;
  final double usdValue;
}

class TxRecord {
  const TxRecord({
    required this.hash,
    required this.chain,
    required this.direction,
    required this.counterparty,
    required this.amount,
    required this.usdValue,
    required this.status,
    required this.timestamp,
  });

  final String hash;
  final ChainId chain;
  final String direction; // 'in' or 'out'
  final String counterparty;
  final double amount;
  final double usdValue;
  final String status; // 'confirmed', 'pending', 'failed'
  final DateTime timestamp;
}

class WalletAccount {
  const WalletAccount({required this.address, required this.mnemonic});
  final String address;
  final String mnemonic;
}

class WalletService {
  Future<WalletAccount> loadOrCreateWallet(String? existingMnemonic) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final mnemonic = existingMnemonic ??
        'plunge glance oxygen blue frame tuna dinner rapid canvas mosquito vivid journey';
    // Deterministic-ish fake address derivation so the UI is stable.
    final hash = mnemonic.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFFFF);
    final address = '0x${hash.toRadixString(16).padLeft(40, 'a')}';
    return WalletAccount(address: address, mnemonic: mnemonic);
  }

  Future<List<Balance>> fetchBalances(String address) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      Balance(chain: ChainId.ethereum, amount: 0.842, usdValue: 2810.45),
      Balance(chain: ChainId.polygon, amount: 1250.12, usdValue: 980.09),
      Balance(chain: ChainId.base, amount: 0.212, usdValue: 707.60),
    ];
  }

  Future<List<TxRecord>> fetchTransactions(String address) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      TxRecord(
        hash: '0xabc1',
        chain: ChainId.ethereum,
        direction: 'in',
        counterparty: '0xA1...bE9',
        amount: 0.5,
        usdValue: 1670.00,
        status: 'confirmed',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      TxRecord(
        hash: '0xabc2',
        chain: ChainId.polygon,
        direction: 'out',
        counterparty: '0x7C...42D',
        amount: 120,
        usdValue: 94.10,
        status: 'confirmed',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      TxRecord(
        hash: '0xabc3',
        chain: ChainId.base,
        direction: 'out',
        counterparty: '0xFe...009',
        amount: 0.05,
        usdValue: 167.20,
        status: 'pending',
        timestamp: now.subtract(const Duration(minutes: 12)),
      ),
    ];
  }

  Future<String> sendTransaction({
    required ChainId chain,
    required String to,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return '0xsimulated${DateTime.now().millisecondsSinceEpoch}';
  }
}
