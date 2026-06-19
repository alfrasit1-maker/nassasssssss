import 'package:flutter/material.dart';
import '../../data/models/ai_chat_message.dart';
import '../../data/models/medical_intake.dart';
import '../../data/repositories/medical_ai_repository.dart';

class MedicalAiChatProvider extends ChangeNotifier {
  final MedicalAiRepository repository;
  MedicalAiChatProvider(this.repository);

  final List<AiChatMessage> messages = [];
  bool isLoading = false;
  String? error;

  Future<String> buildInitialRecommendation(MedicalIntake intake) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final doctors = await repository.recommendDoctors(intake);
      final doctorText = doctors.isEmpty
          ? 'لم يتم العثور على طبيب مطابق حالياً داخل التطبيق.'
          : 'أفضل طبيب مقترح: ${doctors.first.fullName} - ${doctors.first.specialtyName} (تطابق ${doctors.first.matchPercentage}%).';
      final recommendation = 'التخصص المقترح: ${doctors.isEmpty ? 'طب عام' : doctors.first.specialtyName}.\n$doctorText\nالتوصية: احجز موعداً إذا استمرت الأعراض أو كانت الشدة عالية.';
      await _addBot(recommendation);
      return recommendation;
    } catch (e) {
      error = 'تعذر إنشاء التوصية: $e';
      return error!;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> send(MedicalIntake intake, String content) async {
    if (content.trim().isEmpty) return;
    await _addUser(content.trim());
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final reply = await repository.sendMessage(intake, messages, content.trim());
      await _addBot(reply);
    } catch (e) {
      error = 'حدث خطأ أثناء الاتصال بخدمة الذكاء الاصطناعي: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _addUser(String content) async => _add(AiChatMessage(id: DateTime.now().microsecondsSinceEpoch.toString(), content: content, isUser: true, createdAt: DateTime.now()));
  Future<void> _addBot(String content) async => _add(AiChatMessage(id: DateTime.now().microsecondsSinceEpoch.toString(), content: content, isUser: false, createdAt: DateTime.now()));
  Future<void> _add(AiChatMessage msg) async { messages.add(msg); notifyListeners(); await repository.saveMessage(msg); }
}
