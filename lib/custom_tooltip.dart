import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomToolTip extends StatelessWidget {

  String text;

  CustomToolTip({this.text});

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Tooltip(preferBelow: false,
          message: "Copy",
          child: new Text(text, style: TextStyle(fontSize: 20.0)),
      ),
          onTap: () {
            Clipboard.setData(new ClipboardData(text: text));
            Scaffold.of(context).showSnackBar(
                new SnackBar(content: Text('Copied to Clipboard'))
            );
          },
    );
  }
}