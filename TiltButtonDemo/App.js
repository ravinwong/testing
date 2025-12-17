import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, Alert } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import TiltButton from './components/TiltButton';

export default function App() {
  const handlePress = () => {
    Alert.alert('Button Pressed', 'The tilt button was pressed!');
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Tilt Button Demo</Text>
        <Text style={styles.subtitle}>
          Slide your finger across the button to see it tilt
        </Text>

        <View style={styles.buttonContainer}>
          <TiltButton onPress={handlePress} width={220} height={60}>
            Press Me
          </TiltButton>
        </View>

        <View style={styles.buttonContainer}>
          <TiltButton
            onPress={handlePress}
            width={180}
            height={50}
            backgroundColor="#34C759"
            maxTiltDeg={20}
          >
            More Tilt
          </TiltButton>
        </View>

        <View style={styles.buttonContainer}>
          <TiltButton
            onPress={handlePress}
            width={250}
            height={70}
            backgroundColor="#FF3B30"
            maxTiltDeg={10}
          >
            Subtle Tilt
          </TiltButton>
        </View>

        <View style={styles.buttonContainer}>
          <TiltButton
            onPress={handlePress}
            width={150}
            height={150}
            backgroundColor="#5856D6"
            maxTiltDeg={25}
            style={styles.squareButton}
          >
            <Text style={styles.squareText}>Square</Text>
          </TiltButton>
        </View>

        <Text style={styles.instructions}>
          Touch different areas of the button and slide your finger to see the
          3D tilt effect. The button tilts opposite to where you touch.
        </Text>

        <StatusBar style="auto" />
      </View>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
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
  buttonContainer: {
    marginVertical: 15,
  },
  squareButton: {
    borderRadius: 20,
  },
  squareText: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '600',
  },
  instructions: {
    fontSize: 14,
    color: '#8E8E93',
    textAlign: 'center',
    marginTop: 40,
    paddingHorizontal: 20,
    lineHeight: 20,
  },
});
