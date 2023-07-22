import 'dart:io';
import 'package:intl/intl.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';

class RecordCard extends StatefulWidget {
  const RecordCard(
      {Key? key,
      required this.file,
      required this.url,
      required this.kualitas,
      required this.akurasi,
      required this.isWaiting,
      required this.timeCreated,
      this.prediksi})
      : super(key: key);

  final Reference file;
  final String url;
  final String? kualitas;
  final String? akurasi;
  final String? prediksi;
  final String? timeCreated;
  final bool isWaiting;

  @override
  _RecordCardState createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  final recordingPlayer = AssetsAudioPlayer();
  bool _playAudio = false;
  String uploadedDate = "";

  @override
  void initState() {
    super.initState();
    recordingPlayer.playlistAudioFinished.listen((finishedEvent) {
      setState(() {
        _playAudio = false;
      });
    });

    fetchUploadDate();
  }

  Future<void> fetchUploadDate() async {
    try {
      final metadata = await widget.file.getMetadata();
      setState(() {
        DateTime dateTime =
            DateTime.parse(metadata.timeCreated!.toLocal().toString());
        String formattedDate = formatDate(dateTime);
        uploadedDate = formattedDate;
      });
    } catch (e) {
      print('Error fetching upload date: $e');
    }
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(widget.url),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat("d MMMM y (HH.mm)");
    return formatter.format(dateTime);
  }

  @override
  void dispose() {
    recordingPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Diupload: $uploadedDate",
                style: TextStyle(
                  color: Color(0xff696969),
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              widget.isWaiting
                  ? Text(
                      "Menunggu hasil prediksi..",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      widget.kualitas ?? "",
                      style: TextStyle(
                        color: Color(0xff2F80ED),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              !widget.isWaiting
                  ? Row(
                      children: [
                        Text(
                          "Prediksi: ${widget.prediksi ?? ""}",
                          style: TextStyle(
                            color: Color(0xff1E1E1E),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        Text(
                          "Akurasi: ${widget.prediksi ?? ""}",
                          style: TextStyle(
                            color: Color(0xff1E1E1E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                _playAudio = !_playAudio;
              });

              if (_playAudio) playFunc();
              if (!_playAudio) stopPlayFunc();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: _playAudio
                  ? Icon(
                      Icons.pause_circle_filled_rounded,
                      color: Color(0xff2F80ED),
                      size: 36,
                    )
                  : Icon(
                      Icons.play_circle_fill_rounded,
                      color: Color(0xff2F80ED),
                      size: 36,
                    ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(0xffF2F2F2),
      ),
    );
  }
}
