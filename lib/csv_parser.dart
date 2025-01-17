import 'package:flutter/services.dart' show rootBundle;

class CsvParser {
  final String filePath;

  CsvParser(this.filePath);

  Future<List<List<String>>> loadCsv() async {
    try {
      final String csvData = await rootBundle.loadString(filePath);
      final List<String> lines = csvData.split('\n');
      return lines.map((line) => _parseCsvLine(line.trim())).where((row) => row.isNotEmpty).toList();
    } catch (e) {
      print('Error loading CSV file: $e');
      rethrow;
    }
  }

  List<String> _parseCsvLine(String line) {
    if (line.isEmpty) return [];

    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        inQuotes = !inQuotes;
      } else if (line[i] == ',' && !inQuotes) {
        result.add(currentField.toString().trim());
        currentField.clear();
      } else {
        currentField.write(line[i]);
      }
    }
    result.add(currentField.toString().trim());
    return result;
  }
}