import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';

const Color _bgColor = Color(0xFF0A0B1A);
const Color _surfaceColor = Color(0xFF191B34);
const Color _inputFill = Color(0xFF0F1230);
const Color _inputBorder = Color(0xFF26345F);
const Color _cyanAccent = Color(0xFF00D6C9);
const Color _whiteText = Color(0xFFEDEDF4);
const Color _mutedText = Color(0xFF8B8E9F);

class CompanyProfileEditorScreen extends StatefulWidget {
  const CompanyProfileEditorScreen({super.key});

  @override
  State<CompanyProfileEditorScreen> createState() =>
      _CompanyProfileEditorScreenState();
}

class _CompanyProfileEditorScreenState
    extends State<CompanyProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyNameCtrl;
  late final TextEditingController _taglineCtrl;
  late final TextEditingController _missionCtrl;
  late final TextEditingController _cultureCtrl;
  late final TextEditingController _foundedCtrl;
  late final TextEditingController _fundingCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _industryCtrl;

  String _selectedWorkPolicy = 'Hybrid (2 days in office)';
  final List<String> _workPolicyOptions = [
    'Remote',
    'Hybrid (2 days in office)',
    'Hybrid (3 days in office)',
    'On-site',
  ];

  Uint8List? _pickedLogo;
  Uint8List? _pickedCover;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isLoading = true;
  bool _isPickingImage = false;
  String? _loadError;
  String? _loadedUid;

  Future<void> _pickImage(bool isLogo) async {
    if (_isLoading || _isSaving || _isPickingImage || _loadedUid == null) {
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191B34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isLogo ? 'Change Company Logo' : 'Change Cover Image',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D6C9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF00D6C9)),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _readImage(ImageSource.camera, isLogo);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Color(0xFF26345F), height: 1),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D6C9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF00D6C9),
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _readImage(ImageSource.gallery, isLogo);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _readImage(ImageSource source, bool isLogo) async {
    if (!mounted || _isPickingImage || _isSaving) return;
    setState(() => _isPickingImage = true);
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted || AuthService.instance.currentUser?.uid != _loadedUid) {
        return;
      }
      final otherSize = (isLogo ? _pickedCover : _pickedLogo)?.length ?? 0;
      if (bytes.length + otherSize > 300000) {
        throw StateError('Choose images with a combined size below 300 KB.');
      }
      setState(() {
        if (isLogo) {
          _pickedLogo = bytes;
        } else {
          _pickedCover = bytes;
        }
      });
    } catch (error) {
      if (mounted) _showSnack('Could not select image: $error');
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with empty defaults; will be overwritten once Firestore data loads
    _companyNameCtrl = TextEditingController();
    _taglineCtrl = TextEditingController();
    _missionCtrl = TextEditingController();
    _cultureCtrl = TextEditingController();
    _foundedCtrl = TextEditingController();
    _fundingCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _industryCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _loadedUid = null;
    });
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) throw StateError('Sign in again to edit your profile.');
      final data = await AuthService.instance.getUserProfile(uid);
      if (!mounted) return;
      if (AuthService.instance.currentUser?.uid != uid) {
        throw StateError('Your account changed. Open your profile again.');
      }
      if (data == null) throw StateError('Your profile could not be found.');
      Uint8List? decodePhoto(dynamic value) {
        if (value is! String) return null;
        try {
          return base64Decode(value);
        } on FormatException {
          return null;
        }
      }

      setState(() {
        _pickedLogo = decodePhoto(data['logoBase64']);
        _pickedCover = decodePhoto(data['coverBase64']);
        _companyNameCtrl.text = (data['companyName'] ?? '').toString();
        _locationCtrl.text = (data['location'] ?? '').toString();
        _industryCtrl.text = (data['industry'] ?? '').toString();
        // Optional extended fields (saved by editor)
        _taglineCtrl.text = (data['tagline'] ?? '').toString();
        _missionCtrl.text = (data['mission'] ?? '').toString();
        _cultureCtrl.text = (data['culture'] ?? '').toString();
        _foundedCtrl.text = (data['founded'] ?? '').toString();
        _fundingCtrl.text = (data['funding'] ?? '').toString();
        if (data['workPolicy'] != null &&
            _workPolicyOptions.contains(data['workPolicy'].toString())) {
          _selectedWorkPolicy = data['workPolicy'].toString();
        }
        _loadedUid = uid;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load profile: $error';
      });
    }
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _taglineCtrl.dispose();
    _missionCtrl.dispose();
    _cultureCtrl.dispose();
    _foundedCtrl.dispose();
    _fundingCtrl.dispose();
    _locationCtrl.dispose();
    _industryCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: _surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onSave() async {
    if (_isLoading || _isSaving || _isPickingImage || _loadedUid == null) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnack('Please complete all required fields.');
      return;
    }
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null || uid != _loadedUid) {
      _showSnack('Sign in again to edit your profile.');
      return;
    }
    if ((_pickedLogo?.length ?? 0) + (_pickedCover?.length ?? 0) > 300000) {
      _showSnack('Choose images with a combined size below 300 KB.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await AuthService.instance.saveUserProfile(uid, {
        if (_pickedLogo != null) 'logoBase64': base64Encode(_pickedLogo!),
        if (_pickedCover != null) 'coverBase64': base64Encode(_pickedCover!),
        'companyName': _companyNameCtrl.text.trim(),
        'tagline': _taglineCtrl.text.trim(),
        'mission': _missionCtrl.text.trim(),
        'culture': _cultureCtrl.text.trim(),
        'founded': _foundedCtrl.text.trim(),
        'funding': _fundingCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'industry': _industryCtrl.text.trim(),
        'workPolicy': _selectedWorkPolicy,
      });
      if (!mounted) return;
      _showSnack('Company profile saved.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _loadError != null) {
      return Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(title: const Text('Company Profile Editor')),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _inputBorder.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: _whiteText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Company Profile Editor',
                      style: TextStyle(
                        color: _whiteText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving || _isPickingImage ? null : _onSave,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _cyanAccent,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: _cyanAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionTitle(title: 'Branding'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _cyanAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Visual Identity',
                              style: TextStyle(
                                color: _cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _EditorCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: _pickedLogo != null
                                          ? MemoryImage(_pickedLogo!)
                                          : const AssetImage(
                                                  'assets/connect_smarter_logo.png',
                                                )
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _pickImage(true),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: _cyanAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _EditorTextField(
                              label: 'COMPANY NAME',
                              controller: _companyNameCtrl,
                              validator: _requiredValidator,
                            ),
                            const SizedBox(height: 16),
                            _EditorTextField(
                              label: 'TAGLINE',
                              controller: _taglineCtrl,
                              validator: _requiredValidator,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _EditorCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                top: 16,
                                bottom: 12,
                              ),
                              child: Text(
                                'COVER IMAGE',
                                style: TextStyle(
                                  color: _mutedText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _pickImage(false),
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  image: DecorationImage(
                                    image: _pickedCover != null
                                        ? MemoryImage(_pickedCover!)
                                        : const AssetImage(
                                                'assets/Background.png',
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      const _SectionTitle(title: 'Mission & Culture'),
                      const SizedBox(height: 12),
                      _EditorCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EditorTextField(
                              label: 'MISSION STATEMENT',
                              controller: _missionCtrl,
                              validator: _requiredValidator,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _EditorTextField(
                              label: 'CULTURE DESCRIPTION',
                              controller: _cultureCtrl,
                              validator: _requiredValidator,
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      const _SectionTitle(title: 'Key Company Details'),
                      const SizedBox(height: 12),
                      _EditorCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _EditorTextField(
                                    label: 'FOUNDED',
                                    controller: _foundedCtrl,
                                    validator: _requiredValidator,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _EditorTextField(
                                    label: 'FUNDING',
                                    controller: _fundingCtrl,
                                    validator: _requiredValidator,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'WORK POLICY',
                              style: TextStyle(
                                color: _mutedText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedWorkPolicy,
                              items: _workPolicyOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          color: _whiteText,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedWorkPolicy = val);
                                }
                              },
                              dropdownColor: _inputFill,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: _mutedText,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _inputFill,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: _inputBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: _cyanAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _EditorTextField(
                              label: 'LOCATION',
                              controller: _locationCtrl,
                              validator: _requiredValidator,
                              prefixIcon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 16),
                            _EditorTextField(
                              label: 'INDUSTRY',
                              controller: _industryCtrl,
                              validator: _requiredValidator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// REUSABLE WIDGETS

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _whiteText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _EditorCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _inputBorder.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

class _EditorTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _EditorTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: _whiteText, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _cyanAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: _mutedText, size: 20)
                : null,
          ),
        ),
      ],
    );
  }
}
