import React from 'react';
import { ScrollView, View, Text, StyleSheet, Switch } from 'react-native';
import { Colors } from '../../constants/colors';
import { useAppContext } from '../../context/AppContext';

function SettingsRow({ label, value, isLast }: { label: string; value: string; isLast?: boolean }) {
  return (
    <>
      <View style={styles.row}>
        <Text style={styles.rowLabel}>{label}</Text>
        <Text style={styles.rowValue}>{value}</Text>
      </View>
      {!isLast && <View style={styles.separator} />}
    </>
  );
}

export default function ProfileScreen() {
  const { notificationsEnabled, setNotificationsEnabled } = useAppContext();

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Text style={styles.heading}>Settings</Text>
      </View>

      {/* Privacy */}
      <Text style={styles.sectionLabel}>PRIVACY</Text>
      <View style={styles.card}>
        <SettingsRow label="Data processing" value="On-device only" />
        <SettingsRow label="Cloud storage" value="None" />
        <SettingsRow label="GDPR compliant" value="Yes" isLast />
      </View>
      <Text style={styles.footer}>
        All behavioral data is processed locally using on-device ML. No personal data ever leaves your phone.
      </Text>

      {/* Notifications */}
      <Text style={styles.sectionLabel}>NOTIFICATIONS</Text>
      <View style={styles.card}>
        <View style={styles.switchRow}>
          <View style={styles.switchInfo}>
            <Text style={styles.rowLabel}>Wellness nudges</Text>
            <Text style={styles.switchDesc}>Gentle alerts when stress is detected</Text>
          </View>
          <Switch
            value={notificationsEnabled}
            onValueChange={setNotificationsEnabled}
            trackColor={{ false: '#E5E5EA', true: Colors.success }}
          />
        </View>
      </View>

      {/* Technology */}
      <Text style={styles.sectionLabel}>TECHNOLOGY</Text>
      <View style={styles.card}>
        <SettingsRow label="On-device ML" value="TensorFlow Lite" />
        <SettingsRow label="Model training" value="Federated Learning" />
        <SettingsRow label="Privacy" value="GDPR-native" isLast />
      </View>

      {/* About */}
      <Text style={styles.sectionLabel}>ABOUT</Text>
      <View style={styles.card}>
        <SettingsRow label="Version" value="1.0.0" />
        <SettingsRow label="Framework" value="CBT & ACT" isLast />
      </View>
      <Text style={styles.footer}>
        CalmCampus detects early signs of student burnout via behavioral signals and delivers personalized micro-interventions.
      </Text>

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
  sectionLabel: {
    fontSize: 13,
    fontWeight: '400',
    color: Colors.textSecondary,
    marginTop: 28,
    marginBottom: 8,
    marginHorizontal: 20,
    letterSpacing: 0.5,
  },
  card: {
    marginHorizontal: 20,
    backgroundColor: Colors.surface,
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 2,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 13,
  },
  rowLabel: {
    fontSize: 15,
    color: Colors.text,
  },
  rowValue: {
    fontSize: 15,
    color: Colors.textSecondary,
  },
  separator: {
    height: 0.5,
    backgroundColor: Colors.border,
    marginLeft: 16,
  },
  switchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  switchInfo: {
    flex: 1,
    marginRight: 12,
  },
  switchDesc: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginTop: 2,
  },
  footer: {
    fontSize: 13,
    color: Colors.textSecondary,
    lineHeight: 18,
    marginHorizontal: 20,
    marginTop: 8,
    paddingHorizontal: 4,
  },
});
