import 'package:flutter/material.dart';

class OrderStatusStepper extends StatelessWidget {
  final String currentStatus;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? deliveryDate;

  const OrderStatusStepper({
    Key? key,
    required this.currentStatus,
    required this.createdAt,
    this.deliveredAt,
    this.deliveryDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return _buildStepItem(
              step: step['step'] as String,
              completed: step['completed'] as bool,
              current: step['current'] as bool,
              date: step['date'] as DateTime,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildSteps() {
    final orderStatus = currentStatus;

    return [
      {
        'step': 'Processing',
        'completed': true,
        'current': orderStatus == 'Processing',
        'date': createdAt,
      },
      {
        'step': 'Shipped',
        'completed': [
          'Shipped',
          'Out for Delivery',
          'Delivered',
        ].contains(orderStatus),
        'current': orderStatus == 'Shipped',
        'date': createdAt.add(const Duration(hours: 4)),
      },
      {
        'step': 'Out for Delivery',
        'completed': ['Out for Delivery', 'Delivered'].contains(orderStatus),
        'current': orderStatus == 'Out for Delivery',
        'date': createdAt.add(const Duration(hours: 8)),
      },
      {
        'step': 'Delivered',
        'completed': orderStatus == 'Delivered',
        'current': orderStatus == 'Delivered',
        'date':
            deliveredAt ??
            deliveryDate ??
            createdAt.add(const Duration(days: 1)),
      },
    ];
  }

  Widget _buildStepItem({
    required String step,
    required bool completed,
    required bool current,
    required DateTime date,
    required bool isLast,
  }) {
    final Color statusColor =
        completed
            ? Colors.green
            : current
            ? Colors.blue
            : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Indicator Column
        Column(
          children: [
            // Circle Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    completed || current
                        ? statusColor
                        : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child:
                  completed
                      ? Icon(Icons.check, color: Colors.white, size: 18)
                      : current
                      ? Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      )
                      : null,
            ),
            // Connecting Line
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                    completed
                        ? statusColor
                        : Colors.grey.withValues(alpha: 0.3),
              ),
          ],
        ),
        SizedBox(width: 16),
        // Step Details
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        current || completed
                            ? FontWeight.w600
                            : FontWeight.normal,
                    color:
                        completed || current
                            ? Colors.grey[800]
                            : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (current)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Current Status',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Future date
      final futureDiff = date.difference(now);
      if (futureDiff.inHours < 24) {
        return 'Expected in ${futureDiff.inHours}h';
      } else {
        return 'Expected ${_formatDateTime(date)}';
      }
    } else {
      // Past date
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return _formatDateTime(date);
      }
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
