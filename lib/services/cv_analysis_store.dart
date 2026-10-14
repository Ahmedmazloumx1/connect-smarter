/// Singleton that stores the result of the CV analysis in memory for the
/// current session.  This lets the app know:
///   • whether the candidate has already analysed their CV (skip upload screen)
///   • what profile/skills were detected (pass to the jobs screen)
///   • the name of the uploaded CV file (shown on the profile page)
library;

import '../models/cv_analysis.dart';

class CvAnalysisStore {
  CvAnalysisStore._();
  static final CvAnalysisStore instance = CvAnalysisStore._();

  CvAnalysis? _analysis;
  String? _cvFileName;
  int? _cvFileSizeBytes;
  DateTime? _cvUploadedAt;

  bool get hasAnalysis => _analysis != null;

  CvAnalysis? get analysis => _analysis;

  /// The filename of the uploaded CV (e.g. "my_resume.pdf")
  String? get cvFileName => _cvFileName;

  /// File size in bytes, if known.
  int? get cvFileSizeBytes => _cvFileSizeBytes;

  /// When the CV was uploaded this session.
  DateTime? get cvUploadedAt => _cvUploadedAt;

  void save(CvAnalysis analysis, {String? cvFileName, int? cvFileSizeBytes}) {
    _analysis = analysis;
    if (cvFileName != null) _cvFileName = cvFileName;
    if (cvFileSizeBytes != null) _cvFileSizeBytes = cvFileSizeBytes;
    _cvUploadedAt = DateTime.now();
  }

  void clear() {
    _analysis = null;
    _cvFileName = null;
    _cvFileSizeBytes = null;
    _cvUploadedAt = null;
  }
}
