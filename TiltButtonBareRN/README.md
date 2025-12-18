# TiltButton - Bare React Native

A 3D tilt button component for React Native (iOS) that responds to touch position with smooth, opposite-direction tilting.

## Features

- **Opposite-direction tilt**: Push right side → left tilts up
- **Continuous sliding**: Tilt updates in real-time as finger moves
- **Center stays flat**: Touch in the middle = no tilt
- **Spring animation**: Smooth return to flat when released
- **Customizable**: Adjust size, colors, max tilt angle, etc.

## Dependencies

- `react-native-reanimated` (v3.x) - High-performance animations
- `react-native-gesture-handler` - Native gesture tracking

## Setup

### 1. Create a new bare React Native project

```bash
npx react-native init YourProjectName
cd YourProjectName
```

### 2. Install dependencies

```bash
npm install react-native-reanimated react-native-gesture-handler
```

### 3. Configure Babel

Add the Reanimated plugin to `babel.config.js`:

```js
module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: ['react-native-reanimated/plugin'],
};
```

### 4. iOS Setup

```bash
cd ios && pod install && cd ..
```

### 5. Copy the TiltButton component

Copy `src/components/TiltButton.js` to your project.

## Usage

```jsx
import {GestureHandlerRootView} from 'react-native-gesture-handler';
import TiltButton from './components/TiltButton';

const App = () => {
  return (
    <GestureHandlerRootView style={{flex: 1}}>
      <TiltButton
        title="Press Me"
        width={200}
        height={60}
        maxTiltDeg={15}
        backgroundColor="#007AFF"
        onPress={() => console.log('Pressed!')}
      />
    </GestureHandlerRootView>
  );
};
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | string | "Press Me" | Button text |
| `width` | number | 200 | Button width in pixels |
| `height` | number | 60 | Button height in pixels |
| `maxTiltDeg` | number | 15 | Maximum tilt angle in degrees |
| `backgroundColor` | string | "#007AFF" | Button background color |
| `textColor` | string | "#FFFFFF" | Text color |
| `borderRadius` | number | 12 | Corner radius |
| `onPress` | function | undefined | Callback when button is tapped |

## How It Works

1. **Gesture Detection**: Uses `Gesture.Pan()` to track finger position
2. **Position Normalization**: Touch position is normalized to -1 (edge) to 1 (opposite edge), with 0 being center
3. **Opposite Tilt**: `rotateY` is inverted so pushing right tilts left up
4. **Spring Physics**: On release, uses spring animation with damping for natural feel
5. **Perspective**: 800px perspective creates realistic 3D depth
