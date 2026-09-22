import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/ai_badge_result.dart';
import '../../firebase_options.dart';

typedef GeminiMultimodalGenerator
    = Future<({String? vibeTitle, Uint8List? imageBytes})> Function({
  required String prompt,
  required Uint8List photoBytes,
});

/// Remote data source that interacts with `gemini-3.1-flash-image` with multimodal input and output
/// through Firebase Vertex AI (`https://firebasevertexai.googleapis.com/v1beta/projects/<projectId>/models/...`).
/// If the Firebase AI SDK client throws an exception, it falls back to the direct Firebase Vertex AI REST endpoint.
class AiBadgeRemoteDataSource {
  final FirebaseAI? _firebaseAi;
  final GeminiMultimodalGenerator? _geminiMultimodalGenerator;
  final http.Client _httpClient;
  final String? _apiKey;
  final String? _projectId;

  static const List<String> caribbeanFallbackTitles = [
    '¡Qué Chido Cancún! 100%',
    'Bomba Yucateca de Código',
    'Vibra Maya Sagrada 99%',
    '¡A Toda Madre en el Caribe!',
    'Kukulcán del Hot Reload',
    'Cenote Sagrado & Flutter 99%',
    '¡Qué Padre la Riviera Maya!',
    'Marquesita & Widgets 100%',
    'Dash en Chichén Itzá 98%',
    'Rey del Caribe Mexicano',
    '¡Chulada de Widget en Cancún!',
    'Pura Buena Vibra Yucateca',
  ];

  AiBadgeRemoteDataSource({
    FirebaseAI? firebaseAi,
    GeminiMultimodalGenerator? geminiMultimodalGenerator,
    http.Client? httpClient,
    String? apiKey,
    String? projectId,
  })  : _firebaseAi = firebaseAi,
        _geminiMultimodalGenerator = geminiMultimodalGenerator,
        _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey,
        _projectId = projectId;

  /// Returns a deterministic Caribbean title from the fallback catalog for [attendeeName].
  static String getFallbackTitle(String attendeeName) {
    final cleanName = attendeeName.trim();
    if (cleanName.isEmpty) {
      return caribbeanFallbackTitles.first;
    }
    final index = cleanName.hashCode.abs() % caribbeanFallbackTitles.length;
    return caribbeanFallbackTitles[index];
  }

