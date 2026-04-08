import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../providers/wallet_provider.dart';
import '../services/wallet_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(walletProvider).transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction history')),
      body: txs.isEmpty
          ? const Center(
              child: Text('No transactions yet',
                  style: TextStyle(color: Colors.white54)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: txs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _row(txs[i]),
            ),
    );
  }

  Widget _row(TxRecord tx) {
    final out = tx.direction == 'out';
    final statusColor = tx.status == 'pending'
        ? const Color(0xFFF5C242)
        : tx.status == 'failed'
            ? const Color(0xFFF26565)
            : const Color(0xFF4CD080);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(out ? Icons.call_made : Icons.call_received,
              color: out ? const Color(0xFFF26565) : const Color(0xFF4CD080)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${out ? 'Sent to' : 'Received from'} ${tx.counterparty}',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                    '${tx.chain.label} - ${DateFormat('MMM d, HH:mm').format(tx.timestamp)}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${out ? '-' : '+'}${tx.amount} ${tx.chain.symbol}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text(tx.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
