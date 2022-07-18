import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:get/get.dart';
import 'package:motionsensor/dialog/email_dialog.dart';
import 'package:path_provider/path_provider.dart';

import '../components/custom_appbar.dart';
import '../components/text_title.dart';
import '../dialog/ask_dialog.dart';
import 'file_view_page.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({Key? key}) : super(key: key);

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  bool _isLoading = false;
  String _directoryPath = "";
  List<FileSystemEntity> _fileList = [];
  String? _email = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadFileList();
    });
  }

  Future loadFileList() async {
    dynamic directory;

    _isLoading = true;

    if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    _fileList = directory.listSync();
    _fileList.sort((itemA, itemB) {
      return itemA.path.compareTo(itemB.path);
    });

    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: CustomAppBar(
          iconData: Icons.arrow_back,
          title: "saved files",
          actions: [
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                if (_fileList.isEmpty) {
                  return;
                }

                String resultStr = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AskDialog(title: "전체 삭제", contents: "모든 파일을 삭제합니다. 삭제할까요?");
                  },
                  barrierDismissible: false,
                );

                if (resultStr != "YES") {
                  return;
                }

                for (int i = 0; i < _fileList.length; i++) {
                  File? file = File(_fileList[i].path);
                  if (file != null) {
                    await file.delete();
                  }
                }

                Get.back();
              },
              child: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 25),
            GestureDetector(
              onTap: () async {
                _email = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EmailDialog(email: _email);
                  },
                  barrierDismissible: false,
                );

                if (_email != null && _email!.isNotEmpty) {
                  await sendEMail();
                }

                // Get.back();
              },
              child: const Icon(
                Icons.send_and_archive,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: _isLoading
              ? Container()
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _fileList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String filePath = _fileList[index].path;
                          String fileName = filePath.split("/").last;

                          return GestureDetector(
                            onTap: () async {
                              await Get.to(() => FileViewPage(filePath: filePath));
                              await loadFileList();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              color: (index % 2) == 0 ? const Color(0xFFF2F2F2) : Colors.white,
                              child: TextTitle(
                                titleText: fileName,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontColor: fileName.contains("gyroscope")
                                    ? Colors.blueAccent
                                    : fileName.contains("magnet")
                                        ? Colors.purple
                                        : fileName.contains("user")
                                            ? Colors.teal
                                            : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> sendEMail() async {
    if (_email == null || _email!.isEmpty) {
      debugPrint("sendEMail() _email is Empty");
      return;
    }

    if (_fileList.isEmpty) {
      debugPrint("sendEMail() _fileList is Empty");
      return;
    }

    if (Platform.isIOS) {
      final bool canSend = await FlutterMailer.canSendMail();
      if (!canSend) {
        debugPrint("sendEMail() No Email App");
        Get.snackbar("이메일 발신 불가", "iOS 메일앱 설정이 필요합니다.",
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));
        return;
      }
    }

    List<String> attachment = [];

    for (int i = 0; i < _fileList.length; i++) {
      attachment.add(_fileList[i].path);
    }

    final MailOptions mailOptions = MailOptions(
      body: "Sensor 측정 데이터 입니다.",
      subject: "Sensor 측정 데이터",
      recipients: <String>[_email!],
      isHTML: true,
      attachments: attachment,
    );

    String platformResponse;

    debugPrint("sendEMail() try SendMail");

    try {
      final MailerResponse response = await FlutterMailer.send(mailOptions);
      switch (response) {
        case MailerResponse.saved:
          platformResponse = '메일이 저장되었습니다.';
          break;
        case MailerResponse.sent:
          platformResponse = '메일이 발송되었습니다.';
          break;
        case MailerResponse.cancelled:
          platformResponse = '메일 전송이 실패하였습니다.';
          break;
        case MailerResponse.android:
          platformResponse = '메일을 발송하였습니다.';
          break;
        default:
          platformResponse = 'unknown';
          break;
      }
    } on PlatformException catch (error) {
      platformResponse = error.toString();
      debugPrint("sendEMail() exception");
      debugPrint('$error');

      if (!mounted) {
        debugPrint("sendEMail() !mounted");
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Message',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(error.message ?? 'unknown error'),
            ],
          ),
          contentPadding: const EdgeInsets.all(26),
          title: Text(error.code),
        ),
      );
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));

    Get.snackbar("이메일 발신", platformResponse,
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));
  }
}
