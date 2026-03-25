/**
 * Deterministic data generation engine for CalmCampus.
 *
 * Generates realistic behavioral data based on the actual date.
 * The same date always produces the same values (seeded by date string),
 * but values vary naturally across days with patterns like:
 *   - Weekday stress (worse sleep, more screen time mid-week)
 *   - Weekend recovery
 *   - Gradual trends over weeks
 *   - Occasional "bad days"
 */

export interface DailyData {
  date: string;
  dayLabel: string;
  dayOfWeek: number; // 0=Sun, 6=Sat
  sleepHours: number;
  screenTimeHours: number;
  typingSpeed: number;
  appSwitches: number;
  wellnessScore: number;
}

export interface BehavioralSignal {
  id: string;
  label: string;
  value: string;
  unit: string;
  trend: 'up' | 'down' | 'stable';
  trendIsGood: boolean;
  icon: string;
}

// Simple seeded pseudo-random number generator (mulberry32)
function seededRandom(seed: number): () => number {
  return () => {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Convert date string to numeric seed
function dateSeed(dateStr: string): number {
  let hash = 0;
  for (let i = 0; i < dateStr.length; i++) {
    const char = dateStr.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash |= 0;
  }
  return Math.abs(hash);
}

// Clamp a value between min and max
function clamp(val: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, val));
}

// Round to 1 decimal
function round1(val: number): number {
  return Math.round(val * 10) / 10;
}

const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/**
 * Generate data for a single day based on date.
 * Patterns:
 *   - Mon-Wed: increasing stress (less sleep, more screen time)
 *   - Thu: peak stress day
 *   - Fri: slight recovery
 *   - Sat-Sun: recovery (better sleep, less screen time)
 */
function generateDay(date: Date): DailyData {
  const dateStr = date.toISOString().split('T')[0];
  const rand = seededRandom(dateSeed(dateStr));
  const dow = date.getDay(); // 0=Sun, 6=Sat

  // Day-of-week stress multiplier (0 = no stress, 1 = max stress)
  const stressByDay: Record<number, number> = {
    0: 0.1,  // Sunday - relaxed
    1: 0.3,  // Monday - ramping up
    2: 0.5,  // Tuesday - building
    3: 0.7,  // Wednesday - peak midweek
    4: 0.8,  // Thursday - highest stress
    5: 0.5,  // Friday - winding down
    6: 0.15, // Saturday - relaxed
  };
  const stress = stressByDay[dow];

  // Add some daily randomness (±0.15)
  const noise = (rand() - 0.5) * 0.3;
  const effectiveStress = clamp(stress + noise, 0, 1);

  // Occasional "bad day" (~10% chance)
  const isBadDay = rand() < 0.10;
  const badDayBoost = isBadDay ? 0.3 : 0;

  const totalStress = clamp(effectiveStress + badDayBoost, 0, 1);

  // Generate metrics based on stress level
  // Sleep: 8.5h when relaxed → 4.5h when very stressed
  const sleepBase = 8.5 - totalStress * 4.0;
  const sleepHours = round1(clamp(sleepBase + (rand() - 0.5) * 0.8, 4.0, 9.5));

  // Screen time: 2h when relaxed → 8h when stressed
  const screenBase = 2.5 + totalStress * 5.5;
  const screenTimeHours = round1(clamp(screenBase + (rand() - 0.5) * 1.0, 1.5, 9.0));

  // Typing speed: 55 wpm when relaxed → 30 wpm when stressed
  const typingBase = 55 - totalStress * 25;
  const typingSpeed = Math.round(clamp(typingBase + (rand() - 0.5) * 6, 25, 60));

  // App switches per hour: 8 when focused → 35 when distracted
  const switchBase = 8 + totalStress * 27;
  const appSwitches = Math.round(clamp(switchBase + (rand() - 0.5) * 6, 5, 40));

  // Wellness score: composite (weighted average of normalized metrics)
  const sleepScore = clamp((sleepHours - 4) / 5, 0, 1);         // 4h=0, 9h=1
  const screenScore = clamp(1 - (screenTimeHours - 1.5) / 7, 0, 1); // 1.5h=1, 8.5h=0
  const typingScore = clamp((typingSpeed - 25) / 35, 0, 1);     // 25=0, 60=1
  const focusScore = clamp(1 - (appSwitches - 5) / 30, 0, 1);   // 5=1, 35=0

  const rawWellness = (sleepScore * 0.35 + screenScore * 0.25 + typingScore * 0.15 + focusScore * 0.25) * 100;
  const wellnessScore = Math.round(clamp(rawWellness + (rand() - 0.5) * 6, 10, 98));

  return {
    date: dateStr,
    dayLabel: DAY_NAMES[dow],
    dayOfWeek: dow,
    sleepHours,
    screenTimeHours,
    typingSpeed,
    appSwitches,
    wellnessScore,
  };
}

