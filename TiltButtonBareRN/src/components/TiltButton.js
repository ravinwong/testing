import React from 'react';
import {StyleSheet, Text} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  interpolate,
  clamp,
} from 'react-native-reanimated';
import {Gesture, GestureDetector} from 'react-native-gesture-handler';

/**
 * TiltButton - A button that tilts in 3D based on touch position
 *
 * When you press on the right side, the left side tilts up (and vice versa)
 * When you press in the middle, it stays flat
 * Supports continuous sliding touch for real-time tilt updates
 *
 * @param {string} title - Button text
 * @param {number} width - Button width (default: 200)
 * @param {number} height - Button height (default: 60)
 * @param {number} maxTiltDeg - Maximum tilt angle in degrees (default: 15)
 * @param {string} backgroundColor - Button background color (default: #007AFF)
 * @param {string} textColor - Button text color (default: #FFFFFF)
 * @param {number} borderRadius - Button border radius (default: 12)
 * @param {function} onPress - Callback when button is tapped
 */
const TiltButton = ({
  title = 'Press Me',
  width = 200,
  height = 60,
  maxTiltDeg = 15,
  backgroundColor = '#007AFF',
  textColor = '#FFFFFF',
  borderRadius = 12,
  onPress,
}) => {
  // Shared values for tracking touch position relative to button center
  // Range: -1 (left/top edge) to 1 (right/bottom edge), 0 = center
  const touchX = useSharedValue(0);
  const touchY = useSharedValue(0);
  const isPressed = useSharedValue(false);

  // Track the starting position for the gesture
  const startX = useSharedValue(0);
  const startY = useSharedValue(0);

  const panGesture = Gesture.Pan()
    .onBegin(event => {
      isPressed.value = true;

      // Calculate initial touch position relative to button center
      // event.x and event.y are relative to the component
      const normalizedX = (event.x - width / 2) / (width / 2);
      const normalizedY = (event.y - height / 2) / (height / 2);

      touchX.value = clamp(normalizedX, -1, 1);
      touchY.value = clamp(normalizedY, -1, 1);

      // Store starting position for delta calculations
      startX.value = event.x;
      startY.value = event.y;
    })
    .onUpdate(event => {
      // Calculate current position based on start + translation
      const currentX = startX.value + event.translationX;
      const currentY = startY.value + event.translationY;

      // Normalize to -1 to 1 range
      const normalizedX = (currentX - width / 2) / (width / 2);
      const normalizedY = (currentY - height / 2) / (height / 2);

      touchX.value = clamp(normalizedX, -1, 1);
      touchY.value = clamp(normalizedY, -1, 1);
    })
    .onEnd(() => {
      // Check if finger is still roughly within button bounds for onPress
      if (
        Math.abs(touchX.value) <= 1.2 &&
        Math.abs(touchY.value) <= 1.2 &&
        onPress
      ) {
        // Run on JS thread for the callback
        onPress();
      }
    })
    .onFinalize(() => {
      isPressed.value = false;
      // Spring back to flat position
      touchX.value = withSpring(0, {
        damping: 15,
        stiffness: 150,
        mass: 0.5,
      });
      touchY.value = withSpring(0, {
        damping: 15,
        stiffness: 150,
        mass: 0.5,
      });
    });

  const animatedStyle = useAnimatedStyle(() => {
    // Calculate rotation angles
    // Tilt in OPPOSITE direction of touch:
    // - Touch on right (positive X) → rotate Y negative → left side comes up
    // - Touch on bottom (positive Y) → rotate X positive → top side comes up
    const rotateY = interpolate(touchX.value, [-1, 0, 1], [maxTiltDeg, 0, -maxTiltDeg]);

    const rotateX = interpolate(touchY.value, [-1, 0, 1], [-maxTiltDeg, 0, maxTiltDeg]);

    // Subtle scale effect when pressed
    const scale = isPressed.value ? 0.98 : 1;

    return {
      transform: [
        {perspective: 800},
        {rotateX: `${rotateX}deg`},
        {rotateY: `${rotateY}deg`},
        {scale: withSpring(scale, {damping: 20, stiffness: 300})},
      ],
    };
  });

  return (
    <GestureDetector gesture={panGesture}>
      <Animated.View
        style={[
          styles.button,
          {
            width,
            height,
            backgroundColor,
            borderRadius,
          },
          animatedStyle,
        ]}>
        <Text style={[styles.text, {color: textColor}]}>{title}</Text>
      </Animated.View>
    </GestureDetector>
  );
};

const styles = StyleSheet.create({
  button: {
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    elevation: 8,
  },
  text: {
    fontSize: 16,
    fontWeight: '600',
  },
});

export default TiltButton;
