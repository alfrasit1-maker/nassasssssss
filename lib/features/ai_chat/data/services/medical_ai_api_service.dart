import 'package:dio/dio.dart';
import '../models/ai_chat_message.dart';
import '../models/medical_intake.dart';

class MedicalAiApiService {
  final Dio _dio;
  final String? baseUrl;

  MedicalAiApiService({Dio? dio, this.baseUrl}) : _dio = dio ?? Dio();

  Future<String> sendMedicalMessage({required MedicalIntake intake, required List<AiChatMessage> history, required String message}) async {
    // ضع رابط خدمة الذكاء الاصطناعي ومفتاحها في إعدادات آمنة خارج الكود ثم مرر baseUrl/headers هنا.
    if (baseUrl == null || baseUrl!.isEmpty) {
      return 'تحليل أولي: بناءً على البيانات المدخلة (${intake.problem}) ننصح بمراجعة الطبيب المناسب. هذا الرد تجريبي إلى أن يتم ربط API الذكاء الاصطناعي.';
    }
    final response = await _dio.post(baseUrl!, data: {
      'intake': intake.toPrompt(),
      'message': message,
      'history': history.map((e) => e.toMap()).toList(),
    });
    return (response.data['reply'] ?? response.data['message'] ?? '').toString();
  }
}
