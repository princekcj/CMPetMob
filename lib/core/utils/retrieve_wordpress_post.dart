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
      // If the response is a list, you need to handle it accordingly
      final List<PetFact> facts = [];

      for (var item in responseData) {
        print('Item: $item');
        print('Item type: ${item.runtimeType}');
        print('Content: ${item['content']}');
        print('Content type: ${item['content'].runtimeType}');

        // Parse HTML content
        final htmlContent = item['content']['rendered'];
        final document = htmlParser.parse(htmlContent);
        final htmlExContent = item['excerpt']['rendered'];
        final document_2 = htmlParser.parse(htmlExContent);
        final factElement = document_2.querySelector('p'); // Change this based on the HTML structure
        final imgElement = document.querySelector('img'); // Change this based on the HTML structure

        // Extract text and image information
        final fact = factElement?.text ?? '';

        // Extract only the src attribute from the img tag
        final imgSrc = imgElement?.attributes['src'] ?? '';

        print("factsc id $fact");
        print("imgsc id $imgSrc");

        // Split the fact into individual facts at '?' and '!'
        final List<String> individualFacts = fact.split(RegExp(r'[?!]'));

        // Create a PetFact object for each individual fact
        for (var individualFact in individualFacts) {
          print('Individual Fact: $individualFact');
          facts.add(PetFact(fact: individualFact.trim(), img: imgSrc));
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

