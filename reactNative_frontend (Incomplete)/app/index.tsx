import React from 'react';
import {
  View,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Platform,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useIdTokenAuthRequest } from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import { makeRedirectUri } from 'expo-auth-session';
import { auth, signInWithCredential, GoogleAuthProvider } from '@/services/firebase';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';

WebBrowser.maybeCompleteAuthSession();

const { height } = Dimensions.get('window');
const PURPLE = '#52335C';

const redirectUri = makeRedirectUri({
  scheme: 'choosewine4me',
  path: 'redirect'
});

export default function Login() {
  const router = useRouter();

  const [request, response, promptAsync] = useIdTokenAuthRequest({
    clientId: '563782649926-latc3kekgb8sl3880f05ublbopu9tuse.apps.googleusercontent.com',
    redirectUri,
  });

  React.useEffect(() => {
    const login = async () => {
      if (response?.type === 'success') {
        try {
          const idToken = response.params.id_token;
          const credential = GoogleAuthProvider.credential(idToken);
          const firebaseUser = await signInWithCredential(auth, credential);

          const firebaseIdToken = await firebaseUser.user.getIdToken();

          const backendRes = await axios.post('http://localhost:3000/api/auth/firebase', {
            idToken: firebaseIdToken,
          });

          await AsyncStorage.setItem('user', JSON.stringify(backendRes.data.user));
          await AsyncStorage.setItem('token', backendRes.data.token);

          Alert.alert('✅ Login efetuado com sucesso!');
          router.replace('/home');
        } catch (error: unknown) {
          const err = error as Error;
          Alert.alert('Erro ao autenticar', err.message);
        }
      }
    };
    login();
  }, [response]);

  const handleGoogleLogin = () => {
    promptAsync();
  };

  return (
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
      </ThemedView>
    </View>
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
  buttonText: {
    color: PURPLE,
    fontWeight: 'bold',
    fontSize: Platform.OS === 'web' ? 16 : 14,
    lineHeight: Platform.OS === 'web' ? 20 : 18,
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
