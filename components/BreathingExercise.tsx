import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, Animated, Easing } from 'react-native';
import { Colors } from '../constants/colors';

const PHASE_DURATION = 4000;
const phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];

export default function BreathingExercise() {
  const [isActive, setIsActive] = useState(false);
  const [currentPhase, setCurrentPhase] = useState(0);
  const [secondsLeft, setSecondsLeft] = useState(4);
  const scale = useRef(new Animated.Value(0.6)).current;
  const opacity = useRef(new Animated.Value(0.4)).current;
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const animRef = useRef<Animated.CompositeAnimation | null>(null);
  const phaseRef = useRef(0);
  const tickRef = useRef(0);

  const startBreathing = () => {
    setIsActive(true);
    phaseRef.current = 0;
    tickRef.current = 0;
    setCurrentPhase(0);
    setSecondsLeft(4);

    const breathCycle = Animated.loop(
      Animated.sequence([
        // Breathe in
        Animated.parallel([
          Animated.timing(scale, { toValue: 1.0, duration: PHASE_DURATION, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
          Animated.timing(opacity, { toValue: 1, duration: PHASE_DURATION, useNativeDriver: true }),
        ]),
        // Hold
        Animated.delay(PHASE_DURATION),
        // Breathe out
        Animated.parallel([
          Animated.timing(scale, { toValue: 0.6, duration: PHASE_DURATION, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
          Animated.timing(opacity, { toValue: 0.4, duration: PHASE_DURATION, useNativeDriver: true }),
        ]),
        // Hold
        Animated.delay(PHASE_DURATION),
      ])
    );

    animRef.current = breathCycle;
    breathCycle.start();

    intervalRef.current = setInterval(() => {
      tickRef.current += 1;
      const phaseIndex = Math.floor(tickRef.current / 4) % 4;
      const secondInPhase = 4 - (tickRef.current % 4);
      phaseRef.current = phaseIndex;
      setCurrentPhase(phaseIndex);
      setSecondsLeft(secondInPhase);
    }, 1000);
  };

  const stopBreathing = () => {
    setIsActive(false);
    if (intervalRef.current) clearInterval(intervalRef.current);
    if (animRef.current) animRef.current.stop();
    Animated.parallel([
      Animated.timing(scale, { toValue: 0.6, duration: 500, useNativeDriver: true }),
      Animated.timing(opacity, { toValue: 0.4, duration: 500, useNativeDriver: true }),
    ]).start();
    setCurrentPhase(0);
    setSecondsLeft(4);
  };

  useEffect(() => {
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      if (animRef.current) animRef.current.stop();
    };
  }, []);

  return (
    <View style={styles.container}>
      <Pressable
        onPress={isActive ? stopBreathing : startBreathing}
        style={styles.circleWrapper}
      >
        <Animated.View style={[styles.circle, { transform: [{ scale }], opacity }]}>
          <View style={styles.innerCircle}>
            {isActive ? (
              <>
                <Text style={styles.phaseText}>{phases[currentPhase]}</Text>
                <Text style={styles.timer}>{secondsLeft}</Text>
              </>
            ) : (
              <Text style={styles.startText}>Tap to Start</Text>
            )}
          </View>
        </Animated.View>
      </Pressable>
      {isActive ? (
        <Text style={styles.hint}>Tap the circle to stop</Text>
      ) : (
        <Text style={styles.description}>
          Box breathing: 4s in, hold, out, hold. A proven technique to activate your parasympathetic nervous system.
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  circleWrapper: {
    width: 220,
    height: 220,
    alignItems: 'center',
    justifyContent: 'center',
  },
  circle: {
    width: 220,
    height: 220,
    borderRadius: 110,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  innerCircle: {
    width: 140,
    height: 140,
    borderRadius: 70,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  phaseText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  timer: {
    color: '#fff',
    fontSize: 36,
    fontWeight: '700',
  },
  startText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  hint: {
    marginTop: 16,
    color: Colors.textSecondary,
    fontSize: 14,
  },
  description: {
    marginTop: 20,
    color: Colors.textSecondary,
    fontSize: 14,
    textAlign: 'center',
    paddingHorizontal: 32,
    lineHeight: 20,
  },
});
