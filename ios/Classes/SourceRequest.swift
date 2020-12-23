//
//  SourceRequest.swift
//  fit_kit
//
//  Created by Elliot Tikhomirov on 23.04.2020.
//

import HealthKit

class SourceRequest {
    let type: String
    let sampleType: HKSampleType

    private init(type: String, sampleType: HKSampleType) {
        self.type = type;
        self.sampleType = sampleType
    }

    static func fromCall(call: FlutterMethodCall) throws -> SourceRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let type = arguments["type"] as? String else {
            throw "invalid call arguments \(call.arguments)";
        }
        
        guard let values = HKSampleType.fromDartType(type: type),
                let sampleType = values.sampleType as? HKSampleType
                else {
            throw UnsupportedError(message: "type \(type) is not supported");
        }

        return SourceRequest(type: type, sampleType: sampleType)
    }
}

