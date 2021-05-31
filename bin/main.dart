import 'dart:async';
import 'package:mesh/src/blockchain.dart';
import 'package:mesh/src/wallet.dart';

Future<void> main() async {
  final blockchain = BlockChain();
  final myWallet = await Wallet.genNewWallet();
  final ehWallet = await Wallet.genNewWallet();

  await blockchain.createTransaction(100, myWallet.publicKey,
      myWallet.privateKey, ehWallet.publicKey, '1st tx');

  final block = await blockchain.mineBlock();
  print('Mined block\'s hash: ${block?.hash}');
}
