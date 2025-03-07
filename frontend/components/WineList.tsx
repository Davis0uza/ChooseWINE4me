import React from 'react';
import { FlatList, StyleSheet, Dimensions, SafeAreaView } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import winesData from '../assets/data/malbec.json';
import { WineItem } from './WineItem';

const { width } = Dimensions.get('window');
// Se a largura for maior que 768 (ex: tablet ou web), use 2 colunas; caso contrário, 1 coluna.
const numColumns = width > 768 ? 2 : 1;

const WineList = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <ThemedView style={styles.container}>
        <FlatList
          contentContainerStyle={styles.listContainer}
          data={winesData}
          keyExtractor={(item, index) => index.toString()}
          renderItem={({ item }) => <WineItem item={item} />}
          numColumns={numColumns}
          columnWrapperStyle={numColumns > 1 ? styles.columnWrapper : null}
        />
      </ThemedView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#fff',
  },
  container: {
    flex: 1,
    paddingHorizontal: width * 0.05,
    paddingVertical: 16,
  },
  listContainer: {
    flexGrow: 1,
  },
  // Define o espaçamento entre colunas
  columnWrapper: {
    justifyContent: 'space-between',
    marginBottom: 16,
  },
});

export default WineList;
