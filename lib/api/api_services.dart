import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService(this.baseUrl, this.apiKey);

  Future<String> fetchData(String endpoint) async {
    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final request = await http.Request(
        'GET', Uri.parse('$baseUrl/$endpoint')
    );

    request.headers.addAll(headers); // Add headers to the request

    final response = await request.send(); // Send the request

    final responseBody = await response.stream.bytesToString();
    return responseBody;
  }

  Future<String> searchByName(String name) async {
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Accept': '*/*',
      "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,api-Key,X-Amz-Security-Token,locale",
      "Access-Control-Allow-Methods": "GET",
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    final request = http.Request(
      'GET', Uri.parse('$baseUrl/search_by_name/$name'),
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
}
