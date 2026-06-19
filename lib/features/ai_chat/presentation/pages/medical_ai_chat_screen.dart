import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/medical_intake.dart';
import '../../data/repositories/medical_ai_repository.dart';
import '../../data/services/medical_ai_api_service.dart';
import '../providers/medical_ai_chat_provider.dart';

class MedicalAiChatScreen extends StatefulWidget {
  const MedicalAiChatScreen({super.key});

  @override
  State<MedicalAiChatScreen> createState() => _MedicalAiChatScreenState();
}

class _MedicalAiChatScreenState extends State<MedicalAiChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problem = TextEditingController();
  final _started = TextEditingController();
  final _age = TextEditingController();
  final _duration = TextEditingController();
  final _message = TextEditingController();
  String _gender = 'ذكر';
  String _severity = 'متوسطة';
  MedicalIntake? _intake;

  @override
  void dispose() { _problem.dispose(); _started.dispose(); _age.dispose(); _duration.dispose(); _message.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicalAiChatProvider(MedicalAiRepository(apiService: MedicalAiApiService())),
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('المحادثة الطبية الذكية'),
          actions: [
            IconButton(tooltip: 'بدء محادثة جديدة', onPressed: () => setState(() => _intake = null), icon: const Icon(Icons.refresh)),
            IconButton(tooltip: 'معلومات الخدمة', onPressed: () => showAboutDialog(context: context, applicationName: 'AI Medical Chat', children: const [Text('لا تضع API Key داخل الكود. اربط MedicalAiApiService بخدمتك الآمنة.')]), icon: const Icon(Icons.info_outline)),
          ],
        ),
        body: _intake == null ? _buildIntake(context) : _buildChat(context),
      ),
    );
  }

  Widget _buildIntake(BuildContext context) => Form(
    key: _formKey,
    child: ListView(padding: const EdgeInsets.all(16), children: [
      TextFormField(controller: _problem, decoration: const InputDecoration(labelText: 'ما المرض أو المشكلة؟'), validator: _required),
      const SizedBox(height: 12), TextFormField(controller: _started, decoration: const InputDecoration(labelText: 'منذ متى بدأت الأعراض؟'), validator: _required),
      const SizedBox(height: 12), TextFormField(controller: _age, decoration: const InputDecoration(labelText: 'كم عمر المريض؟'), keyboardType: TextInputType.number, validator: (v){ final n=int.tryParse(v??''); return n==null||n<=0?'أدخل عمر صحيح':null;}),
      const SizedBox(height: 12), DropdownButtonFormField(value: _gender, decoration: const InputDecoration(labelText: 'الجنس'), items: ['ذكر','أنثى'].map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged: (v)=>setState(()=>_gender=v!)),
      const SizedBox(height: 12), TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'عدد الأيام أو الأشهر'), validator: _required),
      const SizedBox(height: 12), DropdownButtonFormField(value: _severity, decoration: const InputDecoration(labelText: 'شدة الحالة'), items: ['خفيفة','متوسطة','شديدة','طارئة'].map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged: (v)=>setState(()=>_severity=v!)),
      const SizedBox(height: 20), Consumer<MedicalAiChatProvider>(builder: (context, provider, _) => ElevatedButton.icon(onPressed: provider.isLoading ? null : () async { if(!_formKey.currentState!.validate()) return; final intake=MedicalIntake(problem:_problem.text.trim(), symptomStart:_started.text.trim(), age:int.parse(_age.text.trim()), gender:_gender, duration:_duration.text.trim(), severity:_severity); setState(()=>_intake=intake); await provider.buildInitialRecommendation(intake); }, icon: const Icon(Icons.psychology), label: const Text('تحليل البيانات'))),
    ]),
  );

  Widget _buildChat(BuildContext context) => Consumer<MedicalAiChatProvider>(builder: (context, provider, _) => Column(children: [
    if (provider.error != null) MaterialBanner(content: Text(provider.error!), actions: [TextButton(onPressed: (){}, child: const Text('حسناً'))]),
    Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: provider.messages.length, itemBuilder: (_, i){ final m=provider.messages[i]; return Align(alignment: m.isUser?Alignment.centerRight:Alignment.centerLeft, child: Card(color: m.isUser?Theme.of(context).colorScheme.primaryContainer:null, child: Padding(padding: const EdgeInsets.all(12), child: Text(m.content)))); })),
    if (provider.isLoading) const LinearProgressIndicator(),
    SafeArea(child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: _message, decoration: const InputDecoration(hintText: 'اكتب رسالتك الطبية...'))), IconButton(tooltip: 'إرسال', onPressed: provider.isLoading ? null : () { final text=_message.text; _message.clear(); provider.send(_intake!, text); }, icon: const Icon(Icons.send))]))),
  ]));

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null;
}
