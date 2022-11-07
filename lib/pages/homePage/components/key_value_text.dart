import 'package:flutter/material.dart';

class KeyValueText extends StatelessWidget {
  const KeyValueText({
    super.key,
    required this.textKey,
    required this.textValue,
  });

  final String textKey;
  final String? textValue;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$textKey: ',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: textValue ?? 'null',
            style: TextStyle(fontWeight: FontWeight.normal),
          )
        ]
      )
    );
  }
}