import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/services/record_parser.dart';

void main() {
  test('malformed public job can render without unsafe casts', () {
    final job = parseJobRecord('real-id', {
      'id': 'spoofed-id',
      'title': 12,
      'ownerId': <String>[],
      'company': {'unexpected': 'object'},
      'location': false,
      'description': 44,
      'education': ['degree'],
      'minExperience': double.infinity,
      'skills': [
        42,
        null,
        ' Dart ',
        {'skill': 'Python'},
        '',
      ],
      'questions': 'not a list',
      'isPublic': 'true',
    });
    expect(job['id'], 'real-id');
    expect(job['ownerId'], isNull);
    expect(job['title'] as String, 'Untitled listing');
    expect(job['company'] as String, 'Company not provided');
    expect(job['location'] as String, 'Location not provided');
    expect(job['description'] as String, isEmpty);
    expect(job['education'] as String, isEmpty);
    expect(job['minExperience'] as num?, isNull);
    expect(List<String>.from(job['skills']), ['Dart']);
    expect(job['questions'], isEmpty);
    expect(job['isPublic'], false);
  });

  test('older jobs keep valid content and default missing fields', () {
    final job = parseJobRecord('legacy', {
      'title': 'Developer',
      'ownerId': 'company',
      'skills': ['Flutter', 'Dart'],
      'minExperience': 3.0,
      'isPublic': true,
    });
    expect(job['title'], 'Developer');
    expect(job['ownerId'], 'company');
    expect(job['skills'], ['Flutter', 'Dart']);
    expect(job['description'], '');
    expect(job['minExperience'], 3);
    expect(job['isPublic'], true);
  });

  test(
    'candidate-authored malformed applications have safe display values',
    () {
      final item = parseApplicationRecord('application-id', {
        'jobTitle': null,
        'candidateName': {'name': 'Someone'},
        'profile': false,
        'email': <String>[],
        'status': 'made-up',
        'skills': [false, 'Python', 1],
      });
      expect(item['candidateName'], 'Candidate');
      expect(item['jobTitle'], 'Unavailable listing');
      expect(item['profile'], 'Profile not provided');
      expect(item['email'], isEmpty);
      expect(item['status'], 'unknown');
      expect(List<String>.from(item['skills']), ['Python']);
    },
  );

  test('oversized lists and strings have bounded display output', () {
    expect(recordTextList(List.filled(150, 'Dart')).length, 100);
    expect(recordTextList(['x' * 121, 'Python']), ['Python']);
    expect(recordText('x' * 250, maxLength: 200).length, 200);
    expect(
      recordTextList({
        'skills': ['Dart'],
      }),
      isEmpty,
    );
    expect(recordTextList(null), isEmpty);
  });
}
