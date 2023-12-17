import 'package:cmpets/api/api_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ApiService Tests', () {
    // Create an instance of your ApiService with the base URL and API key
    final apiService = ApiService('http://localhost:8000', 'your_api_key_1');

    test('Test fetchData', () async {
      final response = await apiService.fetchData('get_data');
      expect(response.statusCode, 200); // Replace with the expected status code
      // Add more assertions based on the response content if needed
    });

    test('Test searchByName', () async {
      final name = 'Chocolate'; // Replace with a valid test name
      final result = await apiService.searchByName(name);
      // Add assertions based on the expected result
      expect(result, contains('toxic')); // Replace with expected data
    });

    test('Test getDataByPet', () async {
      final pet = 'dog'; // Replace with a valid test pet
      final response = await apiService.getDataByPet(pet);
      expect(response.statusCode, 200); // Replace with the expected status code
      // Add more assertions based on the response content if needed
    });
  });
}
