import Flutter
import UIKit
import HealthKit

public class SwiftFitKitPlugin: NSObject, FlutterPlugin {

    private let TAG = "FitKit";

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fit_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftFitKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var healthStore: HKHealthStore? = nil;

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: TAG, message: "Not supported", details: nil))
            return
        }

        if (healthStore == nil) {
            healthStore = HKHealthStore();
        }

        do {
            if (call.method == "hasPermissions") {
                let request = try PermissionsRequest.fromCall(call: call)
                hasPermissions(request: request, result: result)
            } else if (call.method == "requestPermissions") {
                let request = try PermissionsRequest.fromCall(call: call)
                requestPermissions(request: request, result: result)
            } else if (call.method == "revokePermissions") {
                revokePermissions(result: result)
            } else if (call.method == "read") {
                let request = try ReadRequest.fromCall(call: call)
                read(request: request, result: result)
            } else if (call.method == "readSleep") {
                let request = try ReadRequest.fromCall(call: call)
                readSleep(request: request, result: result)
            } else if (call.method == "getSources") {
                let request = try SourceRequest.fromCall(call: call)
                getSources(request: request, result: result)
            }
            else if (call.method == "computeCollectionQuery") {
                let request = try CollectionQueryRequest.fromCall(call: call)
                performCollectionQuery(request: request, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: TAG, message: "Error \(error)", details: nil))
        }
    }


    /**
    * On iOS you can only know if user has responded to request access screen.
    * Not possible to tell if he has allowed access to read.
    *
    *   # getRequestStatusForAuthorization #
    *   If "status == unnecessary" means if requestAuthorization will be called request access screen will not be shown.
    *   So user has already responded to request access screen and kinda has permissions.
    *
    *   # authorizationStatus #
    *   If "status == notDetermined" user has not responded to request access screen.
    *   Once he responds no matter of the result status will be sharingDenied.
    */
    private func hasPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            healthStore!.getRequestStatusForAuthorization(toShare: [], read: Set(request.sampleTypes)) { (status, error) in
                guard error == nil else {
                    result(FlutterError(code: self.TAG, message: "hasPermissions", details: error))
                    return
                }

                guard status == HKAuthorizationRequestStatus.unnecessary else {
                    result(false)
                    return
                }

                result(true)
            }
        } else {
            let authorized = request.sampleTypes.map {
                        healthStore!.authorizationStatus(for: $0)
                    }
                    .allSatisfy {
                        $0 != HKAuthorizationStatus.notDetermined
                    }
            result(authorized)
        }
    }

    private func requestPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: request.sampleTypes) { success, error in
            guard success else {
                result(false)
                return
            }

            result(true)
        }
    }

    /**
    * Not supported by HealthKit.
    */
    private func revokePermissions(result: @escaping FlutterResult) {
        result(nil)
    }

    private func read(request: ReadRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: [request.sampleType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSample(request: request, result: result)
        }
    }
    
    private func readSleep(request: ReadRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: [request.sampleType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSleepSample(request: request, result: result)
        }
    }
    


    private func requestAuthorization(sampleTypes: Array<HKSampleType>, completion: @escaping (Bool, FlutterError?) -> Void) {
        healthStore!.requestAuthorization(toShare: nil, read: Set(sampleTypes)) { (success, error) in
            guard success else {
                completion(false, FlutterError(code: self.TAG, message: "Error \(error?.localizedDescription ?? "empty")", details: nil))
                return
            }

            completion(true, nil)
        }
    }
    
    private func getSources(request: SourceRequest, result: @escaping FlutterResult) {
         
        let query = HKSourceQuery.init(sampleType: request.sampleType,
                                         samplePredicate: nil) { (query, sources, error) in
                                         
                                            if (sources != nil || sources?.count != 0) {
                                                
                                                var output: [String] = []
                                                for source in sources! {
                                                    print(source.name)
                                                    output.append(source.name)
                                                }
                                                
                                                result(output)
                                                
                                            } else {
                                                 result(FlutterError(code: self.TAG, message: "No soruces found", details: "Error occured"))
                                            }
                                         
          }
        

          healthStore!.execute(query)
      }

    
    private func readSleepSample(request: ReadRequest, result: @escaping FlutterResult) {
        print("readSleepSample: \(request.type)")

        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: request.limit == nil)

        let query = HKSampleQuery(sampleType: request.sampleType, predicate: predicate, limit: request.limit ?? HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in

            guard var samples = samplesOrNil else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error))
                return
            }

            if (request.limit != nil) {
                // if limit is used sort back to ascending
                samples = samples.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            }

            print(samples)
            result(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: request.unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true
                ]
            })
        }
        healthStore!.execute(query)
    }

    private func readSample(request: ReadRequest, result: @escaping FlutterResult) {
        print("readSample: \(request.type)")

        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: request.limit == nil)

        let query = HKSampleQuery(sampleType: request.sampleType, predicate: predicate, limit: request.limit ?? HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in

            guard var samples = samplesOrNil else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error))
                return
            }

            if (request.limit != nil) {
                // if limit is used sort back to ascending
                samples = samples.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            }

            print(samples)
            result(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: request.unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true
                ]
            })
        }
        healthStore!.execute(query)
    }
    
    
    func performCollectionQuery(request: CollectionQueryRequest, result: @escaping FlutterResult) {

        
        var interval = DateComponents()
        interval.minute = request.interval ?? 1 //Defaults to 1 minute interval
        
        let calendar = Calendar.current
        var dayComponent = DateComponents()
        dayComponent.day  = 1 // For removing one day (yesterday): -1
        //let nextDate = calendar.date(byAdding: dayComponent, to: Date())!
        //let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDate)!
        
        //Test
        //let nextDate = calendar.date(byAdding: dayComponent, to: request.dateTo)!
        //let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDate)!
        
        let anchorDate = request.dateTo
        
        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom
            , end: request.dateTo, options: .strictStartDate)
        
