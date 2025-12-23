import React, { useState, useCallback, useRef } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  withTiming,
  runOnJS,
  interpolate,
  Extrapolation,
} from 'react-native-reanimated';
import * as Haptics from 'expo-haptics';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

/**
 * InvisibleNumberSlider - A gesture-based invisible slider with stop points
 *
 * How it works:
 * - The slider area is completely invisible (transparent)
 * - User drags left or right within the invisible zone
 * - There are 3 stop points in each direction:
 *   - Right: +1 (small), +5 (medium), +10 (large)
 *   - Left: -1 (small), -5 (medium), -10 (large)
 * - Visual feedback shows which stop point is being triggered
 * - Haptic feedback provides tactile confirmation
 *
 * Props:
 * - value: Current numeric value (controlled)
 * - onChange: Callback when value changes
 * - width: Width of the invisible slider zone (default: 300)
 * - height: Height of the invisible slider zone (default: 100)
 * - showDebugZones: Show the invisible zones for debugging (default: false)
 */
const InvisibleNumberSlider = ({
  value = 0,
  onChange,
  width = 300,
  height = 100,
  showDebugZones = false,
}) => {
  // Track which stop point is currently active (-3 to 3, 0 = none)
  const [activeStop, setActiveStop] = useState(0);

  // Track pending value change for display
  const [pendingChange, setPendingChange] = useState(0);

  // Ref to track which stops have been triggered during current gesture
  const triggeredStops = useRef(new Set());

  // Animation values
  const indicatorOpacity = useSharedValue(0);
  const indicatorScale = useSharedValue(1);
  const valueScale = useSharedValue(1);

  // Define stop point thresholds (percentage of half-width)
  // Each stop is at 33%, 66%, 100% of the slide distance
  const STOP_THRESHOLDS = [0.33, 0.66, 1.0];
  const STOP_VALUES = [1, 5, 10];

  // Calculate which stop point based on drag distance
  const getStopPoint = (translationX) => {
    const halfWidth = width / 2;
    const normalizedX = translationX / halfWidth;
    const absNormalized = Math.abs(normalizedX);
    const direction = normalizedX > 0 ? 1 : -1;

    // Find which threshold we've crossed
    for (let i = STOP_THRESHOLDS.length - 1; i >= 0; i--) {
      if (absNormalized >= STOP_THRESHOLDS[i]) {
        return {
          stop: (i + 1) * direction,
          value: STOP_VALUES[i] * direction,
        };
      }
    }

    return { stop: 0, value: 0 };
  };

  // Haptic feedback
  const triggerHaptic = useCallback((intensity) => {
    const absIntensity = Math.abs(intensity);
    switch (absIntensity) {
      case 1:
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        break;
      case 2:
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        break;
      case 3:
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
        break;
    }
  }, []);

  // Update state from gesture (called via runOnJS)
  const updateActiveStop = useCallback((stop, changeValue) => {
    setActiveStop(stop);
    setPendingChange(changeValue);

    // Trigger haptic if entering a new stop point
    if (stop !== 0 && !triggeredStops.current.has(stop)) {
      triggeredStops.current.add(stop);
      triggerHaptic(Math.abs(stop));
    }
  }, [triggerHaptic]);

  // Apply the value change
  const applyChange = useCallback((changeValue) => {
    if (changeValue !== 0 && onChange) {
      onChange(value + changeValue);
    }
    setActiveStop(0);
    setPendingChange(0);
    triggeredStops.current.clear();
  }, [onChange, value]);

  // Pan gesture handler
  const panGesture = Gesture.Pan()
    .onStart(() => {
      indicatorOpacity.value = withTiming(1, { duration: 150 });
      runOnJS(() => triggeredStops.current.clear())();
    })
    .onUpdate((event) => {
      const { stop, value: changeValue } = getStopPoint(event.translationX);

      // Update indicator scale based on distance
      const normalizedDistance = Math.min(Math.abs(event.translationX) / (width / 2), 1);
      indicatorScale.value = interpolate(
        normalizedDistance,
        [0, 0.33, 0.66, 1],
        [1, 1.1, 1.2, 1.3],
        Extrapolation.CLAMP
      );

      runOnJS(updateActiveStop)(stop, changeValue);
    })
    .onEnd(() => {
      indicatorOpacity.value = withTiming(0, { duration: 200 });
      indicatorScale.value = withSpring(1);

      // Animate the value
      valueScale.value = withSequence(
        withSpring(1.2, { damping: 10, stiffness: 400 }),
        withSpring(1, { damping: 15, stiffness: 300 })
      );

      runOnJS(applyChange)(pendingChange);
    });

  // Animated styles
  const indicatorStyle = useAnimatedStyle(() => ({
    opacity: indicatorOpacity.value,
    transform: [{ scale: indicatorScale.value }],
  }));

  const valueStyle = useAnimatedStyle(() => ({
    transform: [{ scale: valueScale.value }],
  }));

  // Get indicator color based on stop point
  const getIndicatorColor = () => {
    if (activeStop === 0) return '#666';
    const absStop = Math.abs(activeStop);
    const isPositive = activeStop > 0;

    if (absStop === 1) return isPositive ? '#4CD964' : '#FF6B6B';
    if (absStop === 2) return isPositive ? '#34C759' : '#FF3B30';
    return isPositive ? '#00C853' : '#D50000';
  };

  // Get change label
  const getChangeLabel = () => {
    if (pendingChange === 0) return '';
    return pendingChange > 0 ? `+${pendingChange}` : `${pendingChange}`;
  };

  return (
    <View style={styles.container}>
      {/* Current Value Display */}
      <Animated.View style={[styles.valueContainer, valueStyle]}>
        <Text style={styles.valueText}>{value}</Text>
        {pendingChange !== 0 && (
          <Text style={[styles.changePreview, { color: getIndicatorColor() }]}>
            {getChangeLabel()}
          </Text>
        )}
      </Animated.View>

      {/* Stop Point Indicator */}
      <Animated.View style={[styles.indicatorContainer, indicatorStyle]}>
        <View style={styles.stopPointsRow}>
          {/* Left stops */}
          {[-3, -2, -1].map((stop) => (
            <View
              key={stop}
              style={[
                styles.stopDot,
                {
                  backgroundColor: activeStop <= stop ? '#FF3B30' : '#DDD',
                  transform: [{ scale: activeStop === stop ? 1.3 : 1 }],
                },
              ]}
            />
          ))}

          {/* Center marker */}
          <View style={styles.centerMarker} />

          {/* Right stops */}
          {[1, 2, 3].map((stop) => (
            <View
              key={stop}
              style={[
                styles.stopDot,
                {
                  backgroundColor: activeStop >= stop ? '#34C759' : '#DDD',
                  transform: [{ scale: activeStop === stop ? 1.3 : 1 }],
                },
              ]}
            />
          ))}
        </View>

        {/* Labels */}
        <View style={styles.labelsRow}>
          <Text style={styles.labelText}>-10</Text>
          <Text style={styles.labelText}>-5</Text>
          <Text style={styles.labelText}>-1</Text>
          <View style={styles.centerSpacer} />
          <Text style={styles.labelText}>+1</Text>
          <Text style={styles.labelText}>+5</Text>
          <Text style={styles.labelText}>+10</Text>
        </View>
      </Animated.View>

      {/* Invisible Slider Zone */}
      <GestureDetector gesture={panGesture}>
        <Animated.View
          style={[
            styles.sliderZone,
            {
              width,
              height,
              backgroundColor: showDebugZones ? 'rgba(0,0,0,0.1)' : 'transparent',
            },
          ]}
        >
          {showDebugZones && (
            <>
              {/* Debug zone indicators */}
              <View style={[styles.debugZone, styles.debugZoneLeft3, { width: width * 0.17 }]}>
                <Text style={styles.debugText}>-10</Text>
              </View>
              <View style={[styles.debugZone, styles.debugZoneLeft2, { left: width * 0.17, width: width * 0.165 }]}>
                <Text style={styles.debugText}>-5</Text>
              </View>
              <View style={[styles.debugZone, styles.debugZoneLeft1, { left: width * 0.335, width: width * 0.165 }]}>
                <Text style={styles.debugText}>-1</Text>
              </View>
              <View style={[styles.debugZone, styles.debugZoneRight1, { left: width * 0.5, width: width * 0.165 }]}>
                <Text style={styles.debugText}>+1</Text>
              </View>
              <View style={[styles.debugZone, styles.debugZoneRight2, { left: width * 0.665, width: width * 0.165 }]}>
                <Text style={styles.debugText}>+5</Text>
              </View>
              <View style={[styles.debugZone, styles.debugZoneRight3, { left: width * 0.83, width: width * 0.17 }]}>
                <Text style={styles.debugText}>+10</Text>
              </View>
            </>
          )}

          {/* Swipe hint */}
          <Text style={styles.swipeHint}>← Swipe here →</Text>
        </Animated.View>
      </GestureDetector>

      {/* Instructions */}
      <Text style={styles.instructions}>
        Drag left or right to adjust the value.{'\n'}
        The further you drag, the bigger the change.
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  valueContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: 20,
  },
  valueText: {
    fontSize: 72,
    fontWeight: '200',
    color: '#1C1C1E',
  },
  changePreview: {
    fontSize: 32,
    fontWeight: '600',
    marginLeft: 8,
  },
  indicatorContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  stopPointsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 20,
  },
  stopDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  centerMarker: {
    width: 4,
    height: 20,
    backgroundColor: '#999',
    borderRadius: 2,
  },
  labelsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    gap: 12,
  },
  labelText: {
    fontSize: 12,
    color: '#8E8E93',
    width: 24,
    textAlign: 'center',
  },
  centerSpacer: {
    width: 4,
  },
  sliderZone: {
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 16,
    borderWidth: 2,
    borderColor: 'rgba(0,0,0,0.1)',
    borderStyle: 'dashed',
  },
  swipeHint: {
    fontSize: 16,
    color: '#C7C7CC',
    fontWeight: '500',
  },
  debugZone: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  debugZoneLeft3: {
    left: 0,
    backgroundColor: 'rgba(255,59,48,0.3)',
  },
  debugZoneLeft2: {
    backgroundColor: 'rgba(255,59,48,0.2)',
  },
  debugZoneLeft1: {
    backgroundColor: 'rgba(255,59,48,0.1)',
  },
  debugZoneRight1: {
    backgroundColor: 'rgba(52,199,89,0.1)',
  },
  debugZoneRight2: {
    backgroundColor: 'rgba(52,199,89,0.2)',
  },
  debugZoneRight3: {
    backgroundColor: 'rgba(52,199,89,0.3)',
  },
  debugText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#333',
  },
  instructions: {
    fontSize: 14,
    color: '#8E8E93',
    textAlign: 'center',
    marginTop: 20,
    lineHeight: 20,
  },
});

export default InvisibleNumberSlider;
