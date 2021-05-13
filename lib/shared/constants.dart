import 'package:flutter/material.dart';

InputDecoration textInputDecoration = InputDecoration(
    enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)));
String format(String string) {
  if (string.contains(' ')) {
    while (string.contains('  ')) {
      string = string.replaceAll('  ', ' ');
    }
    if (string.startsWith(' ')) {
      string = string.substring(1);
    }
    if (string.endsWith(' ')) {
      string = string.substring(0, string.length - 1);
    }
    String formatted = '';
    List<String> vec = string.split(' ');
    vec.forEach((v) {
      formatted = formatted +
          ' ' +
          v.substring(0, 1).toUpperCase() +
          v.substring(1, v.length).toLowerCase();
    });
    return formatted.substring(1);
  } else {
    return string.substring(0, 1).toUpperCase() +
        string.substring(1, string.length).toLowerCase();
  }
}
