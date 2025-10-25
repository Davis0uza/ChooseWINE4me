import React from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';

type Wine = {
  name: string;
  country: string;
  region: string;
  average_rating: number;
  price: number;
  image?: any;
};

type WineItemProps = {
  item: Wine;
};

export const WineItem: React.FC<WineItemProps> = ({ item }) => {
  const bottleSource = item.image
    ? item.image
    : require('../assets/images/wine-placeholder.png');

  const filled = Math.round(item.average_rating);

  const renderRatingIcons = () => {
    const maxRating = 5;
    return (
      <View style={{ flexDirection: 'row' }}>
        {Array.from({ length: maxRating }, (_, index) => {
          const iconName = index < filled ? 'wine' : 'wine-outline';
          return (
            <Ionicons
              key={index}
              name={iconName}
              size={Platform.OS === 'web' ? 16 : 11} // ícones menores no mobile
              color="#9b51e0"
              style={{ marginRight: 2 }}
            />
          );
        })}
      </View>
    );
  };

  return (
    <View style={styles.card}>
      {/* Coluna 1: Imagem */}
      <View style={styles.leftColumn}>
        <View style={styles.imageWrapper}>
          <Image
            source={bottleSource}
            style={styles.wineImage}
            resizeMode="contain"
          />
        </View>
      </View>

      {/* Coluna 2: Fundo roxo + Informações */}
      <View style={styles.middleColumn}>
        <ThemedText type="defaultSemiBold" style={styles.classificationTitle}>
          Classificação:
        </ThemedText>
        <View style={styles.classificationRow}>
          <ThemedText type="default" style={styles.classificationNumber}>
            {filled}
          </ThemedText>
          {renderRatingIcons()}
        </View>
        <ThemedText type="default" style={styles.countryText}>
          {item.country}
        </ThemedText>
        <ThemedText type="default" style={styles.regionText}>
          {item.region}
        </ThemedText>
      </View>

      {/* Coluna 3: Favorito, Nome e Preço */}
      <View style={styles.rightColumn}>
        <TouchableOpacity style={styles.favoriteButton}>
          <Ionicons name="heart-outline" size={24} color="#9b51e0" />
        </TouchableOpacity>
        <ThemedText type="defaultSemiBold" style={styles.wineName}>
          {item.name}
        </ThemedText>
        <View style={styles.priceContainer}>
          <ThemedText type="defaultSemiBold" style={styles.priceText}>
            {item.price.toFixed(2)}€
          </ThemedText>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flex:1,
    flexDirection: 'row',
    borderRadius: 16,
    backgroundColor: '#fff',
    marginHorizontal: 8,
    marginBottom:8,
    borderColor: '#AA99AE',
    borderWidth: 1,
    position: 'relative',
    zIndex:-1
  },
  // COLUNA 1 (Imagem)
  leftColumn: {
    width: 60,
    position: 'relative',
    overflow: 'visible',
  },
  imageWrapper: {
    justifyContent: 'center',
    alignItems: 'center',
    flex: 1,
    position:'relative',
    zIndex:101,
  },
  wineImage: {
    width: '150%',
    position:'relative',
    zIndex:101,
    elevation:1,
    marginRight: -20,
  },
  // COLUNA 2 (Fundo roxo + Infos)
  middleColumn: {
    flex: 0.6,
    backgroundColor: '#F3E9FA',
    padding: 10,
    alignItems: 'center',
    marginTop: 50,
    marginBottom:20,
    borderRadius: 10,
    zIndex:-1,
    alignSelf: 'center',
    position:'relative',
  },
  classificationTitle: {
    marginBottom: 8,
    color: '#333',
  },
  classificationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  classificationNumber: {
    marginRight: 4,
    color: '#9b51e0',
    fontWeight: 'bold',
  },
  countryLabel: {
    fontWeight: '600',
    color: '#555',
  },
  countryText: {
    marginBottom: 4,
    color: '#333',
  },
  regionText: {
    marginBottom: 2,
    color: '#333',
  },
  // COLUNA 3 (Favorito, Nome, Preço)
  rightColumn: {
    flex: 0.5,
    padding: 12,
    position: 'relative',
    justifyContent: 'center',
  },
  favoriteButton: {
    position: 'absolute',
    top: '20%',
    right: '30%',
    width: 36,
    height: 36,
    borderRadius: 18,
    borderWidth: 2,
    borderColor: '#9b51e0',
    backgroundColor: 'transparent',
    justifyContent: 'center',
    alignItems: 'center',
  },  
  wineName: {
    color: '#333',
    alignSelf: 'center',
  },
  priceContainer: {
    position: 'absolute',
    bottom: '15%',
    alignSelf: 'center',
    backgroundColor: '#9b51e0',
    paddingHorizontal: "20%",
    paddingVertical: 10,
    borderRadius: 16,
    maxHeight: 100,
  },
  priceText: {
    color: '#fff',
    fontWeight: '600',
  },
});
