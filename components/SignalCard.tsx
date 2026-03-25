import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Colors } from '../constants/colors';
import type { BehavioralSignal } from '../data/dataEngine';

const iconConfig: Record<string, { emoji: string; bg: string }> = {
  steps: { emoji: '\u{1F6B6}', bg: Colors.successLight },
  moon: { emoji: '\u{1F319}', bg: Colors.purpleLight },
  phone: { emoji: '\u{1F4F1}', bg: Colors.warningLight },
  keyboard: { emoji: '\u{2328}\u{FE0F}', bg: Colors.accentLight },
  target: { emoji: '\u{1F3AF}', bg: Colors.dangerLight },
};

interface SignalCardProps {
  signal: BehavioralSignal;
  isLive?: boolean;
}

export default function SignalCard({ signal, isLive }: SignalCardProps) {
  const config = iconConfig[signal.icon] || { emoji: '\u{1F4CA}', bg: '#F5F5F5' };
  const trendColor = signal.trendIsGood ? Colors.success : Colors.danger;
  const trendLabel = signal.trendIsGood
    ? (signal.trend === 'stable' ? 'Stable' : 'Good')
    : (signal.trend === 'stable' ? 'Stable' : 'Needs attention');

  return (
    <View style={styles.card}>
      <View style={[styles.iconCircle, { backgroundColor: config.bg }]}>
        <Text style={styles.icon}>{config.emoji}</Text>
      </View>
      <View style={styles.info}>
        <View style={styles.labelRow}>
          <Text style={styles.label}>{signal.label}</Text>
          {isLive && (
            <View style={styles.liveBadge}>
              <View style={styles.liveDot} />
              <Text style={styles.liveText}>LIVE</Text>
            </View>
          )}
        </View>
        <View style={styles.valueRow}>
          <Text style={styles.value}>{signal.value}</Text>
          <Text style={styles.unit}> {signal.unit}</Text>
        </View>
      </View>
      <Text style={[styles.trendText, { color: trendColor }]}>{trendLabel}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  icon: {
    fontSize: 18,
  },
  info: {
    flex: 1,
  },
  labelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 1,
  },
  label: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '400',
  },
  liveBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: 6,
    backgroundColor: '#E8FAE8',
    borderRadius: 4,
    paddingHorizontal: 5,
    paddingVertical: 1,
  },
  liveDot: {
    width: 5,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: Colors.success,
    marginRight: 3,
  },
  liveText: {
    fontSize: 9,
    fontWeight: '700',
    color: Colors.success,
    letterSpacing: 0.5,
  },
  valueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  value: {
    fontSize: 20,
    fontWeight: '600',
    color: Colors.text,
  },
  unit: {
    fontSize: 13,
    color: Colors.textSecondary,
    fontWeight: '400',
  },
  trendText: {
    fontSize: 13,
    fontWeight: '600',
  },
});
