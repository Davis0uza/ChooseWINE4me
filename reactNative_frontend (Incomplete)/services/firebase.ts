// services/firebase.ts
import { getApps, initializeApp } from 'firebase/app';
import {
  getAuth,
  signInWithCredential,
  GoogleAuthProvider,
} from 'firebase/auth';

// Configuração do Firebase
const firebaseConfig = {
  apiKey: 'TAIzaSyDiI7-SJGgl3Anbz49yUADKYHlCKmKnSpQ',
  authDomain: 'choosewine4me-8ae68.firebaseapp.com',
  projectId: 'choosewine4me-8ae68',
  storageBucket: 'choosewine4me-8ae68.appspot.com',
  messagingSenderId: '563782649926',
  appId: '1:563782649926:web:06e34d5dd04b918f6f6247',
};

// Evita duplicação do app
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export { signInWithCredential, GoogleAuthProvider };
