/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import { Button, SafeAreaView, StatusBar, StyleSheet, Text, useColorScheme } from 'react-native';
import { initiateEkeyLogin } from 'ekey-react-native-sdk';

function App() {
  const isDarkMode = useColorScheme() === 'dark';

  const onPress = async () => {
    const result = await initiateEkeyLogin();
    console.log('Ekey login result:', result);
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <Text style={styles.title}>Hello, NEC testing Flow!</Text>
      <Button title="Initiate Ekey Flow" onPress={onPress} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: '600',
  },
});

export default App;
