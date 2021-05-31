import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';

class Wallet {
  String publicKey;
  String privateKey;
  KeyPair keyPair;

  Wallet(this.publicKey, this.privateKey, this.keyPair);

  // Generate wallet keys
  static Future<Wallet> genNewWallet() async {
    final algo = Ed25519();
    final keyPair = await algo.newKeyPair();

    // Extract keys
    final publicKeyBytes = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    // Convert to hex
    final publicKeyHex = HEX.encode(publicKeyBytes.bytes);
    final privateKeyHex = HEX.encode(privateKeyBytes);

    return Wallet(publicKeyHex, privateKeyHex, keyPair);
  }

  // Parse string wallet keys
  static SimpleKeyPairData parseWalletKeys(String pubKey, String pvtKey) {
    final payload = SimpleKeyPairData(HEX.decode(pvtKey),
        type: KeyPairType.ed25519,
        publicKey:
            SimplePublicKey(HEX.decode(pubKey), type: KeyPairType.ed25519));
    return payload;
  }
}
