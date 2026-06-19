import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digl/features/medical_profile/models/doctor_recommendation_model.dart';
import 'package:digl/features/medical_profile/services/advanced_diagnosis_service.dart';
import 'package:digl/features/medical_profile/services/doctor_matching_service.dart';
import '../models/ai_chat_message.dart';
import '../models/medical_intake.dart';
import '../services/medical_ai_api_service.dart';

class MedicalAiRepository {
  final MedicalAiApiService apiService;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  MedicalAiRepository({required this.apiService, FirebaseFirestore? firestore, FirebaseAuth? auth})
      : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Future<List<DoctorRecommendation>> recommendDoctors(MedicalIntake intake) async {
    final specialty = _specialtyForProblem(intake.problem);
    return DoctorMatchingService.findMatchingDoctors(
      recommendedSpecialties: [SpecialtyRecommendation(name: specialty, description: 'مطابقة أولية من الذكاء الاصطناعي', matchPercentage: 80)],
      symptoms: intake.symptoms,
      returnCount: 1,
    );
  }

  Future<String> sendMessage(MedicalIntake intake, List<AiChatMessage> history, String message) =>
      apiService.sendMedicalMessage(intake: intake, history: history, message: message);

  Future<void> saveMessage(AiChatMessage message) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    await firestore.collection('users').doc(uid).collection('medical_ai_chats').doc(message.id).set(message.toMap());
  }

  String _specialtyForProblem(String problem) {
    final text = problem.toLowerCase();
    if (text.contains('قلب') || text.contains('صدر')) return 'قلب';
    if (text.contains('جلد') || text.contains('حساسية')) return 'جلدية';
    if (text.contains('طفل')) return 'أطفال';
    if (text.contains('أسنان') || text.contains('سن')) return 'أسنان';
    if (text.contains('معدة') || text.contains('بطن')) return 'باطنية';
    return 'طب عام';
  }
}
