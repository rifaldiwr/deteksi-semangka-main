import 'package:deteksi_semangka/auth_provider.dart';
import 'package:deteksi_semangka/pages/auth_page.dart';
import 'package:deteksi_semangka/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../utils/constant/api_constant.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    // User? user = auth.getUser();
    // String? email = user != null ? user.email : "";

    return StreamBuilder<User?>(
      stream: auth.changeState(),
      builder: (context, snapshotStream) {
        // print(snapshotStream.data);
        if (snapshotStream.connectionState == ConnectionState.active) {
          return (snapshotStream.data != null) ? MainPage() : AuthPage();
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff2F80ED),
            ),
          );
        }
      },
    );
  }
}
