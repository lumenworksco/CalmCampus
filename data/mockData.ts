export interface DailyData {
  date: string;
  dayLabel: string;
  sleepHours: number;
  screenTimeHours: number;
  typingSpeed: number; // words per minute
  appSwitches: number; // number of app switches per hour
  wellnessScore: number;
}

// 7 days of data showing a realistic pattern:
// Good start -> mid-week stress dip -> weekend recovery
const today = new Date();
function getDay(daysAgo: number): { date: string; dayLabel: string } {
  const d = new Date(today);
  d.setDate(d.getDate() - daysAgo);
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return {
    date: d.toISOString().split('T')[0],
    dayLabel: days[d.getDay()],
  };
}

export const weeklyData: DailyData[] = [
  { ...getDay(6), sleepHours: 7.5, screenTimeHours: 4.2, typingSpeed: 52, appSwitches: 12, wellnessScore: 82 },
  { ...getDay(5), sleepHours: 7.2, screenTimeHours: 5.1, typingSpeed: 50, appSwitches: 15, wellnessScore: 78 },
  { ...getDay(4), sleepHours: 6.1, screenTimeHours: 6.8, typingSpeed: 44, appSwitches: 22, wellnessScore: 61 },
  { ...getDay(3), sleepHours: 5.4, screenTimeHours: 7.5, typingSpeed: 38, appSwitches: 28, wellnessScore: 45 },
  { ...getDay(2), sleepHours: 5.8, screenTimeHours: 7.2, typingSpeed: 41, appSwitches: 25, wellnessScore: 52 },
  { ...getDay(1), sleepHours: 6.8, screenTimeHours: 5.5, typingSpeed: 48, appSwitches: 18, wellnessScore: 68 },
  { ...getDay(0), sleepHours: 7.3, screenTimeHours: 4.8, typingSpeed: 51, appSwitches: 14, wellnessScore: 76 },
];

export const todayData = weeklyData[weeklyData.length - 1];

export interface BehavioralSignal {
  id: string;
  label: string;
  value: string;
  unit: string;
  trend: 'up' | 'down' | 'stable';
  trendIsGood: boolean;
  icon: string;
}

export function getTodaySignals(): BehavioralSignal[] {
  const today = todayData;
  const yesterday = weeklyData[weeklyData.length - 2];

  return [
    {
      id: 'sleep',
      label: 'Sleep',
      value: today.sleepHours.toFixed(1),
      unit: 'hours',
      trend: today.sleepHours > yesterday.sleepHours ? 'up' : today.sleepHours < yesterday.sleepHours ? 'down' : 'stable',
      trendIsGood: today.sleepHours >= 7,
      icon: 'moon',
    },
    {
      id: 'screen',
      label: 'Screen Time',
      value: today.screenTimeHours.toFixed(1),
      unit: 'hours',
      trend: today.screenTimeHours > yesterday.screenTimeHours ? 'up' : today.screenTimeHours < yesterday.screenTimeHours ? 'down' : 'stable',
      trendIsGood: today.screenTimeHours <= 5,
      icon: 'phone',
    },
    {
      id: 'typing',
      label: 'Typing Pattern',
      value: today.typingSpeed.toString(),
      unit: 'wpm',
      trend: today.typingSpeed > yesterday.typingSpeed ? 'up' : today.typingSpeed < yesterday.typingSpeed ? 'down' : 'stable',
      trendIsGood: today.typingSpeed >= 45,
      icon: 'keyboard',
    },
    {
      id: 'focus',
      label: 'Focus Score',
      value: Math.round(100 - (today.appSwitches / 30) * 100).toString(),
      unit: '%',
      trend: today.appSwitches < yesterday.appSwitches ? 'up' : today.appSwitches > yesterday.appSwitches ? 'down' : 'stable',
      trendIsGood: today.appSwitches <= 15,
      icon: 'target',
    },
  ];
}
