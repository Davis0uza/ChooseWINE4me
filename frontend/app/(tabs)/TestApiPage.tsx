import React, { useState, useEffect } from 'react';
import { View, Text, Image, StyleSheet } from 'react-native';
import axios from 'axios';

const API_URL = 'https://demo.api4ai.cloud/wine-rec/v1/results';

const TestApiPage = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const imageUrl = 'https://images.vivino.com/thumbs/AL7A6dlCTTSyYa-wR_Jxmw_pl_375x500.png';

  useEffect(() => {
    const recognizeWine = async () => {
      setLoading(true);
      setError(null);

      const formData = new FormData();
      formData.append('url', imageUrl);

      console.log('Enviando payload:', { url: imageUrl });

      try {
        const response = await axios.post(API_URL, formData, {
          headers: {
            'Content-Type': 'multipart/form-data'
          },
        });
        console.log('Resposta da API:', response.data);  // Log da resposta
        setData(response.data);
      } catch (error) {
        console.error('Erro ao chamar a API:', error);
        if (axios.isAxiosError(error)) {
          console.error('Detalhes do erro:', error.response?.data);
          setError(`Erro: ${error.response?.status} - ${error.response?.data?.message || 'Erro desconhecido'}`);
        } else {
          setError('Erro ao chamar a API');
        }
        setData(null);
      } finally {
        setLoading(false);
      }
    };

    recognizeWine();
  }, []);

  return (
    <View style={styles.container}>
      <Image source={{ uri: imageUrl }} style={styles.image} />
      {loading ? (
        <Text style={styles.text}>Carregando...</Text>
      ) : error ? (
        <Text style={styles.text}>{error}</Text>
      ) : (
        <Text style={styles.text}>{data ? JSON.stringify(data, null, 2) : 'Erro ao carregar dados'}</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: 375,
    height: 500,
  },
  text: {
    marginTop: 20,
    fontSize: 16,
    paddingHorizontal: 10,
    textAlign: 'center',
  },
});

export default TestApiPage;
