import React, { useState } from 'react';
import { TouchableOpacity, StyleSheet, View } from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import AntDesign from '@expo/vector-icons/AntDesign';
import Entypo from '@expo/vector-icons/Entypo';

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(prev => !prev);
  };

  return (
    <ThemedView style={styles.navbarContainer}>
      {/* Botão que exibe o ícone de menu ou close conforme o estado */}
      <TouchableOpacity onPress={toggleMenu} style={styles.hamburgerButton}>
        {isOpen ? (
          <AntDesign name="close" size={24} color="black" />
        ) : (
          <Entypo name="menu" size={24} color="black" />
        )}
      </TouchableOpacity>

      {isOpen && (
        <ThemedView style={styles.menuContainer}>
          {/* Topo do menu com informações do usuário */}
          <View style={styles.userInfo}>
            <View>
              <ThemedText type="defaultSemiBold">User</ThemedText>
              <ThemedText>user@example.com</ThemedText>
            </View>
            <TouchableOpacity style={styles.settingsButton}>
              <AntDesign name="setting" size={24} color="black" />
            </TouchableOpacity>
          </View>

          {/* Itens de navegação */}
          <View style={styles.navItems}>
            <TouchableOpacity style={styles.navItem}>
              <ThemedText>Página inicial</ThemedText>
            </TouchableOpacity>
            <TouchableOpacity style={styles.navItem}>
              <ThemedText>Novidades</ThemedText>
            </TouchableOpacity>
            <TouchableOpacity style={styles.navItem}>
              <ThemedText>Castas</ThemedText>
            </TouchableOpacity>
            <TouchableOpacity style={styles.navItem}>
              <ThemedText>Favoritos</ThemedText>
            </TouchableOpacity>
          </View>
        </ThemedView>
      )}
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  navbarContainer: {
    backgroundColor: '#fff',
    padding: 16,
  },
  hamburgerButton: {
    alignSelf: 'flex-start',
  },
  menuContainer: {
    marginTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#ccc',
    paddingTop: 16,
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  settingsButton: {
    padding: 8,
  },
  navItems: {},
  navItem: {
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
});

