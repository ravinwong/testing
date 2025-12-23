import React, { useState } from 'react';
import { StyleSheet, Text, View, Switch, SafeAreaView, StatusBar } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import InvisibleNumberSlider from './components/InvisibleNumberSlider';

export default function App() {
  const [value, setValue] = useState(50);
  const [showDebugZones, setShowDebugZones] = useState(false);

  return (
    <GestureHandlerRootView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.content}>
          <Text style={styles.title}>Invisible Number Slider</Text>
          <Text style={styles.subtitle}>
            An invisible gesture-based slider with stop points
          </Text>

          <View style={styles.sliderContainer}>
            <InvisibleNumberSlider
              value={value}
              onChange={setValue}
              width={320}
              height={120}
              showDebugZones={showDebugZones}
            />
          </View>

          <View style={styles.debugToggle}>
            <Text style={styles.debugLabel}>Show Debug Zones</Text>
            <Switch
              value={showDebugZones}
              onValueChange={setShowDebugZones}
              trackColor={{ false: '#767577', true: '#81b0ff' }}
              thumbColor={showDebugZones ? '#007AFF' : '#f4f3f4'}
            />
          </View>

          <View style={styles.infoCard}>
            <Text style={styles.infoTitle}>How it works:</Text>
            <View style={styles.infoRow}>
              <Text style={styles.infoBullet}>→</Text>
              <Text style={styles.infoText}>
                <Text style={styles.highlight}>Slide right</Text> to add: +1, +5, or +10
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoBullet}>←</Text>
              <Text style={styles.infoText}>
                <Text style={styles.highlight}>Slide left</Text> to subtract: -1, -5, or -10
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoBullet}>•</Text>
              <Text style={styles.infoText}>
                The further you slide, the bigger the change
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoBullet}>•</Text>
              <Text style={styles.infoText}>
                Feel the haptic feedback at each stop point
              </Text>
            </View>
          </View>

          <Text style={styles.techNote}>
            Built with react-native-gesture-handler, react-native-reanimated, and react-native-haptic-feedback
          </Text>
        </View>
      </SafeAreaView>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  safeArea: {
    flex: 1,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1C1C1E',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#8E8E93',
    marginBottom: 40,
    textAlign: 'center',
  },
  sliderContainer: {
    marginVertical: 20,
  },
  debugToggle: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 20,
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  debugLabel: {
    fontSize: 16,
    color: '#1C1C1E',
    fontWeight: '500',
  },
  infoCard: {
    marginTop: 30,
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    width: '100%',
    maxWidth: 340,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1C1C1E',
    marginBottom: 16,
  },
  infoRow: {
    flexDirection: 'row',
    marginBottom: 10,
    alignItems: 'flex-start',
  },
  infoBullet: {
    fontSize: 16,
    color: '#007AFF',
    width: 24,
    fontWeight: '600',
  },
  infoText: {
    flex: 1,
    fontSize: 15,
    color: '#3C3C43',
    lineHeight: 22,
  },
  highlight: {
    fontWeight: '600',
    color: '#007AFF',
  },
  techNote: {
    fontSize: 12,
    color: '#C7C7CC',
    marginTop: 30,
    textAlign: 'center',
    fontStyle: 'italic',
  },
});
