import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
        body: Center(
      child: Container(
        width: 200,
        child: TextButton(
          onPressed: () => {auth.signInWithGoogle()},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Color(0xffF2F2F2),
            ),
            foregroundColor: MaterialStateProperty.all(
              Color(0xff333333),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icon-google.png",
                width: 24,
                height: 24,
              ),
              const SizedBox(
                width: 12,
              ),
              const Text(
                "Login Google",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
