import 'dart:convert';
import 'package:mesh/src/hash_function.dart';
import 'transaction.dart';

class Block {
  final int index;
  final List<Transaction> transactions;
  DateTime timestamp;
  late String hash;
  String prevHash;
  int nonce;
  bool isValid = true;

  Block(
      this.index, this.transactions, this.prevHash, this.timestamp, this.nonce);

  // Calculate hash of block and set hash
  static Future<String> calculateHash(int index, DateTime timeStamp,
      List<Transaction> transactions, String prevHash, int nonce) async {
    final blockTxData = StringBuffer();
    blockTxData.write('${index.toString()}${timeStamp.toIso8601String()}');
    for (final tx in transactions) {
      blockTxData.write(tx.data);
    }
    blockTxData.write('0');
    final toBeHashed = '${blockTxData.toString()}$prevHash${nonce.toString()}';
    return getHexHashFromUint8List(utf8.encode(toBeHashed));
  }
}