  /// Invokes `gemini-3.1-flash-image` to produce an illustrated Caribbean portrait and short vibe title.
  Future<AiBadgeResult> generateBadge({
    required Uint8List photoBytes,
    required String attendeeName,
  }) async {
    final promptText =
        'A vibrant, high-quality digital art portrait of the conference attendee ($attendeeName) '
        'from the reference photo celebrating at FlutterConf LATAM Cancún 2026. '
        'Standing happily right next to the attendee is Dash, the official Flutter mascot. '
        'CRITICAL MASCOT DETAILS: Dash is a cute, round, chubby, fluffy blue plush bird toy (NOT a dolphin, NOT a fish, NOT an aquatic animal). '
        'Dash has a plump round body covered in soft cyan and royal-blue felt feathers with a cream-white belly patch, '
        'large friendly round cartoon eyes, a tiny short triangular orange beak, two small rounded blue bird wings, and two tiny orange bird feet standing on the sand. '
        'Setting: picturesque tropical Cancun beach in Quintana Roo, Mexico, with turquoise Caribbean ocean in the background, fine white sand of the Riviera Maya, swaying green palm trees under bright warm sunlight, with subtle colorful Mexican festival touches. '
        'Style: polished conference badge illustration, sharp focus, rich colors, joyful and festive atmosphere. '
        'CRITICAL REQUIREMENT FOR THE TEXT VIBE: You MUST provide a short, punchy 3 to 5 word conference vibe or title in Spanish that ALWAYS includes authentic Mexican phrases and regional expressions from Cancún, Quintana Roo, and Yucatán (such as "¡Qué Chido!", "Bomba Yucateca", "Vibra Maya", "¡Qué Padre!", "A Toda Madre", "Cenote", "Kukulcán", "Mayab", "Marquesita", etc.). '
        'Examples of expected output: "¡Qué Chido Cancún! 100%", "Bomba Yucateca de Código", "Vibra Maya 100% Chida", "¡Qué Padre la Riviera!", "Kukulcán del Hot Reload", "Cenote Sagrado 99%". Do not include quotes, markdown, or conversational filler.';

    String? aiVibeTitle;
    Uint8List? generatedImageBytes;

    try {
      final customGenerator = _geminiMultimodalGenerator;
      if (customGenerator != null) {
        final result = await customGenerator(
          prompt: promptText,
          photoBytes: photoBytes,
        ).timeout(const Duration(seconds: 20));

        aiVibeTitle = result.vibeTitle;
        generatedImageBytes = result.imageBytes;
      } else {
        bool sdkSucceeded = false;
        try {
          final firebaseAi = _firebaseAi ?? FirebaseAI.googleAI();
          final model = firebaseAi.generativeModel(
            model: 'gemini-3.1-flash-image',
            generationConfig: GenerationConfig(
              responseModalities: [
                ResponseModalities.text,
                ResponseModalities.image,
              ],
            ),
          );

          final prompt = [
            Content.multi([
              TextPart(promptText),
              InlineDataPart('image/jpeg', photoBytes),
            ]),
          ];

          final response = await model
              .generateContent(prompt)
              .timeout(const Duration(seconds: 20));

          final parts = response.candidates.firstOrNull?.content.parts ?? [];
          for (final part in parts) {
            if (part is TextPart) {
              aiVibeTitle ??= part.text;
            }
            if (part is InlineDataPart) {
              generatedImageBytes ??= part.bytes;
            }
          }

          if (aiVibeTitle != null || generatedImageBytes != null) {
            sdkSucceeded = true;
          }
        } catch (_) {
          sdkSucceeded = false;
        }

        // If Firebase AI SDK fails, fallback directly to Firebase Vertex AI REST API
        // at https://firebasevertexai.googleapis.com/v1beta/projects/<projectId>/models/...
        if (!sdkSucceeded) {
          final directResult = await _generateViaFirebaseVertexAiApi(
            promptText: promptText,
            photoBytes: photoBytes,
          );
          aiVibeTitle = directResult.vibeTitle;
          generatedImageBytes = directResult.imageBytes;
        }
      }
    } catch (_) {
      // Gracefully catch timeout / offline / conference Wi-Fi issues
    }

    final cleanVibe = _sanitizeVibeTitle(aiVibeTitle, attendeeName);
    final finalImageBytes =
        (generatedImageBytes != null && generatedImageBytes.isNotEmpty)
            ? generatedImageBytes
            : photoBytes;

    return AiBadgeResult(
      imageBytes: finalImageBytes,
      aiVibeTitle: cleanVibe,
    );
  }

  Future<({String? vibeTitle, Uint8List? imageBytes})>
      _generateViaFirebaseVertexAiApi({
    required String promptText,
    required Uint8List photoBytes,
  }) async {
    try {
      final key = _apiKey ?? DefaultFirebaseOptions.web.apiKey;
      final projectId = _projectId ?? DefaultFirebaseOptions.web.projectId;
      final uri = Uri.parse(
        'https://firebasevertexai.googleapis.com/v1beta/projects/$projectId/models/gemini-3.1-flash-image:generateContent?key=$key',
      );

      final payload = {
        'contents': [
          {
            'parts': [
              {'text': promptText},
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Encode(photoBytes),
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['TEXT', 'IMAGE'],
        }
      };

      final res = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        final firstCandidate = candidates?.firstOrNull as Map<String, dynamic>?;
        final content = firstCandidate?['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>? ?? [];

        String? textResult;
        Uint8List? imageResult;

        for (final item in parts) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('text')) {
              textResult ??= item['text'] as String?;
            }
            if (item.containsKey('inlineData')) {
              final inline = item['inlineData'] as Map<String, dynamic>?;
              final b64 = inline?['data'] as String?;
              if (b64 != null && b64.isNotEmpty) {
                imageResult ??= base64Decode(b64);
              }
            }
          }
        }

        return (vibeTitle: textResult, imageBytes: imageResult);
      }
    } catch (_) {}

    return (vibeTitle: null, imageBytes: null);
  }

  String _sanitizeVibeTitle(String? rawTitle, String attendeeName) {
    if (rawTitle == null) {
      return getFallbackTitle(attendeeName);
    }
    final trimmed = rawTitle
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('"', '')
        .trim();
    if (trimmed.isEmpty || trimmed.length < 3) {
      return getFallbackTitle(attendeeName);
    }
    return trimmed;
  }
}
