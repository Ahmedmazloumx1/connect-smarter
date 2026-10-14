const Map<String, List<Map<String, dynamic>>> questionBank = {
  'design': [
    {
      'q': 'Walk me through your design process from brief to final delivery.',
      'hints': ['research', 'wireframe', 'prototype', 'feedback', 'iterate'],
    },
    {
      'q': 'How do you balance aesthetic appeal with usability in your work?',
      'hints': ['user', 'test', 'accessibility', 'visual', 'usability'],
    },
    {
      'q':
          'Describe a time you received harsh feedback on a design. How did you respond?',
      'hints': ['feedback', 'iterate', 'improve', 'stakeholder', 'revise'],
    },
    {
      'q': 'What tools do you use for prototyping, and why?',
      'hints': ['figma', 'adobe', 'sketch', 'prototype', 'collaborate'],
    },
    {
      'q': 'How do you validate a design decision with real users?',
      'hints': ['user test', 'research', 'interview', 'data', 'feedback'],
    },
  ],
  'flutter': [
    {
      'q': 'What is the difference between StatelessWidget and StatefulWidget?',
      'hints': ['state', 'rebuild', 'immutable', 'mutable', 'widget'],
    },
    {
      'q': 'How does the Flutter widget tree work?',
      'hints': ['tree', 'hierarchy', 'build', 'render', 'compose'],
    },
    {
      'q': 'Explain what BuildContext is and why it matters.',
      'hints': ['context', 'tree', 'location', 'theme', 'navigate'],
    },
    {
      'q': 'How would you manage state in a large Flutter application?',
      'hints': ['provider', 'bloc', 'riverpod', 'getx', 'state'],
    },
    {
      'q': 'What is the difference between hot reload and hot restart?',
      'hints': ['state', 'preserved', 'faster', 'restart', 'dart'],
    },
  ],
  'frontend': [
    {
      'q': 'What is the difference between let, const, and var in JavaScript?',
      'hints': ['scope', 'block', 'function', 'reassign', 'variable'],
    },
    {
      'q': 'Explain the concept of the CSS box model.',
      'hints': ['margin', 'padding', 'border', 'content', 'box'],
    },
    {
      'q': 'What is the DOM and how does JavaScript interact with it?',
      'hints': ['document', 'element', 'manipulate', 'event', 'tree'],
    },
    {
      'q': 'What are React hooks and why were they introduced?',
      'hints': ['useState', 'useEffect', 'functional', 'class', 'lifecycle'],
    },
    {
      'q': 'How do you optimise a webpage for performance?',
      'hints': ['lazy', 'cache', 'compress', 'minify', 'cdn'],
    },
  ],
  'backend': [
    {
      'q': 'What is the difference between REST and GraphQL?',
      'hints': ['endpoint', 'query', 'flexible', 'over-fetch', 'schema'],
    },
    {
      'q': 'How do you design a scalable API?',
      'hints': ['rate limit', 'cache', 'versioning', 'stateless', 'load'],
    },
    {
      'q': 'Explain database indexing and when you would use it.',
      'hints': ['speed', 'query', 'primary', 'search', 'performance'],
    },
    {
      'q': 'What is the difference between SQL and NoSQL databases?',
      'hints': ['schema', 'flexible', 'relational', 'document', 'scale'],
    },
    {
      'q':
          'How do you handle authentication and authorisation in a backend system?',
      'hints': ['jwt', 'oauth', 'token', 'session', 'role'],
    },
  ],
  'default': [
    {
      'q': 'Tell me about yourself and your professional background.',
      'hints': ['experience', 'skills', 'background', 'project', 'role'],
    },
    {
      'q': 'What is your greatest professional strength?',
      'hints': ['problem', 'communicate', 'team', 'lead', 'deliver'],
    },
    {
      'q':
          'Describe a challenging project you worked on and how you overcame it.',
      'hints': ['challenge', 'solution', 'team', 'deliver', 'result'],
    },
    {
      'q': 'Where do you see yourself professionally in 3–5 years?',
      'hints': ['grow', 'lead', 'expert', 'skill', 'contribute'],
    },
    {
      'q': 'Why are you interested in this role?',
      'hints': ['passion', 'skill', 'opportunity', 'grow', 'match'],
    },
  ],
};

List<Map<String, dynamic>> questionsFor(String major) {
  final normalized = major.trim().toLowerCase();
  final key = questionBank.keys.firstWhere(
    (key) => key != 'default' && normalized.contains(key),
    orElse: () => 'default',
  );
  return List.unmodifiable(questionBank[key]!);
}
