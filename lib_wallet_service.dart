import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Server-authoritative wallet foundation. Never write wallet balances directly
/// from the Flutter client; Firestore rules intentionally reject client writes.
class WalletService {
  WalletService({FirebaseAuth? auth, FirebaseFirestore? firestore,
    FirebaseFunctions? functions})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not signed in.');
    return uid;
  }

  Stream<int> watchCcBalance() => _firestore
      .collection('wallets').doc(_uid).snapshots()
      .map((doc) => (doc.data()?['ccBalance'] as num?)?.toInt() ?? 0);

  Future<int> initialize() async {
    final result = await _functions.httpsCallable('initializeWallet').call();
    return (result.data['ccBalance'] as num).toInt();
  }

  Future<int> claimDailyBonus() async {
    final result = await _functions.httpsCallable('claimDailyBonus').call();
    return (result.data['ccBalance'] as num).toInt();
  }
}
