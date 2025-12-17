import React from 'react';
import { StyleSheet, Text } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  interpolate,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';

const TiltButton = ({
  children,
  onPress,
  style,
  width = 200,
  height = 60,
  maxTiltDeg = 15,
  backgroundColor = '#007AFF',
  textColor = '#FFFFFF',
}) => {
  // Shared values for touch position (relative to center, normalized -1 to 1)
  const touchX = useSharedValue(0);
  const touchY = useSharedValue(0);
  const isPressed = useSharedValue(false);

  // Calculate center of button
  const centerX = width / 2;
  const centerY = height / 2;

  const panGesture = Gesture.Pan()
    .onBegin((event) => {
      isPressed.value = true;
      // Calculate offset from center, normalized to -1 to 1
      touchX.value = (event.x - centerX) / centerX;
      touchY.value = (event.y - centerY) / centerY;
    })
    .onUpdate((event) => {
      // Clamp values to button bounds
      const clampedX = Math.max(0, Math.min(width, event.x));
      const clampedY = Math.max(0, Math.min(height, event.y));

      touchX.value = (clampedX - centerX) / centerX;
      touchY.value = (clampedY - centerY) / centerY;
    })
    .onEnd(() => {
      isPressed.value = false;
      // Spring back to flat
      touchX.value = withSpring(0, { damping: 15, stiffness: 150 });
      touchY.value = withSpring(0, { damping: 15, stiffness: 150 });

      // Trigger onPress callback
      if (onPress) {
        onPress();
      }
    })
    .onFinalize(() => {
      isPressed.value = false;
      touchX.value = withSpring(0, { damping: 15, stiffness: 150 });
      touchY.value = withSpring(0, { damping: 15, stiffness: 150 });
    });

  const animatedStyle = useAnimatedStyle(() => {
    // Tilt in opposite direction of touch
    // Touch on right (positive X) -> rotate Y negative (left side up)
    // Touch on bottom (positive Y) -> rotate X positive (top side up)
    const rotateY = interpolate(
      touchX.value,
      [-1, 0, 1],
      [maxTiltDeg, 0, -maxTiltDeg]
    );

    const rotateX = interpolate(
      touchY.value,
      [-1, 0, 1],
      [-maxTiltDeg, 0, maxTiltDeg]
    );

    // Scale down slightly when pressed
    const scale = isPressed.value ? 0.98 : 1;

    return {
      transform: [
        { perspective: 800 },
        { rotateX: `${rotateX}deg` },
        { rotateY: `${rotateY}deg` },
        { scale: withSpring(scale, { damping: 15, stiffness: 300 }) },
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
          },
          style,
          animatedStyle,
        ]}
      >
        {typeof children === 'string' ? (
          <Text style={[styles.text, { color: textColor }]}>{children}</Text>
        ) : (
          children
        )}
      </Animated.View>
    </GestureDetector>
  );
};

const styles = StyleSheet.create({
  button: {
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 12,
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
    fontSize: 18,
    fontWeight: '600',
  },
});

export default TiltButton;
