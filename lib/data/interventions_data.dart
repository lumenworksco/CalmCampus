class CampusResource {
  final String id;
  final String name;
  final String type;
  final String description;
  final String? contact;

  const CampusResource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.contact,
  });
}

const mindfulnessPrompts = [
  "What's one thing you can see, hear, and feel right now?",
  'Notice your breathing. Is it shallow or deep? Just observe without changing it.',
  'What emotion are you feeling right now? Name it without judgement.',
  "Think of one thing that went well today, no matter how small.",
  'Scan your body from head to toe. Where are you holding tension?',
  'What would you say to a friend feeling the way you do right now?',
  'Take a moment to appreciate something in your environment.',
  "What's one thing you're looking forward to, even if it's small?",
];

const campusResources = [
  CampusResource(
    id: 'counseling',
    name: 'Student Counseling KU Leuven',
    type: 'Professional',
    description: 'Free confidential support for all KU Leuven students.',
    contact: 'studentenvoorzieningen@kuleuven.be',
  ),
  CampusResource(
    id: 'crisis',
    name: 'Tele-Onthaal',
    type: 'Crisis',
    description: '24/7 anonymous support for anyone in emotional distress.',
    contact: '106',
  ),
  CampusResource(
    id: 'peer',
    name: 'Student Buddy Program',
    type: 'Peer Support',
    description: 'Connect with trained student volunteers who understand.',
  ),
];
