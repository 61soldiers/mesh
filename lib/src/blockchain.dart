import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
import 'package:mesh/src/block.dart';
import 'package:mesh/src/consensus_mechanism.dart';
import 'package:mesh/src/transaction.dart';
import 'package:mesh/src/wallet.dart';

class BlockChain {
  // The Blockchain
  static List<Block> blockchain = [];
  // Contains unverified transactions
  static List<Transaction> pendingTransactions = [];
  int blockTime = 100; // Block time in milliseconds
  int difficulty = 4;

  BlockChain() {
    createGenesis();
  }

  // Create genesis block
  void createGenesis() {
    final genesisBlock = Block(0, [], '0', DateTime.now().toUtc(), 69);
    genesisBlock.hash = '67656e65736973';
    blockchain.add(genesisBlock);
  }

  // Get last block
  Block lastBlock() {
    return blockchain[blockchain.length - 1];
  }

  // Generate block mining difficulty string
  String genDifficultyString() {
    final dfString = StringBuffer();
    for (var i = 0; i < difficulty; i++) {
      dfString.write('0');
    }
    return dfString.toString();
  }

  // Add block to blockchain
  Future<Block> addBlock(int index, List<Transaction> transactions,
      String prevHash, DateTime timestamp, int nonce) async {
    final block = Block(index, transactions, prevHash, timestamp, nonce);
    block.hash = await Block.calculateHash(block.index, block.timestamp,
        block.transactions, block.prevHash, block.nonce);
    // verify transactions
    final algo = Ed25519();
    for (final tx in block.transactions) {
      final senderPublicKey =
          SimplePublicKey(HEX.decode(tx.sender), type: KeyPairType.ed25519);
      final txSignature =
          Signature(HEX.decode(tx.signature), publicKey: senderPublicKey);
      final isTxValid =
          await algo.verify(utf8.encode(tx.data), signature: txSignature);
      if (!isTxValid) {
        // TODO: Add callback if tx not valid
      }
    }
    // add
    blockchain.add(block);
    return block;
  }

  // Checks if blockchain is valid
  Future<bool> isChainValid() async {
    for (var i = 1; i < blockchain.length; i++) {
      final currentBlock = blockchain[i];
      final prevBlock = blockchain[i - 1];
      // check hash
      final prevBlockHash = await Block.calculateHash(
          prevBlock.index,
          prevBlock.timestamp,
          prevBlock.transactions,
          prevBlock.prevHash,
          prevBlock.nonce);
      if (currentBlock.prevHash != prevBlockHash) {
        return false;
      }
    }
    return true;
  }

  // Create a transaction
  Future<void> createTransaction(int amt, String senderPublicKey,
      String senderPrivateKey, String receiver, String msg) async {
    // TODO: check wallet balance
    final transaction = Transaction(amt, senderPublicKey, receiver, msg);
    await transaction.calcHash();
    final algo = Ed25519();
    final signature = await algo.sign(utf8.encode(transaction.data),
        keyPair: Wallet.parseWalletKeys(senderPublicKey, senderPrivateKey));
    transaction.signature = HEX.encode(signature.bytes);
    pendingTransactions.add(transaction);
  }

  // Mine a block using POW algorithm
  Future<Block?> mineBlock() async {
    final prevBlock = lastBlock();
    final newBlockData = await proofOfWork(Block(prevBlock.index + 1,
        pendingTransactions, prevBlock.hash, DateTime.now().toUtc(), 0));
    if (newBlockData != null) {
      print('Block mined!');
      return addBlock(prevBlock.index + 1, pendingTransactions, prevBlock.hash,
          newBlockData.timestamp, newBlockData.nonce);
    } else {
      return null;
    }
  }
}
