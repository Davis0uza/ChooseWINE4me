//app/(tabs)/index.tsx

import React, { useEffect, useState } from 'react';
import { View, Text, Button, StyleSheet, Alert } from 'react-native';
import { GoogleSignin, statusCodes } from '@react-native-google-signin/google-signin';
import axios from 'axios';
import { useRouter } from 'expo-router';
import { saveToken } from '../../services/AuthService';

interface SimpleUser {
  name?: string;
  email?: string;
  photo?: string;
}

function findFields(obj: any, fields = ['name', 'email', 'photo']) {
  let result: any = {};
  function search(o: any) {
    if (!o || typeof o !== 'object') return;
    for (const key in o) {
      if (fields.includes(key) && o[key] && typeof o[key] === 'string') {
        result[key] = o[key];
      } else if (typeof o[key] === 'object') {
        search(o[key]);
      }
    }
  }
  search(obj);
  return result;
}


export default function LoginTab() {
  const router = useRouter();
  const [userInfo, setUserInfo] = useState<SimpleUser | null>(null);

  useEffect(() => {
    GoogleSignin.configure({
      webClientId: '636405643444-petch5m7g36u6a3dhb7874s4i96ap7vr.apps.googleusercontent.com',
      iosClientId: '636405643444-ih548k700pnrl3jvrbnskq5h8a3dcead.apps.googleusercontent.com',
      offlineAccess: true,
      scopes: ['profile', 'email'],
    });
  }, []);

  const signIn = async () => {
    try {
      await GoogleSignin.hasPlayServices();
      type GoogleUser = {
        user?: { name?: string; email?: string; photo?: string }
      };
      const userInfoGoogle: any = await GoogleSignin.signIn();
      const { name = '', email = '', photo = '' } = findFields(userInfoGoogle);



      setUserInfo({ name, email, photo });

      if (!name || !email) {
        throw new Error('Nome ou email não encontrados no perfil Google');
      }

      // Enviar dados para o backend/Mongo
      const backendResponse = await axios.post('http://192.168.36.215:3000/auth/social-login', {
        name,
        email,
        photo
      });
      
      const { token } = backendResponse.data;
      console.log(token)
      if (token) {
        await saveToken(token);
      }

      if (backendResponse.status !== 200 && backendResponse.status !== 201) {
        throw new Error('Falha na autenticação do backend');
      }

      Alert.alert('Login OK', `Bem-vindo, ${name}`);
      router.replace('/(tabs)/explore');
    } catch (error: any) {
      if (error.code === statusCodes.IN_PROGRESS) {
        Alert.alert('Login em progresso');
      } else if (error.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        Alert.alert('Serviços Google Play não disponíveis');
      } else {
        Alert.alert('Erro', error.message || 'Erro desconhecido');
      }
      console.error('Erro na autenticação:', error);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login com Google</Text>
      <Button title="Entrar com Google" onPress={signIn} />
      {userInfo && <Text style={styles.userText}>Olá, {userInfo.name || 'Usuário'}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff' },
  title: { fontSize: 24, marginBottom: 20 },
  userText: { marginTop: 20, fontSize: 18 },
});
