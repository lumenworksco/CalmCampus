enum ContactType { email, phone, url, none }

class CampusResource {
  final String id;
  final String name;
  final String type;
  final String description;
  final String? contact;
  final ContactType contactType;
  final String? actionUrl;
  final bool isEmergency;

  const CampusResource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.contact,
    this.contactType = ContactType.none,
    this.actionUrl,
    this.isEmergency = false,
  });
}

const mindfulnessPrompts = [
  "What's one thing you can see, hear, and feel right now?",
  'Notice your breathing. Is it shallow or deep? Just observe without changing it.',
  'What emotion are you feeling right now? Name it without judgement.',
  'Think of one thing that went well today, no matter how small.',
  'Scan your body from head to toe. Where are you holding tension?',
  'What would you say to a friend feeling the way you do right now?',
  'Take a moment to appreciate something in your environment.',
  "What's one thing you're looking forward to, even if it's small?",
  'What would you tell a friend who felt the way you do right now?',
  'Name one thing you did well today, however small.',
  'Place your hand on your heart. Feel its rhythm. You are here.',
  'What is one thing you can let go of today?',
];

const campusResources = [
  CampusResource(
    id: 'counseling',
    name: 'Student Counseling KU Leuven',
    type: 'Professional',
    description: 'Free confidential support for all KU Leuven students.',
    contact: 'studentenvoorzieningen@kuleuven.be',
    contactType: ContactType.email,
    actionUrl: 'mailto:studentenvoorzieningen@kuleuven.be',
  ),
  CampusResource(
    id: 'crisis',
    name: 'Tele-Onthaal',
    type: 'Crisis',
    description: '24/7 anonymous support for anyone in emotional distress.',
    contact: '106',
    contactType: ContactType.phone,
    actionUrl: 'tel:106',
    isEmergency: true,
  ),
  CampusResource(
    id: 'peer',
    name: 'Student Buddy Program',
    type: 'Peer Support',
    description: 'Connect with trained student volunteers who understand.',
    contactType: ContactType.url,
  ),
  CampusResource(
    id: 'psychologist',
    name: 'Student Psychologist KU Leuven',
    type: 'Professional',
    description:
        'Free professional psychological support for KU Leuven students.',
    contactType: ContactType.url,
    actionUrl:
        'https://www.kuleuven.be/studentenvoorzieningen/psychologische-begeleiding',
  ),
  CampusResource(
    id: 'hak',
    name: 'HAK (Huisarts aan de KU)',
    type: 'Medical',
    description: 'On-campus general practitioner for students.',
    contact: '016 33 20 60',
    contactType: ContactType.phone,
    actionUrl: 'tel:+3216332060',
  ),
];
