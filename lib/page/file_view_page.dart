import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/custom_appbar.dart';
import '../dialog/ask_dialog.dart';

class FileViewPage extends StatefulWidget {
  const FileViewPage({Key? key, required this.filePath}) : super(key: key);

  final String filePath;

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  bool _isLoading = false;
  File? _selectFile;
  String? _fileName;
  List<String> _readLines = [];

  @override
  void initState() {
    super.initState();

    _fileName = widget.filePath.split("/").last;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isLoading = true;
      if (mounted) {
        setState(() {});
      }

      _selectFile = File(widget.filePath);

      if (_selectFile != null) {
        String temp = await _selectFile!.readAsString();
        debugPrint("temp $temp");

        _readLines = temp.split("\n");
      }

      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: CustomAppBar(
          iconData: Icons.arrow_back,
          title: _fileName!,
          titleFontSize: 15,
          actions: [
            GestureDetector(
              onTap: () async {
                String resultStr = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AskDialog(title: "삭제", contents: "삭제할까요?");
                  },
                  barrierDismissible: false,
                );

                if (resultStr != "YES") {
                  return;
                }

                _selectFile = File(widget.filePath);
                if (_selectFile != null) {
                  await _selectFile?.delete();
                }

                Get.back();
              },
              child: const Icon(
                Icons.delete_outline,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
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
                        itemCount: _readLines.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (_readLines[index].isEmpty) {
                            return Container();
                          }

                          List<String> items = _readLines[index].split(";");
                          String timeStamp = items[0];
                          String valueX = items[1];
                          String valueY = items[2];
                          String valueZ = items[3];

                          return GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              color: (index % 2) == 0 ? const Color(0xFFF2F2F2) : Colors.white,
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        timeStamp,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: widget.filePath.contains("gyroscope")
                                              ? Colors.blueAccent
                                              : widget.filePath.contains("magnet")
                                                  ? Colors.purple
                                                  : widget.filePath.contains("user_")
                                                      ? Colors.teal
                                                      : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        valueX,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF363636),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        valueY,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF363636),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        valueZ,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF363636),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
}
