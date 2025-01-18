import 'package:flutter/services.dart' show rootBundle;

class CsvParseError extends Error {
  final String message;
  final int lineNumber;
  CsvParseError(this.message, this.lineNumber);
  
  @override
  String toString() => 'CsvParseError: $message (Line: $lineNumber)';
}

class CsvParser {
  final String filePath;

  CsvParser(this.filePath);

  Future<List<List<String>>> loadCsv() async {
    try {
      final String csvData = await rootBundle.loadString(filePath);
      final List<String> lines = csvData.split('\n');
      
      List<List<String>> result = [];
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        try {
          final row = _parseCsvLine(line);
          if (row.isNotEmpty) {
            result.add(row);
          }
        } catch (e) {
          throw CsvParseError('Error parsing line: $e', i + 1);
        }
      }
      
      if (result.isEmpty) {
        throw CsvParseError('CSV file is empty or contains no valid rows', 0);
      }
      
      return result;
    } catch (e) {
      if (e is CsvParseError) rethrow;
      print('Error loading CSV file: $e');
      rethrow;
    }
  }

  List<String> _parseCsvLine(String line) {
    if (line.isEmpty) return [];

    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();
    bool fieldStarted = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (!fieldStarted) {
          fieldStarted = true;
        } else if (i + 1 < line.length && line[i + 1] == '"') {
          // Handle escaped quotes
          currentField.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.toString().trim());
        currentField.clear();
        fieldStarted = false;
      } else {
        fieldStarted = true;
        currentField.write(char);
      }
    }

    if (inQuotes) {
      throw FormatException('Unterminated quote in CSV line');
    }

    result.add(currentField.toString().trim());
    return result;
  }
}