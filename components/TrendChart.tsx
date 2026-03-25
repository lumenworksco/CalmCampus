import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { LineChart } from 'react-native-chart-kit';
import { Colors } from '../constants/colors';

interface TrendChartProps {
  title: string;
  data: number[];
  labels: string[];
  color?: string;
  suffix?: string;
}

export default function TrendChart({ title, data, labels, color = Colors.success, suffix = '' }: TrendChartProps) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{title}</Text>
        <Text style={[styles.current, { color }]}>
          {data[data.length - 1]}{suffix}
        </Text>
      </View>
      <LineChart
        data={{
          labels,
          datasets: [{ data, color: () => color, strokeWidth: 2 }],
        }}
        width={320}
        height={180}
        chartConfig={{
          backgroundColor: Colors.surface,
          backgroundGradientFrom: Colors.surface,
          backgroundGradientTo: Colors.surface,
          decimalPlaces: 1,
          color: () => Colors.border,
          labelColor: () => Colors.textTertiary,
          propsForDots: {
            r: '3',
            strokeWidth: '1.5',
            stroke: color,
            fill: '#fff',
          },
          propsForBackgroundLines: {
            strokeDasharray: '',
            stroke: Colors.borderLight,
            strokeWidth: 0.5,
          },
        }}
        bezier
        style={styles.chart}
        withInnerLines={true}
        withOuterLines={false}
        formatYLabel={(v) => `${v}${suffix}`}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 20,
    marginTop: 12,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: 4,
  },
  title: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.text,
  },
  current: {
    fontSize: 17,
    fontWeight: '700',
  },
  chart: {
    borderRadius: 12,
    marginLeft: -12,
  },
});
