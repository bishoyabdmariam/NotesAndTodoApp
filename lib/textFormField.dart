import 'package:flutter/material.dart';

class textformfield extends StatelessWidget {
  const textformfield({
    super.key,
    required this.controller,
    required this.formKey,
    required this.validation,
    required this.hintText,
    required this.maxLines,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String? Function(String?)? validation;
  final String hintText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validation,
      textInputAction: TextInputAction.done,
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.transparent,
        hintStyle: const TextStyle(color: Colors.black12),
      ),
      cursorColor: Colors.black,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Joypixels',
      ),
      maxLines: maxLines,
    );
  }
}
