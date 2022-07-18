import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/input_edit_text_underline.dart';

class EmailDialog extends StatefulWidget {
  const EmailDialog({Key? key, required this.email}) : super(key: key);

  final String? email;

  @override
  State<EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  final TextEditingController _emailEditController = TextEditingController();
  final FocusNode _emailEditFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.email != null && widget.email!.isNotEmpty) {
      _emailEditController.text = "";
    }
  }

  @override
  void dispose() {
    _emailEditController.dispose();
    _emailEditFocus.dispose();

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
              child: const Text(
                "수신자",
                style: TextStyle(
                  fontSize: 22,
                  height: 1.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            InputEditTextUnderline(
              editingController: _emailEditController,
              focusNode: _emailEditFocus,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              title: "email",
              hintText: "수신받을 이메일을 입력하세요",
              isRequired: false,
              isReadOnly: false,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back(result: "");
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
                        if (_emailEditController.text.isEmpty) {
                          Get.snackbar("입력오류", "수신 받을 이메일을 입력하세요",
                              snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));
                          return;
                        }

                        String email = _emailEditController.text;
                        bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email);

                        if (!emailValid) {
                          Get.snackbar("입력오류", "이메일 형식이 올바르지 않습니다.",
                              snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));
                          _emailEditFocus.requestFocus();
                          return;
                        }

                        Get.back(result: _emailEditController.text);
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
