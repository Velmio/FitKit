//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension HKSampleType {
    public static func fromDartType(type: String) throws -> HKSampleType {
        guard let sampleType: HKSampleType = {
            switch type {
            case "heart_rate":
                return HKSampleType.quantityType(forIdentifier: .heartRate)
             case "resting_heart_rate":
                if #available(iOS 11.0, *) {
                 return HKSampleType.quantityType(forIdentifier: .restingHeartRate)
                } else {
                 return nil
                }
            case "irregular_heart_rhythm_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
                } else {
                    return nil
                }
            case "high_heart_rate_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)
                } else {
                    return nil
            }
            case "low_heart_rate_event":
                if #available(iOS 12.2, *) {
                    return HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)
                } else {
                    return nil
            }
            case "step_count":
                return HKSampleType.quantityType(forIdentifier: .stepCount)
            case "stand_time":
                if #available(iOS 13.0, *) {
                     return HKSampleType.quantityType(forIdentifier: .appleStandTime)
                } else {
                    return nil
                } 
            case "exercise_time":
                if #available(iOS 9.3, *) {
                     return HKSampleType.quantityType(forIdentifier: .appleExerciseTime)
                } else {
                    return nil
                }  
            case "height":
                return HKSampleType.quantityType(forIdentifier: .height)
            case "weight":
                return HKSampleType.quantityType(forIdentifier: .bodyMass)
            case "distance":
                return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "energy":
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
            case "water":
                if #available(iOS 9, *) {
                    return HKSampleType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            case "sleep":
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
            //Nutrition Data
            case "Carbohydrate":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)
            case "Protein":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)
            case "Fat":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)
            case "Energy":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)
            case "Saturated fat":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated)
            case "Cholesterol":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)
            case "Fiber":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFiber)
            case "Sugar":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)
            case "Calcium, Ca":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCalcium)
            case "Iron, Fe":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryIron)
            case "Potassium, K":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPotassium)
            case "Sodium, Na":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)
            case "Vitamin A":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA)
            case "Vitamin C":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminC)
            case "Vitamin D":
                return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminD)
            case "Water":
                if #available(iOS 9.0, *) {
                           return  HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)
                } else {
                           // Fallback on earlier versions
                    return nil
             }
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return sampleType
    }
}

extension HKUnit {
    public static func fromDartType(type: String) throws -> HKUnit {
        guard let unit: HKUnit = {
            switch (type) {
            case "heart_rate":
                return HKUnit.init(from: "count/min")
            case "resting_heart_rate":
                return HKUnit.init(from: "count/min")
            case "irregular_heart_rhythm_event":
                return HKUnit.count() //Ignored
            case "high_heart_rate_event":
                return HKUnit.count() //Ignored
            case "low_heart_rate_event":
                return HKUnit.count() //Ignored
            case "step_count":
                return HKUnit.count()
            case "height":
                return HKUnit.meter()
            case "weight":
                return HKUnit.gramUnit(with: .kilo)
            case "distance":
                return HKUnit.meter()
            case "energy":
                return HKUnit.kilocalorie()
            case "water":
                return HKUnit.liter()
            case "sleep":
                return HKUnit.minute() // this is ignored
            case "stand_time":
                return HKUnit.minute()
            case "exercise_time":
                return HKUnit.minute()
            //Nutrition
            case "Carbohydrate":
                return HKUnit.gram()
            case "Protein":
                return HKUnit.gram()
            case "Fat":
                return HKUnit.gram()
            case "Energy":
                return HKUnit.kilocalorie()
            case "Saturated fat":
                return HKUnit.gram()
            case "Cholesterol":
                return HKUnit.gramUnit(with: .milli)
            case "Fiber":
                return HKUnit.gram()
            case "Sugar":
                return HKUnit.gram()
            case "Calcium, Ca":
                return HKUnit.gramUnit(with: .milli)
            case "Iron, Fe":
                return HKUnit.gramUnit(with: .milli)
            case "Potassium, K":
                return HKUnit.gramUnit(with: .milli)
            case "Sodium, Na":
                return HKUnit.gramUnit(with: .milli)
            case "Vitamin A":
                return HKUnit.gramUnit(with: .micro)
            case "Vitamin C":
                return HKUnit.gramUnit(with: .micro)
            case "Vitamin D":
                return HKUnit.gramUnit(with: .micro)
            case "Water":
                if #available(iOS 9.0, *) {
                    return HKUnit.liter()
                } else {
                    // Fallback on earlier versions
                    return nil
                }
                
            default:
                return nil
            }
            }() else {
                throw "type \"\(type)\" is not supported";
        }
        return unit
    }
}

extension HKStatisticsOptions {
    public static func fromDartAggregationOption(aggregateOption: String) throws -> HKStatisticsOptions {
        guard let option: HKStatisticsOptions = {
            switch (aggregateOption) {
            case "cumulativeSum":
                return HKStatisticsOptions.cumulativeSum
            case "discreteAverage":
                return HKStatisticsOptions.discreteAverage
            default:
                return nil
            }
            } () else {
                throw "type \"\(aggregateOption)\" is not supported";
        }
        return option
    }
}
