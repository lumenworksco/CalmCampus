import React, { useState } from 'react';
import { ScrollView, View, Text, StyleSheet, Pressable } from 'react-native';
import { Colors } from '../../constants/colors';
import BreathingExercise from '../../components/BreathingExercise';
import { mindfulnessPrompts, campusResources } from '../../data/interventions';

export default function InterventionsScreen() {
  const [promptIndex, setPromptIndex] = useState(0);

  const nextPrompt = () => {
    setPromptIndex((i) => (i + 1) % mindfulnessPrompts.length);
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Text style={styles.heading}>Calm</Text>
        <Text style={styles.subtitle}>Evidence-based wellbeing tools</Text>
      </View>

      {/* Breathing */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Box Breathing</Text>
        <BreathingExercise />
      </View>

      {/* Mindfulness */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Mindfulness</Text>
        <Text style={styles.promptText}>{mindfulnessPrompts[promptIndex]}</Text>
        <Pressable onPress={nextPrompt} style={({ pressed }) => [styles.pillButton, pressed && { opacity: 0.7 }]}>
          <Text style={styles.pillButtonText}>Next Prompt</Text>
        </Pressable>
      </View>

      {/* Quick Actions */}
      <Text style={styles.sectionTitle}>Quick Actions</Text>
      <View style={styles.actionRow}>
        <View style={styles.actionCard}>
          <Text style={styles.actionIcon}>{'\u{1F6B6}'}</Text>
          <Text style={styles.actionTitle}>Take a Walk</Text>
          <Text style={styles.actionDesc}>10 min reset</Text>
        </View>
        <View style={styles.actionCard}>
          <Text style={styles.actionIcon}>{'\u{1F4AC}'}</Text>
          <Text style={styles.actionTitle}>Reach Out</Text>
          <Text style={styles.actionDesc}>Message a friend</Text>
        </View>
      </View>

      {/* Campus Resources */}
      <Text style={styles.sectionTitle}>Campus Resources</Text>
      <View style={styles.resourcesCard}>
        {campusResources.map((resource, i) => (
          <React.Fragment key={resource.id}>
            <View style={styles.resourceRow}>
              <View style={styles.resourceInfo}>
                <Text style={styles.resourceName}>{resource.name}</Text>
                <Text style={styles.resourceDesc}>{resource.description}</Text>
                {resource.contact && (
                  <Text style={styles.resourceContact}>{resource.contact}</Text>
                )}
              </View>
              <View style={styles.resourceBadge}>
                <Text style={styles.resourceBadgeText}>{resource.type}</Text>
              </View>
            </View>
            {i < campusResources.length - 1 && <View style={styles.separator} />}
          </React.Fragment>
        ))}
      </View>

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
  card: {
    marginHorizontal: 20,
    marginTop: 16,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: Colors.text,
  },
  promptText: {
    fontSize: 17,
    color: Colors.text,
    lineHeight: 24,
    fontStyle: 'italic',
    marginTop: 12,
  },
  pillButton: {
    marginTop: 16,
    alignSelf: 'flex-start',
    backgroundColor: Colors.accent,
    borderRadius: 20,
    paddingHorizontal: 18,
    paddingVertical: 9,
  },
  pillButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 14,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: Colors.text,
    marginTop: 28,
    marginBottom: 12,
    marginHorizontal: 20,
  },
  actionRow: {
    flexDirection: 'row',
    gap: 12,
    marginHorizontal: 20,
  },
  actionCard: {
    flex: 1,
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  actionIcon: {
    fontSize: 28,
    marginBottom: 8,
  },
  actionTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 2,
  },
  actionDesc: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  resourcesCard: {
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
  resourceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  resourceInfo: {
    flex: 1,
  },
  resourceName: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.text,
    marginBottom: 2,
  },
  resourceDesc: {
    fontSize: 13,
    color: Colors.textSecondary,
    lineHeight: 18,
  },
  resourceContact: {
    marginTop: 4,
    fontSize: 13,
    fontWeight: '600',
    color: Colors.accent,
  },
  resourceBadge: {
    backgroundColor: Colors.successLight,
    borderRadius: 8,
    paddingHorizontal: 8,
    paddingVertical: 3,
    marginLeft: 8,
  },
  resourceBadgeText: {
    fontSize: 11,
    fontWeight: '600',
    color: Colors.primaryDark,
  },
  separator: {
    height: 0.5,
    backgroundColor: Colors.border,
    marginLeft: 16,
  },
});
