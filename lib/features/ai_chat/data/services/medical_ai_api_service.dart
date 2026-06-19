import 'package:dio/dio.dart';
import '../models/ai_chat_message.dart';
import '../models/medical_intake.dart';

class MedicalAiApiService {
  final Dio _dio;
  final String? baseUrl;
  final String? apiKey;

  MedicalAiApiService({Dio? dio, this.baseUrl = const String.fromEnvironment('AI_API_URL'), this.apiKey = const String.fromEnvironment('AI_API_KEY')}) : _dio = dio ?? Dio();

  Future<String> sendMedicalMessage({required MedicalIntake intake, required List<AiChatMessage> history, required String message}) async {
    final url = (baseUrl ?? '').trim();
    if (url.isEmpty) {
      return 'تحليل أولي: فهمت رسالتك عن "${intake.problem}". راقب الأعراض، اشرب سوائل كافية، واحجز موعداً إذا استمرت الحالة أو كانت الشدة عالية. يمكنك تشغيل API حقيقي عبر --dart-define=AI_API_URL و AI_API_KEY.';
    }
    final response = await _dio.post(url, data: {
      'system': 'أنت مساعد طبي عربي. قدم إرشاداً منظماً ولا تقدم تشخيصاً نهائياً ولا وصفات خطرة.',
      'intake': intake.toPrompt(),
      'message': message,
      'history': history.map((e) => e.toMap(firestore: false)).toList(),
    }, options: Options(headers: {if ((apiKey ?? '').isNotEmpty) 'Authorization': 'Bearer $apiKey'}));
    return (response.data['reply'] ?? response.data['message'] ?? response.data['choices']?[0]?['message']?['content'] ?? '').toString();
  }
}