/**
 * Get data for the last N days (including today).
 */
export function getWeeklyData(days: number = 7): DailyData[] {
  const result: DailyData[] = [];
  const now = new Date();

  for (let i = days - 1; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    result.push(generateDay(d));
  }

  return result;
}

/**
 * Get today's data.
 */
export function getTodayData(): DailyData {
  return generateDay(new Date());
}

/**
 * Get today's behavioral signals with trend comparison to yesterday.
 */
export function getTodaySignals(): BehavioralSignal[] {
  const today = getTodayData();
  const yesterday = generateDay((() => { const d = new Date(); d.setDate(d.getDate() - 1); return d; })());

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
      value: Math.round(100 - (today.appSwitches / 40) * 100).toString(),
      unit: '%',
      trend: today.appSwitches < yesterday.appSwitches ? 'up' : today.appSwitches > yesterday.appSwitches ? 'down' : 'stable',
      trendIsGood: today.appSwitches <= 15,
      icon: 'target',
    },
  ];
}

/**
 * Generate an AI insight based on the weekly data.
 */
export function getWeeklyInsight(): string {
  const week = getWeeklyData(7);
  const today = week[week.length - 1];
  const avgSleep = week.reduce((s, d) => s + d.sleepHours, 0) / week.length;
  const avgScreen = week.reduce((s, d) => s + d.screenTimeHours, 0) / week.length;
  const worstDay = week.reduce((worst, d) => d.wellnessScore < worst.wellnessScore ? d : worst, week[0]);
  const bestDay = week.reduce((best, d) => d.wellnessScore > best.wellnessScore ? d : best, week[0]);
  const trend = today.wellnessScore - week[0].wellnessScore;

  if (today.sleepHours < 6) {
    return `You slept only ${today.sleepHours}h last night. Sleep deprivation compounds — even one recovery night helps. Consider winding down earlier tonight.`;
  }
  if (today.screenTimeHours > 6) {
    return `Screen time is elevated at ${today.screenTimeHours}h today. Try the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.`;
  }
  if (worstDay.wellnessScore < 50) {
    return `${worstDay.dayLabel} was your toughest day this week (score: ${worstDay.wellnessScore}). Your best was ${bestDay.dayLabel} at ${bestDay.wellnessScore}. The recovery pattern looks healthy.`;
  }
  if (avgSleep < 6.5) {
    return `Your average sleep this week is ${avgSleep.toFixed(1)}h — below the recommended 7-9h. Sleep is the strongest predictor of next-day wellbeing in students.`;
  }
  if (trend > 10) {
    return `Your wellness trend is improving (+${trend} points since ${week[0].dayLabel}). Keep maintaining your current routine — consistency is key.`;
  }
  if (avgScreen > 5.5) {
    return `Average screen time is ${avgScreen.toFixed(1)}h this week. Consider setting app timers for your most-used apps to stay mindful of usage.`;
  }
  return `Your wellness has been ${today.wellnessScore >= 70 ? 'steady' : 'variable'} this week. ${bestDay.dayLabel} was your strongest day. Keep prioritizing sleep and breaks.`;
}
