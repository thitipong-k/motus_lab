import 'dart:io';
import 'dart:convert';

void main() async {
  final httpClient = HttpClient();

  final fonts = {
    'Sarabun-Regular.ttf':
        'https://github.com/google/fonts/raw/main/ofl/sarabun/Sarabun-Regular.ttf',
    'Sarabun-Bold.ttf':
        'https://github.com/google/fonts/raw/main/ofl/sarabun/Sarabun-Bold.ttf',
  };

  for (var entry in fonts.entries) {
    print('Downloading ${entry.key}...');
    final request = await httpClient.getUrl(Uri.parse(entry.value));
    final response = await request.close();
    if (response.statusCode == 200) {
      final file = File('assets/fonts/${entry.key}');
      await response.pipe(file.openWrite());
      print('Saved ${entry.key}');
    } else {
      print('Failed to download ${entry.key}: ${response.statusCode}');
    }
  }
  httpClient.close();
}
