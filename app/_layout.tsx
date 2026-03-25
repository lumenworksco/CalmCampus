import { useFonts } from 'expo-font';
import { Stack, useRouter, useSegments } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { Platform, View, StyleSheet } from 'react-native';
import { AppProvider, useAppContext } from '../context/AppContext';
import { StatusBar } from 'expo-status-bar';

export { ErrorBoundary } from 'expo-router';

SplashScreen.preventAutoHideAsync();

function NavigationGuard({ children }: { children: React.ReactNode }) {
  const { hasOnboarded } = useAppContext();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    const inOnboarding = segments[0] === 'onboarding';
    if (!hasOnboarded && !inOnboarding) {
      router.replace('/onboarding');
    } else if (hasOnboarded && inOnboarding) {
      router.replace('/(tabs)');
    }
  }, [hasOnboarded, segments]);

  return <>{children}</>;
}

function MobileFrame({ children }: { children: React.ReactNode }) {
  if (Platform.OS !== 'web') return <>{children}</>;

  return (
    <View style={webStyles.outerContainer}>
      <View style={webStyles.phoneFrame}>
        {children}
      </View>
    </View>
  );
}

const webStyles = StyleSheet.create({
  outerContainer: {
    flex: 1,
    backgroundColor: '#1a1a2e',
    alignItems: 'center',
    justifyContent: 'center',
  },
  phoneFrame: {
    width: 390,
    height: 844,
    backgroundColor: '#F7F9FC',
    borderRadius: 40,
    overflow: 'hidden',
    ...(Platform.OS === 'web' ? { boxShadow: '0 25px 80px rgba(0,0,0,0.4)' } as any : {}),
  },
});

export default function RootLayout() {
  const [loaded, error] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });

  useEffect(() => {
    if (error) throw error;
  }, [error]);

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync();
    }
  }, [loaded]);

  if (!loaded) return null;

  return (
    <AppProvider>
      <StatusBar style="dark" />
      <MobileFrame>
        <NavigationGuard>
          <Stack screenOptions={{ headerShown: false }}>
            <Stack.Screen name="onboarding" />
            <Stack.Screen name="(tabs)" />
          </Stack>
        </NavigationGuard>
      </MobileFrame>
    </AppProvider>
  );
}
