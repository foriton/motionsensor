import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/input_edit_text_underline.dart';
import '../services/shared_preference.dart';

class OffSetDialog extends StatefulWidget {
  const OffSetDialog({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  State<OffSetDialog> createState() => _OffSetDialogState();

  final String title;
  final String value;
}

class _OffSetDialogState extends State<OffSetDialog> {
  final TextEditingController _offsetEditController = TextEditingController();
  final FocusNode _offsetEditFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _offsetEditController.text = widget.value;
  }

  @override
  void dispose() {
    _offsetEditController.dispose();
    _offsetEditFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 0.5), blurRadius: 0.5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 26),
            Container(
              height: 30,
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            InputEditTextUnderline(
              editingController: _offsetEditController,
              focusNode: _offsetEditFocus,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              title: "offset",
              hintText: "EX)0.01",
              isRequired: false,
              isReadOnly: false,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "취소",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.0,
                            color: Color(0xFF686C73),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (double.tryParse(_offsetEditController.text) == null) {
                          Get.snackbar("입력오류", "정수를 입력하세요");
                          return;
                        }

                        double? value = double.tryParse(_offsetEditController.text);

                        if (widget.title == "accelerometer") {
                          await SharedPreference().saveOffsetAccelerometer(value.toString());
                        } else if (widget.title == "userAccelerometer") {
                          await SharedPreference().saveOffsetUserAccelerometer(value.toString());
                        } else if (widget.title == "gyroscope") {
                          await SharedPreference().saveOffsetGyroscope(value.toString());
                        } else if (widget.title == "magnetometer") {
                          await SharedPreference().saveOffsetMagnetometer(value.toString());
                        } else if (widget.title == "sampling rate") {
                          await SharedPreference().saveSamplingRate(value.toString());
                        }

                        Get.back(result: value.toString());
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC113),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "확인",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
