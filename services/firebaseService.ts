// src/services/FirebaseService.ts
import { db } from '@/firebaseConfig';
import { collection, query, where, getDocs, QueryConstraint, addDoc } from 'firebase/firestore/lite';

export class FirebaseService {
  private async getData(collectionName: string, filters: { [key: string]: any } = {}) {
    try {
      const constraints: QueryConstraint[] = Object.entries(filters).map(
        ([field, value]) => where(field, '==', value) // Adjust comparison operator if needed
      );

      const q = query(collection(db, collectionName), ...constraints);
      const querySnapshot = await getDocs(q);
      return querySnapshot.docs.map((doc) => doc.data());
    } catch (error) {
      console.error('Error fetching documents:', error);
      throw error;
    }
  }

  private async addData(collectionName: string, data: object) {
    try {
      await addDoc(collection(db, collectionName), data);
    } catch (error) {
      console.error('Error adding document:', error);
      throw error;
    }
  }

  public async saveCalories(calories: number) {
    await this.addData('calories', { calories, timestamp: new Date() });
  }
}
