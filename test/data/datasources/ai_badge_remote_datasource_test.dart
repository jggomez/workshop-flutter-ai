import 'dart:convert';
import 'dart:typed_data';
import 'package:cancun_dashbooth/data/datasources/ai_badge_remote_datasource.dart';
import 'package:cancun_dashbooth/domain/entities/ai_badge_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late Uint8List testPhotoBytes;
  late Uint8List aiGeneratedImageBytes;

  setUpAll(() {
    registerFallbackValue(Uri());
    testPhotoBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    aiGeneratedImageBytes = Uint8List.fromList([10, 20, 30, 40, 50, 60]);
  });

  group('AiBadgeRemoteDataSource (gemini-3.1-flash-image)', () {
    test('successfully generates badge using Gemini multimodal image and text',
        () async {
      String? capturedPrompt;
      Uint8List? capturedPhoto;

      final dataSource = AiBadgeRemoteDataSource(
        geminiMultimodalGenerator: (
            {required prompt, required photoBytes}) async {
          capturedPrompt = prompt;
          capturedPhoto = photoBytes;
          return (
            vibeTitle: 'Dash Surfista Legendario | Vibra Caribeña 100%',
            imageBytes: aiGeneratedImageBytes,
          );
        },
      );

      final result = await dataSource.generateBadge(
        photoBytes: testPhotoBytes,
        attendeeName: 'Valeria',
      );

      expect(result, isA<AiBadgeResult>());
      expect(
          result.aiVibeTitle, 'Dash Surfista Legendario | Vibra Caribeña 100%');
      // The image returned MUST be the IA generated image directly
      expect(result.imageBytes, equals(aiGeneratedImageBytes));
      expect(capturedPrompt, contains('FlutterConf LATAM Cancún 2026'));
      expect(capturedPrompt, contains('Valeria'));
      expect(capturedPrompt, contains('Dash'));
      expect(capturedPhoto, equals(testPhotoBytes));
    });

    test(
        'falls back to Firebase Vertex AI direct REST API when Firebase AI SDK throws 401 or exception',
        () async {
      final mockClient = MockHttpClient();
      final expectedImage = Uint8List.fromList([7, 8, 9, 10]);
      final jsonResponse = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Capitán de Widgets Caribeños | Vibra Caribeña 100%'},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Encode(expectedImage),
                  }
                }
              ]
            }
          }
        ]
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonResponse, 200));

      final dataSource = AiBadgeRemoteDataSource(
        httpClient: mockClient,
        apiKey: 'test-api-key',
        projectId: 'dashbooth-cancun-2026',
      );

      final result = await dataSource.generateBadge(
        photoBytes: testPhotoBytes,
        attendeeName: 'Diego',
      );

      expect(result.aiVibeTitle,
          'Capitán de Widgets Caribeños | Vibra Caribeña 100%');
      expect(result.imageBytes, equals(expectedImage));

      verify(() => mockClient.post(
            Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/projects/dashbooth-cancun-2026/models/gemini-3.1-flash-image:generateContent?key=test-api-key'),
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          )).called(1);
    });

    test(
        'falls back cleanly to original photo and Caribbean catalog title when both APIs fail',
        () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(Exception('No internet'));

      final dataSource = AiBadgeRemoteDataSource(
        httpClient: mockClient,
        apiKey: 'test-api-key',
      );

      final result = await dataSource.generateBadge(
        photoBytes: testPhotoBytes,
        attendeeName: 'Carlos Maya',
      );

      expect(result, isA<AiBadgeResult>());
      expect(result.aiVibeTitle.isNotEmpty, isTrue);
      expect(AiBadgeRemoteDataSource.caribbeanFallbackTitles,
          contains(result.aiVibeTitle));
      expect(result.imageBytes, equals(testPhotoBytes));
    });

    test(
        'returns original photo if Gemini returns text vibe without image part',
        () async {
      final dataSource = AiBadgeRemoteDataSource(
        geminiMultimodalGenerator: (
            {required prompt, required photoBytes}) async {
          return (
            vibeTitle: 'Explorador Maya de Flutter | Vibra Tropical 99%',
            imageBytes: null,
          );
        },
      );

      final result = await dataSource.generateBadge(
        photoBytes: testPhotoBytes,
        attendeeName: 'Sofía',
      );

      expect(result.aiVibeTitle,
          'Explorador Maya de Flutter | Vibra Tropical 99%');
      expect(result.imageBytes, equals(testPhotoBytes));
    });

    test('getFallbackTitle returns consistent non-empty title for any name',
        () {
      final title1 = AiBadgeRemoteDataSource.getFallbackTitle('Ana');
      final title2 = AiBadgeRemoteDataSource.getFallbackTitle('');

      expect(title1.isNotEmpty, isTrue);
      expect(title2.isNotEmpty, isTrue);
      expect(AiBadgeRemoteDataSource.caribbeanFallbackTitles, contains(title1));
      expect(AiBadgeRemoteDataSource.caribbeanFallbackTitles, contains(title2));
    });
  });
}
