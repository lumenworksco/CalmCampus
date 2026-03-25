import React from 'react';
import { ScrollView, Text, View, StyleSheet } from 'react-native';
import { Colors } from '../../constants/colors';
import TrendChart from '../../components/TrendChart';
import { getWeeklyData, getWeeklyInsight } from '../../data/dataEngine';

export default function InsightsScreen() {
  const weeklyData = getWeeklyData(7);
  const insight = getWeeklyInsight();
  const labels = weeklyData.map((d) => d.dayLabel);

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Text style={styles.heading}>Insights</Text>
        <Text style={styles.subtitle}>7-day behavioral trends</Text>
      </View>

      {/* AI Insight */}
      <View style={styles.insightCard}>
        <View style={styles.insightRow}>
          <Text style={styles.insightIcon}>{'\u{2728}'}</Text>
          <View style={styles.insightContent}>
            <Text style={styles.insightTitle}>Summary</Text>
            <Text style={styles.insightText}>{insight}</Text>
          </View>
        </View>
      </View>

      <TrendChart
        title="Wellness Score"
        data={weeklyData.map((d) => d.wellnessScore)}
        labels={labels}
        color={Colors.success}
      />

      <TrendChart
        title="Sleep"
        data={weeklyData.map((d) => d.sleepHours)}
        labels={labels}
        color={Colors.purple}
        suffix="h"
      />

      <TrendChart
        title="Screen Time"
        data={weeklyData.map((d) => d.screenTimeHours)}
        labels={labels}
        color={Colors.warning}
        suffix="h"
      />

      <TrendChart
        title="Focus Score"
        data={weeklyData.map((d) => Math.round(100 - (d.appSwitches / 30) * 100))}
        labels={labels}
        color={Colors.accent}
        suffix="%"
      />

      <View style={{ height: 40 }} />
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
  heading: {
    fontSize: 34,
    fontWeight: '700',
    color: Colors.text,
    letterSpacing: 0.4,
  },
  subtitle: {
    fontSize: 15,
    color: Colors.textSecondary,
    marginTop: 4,
  },
  insightCard: {
    marginHorizontal: 20,
    marginTop: 20,
    marginBottom: 8,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  insightRow: {
    flexDirection: 'row',
  },
  insightIcon: {
    fontSize: 20,
    marginRight: 12,
    marginTop: 2,
  },
  insightContent: {
    flex: 1,
  },
  insightTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 4,
  },
  insightText: {
    fontSize: 14,
    color: Colors.textSecondary,
    lineHeight: 20,
  },
});
