import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Entry point of the Flutter application.
// The main() function runs the root widget MyApp.
void main() {
  runApp(const MyApp());
}

// The root widget of our app.
// It sets up the MaterialApp with a title, theme, and the home page.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz News App', // Title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Main color theme of the app
      ),
      home: const NewsHomePage(), // The first screen the user sees
    );
  }
}

// Utilities class for helper functions.
// Here, we provide a static function to download data from the internet.
class Utilities {
  // Static function that downloads data from a given URL.
  // It uses the HTTP GET method and returns the response body as a String.
  static Future<String> download(String url) async {
    final uri = Uri.parse(url); // Parse the string into a URI object
    final resp = await http.get(uri); // Perform an HTTP GET request
    if (resp.statusCode == 200) {
      // If the response is successful (HTTP 200 OK)
      return resp.body; // Return the response body (JSON string)
    } else {
      // If something goes wrong, throw an error with the status code
      throw Exception('Failed to download data: HTTP ${resp.statusCode}');
    }
  }
}

// A model class to represent a News item.
// Each item has an id, title, summary, and details.
class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String details;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
  });

  // Factory constructor to create a NewsItem from JSON data.
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      details: json['details'] ?? '',
    );
  }
}

// The home page widget where the news is displayed.
class NewsHomePage extends StatefulWidget {
  const NewsHomePage({Key? key}) : super(key: key);

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

// State class for NewsHomePage.
// This class fetches news from the internet and displays it.
class _NewsHomePageState extends State<NewsHomePage> {
  // The URL where our JSON news data is hosted.
  final String jsonUrl =
      'https://varanasi-software-junction.github.io/pictures-json/quizjson/news.json';

  // Future that will hold the list of news items after downloading.
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch news when the widget is first created.
    _newsFuture = fetchNews();
  }

  // Function to fetch and parse news from the internet.
  Future<List<NewsItem>> fetchNews() async {
    final body = await Utilities.download(jsonUrl); // Download JSON as string
    final dynamic parsed = json.decode(body); // Decode JSON string into Dart object
    if (parsed is List) {
      // If the parsed JSON is a list, convert each item into a NewsItem
      return parsed.map((e) => NewsItem.fromJson(e)).toList();
    } else {
      // If JSON is not a list, throw an error
      throw Exception('Unexpected JSON format');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'), // Title in the app bar
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture, // The future to wait for (news download)
        builder: (context, snapshot) {
          // While waiting for the data, show a loading spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // If there was an error, show the error message.
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          // If no news data is found, show a message.
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available'));
          }

          // If data is available, display the list of news items.
          final news = snapshot.data!;

          return Column(
            children: [
              // Expanded widget so that the list takes most of the screen.
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: news.length, // Number of news items
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = news[index];
                    return Card(
                      elevation: 3, // Shadow effect for card
                      child: ListTile(
                        title: Text(item.title), // Display news title
                        subtitle: Text(item.summary), // Display summary
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline), // Info button
                          onPressed: () {
                            // Show details in a popup dialog when pressed.
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(item.title), // Title in dialog
                                content: Text(item.details), // Details in dialog
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'), // Close button
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Button at the bottom to go to the Subjects page.
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity, // Button takes full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to SubjectsPage when pressed.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubjectsPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Next: Subjects', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// The Subjects page, displayed after clicking "Next" on the News page.
class SubjectsPage extends StatelessWidget {
  const SubjectsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A simple list of subjects. In a real app, this could also come from JSON.
    final subjects = [
      'Mathematics',
      'Science',
      'History',
      'Geography',
      'Computer Science',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')), // Title for the subjects page
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: subjects.length, // Number of subjects
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(subjects[index]), // Show subject name
              trailing: const Icon(Icons.arrow_forward_ios), // Forward arrow icon
              onTap: () {
                // When a subject is tapped, show a message.
                // In a real app, you would navigate to the quiz page for that subject.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open ${subjects[index]} (not implemented)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
