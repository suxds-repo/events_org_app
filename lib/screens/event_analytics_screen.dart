import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class EventAnalyticsScreen extends StatefulWidget {
  final String eventId;

  const EventAnalyticsScreen({super.key, required this.eventId});

  @override
  State<EventAnalyticsScreen> createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> feedbacks = [];
  double averageRating = 0.0;
  int totalReviews = 0;
  int checkedInCount = 0;
  bool showChart = false;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final rawFeedbacks = await supabase
          .from('event_feedback')
          .select('user_id, rating, comment')
          .eq('event_id', widget.eventId);

      double totalRating = 0.0;
      int count = 0;

      final List<Map<String, dynamic>> processedFeedbacks = [];

      for (final f in rawFeedbacks) {
        final userId = f['user_id'];
        String userName = 'Анонимный пользователь';

        if (userId != null) {
          final userResponse =
              await supabase
                  .from('users')
                  .select('full_name')
                  .eq('id', userId)
                  .maybeSingle();

          if (userResponse != null && userResponse['full_name'] != null) {
            userName = userResponse['full_name'];
          }
        }

        processedFeedbacks.add({
          'user_name': userName,
          'rating': f['rating'],
          'comment': f['comment'] ?? '',
        });

        totalRating += (f['rating'] ?? 0).toDouble();
        count++;
      }

      final checkedInParticipants = await supabase
          .from('participants')
          .select('id')
          .eq('event_id', widget.eventId)
          .eq('checked_in', true);

      setState(() {
        feedbacks = processedFeedbacks;
        totalReviews = count;
        averageRating = count > 0 ? totalRating / count : 0.0;
        checkedInCount = checkedInParticipants.length;
      });
    } catch (e) {
      print('Ошибка при загрузке аналитики: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить аналитику')),
      );
    }
  }

  Map<int, int> getRatingDistribution() {
    final Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in feedbacks) {
      final rating = (feedback['rating'] ?? 0).toInt();
      if (distribution.containsKey(rating)) {
        distribution[rating] = distribution[rating]! + 1;
      }
    }
    return distribution;
  }

  Widget buildRatingChart() {
    final distribution = getRatingDistribution();
    final maxCount = distribution.values.fold<int>(
      0,
      (max, curr) => curr > max ? curr : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.6,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxCount + 1).toDouble(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, _, rod, __) {
                    return BarTooltipItem(
                      '${group.x.toInt()} ⭐: ${rod.toY.toInt()} отзыва(ов)',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => Text('${value.toInt()}⭐'),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups:
                  distribution.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.indigo,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (maxCount + 1).toDouble(),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика мероприятия')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            feedbacks.isEmpty
                ? const Center(child: Text('Отзывов пока нет'))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Средняя оценка: ${averageRating.toStringAsFixed(1)} ⭐',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Всего отзывов: $totalReviews'),
                    Text('Прошли по QR: $checkedInCount'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showChart = !showChart;
                        });
                      },
                      child: Text(
                        showChart ? 'Скрыть график' : 'Показать график',
                      ),
                    ),
                    if (showChart) buildRatingChart(),
                    const Divider(height: 32),
                    const Text('Отзывы:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final f = feedbacks[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(f['rating'].toString()),
                              ),
                              title: Text(f['user_name']),
                              subtitle: Text(f['comment']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
