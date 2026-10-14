import 'complete_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cv_upload_screen.dart';
import 'login_screen.dart';
import 'terms_of_service_screen.dart';
import 'create_company_account_screen.dart';
import 'privacy_policy_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'package:flutter/gestures.dart';

class UserSignUpScreen extends StatefulWidget {
  const UserSignUpScreen({super.key});

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  bool _isJobSeeker = true;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _selectedGender;
  String? _selectedMajor;

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateFields() {
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Please enter your last name');
      return false;
    }
    if (_dobController.text.trim().isEmpty) {
      _showError('Please enter your date of birth');
      return false;
    }
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return false;
    }
    if (_selectedMajor == null) {
      _showError('Please select your major');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _showError('Please confirm your password');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (!_agreeToTerms) {
      _showError('You must agree to the Terms and Privacy Policy');
      return false;
    }
    return true;
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 15,
      ),
      filled: true,
      fillColor: const Color(0xFF111738),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060A1B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Connect Smarter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // balance the back arrow
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Heading
                    const Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Join our network and start connecting',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111738),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton('Job Seeker', _isJobSeeker, () {
                            setState(() => _isJobSeeker = true);
                          }),
                          _buildToggleButton('Company', !_isJobSeeker, () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateCompanyAccountScreen(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('First Name'),
                    TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(hint: 'John'),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Middle Name'),
                    TextField(
                      controller: _middleNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(hint: 'Optional'),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Last Name'),
                    TextField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(hint: 'Doe'),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date of Birth'),
                              TextField(
                                controller: _dobController,
                                style: const TextStyle(color: Colors.white),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFF3B5BDB),
                                            surface: Color(0xFF111738),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    _dobController.text =
                                        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
                                  }
                                },
                                decoration: _inputDecoration(
                                  hint: 'mm/dd/yyyy',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Gender'),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                dropdownColor: const Color(0xFF111738),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(hint: ''),
                                hint: Text(
                                  'Select',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 15,
                                  ),
                                ),
                                items: ['Male', 'Female']
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedGender = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Major'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMajor,
                      dropdownColor: const Color(0xFF111738),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: _inputDecoration(hint: ''),
                      hint: Text(
                        'Select Major',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 15,
                        ),
                      ),
                      items:
                          [
                                'Computer Science',
                                'Engineering',
                                'Business',
                                'Design',
                                'Marketing',
                                'Other',
                              ]
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _selectedMajor = val),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Email Address'),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: 'john.doe@example.com',
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Phone Number'),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(hint: '+20 100 123 4567'),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Password'),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Confirm Password'),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (val) =>
                                setState(() => _agreeToTerms = val ?? false),
                            activeColor: const Color(0xFF3B5BDB),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    color: Color(0xFF5B7FFF),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsOfServiceScreen(),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFF5B7FFF),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacyPolicyScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5BDB),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF3B5BDB,
                          ).withValues(alpha: 0.3),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSubmitting)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else ...[
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account?  '),
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: Color(0xFF5B7FFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!_validateFields()) return;

    setState(() => _isSubmitting = true);
    final authService = AuthService.instance;
    final email = _emailController.text.trim().toLowerCase();

    try {
      if (!FirebaseService.isInitialized) {
        throw Exception(
          'Firebase is not initialized. Please check your internet connection.',
        );
      }

      await authService.registerWithProfile(
        email: email,
        password: _passwordController.text,
        profile: {
          'email': email,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'dateOfBirth': _dobController.text.trim(),
          'gender': _selectedGender,
          'major': _selectedMajor,
          'phone': _phoneController.text.trim(),
          'userType': 'job_seeker',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CvUploadScreen()),
      );
    } on ProfileSetupRequiredException catch (error) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(initialProfile: error.profile),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showError(authService.formatAuthError(error));
    } catch (error) {
      if (!mounted) return;
      _showError('Could not create account: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B5BDB) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
