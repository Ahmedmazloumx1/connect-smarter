import 'package:flutter/material.dart';
import 'services/job_service.dart';
import 'services/auth_service.dart';
import 'terms_of_service_screen.dart';

class PostNewJobScreen extends StatefulWidget {
  const PostNewJobScreen({super.key});

  @override
  State<PostNewJobScreen> createState() => _PostNewJobScreenState();
}

class _PostNewJobScreenState extends State<PostNewJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _skillController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionController = TextEditingController();

  final List<String> _skills = [];
  String? _selectedEducation;
  double _minExperience = 3;
  final List<String> _questions = [];
  bool _isPublic = true;
  bool _isSubmitting = false;

  final List<String> _educationOptions = [
    'High School',
    'Diploma',
    'Bachelors',
    'Masters',
    'PhD',
    'No degree required',
  ];

  static const Color bgColor = Color(0xFF0A0B1A);
  static const Color surfaceColor = Color(0xFF111427);
  static const Color inputFill = Color(0xFF191B34);
  static const Color inputBorder = Color(0xFF354080);
  static const Color brightBlue = Color(0xFF1D2BFF);
  static const Color accentCyan = Color(0xFF00BFA5);
  static const Color whiteText = Color(0xFFEDEDF4);
  static const Color mutedText = Color(0xFF8B8E9F);
  static const Color chipBg = Color(0xFF18237A);

  @override
  void dispose() {
    _titleController.dispose();
    _skillController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.length > 120 || _skills.length >= 100) {
      _showError('Use up to 100 skills, at most 120 characters each.');
      return;
    }
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _addQuestion() {
    final question = _questionController.text.trim();
    if (question.length > 2000 || _questions.length >= 20) {
      _showError('Use up to 20 questions, at most 2000 characters each.');
      return;
    }
    if (question.isNotEmpty) {
      setState(() {
        _questions.add(question);
        _questionController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty) {
      _showError('Please add at least one skill.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = AuthService.instance.currentUser;
      final companyProfile = currentUser == null
          ? null
          : await AuthService.instance.getUserProfile(currentUser.uid);
      final companyName = (companyProfile?['companyName'] ?? 'Your Company')
          .toString();

      await JobService.instance.saveJob({
        'title': _titleController.text.trim(),
        'company': companyName,
        'ownerId': currentUser?.uid,
        'location': 'Remote',
        'logo': 'assets/connect_smarter_logo.png',
        'match': 'New Listing',
        'category': _titleController.text.trim(),
        'education': _selectedEducation ?? 'No degree required',
        'isRemote': true,
        'isFullTime': true,
        'skills': _skills,
        'description': _descriptionController.text.trim(),
        'questions': _questions,
        'minExperience': _minExperience,
        'isPublic': _isPublic,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job posted successfully!'),
          backgroundColor: accentCyan,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showError('Could not post job: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post New Job',
          style: TextStyle(
            color: whiteText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Job Title'),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g. Senior Product Designer',
                  validator: (val) => val!.isEmpty ? 'Enter job title' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Required Skills'),
                _buildSkillSection(),
                const SizedBox(height: 24),

                _buildLabel('Required Education'),
                _buildDropdownField<String>(
                  hint: 'Select degree',
                  value: _selectedEducation,
                  items: _educationOptions,
                  onChanged: (val) => setState(() => _selectedEducation = val),
                  validator: (val) =>
                      val == null ? 'Select education level' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Minimum Experience (Years)'),
                _buildExperienceSlider(),
                const SizedBox(height: 24),

                _buildLabel('Job Description'),
                _buildTextField(
                  controller: _descriptionController,
                  hint:
                      'Describe the role, responsibilities, and ideal candidate...',
                  maxLines: 5,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter job description' : null,
                ),
                const SizedBox(height: 24),

                _buildInterviewQuestionsHeader(),
                _buildQuestionsSection(),
                const SizedBox(height: 24),

                _buildPublicListingCard(),
                const SizedBox(height: 40),

                _buildPostButton(),
                const SizedBox(height: 24),

                _buildFooter(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: mutedText,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: whiteText, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4B5175), fontSize: 14),
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brightBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSkillSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
          ),
          if (_skills.isNotEmpty) const SizedBox(height: 12),
          TextField(
            controller: _skillController,
            onSubmitted: (_) => _addSkill(),
            style: const TextStyle(color: whiteText, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Add skill...',
              hintStyle: TextStyle(color: Color(0xFF4B5175), fontSize: 14),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: whiteText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _skills.remove(skill)),
            child: const Icon(Icons.close, color: whiteText, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    T? value,
    String? hint,
    required List<T> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: hint != null
          ? Text(
              hint,
              style: const TextStyle(color: Color(0xFF4B5175), fontSize: 14),
            )
          : null,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: const TextStyle(color: whiteText, fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: surfaceColor,
      icon: const Icon(Icons.keyboard_arrow_down, color: mutedText),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brightBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildExperienceSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: brightBlue,
                inactiveTrackColor: bgColor,
                thumbColor: brightBlue,
                overlayColor: brightBlue.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _minExperience,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (val) => setState(() => _minExperience = val),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_minExperience.toInt()}+',
            style: const TextStyle(
              color: whiteText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewQuestionsHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Text(
            'Job Interview Questions',
            style: TextStyle(
              color: mutedText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PREPARATION',
              style: TextStyle(
                color: accentCyan,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${idx + 1}',
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: whiteText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _questions.removeAt(idx)),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: inputBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    onSubmitted: (_) => _addQuestion(),
                    style: const TextStyle(color: whiteText, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add a question for candidates to prepare...',
                      hintStyle: TextStyle(
                        color: Color(0xFF4B5175),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _addQuestion,
                  child: const Icon(
                    Icons.add_circle,
                    color: brightBlue,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'These questions appear on the job listing for preparation. Practice scoring uses a separate question bank.',
            style: TextStyle(
              color: mutedText,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicListingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.visibility_outlined,
              color: brightBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Public Listing',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This job will be visible to all candidates on the platform.',
                  style: TextStyle(color: mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
            activeThumbColor: brightBlue,
            activeTrackColor: brightBlue.withValues(alpha: 0.3),
            inactiveTrackColor: bgColor,
            inactiveThumbColor: mutedText,
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: brightBlue.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: const Icon(Icons.near_me_outlined),
          label: const Text(
            'Post Job',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: brightBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsOfServiceScreen(),
            ),
          );
        },
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: mutedText, fontSize: 12),
            children: [
              TextSpan(text: 'By posting, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: accentCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }
}
