import 'package:deteksi_semangka/components/record_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';

class FileListScreen extends StatefulWidget {
  final String email;
  final bool isAll;

  FileListScreen({required this.email, required this.isAll});

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> triggerFetchFiles() async {
    await _fetchFiles();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshData() async {
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        setState(() {});
      },
      child: FutureBuilder<List<RecordCard>>(
        future: _fetchFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          var recordCards = snapshot.data;
          auth.setCount(recordCards!.length);

          if (!widget.isAll) {
            recordCards = recordCards.take(3).toList();
          }

          return ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemCount: recordCards!.length,
            itemBuilder: (context, index) {
              return recordCards?[index];
            },
          );
        },
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat("d MMMM y (HH.mm)");
    return formatter.format(dateTime);
  }

  Future<List<RecordCard>> _fetchFiles() async {
    try {
      final ListResult audioResult =
          await _storage.ref().child('audio').listAll();
      final ListResult textResult =
          await _storage.ref().child('text').listAll();
      List<RecordCard> recordCards = [];

      for (var audioFile in audioResult.items) {
        final audioFileName = audioFile.name;
        final audioFileUrl = await audioFile.getDownloadURL();

        // Check if the file is in WAV format and matches the user's email
        if (audioFileName.endsWith('.wav') &&
            audioFileName.contains(widget.email)) {
          String? txtContent;
          String? kualitas;
          String? akurasi;
          String? prediksi;
          String timeCreated = "";
          bool isWaiting = false;
          final metadata = await audioFile.getMetadata();

          DateTime dateTime =
              DateTime.parse(metadata.timeCreated!.toLocal().toString());
          String formattedDate = formatDate(dateTime);
          timeCreated = formattedDate;

          var txtFile = textResult.items.firstWhere(
            (textFile) =>
                textFile.name == audioFileName.replaceAll('.wav', '.txt'),
            orElse: () => _storage.ref().child('text/empty.txt'),
          );

          if (txtFile.name != "empty.txt") {
            final txtFileUrl = await txtFile.getDownloadURL();

            final response = await http.get(Uri.parse(txtFileUrl));
            if (response.statusCode == 200) {
              txtContent = response.body;
              final lines = txtContent.split('\n');
              for (var line in lines) {
                if (line.startsWith('kualitas:')) {
                  kualitas = line.split(':')[1];
                } else if (line.startsWith('akurasi:')) {
                  akurasi = line.split(':')[1];
                } else if (line.startsWith('prediksi:')) {
                  prediksi = line.split(':')[1];
                }
              }
            }
          } else {
            isWaiting = true;
          }

          recordCards.add(RecordCard(
            file: audioFile,
            url: audioFileUrl,
            kualitas: kualitas,
            akurasi: akurasi,
            prediksi: prediksi,
            isWaiting: isWaiting,
            timeCreated: timeCreated,
          ));
        }
      }
      recordCards.sort((a, b) => b.timeCreated!.compareTo(a.timeCreated!));

      return recordCards;
    } catch (e) {
      // Handle error if any
      print('Error fetching files: $e');
      return [];
    }
  }
}
