import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_crypto_wallet/providers/session_provider.dart';
import 'package:flutter_crypto_wallet/providers/wallet_provider.dart';
import 'package:flutter_crypto_wallet/screens/dapp_screen.dart';
import 'package:flutter_crypto_wallet/screens/history_screen.dart';
import 'package:flutter_crypto_wallet/screens/receive_screen.dart';
import 'package:flutter_crypto_wallet/screens/wallet_screen.dart';
import 'package:flutter_crypto_wallet/services/wallet_connect_service.dart';
import 'package:flutter_crypto_wallet/services/wallet_service.dart';

// Pre-seeded wallet notifier so screenshots show real-looking content without
// touching the Keychain-backed SecureVault during the test run.
class _SeededWalletNotifier extends WalletNotifier {
  _SeededWalletNotifier(super.service, super.vault) {
    state = WalletState(
      account: const WalletAccount(
        address: '0x7B5cFa4D2eB54Cd08042Da1bE9Fe009A1c427B5c',
        mnemonic:
            'plunge glance oxygen blue frame tuna dinner rapid canvas mosquito vivid journey',
      ),
      balances: const [
        Balance(chain: ChainId.ethereum, amount: 0.842, usdValue: 2810.45),
        Balance(chain: ChainId.polygon, amount: 1250.12, usdValue: 980.09),
        Balance(chain: ChainId.base, amount: 0.212, usdValue: 707.60),
      ],
      transactions: [
        TxRecord(
          hash: '0xabc1',
          chain: ChainId.ethereum,
          direction: 'in',
          counterparty: '0xA1...bE9',
          amount: 0.5,
          usdValue: 1670.00,
          status: 'confirmed',
          timestamp: DateTime(2026, 6, 12, 9, 12),
        ),
        TxRecord(
          hash: '0xabc2',
          chain: ChainId.polygon,
          direction: 'out',
          counterparty: '0x7C...42D',
          amount: 120,
          usdValue: 94.10,
          status: 'confirmed',
          timestamp: DateTime(2026, 6, 11, 18, 40),
        ),
        TxRecord(
          hash: '0xabc3',
          chain: ChainId.base,
          direction: 'out',
          counterparty: '0xFe...009',
          amount: 0.05,
          usdValue: 167.20,
          status: 'pending',
          timestamp: DateTime(2026, 6, 12, 8, 58),
        ),
      ],
      loading: false,
    );
  }

  // Skip the network/Keychain refresh; the seeded state is already populated.
  @override
  Future<void> refresh() async {}
}

class _SeededSessionNotifier extends SessionNotifier {
  _SeededSessionNotifier(super.service) {
    state = const SessionState(
      pending: PendingSession(
        uri: 'wc:demo',
        dappName: 'Uniswap',
        dappUrl: 'https://app.uniswap.org',
      ),
      active: [
        ActiveSession(
          topic: 'topic_demo',
          dappName: 'Aave',
          chains: ['eip155:1', 'eip155:137', 'eip155:8453'],
        ),
      ],
    );
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final overrides = <Override>[
    walletProvider.overrideWith(
      (ref) => _SeededWalletNotifier(
        ref.watch(walletServiceProvider),
        ref.watch(secureVaultProvider),
      ),
    ),
    sessionProvider.overrideWith(
      (ref) => _SeededSessionNotifier(ref.watch(walletConnectServiceProvider)),
    ),
  ];

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7B5CFA),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0B0F1E),
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('capture crypto wallet flow', (tester) async {
    await pump(tester, const WalletScreen());
    await shoot(tester, '01-wallet');

    await pump(tester, const HistoryScreen());
    await shoot(tester, '02-history');

    await pump(tester, const ReceiveScreen());
    await shoot(tester, '03-receive');

    await pump(tester, const DappScreen());
    await shoot(tester, '04-dapp');
  });
}
