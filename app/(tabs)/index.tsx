// app/(tabs)/index.tsx
import React, { useState, useEffect } from 'react';
import { View, Text, Button, StyleSheet, Alert } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { TimePeriod } from '@/constants/TimePeriod';
import { HealthService } from '@/services/healthService';
import { FirebaseService } from '@/services/firebaseService';

const healthService = new HealthService();
const firebaseService = new FirebaseService();

export default function HomeScreen() {
  const [calories, setCalories] = useState<number>(0);
  const [selectedPeriod, setSelectedPeriod] = useState<TimePeriod>(TimePeriod.DAY);

  const fetchCalories = async () => {
    try {
      const burned = await healthService.getCalories(selectedPeriod);
      setCalories(burned);
    } catch (error) {
      console.error('Error fetching health data:', error);
    }
  };

  const handleSave = async () => {
    try {
      await firebaseService.saveCalories(calories);
      Alert.alert('Success', 'Calories saved to Firebase!');
    } catch (error) {
      console.error('Error saving to Firestore:', error);
    }
  };

  useEffect(() => {
    fetchCalories();
  }, [selectedPeriod]);

  return (
    <View style={styles.container}>
      <Text>Calories Burned: {calories}</Text>
      <Picker
        selectedValue={selectedPeriod}
        onValueChange={(itemValue) => setSelectedPeriod(itemValue)}
        style={styles.picker}>
        {Object.entries(TimePeriod).map(([key, value]) => (
          <Picker.Item key={key} label={key} value={value} />
        ))}
      </Picker>
      <Button title="Save to Firebase" onPress={handleSave} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  picker: {
    width: '80%',
    marginVertical: 16,
  },
});
