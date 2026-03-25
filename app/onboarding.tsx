import React, { useState } from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { Colors } from '../constants/colors';
import { useAppContext } from '../context/AppContext';

const slides = [
  {
    emoji: '\u{1F9E0}',
    title: 'Welcome to\nCalmCampus',
    description: 'Your privacy-first companion for student wellbeing. Detect early signs of stress before burnout strikes.',
  },
  {
    emoji: '\u{1F512}',
    title: 'Your Data\nStays Yours',
    description: 'All behavioral analysis happens on your device. Nothing is ever sent to a server. GDPR-compliant by design.',
  },
  {
    emoji: '\u{1F33F}',
    title: 'Gentle\nInterventions',
    description: 'Evidence-based techniques — breathing exercises, mindfulness, and campus resources when you need them.',
  },
];

export default function OnboardingScreen() {
  const [step, setStep] = useState(0);
  const { setHasOnboarded } = useAppContext();

  const isLast = step === slides.length - 1;
  const slide = slides[step];

  const handleNext = () => {
    if (isLast) {
      setHasOnboarded(true);
    } else {
      setStep(step + 1);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.slideContainer}>
        <View style={styles.emojiCircle}>
          <Text style={styles.emoji}>{slide.emoji}</Text>
        </View>
        <Text style={styles.title}>{slide.title}</Text>
        <Text style={styles.description}>{slide.description}</Text>
      </View>

      <View style={styles.bottomContainer}>
        <View style={styles.dots}>
          {slides.map((_, i) => (
            <View key={i} style={[styles.dot, i === step && styles.dotActive]} />
          ))}
        </View>

        <Pressable onPress={handleNext} style={({ pressed }) => [styles.button, pressed && { opacity: 0.8 }]}>
          <Text style={styles.buttonText}>
            {isLast ? 'Get Started' : 'Continue'}
          </Text>
        </Pressable>

        {!isLast && (
          <Pressable onPress={() => setHasOnboarded(true)} style={styles.skipButton}>
            <Text style={styles.skipText}>Skip</Text>
          </Pressable>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  slideContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 44,
  },
  emojiCircle: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: Colors.background,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 32,
  },
  emoji: {
    fontSize: 40,
  },
  title: {
    fontSize: 34,
    fontWeight: '700',
    color: Colors.text,
    textAlign: 'center',
    marginBottom: 16,
    lineHeight: 41,
    letterSpacing: 0.4,
  },
  description: {
    fontSize: 17,
    color: Colors.textSecondary,
    textAlign: 'center',
    lineHeight: 24,
  },
  bottomContainer: {
    paddingHorizontal: 44,
    paddingBottom: 50,
    alignItems: 'center',
  },
  dots: {
    flexDirection: 'row',
    marginBottom: 28,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Colors.border,
    marginHorizontal: 4,
  },
  dotActive: {
    backgroundColor: Colors.accent,
    width: 24,
  },
  button: {
    backgroundColor: Colors.accent,
    borderRadius: 14,
    paddingVertical: 16,
    width: '100%',
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 17,
    fontWeight: '600',
  },
  skipButton: {
    marginTop: 16,
    padding: 8,
  },
  skipText: {
    color: Colors.accent,
    fontSize: 15,
    fontWeight: '500',
  },
});
