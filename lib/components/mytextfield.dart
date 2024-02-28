// ignore_for_file: prefer_const_constructors, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class mytextfield extends StatelessWidget {
  final Controller;
  final String hinttext;
  final bool obscureText;
  final keyboardtype;
  final prefix;

  const mytextfield({
    super.key,
    required this.Controller,
    required this.hinttext,
    required this.obscureText,
    required this.keyboardtype,
    required this.prefix,
    //required Null Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: TextField(
        
        controller: Controller,
        style: TextStyle(color: Colors.white),
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: prefix,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(133, 127, 247, 1)),
            ),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            fillColor: Colors.white10,
            filled: true,
            hintText: hinttext,
            hintStyle: TextStyle(color: Color.fromARGB(255, 122, 122, 122))),
      ),
    );
  }
}
