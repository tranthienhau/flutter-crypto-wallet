import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wallet_provider.dart';
import '../services/biometrics_service.dart';
import '../services/wallet_service.dart';

final biometricsProvider = Provider((ref) => BiometricsService());

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  ChainId _chain = ChainId.ethereum;
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  String? _status;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _chainSelector(),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Recipient address',
                hintText: '0x...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (${_chain.symbol})',
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_busy ? 'Signing...' : 'Sign with Face ID'),
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, style: const TextStyle(color: Colors.white70)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chainSelector() {
    return Wrap(
      spacing: 8,
      children: ChainId.values.map((c) {
        final selected = c == _chain;
        return ChoiceChip(
          label: Text(c.label),
          selected: selected,
          onSelected: (_) => setState(() => _chain = c),
        );
      }).toList(),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _toController.text.isEmpty) {
      setState(() => _status = 'Invalid recipient or amount.');
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    final ok = await ref
        .read(biometricsProvider)
        .requestBiometric('Confirm transaction');
    if (!ok) {
      setState(() {
        _busy = false;
        _status = 'Biometric authentication cancelled.';
      });
      return;
    }
    final hash = await ref.read(walletProvider.notifier).send(
          chain: _chain,
          to: _toController.text,
          amount: amount,
        );
    setState(() {
      _busy = false;
      _status = 'Submitted: $hash';
    });
  }
}
