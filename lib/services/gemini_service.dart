import 'dart:convert';
import 'package:http/http.dart' as http;

// Anahtar artık kodda değil — build sırasında GitHub Secrets'tan geliyor.
const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

const String _model = 'gemini-3.6-flash';
const String _baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

class GeminiResult {
  final String summary;
  final String category;
  GeminiResult({required this.summary, required this.category});
}

class GeminiService {
  static Future<GeminiResult> summarizeAndCategorize(String content) async {
    if (content.trim().isEmpty) {
      return GeminiResult(summary: '', category: 'Diğer');
    }
    final body = {
      "system_instruction": {
        "parts": [
          {
            "text":
                "Sen DogonNote adlı bir not uygulamasının arka planında çalışan bir "
                    "asistansın. Kullanıcı bir not yazıyor. Görevin SADECE geçerli "
                    "JSON döndürmek, başka hiçbir açıklama ekleme. Format:\n"
                    "{\"summary\": \"tek cümlelik kısa Türkçe özet\", "
                    "\"category\": \"İş|Kişisel|Fikir|Alışveriş|Sağlık|Eğitim|Diğer kategorilerinden biri\"}"
          }
        ]
      },
      "contents": [
        {"role": "user", "parts": [{"text": content}]}
      ],
      "generationConfig": {"temperature": 0.4, "responseMimeType": "application/json"}
    };
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Gemini API hatası: ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) throw Exception('Gemini yanıtı boş döndü.');
    final parsed = jsonDecode(text);
    return GeminiResult(summary: parsed['summary'] ?? '', category: parsed['category'] ?? 'Diğer');
  }

  static Future<List<String>> semanticSearch({
    required String query,
    required List<Map<String, String>> notes,
  }) async {
    if (notes.isEmpty) return [];
    final notesList = notes
        .map((n) => "id:${n['id']} | başlık:${n['title']} | içerik:${n['content']}")
        .join('\n---\n');
    final body = {
      "system_instruction": {
        "parts": [
          {
            "text":
                "Aşağıda kullanıcının notları var. Kullanıcının arama sorgusuna "
                    "anlam bakımından en çok uyan notların id'lerini alaka sırasına "
                    "göre bir JSON dizisi olarak döndür. SADECE şu formatta yanıt ver: "
                    "{\"ids\": [\"id1\", \"id2\", ...]}. Alakasız notları listeleme."
          }
        ]
      },
      "contents": [
        {"role": "user", "parts": [{"text": "Sorgu: $query\n\nNotlar:\n$notesList"}]}
      ],
      "generationConfig": {"temperature": 0.2, "responseMimeType": "application/json"}
    };
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Gemini API hatası: ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) return [];
    final parsed = jsonDecode(text);
    return List<String>.from(parsed['ids'] ?? []);
  }
}
