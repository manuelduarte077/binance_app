class WeightModel {
  int? stepsTarget;
  String? sleepTime;
  String? wakeTime;
  int? waterTarget;

  WeightModel({
    this.stepsTarget,
    this.sleepTime,
    this.wakeTime,
    this.waterTarget,
  });

  Map<String, dynamic> toMap() {
    return {
      'stepsTarget': stepsTarget,
      'sleeptime': sleepTime,
      'waketime': wakeTime,
      'waterIntakeGoal': waterTarget,
    };
  }

  factory WeightModel.fromMap(map) {
    return WeightModel(
      stepsTarget: map['stepsTarget'],
      sleepTime: map['sleeptime'],
      wakeTime: map['waketime'],
      waterTarget: map['waterTarget'],
    );
  }
}
