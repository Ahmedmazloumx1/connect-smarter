import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';
import 'services/cv_analysis_store.dart';
import 'services/profile_image_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedMajor;

  final _profileMgr = ProfileImageManager();
  final ImagePicker _picker = ImagePicker();
  static const List<String> _baseMajorOptions = [
    'Computer Science',
    'Engineering',
    'Business',
    'Design',
    'Marketing',
    'Other',
  ];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPickingImage = false;
  String? _loadError;
  String? _loadedUid;
  Uint8List? _pickedPhoto;
  Map<String, dynamic>? _profileData;

  List<String> get _majorOptions {
    if (_selectedMajor == null || _baseMajorOptions.contains(_selectedMajor)) {
      return _baseMajorOptions;
    }
    return [_selectedMajor!, ..._baseMajorOptions];
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _loadedUid = null;
    });
    try {
      final uid = AuthService.instance.currentUser?.uid;
      if (uid == null) {
        throw StateError('Sign in again to edit your profile.');
      }
      final data = await AuthService.instance.getUserProfile(uid);
      if (!mounted) return;
      if (AuthService.instance.currentUser?.uid != uid) {
        throw StateError('Your account changed. Open your profile again.');
      }
      if (data == null) throw StateError('Your profile could not be found.');
      Uint8List? photo;
      if (data['photoBase64'] is String) {
        try {
          photo = base64Decode(data['photoBase64'] as String);
        } on FormatException {
          // A legacy invalid photo can be replaced without losing text fields.
        }
      }
      setState(() {
        _loadedUid = uid;
        _pickedPhoto = photo;
        _profileData = data;
        _firstNameController.text = (data['firstName'] ?? '').toString();
        _lastNameController.text = (data['lastName'] ?? '').toString();
        _emailController.text = (data['email'] ?? '').toString();
        _phoneController.text = (data['phone'] ?? '').toString();
        _dobController.text = (data['dateOfBirth'] ?? '').toString();
        final gender = data['gender']?.toString();
        _selectedGender = ['Male', 'Female'].contains(gender) ? gender : null;
        _selectedMajor = data['major']?.toString();
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

  Future<void> _pickImage() async {
    if (_isSaving || _isPickingImage) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111738),
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
              const Text(
                'Change Profile Photo',
                style: TextStyle(
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
                    color: const Color(0xFF3B5BDB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF3B5BDB)),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  'Use your camera',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _readImage(ImageSource.camera);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Color(0xFF1E3A5F), height: 1),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF3B5BDB),
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  'Pick an existing photo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _readImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _readImage(ImageSource source) async {
    if (!mounted || _isPickingImage || _isSaving) return;
    setState(() => _isPickingImage = true);
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted || AuthService.instance.currentUser?.uid != _loadedUid) {
        return;
      }
      if (bytes.length > 150000) {
        throw StateError('Choose a profile image smaller than 150 KB.');
      }
      setState(() => _pickedPhoto = bytes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not select image: $error')));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading || _isSaving || _isPickingImage || _loadedUid == null) {
      return;
    }
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null || uid != _loadedUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in again to edit your profile.')),
      );
      return;
    }
    if ((_pickedPhoto?.length ?? 0) > 150000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a profile image smaller than 150 KB.'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await AuthService.instance.saveUserProfile(uid, {
        if (_pickedPhoto != null) 'photoBase64': base64Encode(_pickedPhoto!),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender,
        if (_selectedMajor != null) 'major': _selectedMajor,
      });
      if (AuthService.instance.currentUser?.uid == uid) {
        _profileMgr.profileImage.value = _pickedPhoto;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF00C48C),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B5BDB),
            surface: Color(0xFF111738),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF3B5BDB))
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

    final fullName = [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // CV info from store
    final store = CvAnalysisStore.instance;
    final savedCvAnalysis = _profileData?['cvAnalysis'] is Map
        ? Map<String, dynamic>.from(_profileData!['cvAnalysis'] as Map)
        : <String, dynamic>{};
    final cvName = store.cvFileName ?? savedCvAnalysis['fileName']?.toString();
    final savedSize = savedCvAnalysis['fileSizeBytes'];
    final cvSize =
        store.cvFileSizeBytes ?? (savedSize is num ? savedSize.toInt() : null);
    final detectedProfile =
        store.analysis?.profile ?? savedCvAnalysis['profile']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF3B5BDB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3B5BDB),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF1A1F3D),
                          backgroundImage: _pickedPhoto != null
                              ? MemoryImage(_pickedPhoto!)
                              : const AssetImage('assets/user_profile.png')
                                    as ImageProvider,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B5BDB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName.isNotEmpty ? fullName : 'Your Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedMajor != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedMajor!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildSectionLabel('PERSONAL INFORMATION'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('First Name', _firstNameController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField('Last Name', _lastNameController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Email Address',
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Phone Number',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111738),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            dropdownColor: const Color(0xFF111738),
                            hint: const Text(
                              'Select',
                              style: TextStyle(color: Colors.grey),
                            ),
                            isExpanded: true,
                            items: ['Male', 'Female']
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      g,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Date of Birth',
              _dobController,
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            // Major dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Major',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111738),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMajor,
                      dropdownColor: const Color(0xFF111738),
                      hint: const Text(
                        'Select Major',
                        style: TextStyle(color: Colors.grey),
                      ),
                      isExpanded: true,
                      items: _majorOptions
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMajor = v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionLabel('CV / RESUME'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111738),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cvName != null
                      ? const Color(0xFF3B5BDB).withValues(alpha: 0.4)
                      : const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: cvName != null
                        ? const Color(0xFF3B5BDB)
                        : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cvName ?? 'No CV uploaded yet',
                          style: TextStyle(
                            color: cvName != null ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cvName != null && cvSize != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Uploaded • ${_formatSize(cvSize)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ] else if (cvName == null) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Upload your CV from the home screen',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                        if (detectedProfile != null &&
                            detectedProfile.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$detectedProfile profile detected',
                            style: const TextStyle(
                              color: Color(0xFF00C48C),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (cvName != null)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00C48C),
                      size: 20,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving || _isPickingImage ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bookmark_outline),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly || identical(controller, _emailController),
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF111738),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
