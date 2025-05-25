import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_flutter_list.dart/core/constants/url.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      home: const HomePage(),
    );
  }
}

class News {
  final String title;
  final String description;

  News({required this.title, required this.description});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<News>> newsStream;
  late StreamSubscription<List<News>> subscription;

  @override
  void initState() {
    super.initState();
    newsStream = fetchNewsPeriodically();
  }

  Stream<List<News>> fetchNewsPeriodically() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      try {
        final response = await http.get(
          Uri.parse(url),
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final articles = jsonData['articles'] as List;
          final newsList = articles.map((item) => News.fromJson(item)).toList();
          yield newsList;
        } else {
          throw Exception('Failed to load news: ${response.statusCode}');
        }
      } catch (e) {
        yield* Stream.error(e);
      }
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter News List'),
      ),
      body: StreamBuilder<List<News>>(
        stream: newsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return ListTile(
                title: Text(news.title),
                subtitle: Text(news.description),
              );
            },
          );
        },
      ),
    );
  }
}