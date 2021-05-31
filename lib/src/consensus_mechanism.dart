import 'dart:convert';

import 'package:mesh/src/block.dart';
import 'package:mesh/src/hash_function.dart';

// Proof of work implementation
Future<ProofOfWorkData?> proofOfWork(Block block) async {
  var nonce = 0;
  var check = true;
  // Get block's data into a string
  final blockData = StringBuffer();
  blockData
      .write('${block.index.toString()}${block.timestamp.toIso8601String()}');
  for (final tx in block.transactions) {
    blockData.write(tx.data);
  }
  // Why is this here ?. To match how the block is hashed in the Block object
  blockData.write(block.nonce.toString());
  while (check) {
    final tryHash = await getHexHashFromUint8List(
        utf8.encode('${blockData.toString()}${block.prevHash}$nonce'));
    if (tryHash.substring(0, 4) == '0000') {
      check = false;
      return ProofOfWorkData(nonce, block.timestamp);
    }
    nonce += 1;
  }
  return null;
}

class ProofOfWorkData {
  int nonce;
  DateTime timestamp;

  ProofOfWorkData(this.nonce, this.timestamp);
}
