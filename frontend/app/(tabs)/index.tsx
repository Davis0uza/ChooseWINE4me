import React from 'react';
import { StyleSheet, SafeAreaView } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import WineList from '@/components/WineList';
import { Navbar } from '@/components/Navbar';

export default function HomeScreen() {
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

