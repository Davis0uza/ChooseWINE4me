import React from 'react';
import { StyleSheet, SafeAreaView, Button } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import WineList from '@/components/WineList';
import { Navbar } from '@/components/Navbar';
import { useRouter } from 'expo-router';

export default function HomeScreen() {
  const router = useRouter();

  return (
    <SafeAreaView style={styles.safeArea}>
      <ThemedView style={styles.container}>
        <Navbar />
        <ThemedText type="title" style={styles.title}>
          Bem-vindo!
        </ThemedText>
        <ThemedText type="subtitle" style={styles.subtitle}>
          Lista de vinhos
        </ThemedText>
        <WineList />
        <Button 
          title="Ir para TestApiPage"
          onPress={() => router.push('/(tabs)/TestApiPage')}
        />
      </ThemedView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  container: {
    flex: 1,
    padding: 16,
  },
  title: {
    marginBottom: 8,
  },
  subtitle: {
    marginBottom: 16,
  },
});
