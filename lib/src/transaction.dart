import 'dart:convert';
import 'package:mesh/src/hash_function.dart';

// Transaction object

class Transaction {
  int amount;
  String sender;
  String receiver;
  String message;
  late DateTime timestamp;
  late String hash;
  late String signature;
  late String data; // sum of all other properties

  Transaction(this.amount, this.sender, this.receiver, this.message) {
    timestamp = DateTime.now().toUtc();
  }

  // Hash the transaction
  Future<void> calcHash() async {
    final toBeHashed = '''${amount.toString()}$sender$receiver$message
        ${timestamp.toIso8601String()}''';
    // set tx data (for ease of use when verifying transactions)
    data = toBeHashed;
    hash = await getHexHashFromUint8List(utf8.encode(toBeHashed));
  }
}
