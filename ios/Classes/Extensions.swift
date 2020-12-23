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
    public static func fromDartType(type: String) -> (sampleType: HKSampleType?, unit: HKUnit)? {
        switch type {
        case "heart_rate":
            return (
                HKSampleType.quantityType(forIdentifier: .heartRate),
                HKUnit.init(from: "count/min")
            )
         case "max_heart_rate":
            return (HKSampleType.quantityType(forIdentifier: .heartRate), HKUnit.init(from: "count/min"))
         case "resting_heart_rate":
            if #available(iOS 11.0, *) {
             return (HKSampleType.quantityType(forIdentifier: .restingHeartRate), HKUnit.init(from: "count/min"))
            } else {
             return nil
            }
        case "irregular_heart_rhythm_event":
            if #available(iOS 12.2, *) {
                return (HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent), HKUnit.count())
            } else {
                return nil
            }
        case "high_heart_rate_event":
            if #available(iOS 12.2, *) {
                return (HKSampleType.categoryType(forIdentifier: .highHeartRateEvent),HKUnit.count())
            } else {
                return nil
        }
        case "low_heart_rate_event":
            if #available(iOS 12.2, *) {
                return (HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent),HKUnit.count())
            } else {
                return nil
        }
        case "step_count":
            return (HKSampleType.quantityType(forIdentifier: .stepCount),HKUnit.count())
        case "stand_time":
            if #available(iOS 13.0, *) {
                 return (HKSampleType.quantityType(forIdentifier: .appleStandTime), HKUnit.minute())
            } else {
                return nil
            }
        case "exercise_time":
            if #available(iOS 9.3, *) {
                 return (HKSampleType.quantityType(forIdentifier: .appleExerciseTime), HKUnit.minute())
            } else {
                return nil
            }
        case "height":
            return (HKSampleType.quantityType(forIdentifier: .height), HKUnit.meter())
        case "weight":
            return (HKSampleType.quantityType(forIdentifier: .bodyMass),HKUnit.gramUnit(with: .kilo))
        case "distance":
            return (HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning), HKUnit.meter())
        case "energy":
            return (HKSampleType.quantityType(forIdentifier: .activeEnergyBurned), HKUnit.kilocalorie())
        case "Water":
            if #available(iOS 9, *) {
                return (HKSampleType.quantityType(forIdentifier: .dietaryWater), HKUnit.liter())
            } else {
                return nil
            }
        case "sleep":
            return (HKSampleType.categoryType(forIdentifier: .sleepAnalysis), HKUnit.minute())
        //Nutrition Data
        case "Carbohydrate":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates), HKUnit.gram())
        case "Protein":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein), HKUnit.gram())
        case "Fat":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal), HKUnit.gram())
        case "Energy":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed), HKUnit.kilocalorie())
        case "Saturated fat":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated), HKUnit.gram())
        case "Cholesterol":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol), HKUnit.gramUnit(with: .milli))
        case "Fiber":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFiber), HKUnit.gram())
        case "Sugar":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar), HKUnit.gram())
        case "Calcium, Ca":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCalcium), HKUnit.gramUnit(with: .milli))
        case "Iron, Fe":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryIron),HKUnit.gramUnit(with: .milli))
        case "Potassium, K":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPotassium), HKUnit.gramUnit(with: .milli))
        case "Sodium, Na":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium), HKUnit.gramUnit(with: .milli))
        case "Vitamin A":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA), HKUnit.gramUnit(with: .micro))
        case "Vitamin C":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminC), HKUnit.gramUnit(with: .milli))
        case "Vitamin D":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminD), HKUnit.gramUnit(with: .micro))
        case "Folate":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFolate), HKUnit.gramUnit(with: .micro))
        case "Folic acid":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFolate), HKUnit.gramUnit(with: .micro))
        case "Thiamin (Vitamin B1)":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryThiamin),HKUnit.gramUnit(with: .milli))
        case "Riboflavin (Vitamin B2)":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryRiboflavin),HKUnit.gramUnit(with: .milli))
        case "Niacin (Vitamin B3)":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryNiacin),HKUnit.gramUnit(with: .milli))
        case "Vitamin B6":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB6), HKUnit.gramUnit(with: .milli))
        case "Vitamin B12":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB12), HKUnit.gramUnit(with: .micro))
        case "Vitamin E":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminE), HKUnit.gramUnit(with: .milli))
        case "Zinc, Zn":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryZinc), HKUnit.gramUnit(with: .milli))
        case "Retinol (Vitamin A1)":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA), HKUnit.gramUnit(with: .micro))
        case "Magnesium, Mg":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryMagnesium),HKUnit.gramUnit(with: .milli))
        case "Caffeine":
            return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine), HKUnit.gramUnit(with: .milli))
        case "VO2Max":
            if #available(iOS 11.0, *) {
                return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.vo2Max), HKUnit(from: "ml/kg*min"))
            } else {
                // Fallback on earlier versions
                return nil
            }
        case "Oxygen Saturation":
            if #available(iOS 13.0, *) {
                return (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation), HKUnit.percent())
            } else {
                // Fallback on earlier versions
                return nil
            }
        default:
            return nil
        }
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
            case "discreteMax":
                return HKStatisticsOptions.discreteMax
            default:
                return nil
            }
            } () else {
                throw "type \"\(aggregateOption)\" is not supported";
        }
        return option
    }
}

public struct UnsupportedError: Error {
    let message: String
}
