import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../components/record_list.dart';

class AllRecord extends StatelessWidget {
  const AllRecord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SafeArea(
          child: Container(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hasil Prediksi",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Berikut merupakan hasil prediksi dari suara semangka yang telah direkam sebelumnya",
                        style: TextStyle(
                          color: Color(0xff696969),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Flexible(
                          child: FileListScreen(
                        email: auth.getUserEmail()!,
                        isAll: true,
                      )),
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
