import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyC7Gc4Q2LgLPdlfVb5IPx9ck6scoKe5Ju0',
  authDomain: 'fitxp-6c3c3.firebaseapp.com',
  projectId: 'fitxp-6c3c3',
  messagingSenderId: '896043199805',
  appId: '1:896043199805:ios:4a3fdbc51da713d728e954',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
