import 'package:deteksi_semangka/components/record_component.dart';
import 'package:deteksi_semangka/components/record_list.dart';
import 'package:deteksi_semangka/pages/all_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(builder: (context, auth, _) {
        final countElement = auth.getCountElement();
        return SafeArea(
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
                    Container(
                      height: 260,
                      child: FileListScreen(
                        email: auth.getUserEmail()!,
                        isAll: false,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      width: 500,
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllRecord()),
                            );
                          },
                          child: Text("Lihat semua prediksi")),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
              RecordComponent(),
            ],
          ),
        );
      }),
    );
  }
}
