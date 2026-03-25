export interface Intervention {
  id: string;
  type: 'breathing' | 'mindfulness' | 'break' | 'resource';
  title: string;
  description: string;
  duration?: string;
  icon: string;
}

export const interventions: Intervention[] = [
  {
    id: 'box-breathing',
    type: 'breathing',
    title: 'Box Breathing',
    description: 'A simple 4-4-4-4 breathing technique to calm your nervous system. Breathe in for 4 seconds, hold for 4, breathe out for 4, hold for 4.',
    duration: '2 min',
    icon: 'wind',
  },
  {
    id: 'body-scan',
    type: 'mindfulness',
    title: 'Quick Body Scan',
    description: 'Notice how each part of your body feels right now. Start from your toes and slowly move your attention upward. No need to change anything — just observe.',
    duration: '3 min',
    icon: 'person',
  },
  {
    id: 'take-a-walk',
    type: 'break',
    title: 'Take a Walk',
    description: 'Step away from your screen for 10 minutes. A short walk — even indoors — can reset your focus and lower cortisol levels.',
    duration: '10 min',
    icon: 'walk',
  },
  {
    id: 'connect',
    type: 'break',
    title: 'Reach Out',
    description: "Send a quick message to a friend or classmate. Social connection is one of the strongest buffers against stress.",
    duration: '5 min',
    icon: 'people',
  },
];

export const mindfulnessPrompts = [
  "What's one thing you can see, hear, and feel right now?",
  "Take three slow breaths. Notice how your body feels after each one.",
  "What would you tell a friend who felt the way you do right now?",
  "Name three things that went well today, no matter how small.",
  "Place your hand on your chest. Feel your heartbeat. You are here.",
  "What's one kind thing you can do for yourself in the next hour?",
  "Notice your thoughts without judgment. They are clouds passing through.",
  "What matters most to you right now? Let that guide your next step.",
];

export const campusResources = [
  {
    id: 'counseling',
    name: 'Student Counseling KU Leuven',
    description: 'Free, confidential counseling for all KU Leuven students.',
    contact: 'studentenvoorzieningen@kuleuven.be',
    type: 'Professional support',
  },
  {
    id: 'crisis',
    name: 'Tele-Onthaal',
    description: '24/7 crisis line — free and anonymous.',
    contact: '106',
    type: 'Crisis support',
  },
  {
    id: 'peer',
    name: 'Student Buddy Program',
    description: 'Connect with trained peer supporters on campus.',
    type: 'Peer support',
  },
];
