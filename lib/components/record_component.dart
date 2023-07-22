import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RecordComponent extends StatefulWidget {
  const RecordComponent({Key? key}) : super(key: key);

  @override
  State<RecordComponent> createState() => _RecordComponentState();
}

class _RecordComponentState extends State<RecordComponent> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  String _recordPath = "";
  File? recordFile;
  String pathToAudio = "";
  bool isEnableUpload = false;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  Future initRecorder() async {
    pathToAudio = '/sdcard/DeteksiSemangka/temp.wav';
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final externalStatus = await Permission.manageExternalStorage.request();

    if (microphoneStatus != PermissionStatus.granted &&
        storageStatus != PermissionStatus.granted &&
        externalStatus != PermissionStatus.granted) {
      Fluttertoast.showToast(
        msg: "Please allow the access!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    await recorder.openRecorder();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    final folder = await getTemporaryDirectory();
    final filePath = '${folder.path}/audio.wav';
    pathToAudio = filePath;

    await recorder.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
  }

  Future stop(String email) async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    _recordPath = audioFile.path;
    recordFile = audioFile;

    setState(() {
      isEnableUpload = true;
    });
  }

  Future<void> uploadFileToFirebaseStorage(String email, context) async {
    final uuid = const Uuid().v4();
    final dateTime = DateTime.now().toString();
    final sanitizedDateTime = dateTime.replaceAll(RegExp(r'[:.]'), '');
    final newFileName = '$uuid-$email-$sanitizedDateTime.wav';

    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('audio/$newFileName');

    final file = File(pathToAudio);
    final uploadTask = storageRef.putFile(file);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xffffffff),
          title: Text('Mengupload rekaman'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Harap menunggu file rekaman sedang diupload...'),
                Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff2F80ED),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await uploadTask.whenComplete(() {
      print('File uploaded to Firebase Storage');
      Navigator.pop(context);
      setState(() {
        isEnableUpload = false;
      });

      Fluttertoast.showToast(
        msg: "Upload success!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xffD4E5FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Record Suara Semangka",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              StreamBuilder(
                stream: recorder.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;

                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  final twoDigitMinutes =
                      twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitSeconds =
                      twoDigits(duration.inSeconds.remainder(60));

                  return duration.inSeconds > 0 && auth.getIsUploaded()
                      ? Text(
                          '$twoDigitMinutes:$twoDigitSeconds',
                          style: TextStyle(
                            color: Color(0xff555555),
                          ),
                        )
                      : SizedBox();
                },
              ),
              SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () async {
                  if (recorder.isRecording) {
                    await stop(auth.getUserEmail() ?? "");
                  } else {
                    await record();
                    auth.setIsUpload(true);
                  }

                  setState(() {});
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: recorder.isRecording
                      ? Icon(
                          Icons.stop_circle_rounded,
                          color: Color(0xff2F80ED),
                          size: 60,
                        )
                      : Icon(
                          Icons.play_circle_fill_rounded,
                          color: Color(0xff2F80ED),
                          size: 60,
                        ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                width: 300,
                child: TextButton(
                  onPressed: () async {
                    if (isEnableUpload && auth.getUserEmail() != null) {
                      try {
                        await uploadFileToFirebaseStorage(
                            auth.getUserEmail()!, context);
                        auth.setIsUpload(false);
                      } catch (e) {
                        print('Error uploading file: $e');
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: isEnableUpload
                        ? MaterialStateProperty.all(
                            Color(0xff2F80ED),
                          )
                        : MaterialStateProperty.all(
                            Color(0xffaaaaaa),
                          ),
                    foregroundColor: MaterialStateProperty.all(
                      Color(0xffFFFFFF),
                    ),
                  ),
                  child: Text(
                    "Upload ke Firebase",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
