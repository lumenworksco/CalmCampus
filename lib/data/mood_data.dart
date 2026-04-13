/// Shared mood emoji and label mapping used across the app.
const moodData = <int, (String, String)>{
  1: ('\u{1F61E}', 'Awful'),
  2: ('\u{1F614}', 'Bad'),
  3: ('\u{1F610}', 'Okay'),
  4: ('\u{1F642}', 'Good'),
  5: ('\u{1F60A}', 'Great'),
};

/// Returns the emoji for a mood rating (1-5), or a neutral face as default.
String moodEmoji(int rating) => moodData[rating]?.$1 ?? '\u{1F610}';

/// Returns the label for a mood rating (1-5), or empty string as default.
String moodLabel(int rating) => moodData[rating]?.$2 ?? '';
