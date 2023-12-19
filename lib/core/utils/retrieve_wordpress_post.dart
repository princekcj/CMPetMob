import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;


class WordPressPost {
  final String title;
  final String link;
  final String contentSrc;

  WordPressPost({required this.title, required this.link, required this.contentSrc});
}

class PetFact {
  final String fact;
  final String img;

  PetFact({required this.fact, required this.img});
}


Future<List<WordPressPost>> getLatestPosts() async {
  // Replace 'your-wordpress-site.com' with the actual URL of your WordPress site.
  final String wordpressUrl = 'http://cmpet.co.uk/?';

  // Replace '/wp-json/wp/v2/posts' with the route to your posts in the WordPress REST API.
  final String postsRoute = 'rest_route=/wp/v2/posts';

  // Set the number of posts to retrieve.
  final int numberOfPosts = 8;

  // Make the request to the WordPress REST API.
  final response = await http.get(Uri.parse('$wordpressUrl$postsRoute&per_page=$numberOfPosts'));

  print(response.body);

  if (response.statusCode == 200) {
    // Parse the response body.
    final List<dynamic> data = json.decode(response.body);

    // Extract the title, link, and content src for each post.
    List<WordPressPost> posts = [];
    for (var post in data) {
      int id = post['id'];
      String title = post['title']['rendered'];
      String link = post['link'];
      String contentSrc = extractContentSrc(post['content']['rendered']);
      posts.add(WordPressPost(title: title, link: link, contentSrc: contentSrc));
    }

    return posts;
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load posts');
  }
}

String extractContentSrc(String content) {
  // Replace this with your logic to extract the 'src' value from the 'content'.
  // This is just a simple example; you might need to use regular expressions or other methods based on your actual data structure.
  const startTag = 'src="';
  const endTag = '"';
  int startIndex = content.indexOf(startTag);
  int endIndex = content.indexOf(endTag, startIndex + startTag.length);
  return content.substring(startIndex + startTag.length, endIndex);
}

Future<List<PetFact>> fetchData() async {
  final response = await http.get(Uri.parse('https://cmpet.co.uk/?rest_route=/wp/v2/pages&slug=pet-facts'));

  print("re1 is $response");

  var status = response.statusCode;
  var bofu = response.body;

  print("re1 status is $status");
  print("re1 body is $bofu");

  if (response.statusCode == 200) {
    print("made re1 ");

    final dynamic responseData = json.decode(response.body);

    if (responseData is List<dynamic>) {
      final List<PetFact> facts = [];

      for (var item in responseData) {
        final htmlContent = item['content']['rendered'];
        final document = htmlParser.parse(htmlContent);

        // Select the table rows
        final tableRows = document.querySelectorAll('tr');

        for (var row in tableRows) {
          final cells = row.children;

          // Ensure the row has three cells
          if (cells.length == 3) {
            // Extract fact number, fact text, and image source
            final factText = cells[1].text.trim();
            final imgSrc = cells[2].querySelector('img')?.attributes['src'] ?? '';

            // Create a PetFact object
            facts.add(PetFact(fact: '$factText', img: imgSrc));
          }
        }
      }

      print("fats is $facts");
      return facts;
    } else {
      throw Exception('Invalid response format');
    }
  } else {
    throw Exception('Failed to load pet facts');
  }
}


Future<List<PetFact>> getPetFacts() async {
  try {
    return await fetchData();
  } catch (e) {
    print('Error fetching pet facts: $e');
    return [];
  }
}

