import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_vault.dart';
import '../services/wallet_service.dart';

final secureVaultProvider = Provider((ref) => const SecureVault());
final walletServiceProvider = Provider((ref) => WalletService());

class WalletState {
  const WalletState({
    required this.account,
    required this.balances,
    required this.transactions,
    required this.loading,
  });

  final WalletAccount? account;
  final List<Balance> balances;
  final List<TxRecord> transactions;
  final bool loading;

  double get totalUsd =>
      balances.fold<double>(0, (acc, b) => acc + b.usdValue);

  WalletState copyWith({
    WalletAccount? account,
    List<Balance>? balances,
    List<TxRecord>? transactions,
    bool? loading,
  }) {
    return WalletState(
      account: account ?? this.account,
      balances: balances ?? this.balances,
      transactions: transactions ?? this.transactions,
      loading: loading ?? this.loading,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier(this._service, this._vault)
      : super(const WalletState(
          account: null,
          balances: [],
          transactions: [],
          loading: false,
        ));

  final WalletService _service;
  final SecureVault _vault;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final existing = await _vault.readMnemonic();
    final account = await _service.loadOrCreateWallet(existing);
    if (existing == null) {
      await _vault.writeMnemonic(account.mnemonic);
    }
    final balances = await _service.fetchBalances(account.address);
    final txs = await _service.fetchTransactions(account.address);
    state = WalletState(
      account: account,
      balances: balances,
      transactions: txs,
      loading: false,
    );
  }

  Future<String> send({
    required ChainId chain,
    required String to,
    required double amount,
  }) async {
    return _service.sendTransaction(chain: chain, to: to, amount: amount);
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    ref.watch(walletServiceProvider),
    ref.watch(secureVaultProvider),
  );
});
