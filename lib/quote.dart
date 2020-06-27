import 'package:flutter/material.dart';

class Quote {
  final String quote;
  final String author;
  final String cat;

  Quote({this.quote, this.author, this.cat});

  factory Quote.fromJson(Map<String, dynamic> json){
    return Quote(
      quote: json['quote'],
      author: json['author'],
      cat: json['cat'],
    );
  }
}