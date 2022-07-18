import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputEditTextUnderline extends StatelessWidget {
  const InputEditTextUnderline({
    Key? key,
    this.editingController,
    this.focusNode,
    this.title = "",
    this.hintText = "",
    this.onChanged,
    this.validator,
    this.onSubmitted,
    this.isRequired = false,
    this.maxLength,
    this.isReadOnly = false,
    this.isObscureText = false,
    this.padding,
    this.inputType,
    this.isPicture = false,
    this.imagePath = "",
  }) : super(key: key);

  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final String title;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final bool isRequired;
  final bool isObscureText;
  final int? maxLength;
  final bool isReadOnly;
  final EdgeInsetsGeometry? padding;
  final TextInputType? inputType;
  final bool isPicture;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    double screenWidth = Get.width;

    return Container(
      height: 93,
      alignment: Alignment.topLeft,
      padding: padding,
      child: Stack(
        children: [
          Container(
            height: 93,
          ),
          Container(
            height: 18,
            // color: Colors.blue,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 1),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.0,
                            color: Color(0xFF686C73),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isRequired)
                  Column(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF10000),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: isPicture ? 28 : 0,
            child: Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: editingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFFCDD0D3),
                    fontSize: 18.0,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                maxLength: maxLength,
                obscureText: isObscureText,
                onChanged: onChanged,
                validator: validator,
                onFieldSubmitted: onSubmitted,
                readOnly: isReadOnly,
                keyboardType: inputType,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: isReadOnly ? const Color(0xFF898D93) : Colors.black,
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (isPicture)
            Positioned(
              top: 26,
              left: 0,
              child: Image.asset(
                imagePath,
                width: 22,
                height: 22,
              ),
            ),
          Positioned(
            top: 56,
            child: Container(
              height: 1,
              width: screenWidth,
              color: const Color(0xFFE4E7ED),
            ),
          ),
        ],
      ),
    );
  }
}
