import { useState, useEffect } from 'react';
import { Platform } from 'react-native';
import { Pedometer } from 'expo-sensors';

interface PedometerData {
  stepsToday: number;
  isAvailable: boolean;
  isLoading: boolean;
}

export function usePedometer(): PedometerData {
  const [stepsToday, setStepsToday] = useState(0);
  const [isAvailable, setIsAvailable] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let subscription: ReturnType<typeof Pedometer.watchStepCount> | null = null;

    async function init() {
      try {
        const available = await Pedometer.isAvailableAsync();
        setIsAvailable(available);

        if (!available) {
          setIsLoading(false);
          return;
        }

        // Get steps from midnight today
        const now = new Date();
        const midnight = new Date(now);
        midnight.setHours(0, 0, 0, 0);

        const result = await Pedometer.getStepCountAsync(midnight, now);
        setStepsToday(result.steps);
        setIsLoading(false);

        // Subscribe to live updates
        subscription = Pedometer.watchStepCount((result) => {
          // watchStepCount gives incremental steps, so re-fetch total
          Pedometer.getStepCountAsync(midnight, new Date()).then((r) => {
            setStepsToday(r.steps);
          }).catch(() => {});
        });
      } catch {
        setIsLoading(false);
      }
    }

    init();

    return () => {
      subscription?.remove();
    };
  }, []);

  return { stepsToday, isAvailable, isLoading };
}
