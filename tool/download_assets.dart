import 'dart:io';

void main() async {
  final webDir = Directory('web');
  if (!webDir.existsSync()) {
    webDir.createSync();
    print('Created web directory');
  }

  await downloadFile(
      'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.3.0/sqlite3.wasm',
      'web/sqlite3.wasm');
  await downloadFile(
      'https://github.com/simolus3/drift/releases/latest/download/drift_worker.js',
      'web/drift_worker.js');
}

Future<void> downloadFile(String url, String path) async {
  print('Downloading $url to $path...');
  final client = HttpClient();
  var uri = Uri.parse(url);
  var request = await client.getUrl(uri);
  var response = await request.close();

  // Handle redirects manually if needed, though HttpClient handles them by default up to 5
  // GitHub returns 302 Found
  if (response.statusCode == 302 || response.statusCode == 301) {
    final location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      print('Redirecting to $location');
      uri = Uri.parse(location);
      request = await client.getUrl(uri);
      response = await request.close();
    }
  }

  if (response.statusCode == 200) {
    final file = File(path);
    await response.pipe(file.openWrite());
    print('Downloaded $path');
  } else {
    print('Failed to download $url: ${response.statusCode}');
    // Read body to see error
    await response.transform(SystemEncoding().decoder).forEach(print);
  }
}
