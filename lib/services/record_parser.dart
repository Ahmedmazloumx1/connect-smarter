/// Firestore documents may predate the current schema or contain untrusted data.
/// Normalize values before screens cast them; never stringify maps as user text.
String recordText(
  Object? value, {
  String fallback = '',
  int maxLength = 10000,
}) {
  if (value is! String || value.trim().isEmpty) return fallback;
  final text = value.trim();
  return text.length <= maxLength ? text : text.substring(0, maxLength);
}

List<String> recordTextList(
  Object? value, {
  int maxItems = 100,
  int maxItemLength = 120,
}) {
  if (value is! List) return <String>[];
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty && item.length <= maxItemLength)
      .take(maxItems)
      .toList();
}

Map<String, dynamic> parseJobRecord(String id, Map<String, dynamic> data) {
  final experience = data['minExperience'];
  return {
    ...data,
    'id': id,
    'ownerId': data['ownerId'] is String ? data['ownerId'] : null,
    'title': recordText(
      data['title'],
      fallback: 'Untitled listing',
      maxLength: 200,
    ),
    'company': recordText(
      data['company'],
      fallback: 'Company not provided',
      maxLength: 200,
    ),
    'location': recordText(
      data['location'],
      fallback: 'Location not provided',
      maxLength: 200,
    ),
    'description': recordText(data['description']),
    'education': recordText(data['education'], maxLength: 200),
    'skills': recordTextList(data['skills']),
    'questions': recordTextList(
      data['questions'],
      maxItems: 20,
      maxItemLength: 2000,
    ),
    'minExperience':
        experience is num &&
            experience.isFinite &&
            experience >= 0 &&
            experience <= 80
        ? experience.toInt()
        : null,
    'isPublic': data['isPublic'] == true,
    'isRemote': data['isRemote'] == true,
    'isFullTime': data['isFullTime'] == true,
  };
}

Map<String, dynamic> parseApplicationRecord(
  String id,
  Map<String, dynamic> data,
) => {
  ...data,
  'id': id,
  'jobTitle': recordText(
    data['jobTitle'],
    fallback: 'Unavailable listing',
    maxLength: 200,
  ),
  'candidateName': recordText(
    data['candidateName'],
    fallback: 'Candidate',
    maxLength: 200,
  ),
  'email': recordText(data['email'], maxLength: 320),
  'profile': recordText(
    data['profile'],
    fallback: 'Profile not provided',
    maxLength: 200,
  ),
  'skills': recordTextList(data['skills']),
  'status':
      const ['submitted', 'shortlisted', 'rejected'].contains(data['status'])
      ? data['status']
      : 'unknown',
};