//        dayComponent.day  = -1
//        let oneDayBeforeStart = calendar.date(byAdding: dayComponent, to: request.dateFrom)!
//        let flexyStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: oneDayBeforeStart)!
        
//        let predicate = HKQuery.predicateForSamples(withStart: flexyStart
//        , end: anchorDate, options: .strictStartDate)
        
        
        guard let type = request.sampleType as? HKQuantityType else {
            result(FlutterError(code: TAG, message: "Not supported", details: nil))
            return
        }
        
                
        let query = HKStatisticsCollectionQuery.init(quantityType: type,
                                                     quantitySamplePredicate: predicate,
                                                     options: request.option,
                                                     anchorDate: anchorDate,
                                                     intervalComponents: interval)
        
        
        query.initialResultsHandler = {
            query, results, error in
            
            //let startDate = calendar.startOfDay(for: Date())
            
            var output: [NSDictionary] = [NSDictionary]()
            
            results?.enumerateStatistics(from: request.dateFrom,
                                         to: request.dateTo, with: { (result, stop) in
                                                                                        
                                            var value: Double
                                            
                                            switch (request.aggregationOption) {
                                            case "cumulativeSum":
                                                value = result.sumQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            case "discreteAverage":
                                                value = result.averageQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            case "discreteMax":
                                                value = result.maximumQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            default:
                                                value = -1
                                            }
                                            
                                            let sample: NSDictionary =  [
                                                "value": value,
                                                "date_from" : Int(result.startDate.timeIntervalSince1970 * 1000),
                                                "date_to": Int(result.endDate.timeIntervalSince1970 * 1000),
                                                "source": "Collection Query",
                                                "user_entered": false
                                            ]
                                            
                                            if (value != 0) {
                                                output.append(sample)
                                            }
                                            
            })
            
            result(output)
        }
        
        healthStore!.execute(query)
    }
    
    
    
    //Used for background execution
    public func performHeadlessCollectionQuery(request: CollectionQueryRequest, completionHandler: @escaping ([NSDictionary]) -> Void ) {

        
        var interval = DateComponents()
        interval.minute = request.interval ?? 1 //Defaults to 1 minute interval
        
        let calendar = Calendar.current
        var dayComponent = DateComponents()
        dayComponent.day  = 1 // For removing one day (yesterday): -1
        let nextDate = calendar.date(byAdding: dayComponent, to: Date())!
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom
            , end: request.dateTo, options: .strictStartDate)
        
        
        guard let type = request.sampleType as? HKQuantityType else {
            print("Not supported")
            completionHandler([])
            return
        }
        
                
        let query = HKStatisticsCollectionQuery.init(quantityType: type,
                                                     quantitySamplePredicate: predicate,
                                                     options: request.option,
                                                     anchorDate: anchorDate,
                                                     intervalComponents: interval)
        
        
        query.initialResultsHandler = {
            query, results, error in
            
            //let startDate = calendar.startOfDay(for: Date())
            
            var output: [NSDictionary] = [NSDictionary]()
            
            results?.enumerateStatistics(from: request.dateFrom,
                                         to: request.dateTo, with: { (result, stop) in
                                                                                        
                                            var value: Double
                                            
                                            switch (request.aggregationOption) {
                                            case "cumulativeSum":
                                                value = result.sumQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            case "discreteAverage":
                                                value = result.averageQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            case "discreteMax":
                                                value = result.maximumQuantity()?.doubleValue(for: request.unit) ?? 0;
                                            default:
                                                value = -1
                                            }
                                            
                                            let sample: NSDictionary =  [
                                                "value": value,
                                                "date_from" : Int(result.startDate.timeIntervalSince1970 * 1000),
                                                "date_to": Int(result.endDate.timeIntervalSince1970 * 1000),
                                                "source": "Collection Query",
                                                "user_entered": false
                                            ]
                                            
                                            if (value != 0) {
                                                output.append(sample)
                                            }
                                            
            })
            
            completionHandler(output)
        }
        
        healthStore!.execute(query)
    }

    private func readValue(sample: HKSample, unit: HKUnit) -> Any {
        if let sample = sample as? HKQuantitySample {
            return sample.quantity.doubleValue(for: unit)
        } else if let sample = sample as? HKCategorySample {
            return sample.value
        }

        return -1
    }

    private func readSource(sample: HKSample) -> String {
        if #available(iOS 9, *) {
            return sample.sourceRevision.source.name;
        }

        return sample.source.name;
    }
}
