import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService(this.baseUrl, this.apiKey);

  Future<String> fetchData(String endpoint) async {
    final cachedData = await getCachedData(endpoint);

    if (cachedData != null && !isDataStale(cachedData)) {
      // Return cached data if available and not stale
      return cachedData['data'];
    }

    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final request = await http.Request('GET', Uri.parse('$baseUrl/$endpoint'));
    request.headers.addAll(headers);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // Cache the fetched data
    await cacheData(endpoint, responseBody);

    return responseBody;
  }

  Future<String> searchByName(String name) async {
    final cachedData = await getCachedData('search_by_name/$name');

    if (cachedData != null && !isDataStale(cachedData)) {
      return cachedData['data'];
    }

    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Accept': '*/*',
      "Access-Control-Allow-Headers":
      "Origin,Content-Type,X-Amz-Date,Authorization,api-Key,X-Amz-Security-Token,locale",
      "Access-Control-Allow-Methods": "GET",
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final request =
    http.Request('GET', Uri.parse('$baseUrl/search_by_name/$name'));
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      await cacheData('search_by_name/$name', responseBody);
      return responseBody;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to fetch data');
    }
  }

  Future<Map<String, dynamic>?> getCachedData(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDataString = prefs.getString(cacheKey);

    if (cachedDataString != null) {
      try {
        return json.decode(cachedDataString);
      } catch (e) {
        print('Error decoding cached data: $e');
      }
    }

    return null;
  }

  Future<String> searchByNames(List<String> names) async {
    try {
      final headers = {
        "Access-Control-Allow-Origin": "*",
        'Accept': '*/*',
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "GET",
        'Content-Type': 'application/json',
        'api-key': apiKey,
      };

      // Combine multiple names into a comma-separated string
      final namesString = names.join(',');

      final request = http.Request(
        'GET', Uri.parse('$baseUrl/search_by_names/$namesString'),
      );
      request.headers.addAll(headers); // Add headers to the request

      final response = await request.send(); // Send the request

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return responseBody;
      } else {
        print(response.reasonPhrase);
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print("Error searching by names: $error");
      throw error; // Rethrow the error to handle it in the calling code
    }
  }


  Future<String> getDataByPet(String pet) async {
    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final request = await http.Request(
      'GET', Uri.parse('$baseUrl/get_data/$pet'),
    );

    request.headers.addAll(headers); // Add headers to the request

    final response = await request.send(); // Send the request

    final responseBody = await response.stream.bytesToString();
    return responseBody;

  }


  Future<void> cacheData(String cacheKey, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    prefs.setString(cacheKey, json.encode(cachedData));
  }

  bool isDataStale(Map<String, dynamic> cachedData) {
    final timestamp = DateTime.parse(cachedData['timestamp']);
    final currentTime = DateTime.now();
    final difference = currentTime.difference(timestamp);

    return difference.inHours > 24;
  }
}
