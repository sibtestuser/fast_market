import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userCredentialProvider = NotifierProvider<UserCredentialNotifier, UserCredential?>(UserCredentialNotifier.new);

class UserCredentialNotifier extends Notifier<UserCredential?> {
  @override
  UserCredential? build() {
    // TODO: implement build
    return null;
  }

  void changeState(UserCredential? newState) {
    state = newState;
  }
}
