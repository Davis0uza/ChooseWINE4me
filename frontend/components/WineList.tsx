import React, { useState } from 'react';
import { FlatList, TouchableOpacity, StyleSheet, Dimensions, SafeAreaView } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import winesData from '../assets/data/malbec.json';

const ITEMS_PER_PAGE = 10;
const { width } = Dimensions.get('window');

const WineList = () => {
  const [currentPage, setCurrentPage] = useState(0);
  const startIndex = currentPage * ITEMS_PER_PAGE;
  const endIndex = startIndex + ITEMS_PER_PAGE;
  const winesToShow = winesData.slice(startIndex, endIndex);

  const handleNextPage = () => {
    if (endIndex < winesData.length) {
      setCurrentPage(prev => prev + 1);
    }
  };

  const handlePreviousPage = () => {
    if (currentPage > 0) {
      setCurrentPage(prev => prev - 1);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ThemedView style={styles.container}>
        <FlatList
          contentContainerStyle={styles.listContainer}
          data={winesToShow}
          keyExtractor={(item, index) => index.toString()}
          renderItem={({ item }) => (
            <ThemedView style={styles.itemContainer}>
              <ThemedText type="defaultSemiBold" style={styles.itemText}>
                Nome: {item.name}
              </ThemedText>
              <ThemedText style={styles.itemText}>País: {item.country}</ThemedText>
              <ThemedText style={styles.itemText}>Região: {item.region}</ThemedText>
              <ThemedText style={styles.itemText}>Avaliação: {item.average_rating}</ThemedText>
              <ThemedText style={styles.itemText}>Preço: {item.price}</ThemedText>
            </ThemedView>
          )}
        />

        <ThemedView style={styles.paginationContainer}>
          <TouchableOpacity
            style={[styles.button, currentPage === 0 && styles.disabledButton]}
            onPress={handlePreviousPage}
            disabled={currentPage === 0}
          >
            <ThemedText style={styles.buttonText}>Anterior</ThemedText>
          </TouchableOpacity>

          <ThemedText style={styles.pageInfo}>
            Página {currentPage + 1} de {Math.ceil(winesData.length / ITEMS_PER_PAGE)}
          </ThemedText>

          <TouchableOpacity
            style={[styles.button, endIndex >= winesData.length && styles.disabledButton]}
            onPress={handleNextPage}
            disabled={endIndex >= winesData.length}
          >
            <ThemedText style={styles.buttonText}>Próxima</ThemedText>
          </TouchableOpacity>
        </ThemedView>
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
    paddingHorizontal: width * 0.05, // Usa 5% da largura da tela para padding
    paddingVertical: 16,
  },
  listContainer: {
    flexGrow: 1,
  },
  itemContainer: {
    width: '100%', // Usa toda a largura disponível
    marginBottom: 12,
    padding: 10,
    backgroundColor: '#f2f2f2',
    borderRadius: 8,
  },
  itemText: {
    marginBottom: 4,
  },
  paginationContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between', // Distribui igualmente os elementos
    alignItems: 'center',
    marginTop: 16,
  },
  button: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#007AFF',
    borderRadius: 8,
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  disabledButton: {
    backgroundColor: '#ccc',
  },
  pageInfo: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default WineList;
