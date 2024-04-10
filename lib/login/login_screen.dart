import 'package:fast_market/login/provider/login_provider.dart';
import 'package:fast_market/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(credential);
      // userCredential = credential;
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(e.toString());
      } else if (e.code == 'wrong-password') {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
      return null;
    }

    // return googleUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/fastcampus_logo.png'),
                const Text(
                  '패캠마트',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 42),
                ),
                const SizedBox(
                  height: 38,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          isDense: true,
                          labelText: '이메일',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일 주소를 입력하세요';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: pwdTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          isDense: true,
                          labelText: '비밀번호',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력하세요';
                          }
                          return null;
                        },
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 38.0),
                        child: Consumer(builder: (context, ref, child) {
                          return MaterialButton(
                            height: 48,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.red,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final result =
                                    await signIn(emailTextController.text.trim(), pwdTextController.text.trim());

                                if (result == null && context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text('로그인에 실패했습니다')));
                                  return;
                                }
                                //로그인 성공
                                ref.read(userCredentialProvider.notifier).changeState(result);
                                if (context.mounted) context.go('/');
                              }
                            },
                            child: const Text(
                              '로그인',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/sign_up');
                        },
                        child: Text(
                          '계정이 없나요? 회원가입',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Divider(),
                      InkWell(
                        onTap: () async {
                          final userCredit = await signInWithGoogle();
                          if (userCredit == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패')));
                            return;
                          }
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        child: Image.asset('assets/images/btn_google_signin.png'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
