import React, { useEffect } from 'react';
import {
  View,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Platform,
  Alert,
} from 'react-native';
import { useRouter, Stack } from 'expo-router';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import { Ionicons } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { auth } from '@/services/firebase';
import { GoogleAuthProvider, signInWithCredential } from 'firebase/auth';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';

WebBrowser.maybeCompleteAuthSession();

const { height } = Dimensions.get('window');
const PURPLE = '#52335C';

export default function LoginScreen() {
  const router = useRouter();

  const [request, response, promptAsync] = Google.useIdTokenAuthRequest({
    clientId: '563782649926-latc3kekgb8sl3880f05ublbopu9tuse.apps.googleusercontent.com',
    redirectUri: Platform.select({
      web: 'https://auth.expo.io/@zawwy/choosewine4me',
      default: undefined,
    }),
  });

  useEffect(() => {
    const authenticate = async () => {
      if (response?.type === 'success') {
        try {
          const idToken = response.params.id_token;
          const credential = GoogleAuthProvider.credential(idToken);
          const firebaseUser = await signInWithCredential(auth, credential);

          const backendRes = await axios.post('http://localhost:3000/api/auth/firebase', {
            idToken: await firebaseUser.user.getIdToken(),
          });

          await AsyncStorage.setItem('user', JSON.stringify(backendRes.data.user));
          await AsyncStorage.setItem('token', backendRes.data.token);

          router.replace('/home');
        } catch (error) {
          console.error('Erro ao fazer login com Google:', error);
          Alert.alert('Erro no login com Google');
        }
      }
    };

    authenticate();
  }, [response]);

  const handleGoogleLogin = () => {
    promptAsync();
  };

  const handleEmailLogin = () => {
    Alert.alert('Ainda não disponível', 'Funcionalidade em desenvolvimento.');
  };

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />

      <View style={styles.container}>
        {Platform.OS === 'web' ? (
          <Image
            source={require('../assets/images/fundo-login.jpg')}
            style={StyleSheet.absoluteFillObject}
            resizeMode="cover"
          />
        ) : (
          <Image
            source={require('../assets/images/fundo-login.jpg')}
            style={styles.topImage}
            resizeMode="cover"
          />
        )}

        <ThemedView style={styles.loginBox}>
          <Image
            source={require('../assets/images/logo-login.png')}
            style={styles.logo}
            resizeMode="contain"
          />

          <TouchableOpacity style={styles.button} onPress={handleGoogleLogin}>
            <View style={styles.buttonContent}>
              <Ionicons name="logo-google" size={20} color={PURPLE} style={styles.icon} />
              <ThemedText style={styles.buttonText}>Login com Google</ThemedText>
            </View>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.secondaryButton]} onPress={handleEmailLogin}>
            <View style={styles.buttonContent}>
              <Ionicons name="mail-outline" size={20} color={PURPLE} style={styles.icon} />
              <ThemedText style={[styles.buttonText, styles.secondaryText]}>
                Login com Email
              </ThemedText>
            </View>
          </TouchableOpacity>
        </ThemedView>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  topImage: {
    width: '100%',
    height: height * 0.55,
    position: 'absolute',
    top: 0,
    left: 0,
  },
  loginBox: {
    backgroundColor: '#fff',
    borderRadius: 30,
    alignItems: 'center',
    gap: 20,
    paddingVertical: 90,
    paddingHorizontal: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 6,
    ...(Platform.OS === 'web'
      ? {
          width: '90%',
          maxWidth: 420,
          alignSelf: 'center',
          marginTop: 40,
        }
      : {
          position: 'absolute',
          bottom: 0,
          width: '100%',
          borderBottomLeftRadius: 0,
          borderBottomRightRadius: 0,
          borderTopLeftRadius: 30,
          borderTopRightRadius: 30,
        }),
  },
  logo: {
    width: 200,
    height: 150,
  },
  button: {
    width: '100%',
    maxWidth: 320,
    borderRadius: 30,
    borderWidth: 2,
    borderColor: PURPLE,
    paddingVertical: Platform.OS === 'web' ? 14 : 16,
    paddingHorizontal: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
  secondaryButton: {
    backgroundColor: '#fff',
  },
  buttonText: {
    color: PURPLE,
    fontWeight: 'bold',
    fontSize: Platform.OS === 'web' ? 16 : 14,
    lineHeight: Platform.OS === 'web' ? 20 : 18,
  },
  secondaryText: {
    opacity: 1,
  },
  buttonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  icon: {
    marginRight: 6,
  },
});
