import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_fitness/utils/app_colors.dart';

class BMIChart extends StatelessWidget {
  final double height;
  final double weight;

  const BMIChart({
    super.key,
    required this.height,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    double bmi = calculateBMI(height, weight);

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
        startDegreeOffset: 250,
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 1,
        centerSpaceRadius: 0,
        sections: showingSections(bmi),
      ),
    );
  }

  List<PieChartSectionData> showingSections(double bmi) {
    const color0 = AppColors.secondaryColor2;
    const color1 = AppColors.whiteColor;

    return [
      PieChartSectionData(
        color: color0,
        value: bmi,
        title: '',
        radius: 55,
        titlePositionPercentageOffset: 0.55,
        badgeWidget: Text(
          bmi.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      PieChartSectionData(
        color: color1,
        value: 100 - bmi,
        title: '',
        radius: 42,
        titlePositionPercentageOffset: 0.55,
      ),
    ];
  }

  double calculateBMI(double height, double weight) {
    return weight / ((height / 100) * (height / 100));
  }
}
