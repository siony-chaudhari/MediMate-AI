import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OCRService {
  static const String _tesseractDataPath = 'assets/tessdata';
  
  // Medicine name patterns
  static const List<String> _medicinePatterns = [
    r'\b(?:tablet|pill|capsule|syrup|injection|cream|ointment|gel|drops|spray)\b',
    r'\b(?:mg|mcg|g|ml|IU|units)\b',
    r'\b(?:exp|expiry|expires|best before|use by)\b',
    r'\b(?:manufactured|mfg|made|produced)\b',
    r'\b(?:batch|lot|serial)\b',
  ];

  // Date patterns
  static const List<String> _datePatterns = [
    r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b', // DD/MM/YYYY or MM/DD/YYYY
    r'\b\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{2,4}\b', // DD MMM YYYY
    r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2}\s+\d{2,4}\b', // MMM DD YYYY
    r'\b\d{4}[/-]\d{1,2}[/-]\d{1,2}\b', // YYYY/MM/DD
  ];

  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    
    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<Map<String, dynamic>?> extractMedicineInfo(File imageFile) async {
    try {
      // Preprocess image
      final processedImage = await _preprocessImage(imageFile);
      
      // Extract text using OCR
      final extractedText = await _performOCR(processedImage);
      
      // Parse extracted information
      return _parseMedicineInfo(extractedText);
    } catch (e) {
      print('OCR extraction failed: $e');
      return null;
    }
  }

  Future<File> _preprocessImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception('Failed to decode image');
      
      // Convert to grayscale
      final grayscale = img.grayscale(image);
      
      // Apply Gaussian blur to reduce noise
      final blurred = img.gaussianBlur(grayscale, radius: 1);
      
      // Apply adaptive threshold for better text recognition
      final thresholded = _applyAdaptiveThreshold(blurred);
      
      // Enhance contrast
      final enhanced = img.contrast(thresholded, 150);
      
      // Save processed image
      final tempDir = await getTemporaryDirectory();
      final processedPath = '${tempDir.path}/processed_medicine_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodePng(enhanced));
      
      return processedFile;
    } catch (e) {
      print('Image preprocessing failed: $e');
      return imageFile; // Return original if preprocessing fails
    }
  }

  img.Image _applyAdaptiveThreshold(img.Image image) {
    // Simple adaptive threshold implementation
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);
    
    const windowSize = 15;
    const threshold = 0.1;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Calculate local mean
        int sum = 0;
        int count = 0;
        
        for (int wy = -windowSize ~/ 2; wy <= windowSize ~/ 2; wy++) {
          for (int wx = -windowSize ~/ 2; wx <= windowSize ~/ 2; wx++) {
            final ny = y + wy;
            final nx = x + wx;
            
            if (ny >= 0 && ny < height && nx >= 0 && nx < width) {
              sum += image.getPixel(nx, ny).r;
              count++;
            }
          }
        }
        
        final localMean = sum / count;
        final pixel = image.getPixel(x, y);
        final gray = pixel.r;
        
        // Apply threshold
        final newValue = gray < localMean * (1 - threshold) ? 0 : 255;
        result.setPixel(x, y, img.ColorRgb8(newValue, newValue, newValue));
      }
    }
    
    return result;
  }

  Future<String> _performOCR(File imageFile) async {
    try {
      // This is a placeholder for actual Tesseract integration
      // In a real implementation, you would use the tesseract_ocr package
      
      // For now, return a mock response
      return _getMockOCRResult();
    } catch (e) {
      print('OCR failed: $e');
      return '';
    }
  }

  String _getMockOCRResult() {
    // Mock OCR result for testing
    return '''
    Amoxicillin 500mg
    Capsules
    Expiry: 31/12/2024
    Manufactured: 01/01/2023
    Batch: AMX2023001
    Manufacturer: PharmaCorp
    Take 1 capsule 3 times daily
    Store in a cool, dry place
    ''';
  }

  Map<String, dynamic>? _parseMedicineInfo(String text) {
    try {
      final Map<String, dynamic> result = {};
      
      // Extract medicine name
      final medicineName = _extractMedicineName(text);
      if (medicineName.isNotEmpty) {
        result['name'] = medicineName;
      }
      
      // Extract dosage
      final dosage = _extractDosage(text);
      if (dosage.isNotEmpty) {
        result['dosage'] = dosage;
      }
      
      // Extract expiry date
      final expiryDate = _extractExpiryDate(text);
      if (expiryDate != null) {
        result['expiryDate'] = expiryDate;
      }
      
      // Extract manufactured date
      final manufacturedDate = _extractManufacturedDate(text);
      if (manufacturedDate != null) {
        result['manufacturedDate'] = manufacturedDate;
      }
      
      // Extract batch number
      final batchNumber = _extractBatchNumber(text);
      if (batchNumber.isNotEmpty) {
        result['batchNumber'] = batchNumber;
      }
      
      // Extract manufacturer
      final manufacturer = _extractManufacturer(text);
      if (manufacturer.isNotEmpty) {
        result['manufacturer'] = manufacturer;
      }
      
      return result.isNotEmpty ? result : null;
    } catch (e) {
      print('Parsing failed: $e');
      return null;
    }
  }

  String _extractMedicineName(String text) {
    // Simple pattern matching for medicine names
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && 
          !trimmed.toLowerCase().contains('expiry') &&
          !trimmed.toLowerCase().contains('manufactured') &&
          !trimmed.toLowerCase().contains('batch') &&
          !trimmed.toLowerCase().contains('take') &&
          !trimmed.toLowerCase().contains('store')) {
        return trimmed;
      }
    }
    return '';
  }

  String _extractDosage(String text) {
    // Extract dosage information
    final dosageRegex = RegExp(r'\b\d+\s*(?:mg|mcg|g|ml|IU|units)\b', caseSensitive: false);
    final match = dosageRegex.firstMatch(text);
    return match?.group(0) ?? '';
  }

  DateTime? _extractExpiryDate(String text) {
    // Extract expiry date
    for (final pattern in _datePatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      final match = regex.firstMatch(text);
      if (match != null) {
        try {
          return _parseDate(match.group(0)!);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  DateTime? _extractManufacturedDate(String text) {
    // Extract manufactured date
    final manufacturedRegex = RegExp(r'\b(?:manufactured|mfg|made|produced)\s*:\s*(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\b', caseSensitive: false);
    final match = manufacturedRegex.firstMatch(text);
    if (match != null) {
      try {
        return _parseDate(match.group(1)!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String _extractBatchNumber(String text) {
    // Extract batch number
    final batchRegex = RegExp(r'\b(?:batch|lot|serial)\s*:\s*([A-Z0-9]+)\b', caseSensitive: false);
    final match = batchRegex.firstMatch(text);
    return match?.group(1) ?? '';
  }

  String _extractManufacturer(String text) {
    // Extract manufacturer
    final manufacturerRegex = RegExp(r'\b(?:manufacturer|mfg|made by)\s*:\s*([A-Za-z\s]+)\b', caseSensitive: false);
    final match = manufacturerRegex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }

  DateTime _parseDate(String dateStr) {
    // Simple date parsing
    final cleanDate = dateStr.replaceAll(RegExp(r'[^\d/]'), '');
    final parts = cleanDate.split('/');
    
    if (parts.length == 3) {
      int day, month, year;
      
      if (parts[2].length == 2) {
        year = 2000 + int.parse(parts[2]);
      } else {
        year = int.parse(parts[2]);
      }
      
      // Assume DD/MM/YYYY format
      day = int.parse(parts[0]);
      month = int.parse(parts[1]);
      
      return DateTime(year, month, day);
    }
    
    throw FormatException('Invalid date format: $dateStr');
  }

  Future<bool> validateExtractedInfo(Map<String, dynamic> info) async {
    // Validate extracted information
    if (info['name']?.toString().isEmpty ?? true) {
      return false;
    }
    
    if (info['expiryDate'] == null) {
      return false;
    }
    
    // Check if expiry date is in the future
    final expiryDate = info['expiryDate'] as DateTime;
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    
    return true;
  }
}
