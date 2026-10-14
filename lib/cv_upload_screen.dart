import 'package:flutter/material.dart';
import 'recommended_jobs_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'cv_analyze_screen.dart';
import 'applications_screen.dart';
import 'account_settings_screen.dart';
import 'models/cv_analysis.dart';
export 'models/cv_analysis.dart';
import 'services/cv_service.dart';
import 'services/auth_service.dart';
import 'services/cv_analysis_store.dart';
import 'services/firebase_service.dart';

class CvUploadScreen extends StatefulWidget {
  const CvUploadScreen({super.key});

  @override
  State<CvUploadScreen> createState() => _CvUploadScreenState();
}

class _CvUploadScreenState extends State<CvUploadScreen> {
  PlatformFile? _selectedCv;
  bool _isAnalyzing = false;

  Future<bool> _saveCvAnalysis(CvAnalysis analysis) async {
    CvAnalysisStore.instance.save(
      analysis,
      cvFileName: _selectedCv?.name,
      cvFileSizeBytes: _selectedCv?.size,
    );

    if (!FirebaseService.isInitialized) return false;

    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await AuthService.instance.saveUserProfile(uid, {
        'cvAnalysis': {
          'profile': analysis.profile,
          'skills': analysis.skills,
          'matchReason': analysis.matchReason,
          'fileName': _selectedCv?.name,
          'fileSizeBytes': _selectedCv?.size,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
        'detectedProfile': analysis.profile,
        'tags': analysis.skills,
      });
      return true;
    } catch (e) {
      debugPrint('CV analysis saved locally, Firestore save failed: $e');
      return false;
    }
  }

  Future<void> _pickFile() async {
    if (_isAnalyzing) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      if (result.files.first.size > CvService.maxBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a file smaller than 5 MB.')),
        );
        return;
      }
      setState(() => _selectedCv = result.files.first);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the file picker. Please retry.'),
        ),
      );
    }
  }

  void _removeFile() {
    if (_isAnalyzing) return;
    setState(() {
      _selectedCv = null;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060A1B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 36), // Balance for no back button
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Connect Smarter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Your CV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Extract the skills mentioned in your CV.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _selectedCv == null ? _pickFile : null,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1E3A5F),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCv == null
                                ? const Color(0xFF0D1230).withValues(alpha: 0.5)
                                : const Color(
                                    0xFF0D1230,
                                  ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A1F4E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF3B5BDB),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _selectedCv == null
                                    ? 'Select your CV file'
                                    : 'CV Already Selected',
                                style: TextStyle(
                                  color: _selectedCv == null
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supported formats: PDF, DOCX, TXT (Max 5MB)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use a document with selectable text',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF5B7FFF,
                                  ).withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _selectedCv == null
                                    ? _pickFile
                                    : null,
                                icon: const Icon(Icons.attach_file, size: 18),
                                label: Text(
                                  _selectedCv == null
                                      ? 'Select File'
                                      : 'File Selected',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF263DB0),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFF263DB0,
                                  ).withValues(alpha: 0.2),
                                  disabledForegroundColor: Colors.white
                                      .withValues(alpha: 0.3),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_selectedCv != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selected CV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1E2A5F,
                              ).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ready to Analyze',
                              style: TextStyle(
                                color: Color(0xFF5B7FFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final file = _selectedCv!;
                          final extension = file.extension?.toLowerCase();
                          final isPdf = extension == 'pdf';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0D1230,
                              ).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF1E3A5F,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isPdf
                                        ? const Color(
                                            0xFFFF5252,
                                          ).withValues(alpha: 0.15)
                                        : const Color(
                                            0xFF3B5BDB,
                                          ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isPdf
                                        ? Icons.picture_as_pdf
                                        : Icons.description,
                                    color: isPdf
                                        ? const Color(0xFFFF5252)
                                        : const Color(0xFF3B5BDB),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatBytes(file.size)} • Selected',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                  onPressed: _removeFile,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1230),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF5B7FFF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We extract listed skills and compare them with job requirements. Your original file is not stored.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedCv != null && !_isAnalyzing)
                          ? () async {
                              setState(() => _isAnalyzing = true);

                              try {
                                final analysis = await CvService().analyze(
                                  _selectedCv!,
                                );
                                {
                                  if (!mounted) return;
                                  final saved = await _saveCvAnalysis(analysis);

                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CvAnalyzeScreen(
                                        analysis: analysis,
                                        savedToAccount: saved,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('CV analysis failed: $e'),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isAnalyzing = false);
                                }
                              }
                            }
                          : null,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.psychology, size: 24),
                      label: Text(
                        _isAnalyzing ? 'Analyzing...' : 'Analyze CV',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1424B8),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF1424B8,
                        ).withValues(alpha: 0.3),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F24),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF1E2A5F).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home_outlined, 'Home', true),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Explore published jobs and compare their required skills with your CV.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF1424B8),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendedJobsScreen(),
                        ),
                      );
                    },
                    child: _buildBottomNavItem(Icons.search, 'Search', false),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApplicationsScreen(),
                        ),
                      );
                    },
                    child: _buildBottomNavItem(
                      Icons.notifications_none,
                      'Notifications',
                      false,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                    child: _buildBottomNavItem(
                      Icons.person_outline,
                      'Profile',
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    final color = isActive
        ? const Color(0xFF00C48C)
        : Colors.white.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
