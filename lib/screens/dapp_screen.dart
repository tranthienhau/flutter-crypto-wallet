import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/session_provider.dart';

class DappScreen extends ConsumerStatefulWidget {
  const DappScreen({super.key});

  @override
  ConsumerState<DappScreen> createState() => _DappScreenState();
}

class _DappScreenState extends ConsumerState<DappScreen> {
  final _uriController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('dApp connect')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paste a WalletConnect v2 URI to pair.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: _uriController,
              decoration: const InputDecoration(
                labelText: 'wc:...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref
                  .read(sessionProvider.notifier)
                  .pair(_uriController.text),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Pair'),
              ),
            ),
            const SizedBox(height: 20),
            if (session.pending != null)
              _pendingCard(session.pending!.dappName, session.pending!.dappUrl),
            const SizedBox(height: 20),
            const Text('Active sessions',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Expanded(
              child: session.active.isEmpty
                  ? const Center(
                      child: Text('No active sessions',
                          style: TextStyle(color: Colors.white38)))
                  : ListView(
                      children: session.active
                          .map((s) => Card(
                                color: const Color(0xFF141A2E),
                                child: ListTile(
                                  title: Text(s.dappName,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  subtitle: Text(s.chains.join(', '),
                                      style: const TextStyle(
                                          color: Colors.white54)),
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(String name, String url) {
    return Card(
      color: const Color(0xFF1A2540),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pair request', style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 4),
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(url, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(sessionProvider.notifier).reject(),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        ref.read(sessionProvider.notifier).approve(),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
