//
// Created by Ilia Tikhomirov on 2020-02-21.
//

import HealthKit

public class CollectionQueryRequest {
    public let type: String
    public let sampleType: HKSampleType
    public let unit: HKUnit
    public let dateFrom: Date
    public let dateTo: Date
    public let limit: Int?
    public let aggregationOption: String
    public let option: HKStatisticsOptions
    public let interval: Int? //minutes

    public init(type: String, sampleType: HKSampleType, unit: HKUnit, dateFrom: Date, dateTo: Date, limit: Int?, aggregationOption: String, option: HKStatisticsOptions, interval: Int?) {
        self.type = type;
        self.sampleType = sampleType
        self.unit = unit
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.limit = limit
        self.aggregationOption = aggregationOption
        self.option = option
        self.interval = interval
    }

    static func fromCall(call: FlutterMethodCall) throws -> CollectionQueryRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let type = arguments["type"] as? String,
              let dateFromEpoch = arguments["date_from"] as? NSNumber,
              let dateToEpoch = arguments["date_to"] as? NSNumber,
              let aggregationOption = arguments["aggregationOption"] as? String
        else {
            throw "invalid call arguments \(call.arguments)";
        }

        guard let values = HKSampleType.fromDartType(type: type),
                let sampleType = values.sampleType as? HKSampleType,
                let unit = values.unit as? HKUnit else {
            throw UnsupportedError(message: "type \(type) is not supported");
        }
        let dateFrom = Date(timeIntervalSince1970: dateFromEpoch.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: dateToEpoch.doubleValue / 1000)
        let limit = arguments["limit"] as? Int
        let interval = arguments["interval"] as? Int
        let option = try HKStatisticsOptions.fromDartAggregationOption(aggregateOption: aggregationOption)

        return CollectionQueryRequest(type: type, sampleType: sampleType, unit: unit, dateFrom: dateFrom, dateTo: dateTo, limit: limit, aggregationOption: aggregationOption, option: option, interval: interval)
    }
}
