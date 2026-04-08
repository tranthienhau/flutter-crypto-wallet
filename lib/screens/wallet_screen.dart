import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/wallet_provider.dart';
import '../services/wallet_service.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final address = state.account?.address ?? '0x...';

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _portfolio(state.totalUsd),
            const SizedBox(height: 12),
            _addressCard(address),
            const SizedBox(height: 16),
            _actionRow(context),
            const SizedBox(height: 20),
            const Text('Balances',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            ...state.balances.map(_balanceRow),
          ],
        ),
      ),
    );
  }

  Widget _portfolio(double totalUsd) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B5CFA), Color(0xFF4D2EB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total portfolio',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('\$${totalUsd.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _addressCard(String address) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet,
              color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              address,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    return Row(
      children: [
        _action(context, Icons.send, 'Send', '/send'),
        _action(context, Icons.call_received, 'Receive', '/receive'),
        _action(context, Icons.history, 'History', '/history'),
        _action(context, Icons.link, 'dApp', '/dapp'),
      ],
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, String route) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: const Color(0xFF141A2E),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(route),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(height: 6),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _balanceRow(Balance b) {
    return Card(
      color: const Color(0xFF141A2E),
      child: ListTile(
        title: Text(b.chain.label,
            style: const TextStyle(color: Colors.white)),
        subtitle: Text('${b.amount} ${b.chain.symbol}',
            style: const TextStyle(color: Colors.white54)),
        trailing: Text('\$${b.usdValue.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
