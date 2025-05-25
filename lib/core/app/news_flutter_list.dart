import 'package:flutter/material.dart';
import 'package:news_flutter_list.dart/main.dart';

class NewsFlutterList extends StatelessWidget {
  const NewsFlutterList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}