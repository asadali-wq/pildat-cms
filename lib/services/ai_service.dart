import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ScanService {
  // --- PASTE YOUR GOOGLE CLOUD API KEY HERE ---
  // This key will be used for both Cloud Vision and Gemini
  final String _apiKey = const String.fromEnvironment('GOOGLE_API_KEY');
  // ---------------------------------------------

  final ImagePicker _imagePicker = ImagePicker();

  // This is the main public function our app will call.
  // It returns a Map of the fields the AI found.
  Future<Map<String, dynamic>?> scanCard(ImageSource source) async {
    // 1. CAPTURE IMAGE
    final XFile? imageFile = await _imagePicker.pickImage(source: source);
    if (imageFile == null) return null; // User cancelled

    // 2. READ TEXT (OCR)
    // This calls the Google Cloud Vision API (the "Eyes")
    final String rawText = await _runCloudVisionOCR(imageFile);
    if (rawText.isEmpty) {
      throw Exception('No text found on the card.');
    }

    // 3. ANALYZE TEXT (AI)
    // This calls the Gemini API (the "Brain")
    final Map<String, dynamic>? fields = await _extractFieldsWithGemini(rawText);
    
    return fields;
  }

  /// STEP 2: Calls Google Cloud Vision API to get raw text from an image.
  Future<String> _runCloudVisionOCR(XFile imageFile) async {
    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';

    // Read the image file as bytes
    final bytes = await File(imageFile.path).readAsBytes();
    // Convert bytes to a base64 string
    final String base64Image = base64Encode(bytes);

    // Build the request body for Google Vision
    final String requestBody = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'}
          ]
        }
      ]
    });

    // Make the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Get the full text annotation
      final String fullText =
          data['responses'][0]['fullTextAnnotation']['text'];
      return fullText;
    } else {
      // Handle API error
      throw Exception('Cloud Vision API failed: ${response.body}');
    }
  }

  /// STEP 3: Calls Gemini API to parse raw text into structured JSON.
  Future<Map<String, dynamic>?> _extractFieldsWithGemini(String text) async {
	final model = GenerativeModel(
	  model: 'gemini-2.5-pro', // <-- The correct, modern model
	  apiKey: _apiKey,
	);

    // This is the prompt that follows your exact rules
	final prompt = """
	    You are an expert contact card parser for a CRM. I will provide you with raw OCR text from a business card.
	    Your job is to extract the following fields and return *only* a valid, minified JSON object with no markdown.
    
	    The fields to extract are:
	    full_name, designation_name, employer_name, work_address, residence_address, work_city, work_country, work_telephone, celluler_phone1, whatsapp_number, email_address, website, twitter_handler, facebook, linkedin, instagram

	    RULES:
	    1. If a field is not present in the text, its value MUST be null.
	    2. If an address is found but its type (work/residence) is unclear, default it to 'work_address'.
	    3. 'work_telephone' is for landlines (office numbers). 'celluler_phone1' is for mobile numbers.
	    4. 'employer_name' is the company name.
	    5. **Crucial:** The OCR text may contain "junk" or "noise" words. Be critical and remove any obvious OCR errors or unrelated words. For example, if the text says "Ubunty Spark Computers," the real company name is "Spark Computers."
    
	    RAW TEXT:
	    "$text"

	    JSON:
	    """;

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text == null) {
      return null;
    }
    
    // Clean the AI response (it sometimes adds markdown backticks)
    final String cleanJson = response.text!
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
        
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }
}