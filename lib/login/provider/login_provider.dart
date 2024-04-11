import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StreamProvider((ref) {
  // return FirebaseAuth.instance.authStateChanges().listen((event) {
  //   ref.read(userCredentialProvider.notifier).changeState(event);
  // });
  return FirebaseAuth.instance.authStateChanges();
});

final userCredentialProvider = NotifierProvider<UserCredentialNotifier, User?>(UserCredentialNotifier.new);

class UserCredentialNotifier extends Notifier<User?> {
  @override
  User? build() {
    // TODO: implement build
    return null;
  }

  void changeState(User? newState) {
    state = newState;
  }
}

// final currentUserProvider = StreamProvider((ref) {
//   final auth = ref.watch(userCredentialProvider);
// });

