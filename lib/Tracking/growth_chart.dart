import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plant Growth Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('plants')
              .orderBy('date', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var plants = snapshot.data!.docs;

            if (plants.isEmpty) {
              return Center(child: Text("No Data Available"));
            }

            // 🟢 Sort and calculate day difference
            plants.sort((a, b) => a['date'].compareTo(b['date']));
            DateTime firstDate = plants.first['date'].toDate();

            List<FlSpot> spots = [];
            for (var doc in plants) {
              DateTime currentDate = doc['date'].toDate();
              double daysDiff = currentDate.difference(firstDate).inDays.toDouble() + 1;
              double height = doc['height'].toDouble();
              spots.add(FlSpot(daysDiff, height));
            }

            return LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()} cm",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "Day ${value.toInt()}",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
