import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Colors } from '../../constants/colors';
import WellnessGauge from '../../components/WellnessGauge';
import SignalCard from '../../components/SignalCard';
import { todayData, getTodaySignals } from '../../data/mockData';

function getGreeting(): string {
  const h = new Date().getHours();
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

export default function DashboardScreen() {
  const signals = getTodaySignals();

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Text style={styles.greeting}>{getGreeting()}</Text>
        <Text style={styles.date}>{new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</Text>
      </View>

      {/* Wellness Score Card */}
      <View style={styles.wellnessCard}>
        <WellnessGauge score={todayData.wellnessScore} />
      </View>

      {/* Signals Section */}
      <Text style={styles.sectionTitle}>Today's Signals</Text>
      <View style={styles.signalsContainer}>
        {signals.map((signal, i) => (
          <React.Fragment key={signal.id}>
            <SignalCard signal={signal} />
            {i < signals.length - 1 && <View style={styles.separator} />}
          </React.Fragment>
        ))}
      </View>

      {/* Privacy Footer */}
      <View style={styles.privacyBanner}>
        <Text style={styles.privacyIcon}>{'\u{1F512}'}</Text>
        <Text style={styles.privacyText}>
          All data stays on your device
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    paddingTop: 60,
    paddingHorizontal: 20,
    paddingBottom: 8,
  },
  greeting: {
    fontSize: 34,
    fontWeight: '700',
    color: Colors.text,
    letterSpacing: 0.4,
  },
  date: {
    fontSize: 15,
    color: Colors.textSecondary,
    marginTop: 4,
  },
  wellnessCard: {
    marginHorizontal: 20,
    marginTop: 20,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    paddingVertical: 28,
    paddingHorizontal: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: Colors.text,
    marginTop: 28,
    marginBottom: 12,
    marginHorizontal: 20,
  },
  signalsContainer: {
    marginHorizontal: 20,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  separator: {
    height: 0.5,
    backgroundColor: Colors.border,
    marginLeft: 68,
  },
  privacyBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 24,
    marginBottom: 40,
    paddingVertical: 8,
  },
  privacyIcon: {
    fontSize: 13,
    marginRight: 6,
  },
  privacyText: {
    fontSize: 13,
    color: Colors.textTertiary,
  },
});
