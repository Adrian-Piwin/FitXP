// src/services/HealthService.ts
import AppleHealthKit, { HealthKitPermissions, HealthPermission, HealthValue, HealthInputOptions } from 'react-native-health';
import { TimePeriod } from '@/constants/TimePeriod';

const initOptions: HealthKitPermissions = {
  permissions: {
    read: [AppleHealthKit.Constants.Permissions.ActiveEnergyBurned, AppleHealthKit.Constants.Permissions.EnergyConsumed],
    write: [],
  },
};

export class HealthService {
  constructor() {
    this.initHealthKit();
  }

  private initHealthKit(): void {
    AppleHealthKit.initHealthKit(initOptions, (err: string, results: HealthValue) => {
      if (err) {
        console.error('Error initializing HealthKit:', err);
        throw new Error(err);
      }
      console.log('HealthKit initialized:', results);
    });
  }

  private getStartDate(period: TimePeriod): string {
    const now = new Date();
    const startDate = new Date();

    if (period !== TimePeriod.ALL_TIME) {
      startDate.setDate(now.getDate() - period);
    } else {
      startDate.setFullYear(2000); // Arbitrary far-past year to fetch all data
    }

    return startDate.toISOString();
  }

  private createQueryOptions(period: TimePeriod): HealthInputOptions {
    return {
      startDate: this.getStartDate(period),
      endDate: new Date().toISOString(),
      ascending: true,
      includeManuallyAdded: true,
    };
  }

  public async getCalories(period: TimePeriod): Promise<number> {
    const options = this.createQueryOptions(period);

    return new Promise((resolve, reject) => {
      AppleHealthKit.getEnergyConsumedSamples(
        (options),
        (err: Object, results: HealthValue[]) => {
          if (err) {
            return reject(err);
          }
          
          const totalCalories = results.reduce((sum, item) => sum + item.value, 0);
          resolve(totalCalories);
        }
      );
    });
  }

  public async getEnergyBurned(period: TimePeriod): Promise<number> {
    const options = this.createQueryOptions(period);

    return new Promise((resolve, reject) => {
      AppleHealthKit.getActiveEnergyBurned(
        options,
        (err: Object, results: HealthValue[]) => {
          if (err) {
            return reject(err);
          }

          const totalEnergyBurned = results.reduce((sum, item) => sum + item.value, 0);
          resolve(totalEnergyBurned);
        }
      );
    });
  }
}
