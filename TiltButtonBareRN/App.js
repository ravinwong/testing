import React from 'react';
import {SafeAreaView, StyleSheet, Text, View, Alert} from 'react-native';
import {GestureHandlerRootView} from 'react-native-gesture-handler';
import {TiltButton} from './src/components';

const App = () => {
  const handlePress = buttonName => {
    Alert.alert('Button Pressed', `You pressed: ${buttonName}`);
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.content}>
          <Text style={styles.title}>3D Tilt Button Demo</Text>
          <Text style={styles.subtitle}>
            Slide your finger across the buttons to see the tilt effect
          </Text>

          <View style={styles.buttonContainer}>
            {/* Default button */}
            <TiltButton
              title="Default Tilt"
              onPress={() => handlePress('Default Tilt')}
            />

            {/* High tilt button */}
            <TiltButton
              title="High Tilt (25°)"
              width={220}
              height={55}
              maxTiltDeg={25}
              backgroundColor="#34C759"
              onPress={() => handlePress('High Tilt')}
            />

            {/* Subtle tilt button */}
            <TiltButton
              title="Subtle Tilt (8°)"
              width={220}
              height={55}
              maxTiltDeg={8}
              backgroundColor="#FF9500"
              onPress={() => handlePress('Subtle Tilt')}
            />

            {/* Square button */}
            <TiltButton
              title="Square"
              width={120}
              height={120}
              maxTiltDeg={20}
              backgroundColor="#AF52DE"
              borderRadius={20}
              onPress={() => handlePress('Square')}
            />

            {/* Wide button */}
            <TiltButton
              title="Wide Button - Slide across me!"
              width={300}
              height={50}
              maxTiltDeg={12}
              backgroundColor="#FF3B30"
              onPress={() => handlePress('Wide Button')}
            />
          </View>
        </View>
      </SafeAreaView>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  safeArea: {
    flex: 1,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    paddingTop: 40,
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1C1C1E',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#8E8E93',
    textAlign: 'center',
    marginBottom: 40,
  },
  buttonContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 24,
  },
});

export default App;
