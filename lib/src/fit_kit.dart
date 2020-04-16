part of fit_kit;

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');

  /// iOS isn't completely supported by HealthKit, false means no, true means user has approved or declined permissions.
  /// In case user has declined permissions read will just return empty list for declined data types.
  static Future<bool> hasPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('hasPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// If you're using more than one DataType it's advised to call requestPermissions with all the data types once,
  /// otherwise iOS HealthKit will ask to approve every permission one by one in separate screens.
  ///
  /// `await FitKit.requestPermissions(DataType.values)`
  static Future<bool> requestPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// iOS isn't supported by HealthKit, method does nothing.
  static Future<void> revokePermissions() async {
    return await _channel.invokeMethod('revokePermissions');
  }

  /// #### It's not advised to call `await FitKit.read(dataType)` without any extra parameters. This can lead to FAILED BINDER TRANSACTION on Android devices because of the data batch size being too large.
  static Future<List<FitData>> read(
    DataType type, {
    DateTime dateFrom,
    DateTime dateTo,
    int limit,
  }) async {
    return await _channel.invokeListMethod('read', {
      "type": _dataTypeToString(type),
      "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
      "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
      "limit": limit,
    }).then(
      (response) => response.map((item) => FitData.fromJson(item)).toList(),
    );
  }

  static Future<List<FitData>> computeCollectionQuery(
      DataType type,
      {
      DateTime dateFrom,
      DateTime dateTo,
      int limit,
      CollectionOptions aggregationOption,
      int interval
      }) async {

      return await _channel.invokeListMethod('computeCollectionQuery', {
      "type": _dataTypeToString(type),
      "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
      "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
      "limit": limit,
      "aggregationOption": _optionTypeToString(aggregationOption) ?? _optionTypeToString(CollectionOptions.CUMULATIVE_SUM),
      "interval": interval
    }).then(
      (response) => response.map((item) => FitData.fromJson(item)).toList(),
    );
  
  }

  static Future<FitData> readLast(DataType type) async {
    return await read(type, limit: 1)
        .then((results) => results.isEmpty ? null : results[0]);
  }

  static String _optionTypeToString(CollectionOptions option){
    switch (option){
      case CollectionOptions.CUMULATIVE_SUM:
        return "cumulativeSum";
      case CollectionOptions.DISCRETE_AVERAGE:
        return "discreteAverage";
    }
    throw Exception('CollectionOptions $option not supported');
  }

  static String _dataTypeToString(DataType type) {
    switch (type) {
      case DataType.HEART_RATE:
        return "heart_rate";
      case DataType.RESTING_HEART_RATE:
        return "resting_heart_rate";
      case DataType.IRREGULAR_HEART_RHYTHM_EVENT:
        return "irregular_heart_rhythm_event";
      case DataType.HIGH_HEART_RATE_EVENT:
        return "high_heart_rate_event";
      case DataType.LOW_HEART_RATE_EVENT:
        return "low_heart_rate_event";
      case DataType.STEP_COUNT:
        return "step_count";
      case DataType.HEIGHT:
        return "height";
      case DataType.WEIGHT:
        return "weight";
      case DataType.DISTANCE:
        return "distance";
      case DataType.ENERGY:
        return "energy";
      case DataType.WATER:
        return "Water";
      case DataType.SLEEP:
        return "sleep";
      case DataType.CARBOHYDRATE:
        return "Carbohydrate";
      case DataType.PROTEIN:
        return "Protein";
      case DataType.FAT:
        return "Fat";
      case DataType.STAND_TIME:
        return "stand_time";
      case DataType.EXERCISE_TIME:
        return "exercise_time";
      case DataType.SATURATED_FAT:
        return "Saturated fat";
      case DataType.CHOLESTEROL:
        return "Cholesterol";
      case DataType.FIBER:
        return "Fiber";
      case DataType.SUGAR:
        return "Sugar";
      case DataType.CALCIUM:
        return "Calcium, Ca";
      case DataType.IRON:
        return "Iron, Fe";
      case DataType.POTASSIUM:
        return "Potassium, K";
      case DataType.SODIUM:
        return "Sodium, Na";
      case DataType.VITAMIN_A:
        return "Vitamin A";
      case DataType.VITAMIN_D:
        return "Vitamin D";
      case DataType.VITAMIN_C:
        return "Vitamin C";
      case DataType.DIETARY_ENERGY:
        return "Energy";
    }
    throw Exception('dataType $type not supported');
  }
}

enum DataType {
  HEART_RATE,
  RESTING_HEART_RATE,
  IRREGULAR_HEART_RHYTHM_EVENT,
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  STEP_COUNT,
  HEIGHT,
  WEIGHT,
  DISTANCE,
  ENERGY,
  WATER,
  SLEEP,
  STAND_TIME,
  EXERCISE_TIME,
  CARBOHYDRATE,
  PROTEIN,
  DIETARY_ENERGY,
  FAT,
  SATURATED_FAT,
  CHOLESTEROL,
  FIBER,
  SUGAR,
  CALCIUM,
  IRON,
  POTASSIUM,
  SODIUM,
  VITAMIN_A,
  VITAMIN_D,
  VITAMIN_C

}

enum CollectionOptions {
  CUMULATIVE_SUM,
  DISCRETE_AVERAGE
}