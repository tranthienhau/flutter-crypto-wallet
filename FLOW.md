# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (lib-only project) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_crypto_wallet
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "6AB4D32E-B2E8-48FD-9AD1-473E2E4B5899"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - pumps each screen directly inside a `ProviderScope` instead of booting `main()`, so it never touches the Keychain-backed `SecureVault` or `local_auth`. Two provider overrides seed real-looking content:
  - `walletProvider` is overridden with a pre-seeded `WalletNotifier` (multi-chain balances summing to a portfolio total, plus a list of confirmed/pending transactions) whose `refresh()` is a no-op.
  - `sessionProvider` is overridden with a pending WalletConnect pair request and one active dApp session.
- The test pumps `WalletScreen`, `HistoryScreen`, `ReceiveScreen`, and `DappScreen` in turn, calling `binding.convertFlutterSurfaceToImage()` + `binding.takeScreenshot('NN-name')` at each, producing `01-wallet`, `02-history`, `03-receive`, `04-dapp`.
