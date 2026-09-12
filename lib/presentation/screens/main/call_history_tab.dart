import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:novacall/business_logic/callHistoryCubit/call_history_cubit.dart';
import 'package:novacall/data/model/call_model.dart';

class CallHistoryTab extends StatefulWidget {
  const CallHistoryTab({super.key});

  @override
  State<CallHistoryTab> createState() => _CallHistoryTabState();
}

class _CallHistoryTabState extends State<CallHistoryTab> {
  @override
  void initState() {
    super.initState();
    context.read<CallHistoryCubit>().loadHistory();
  }
  

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Call History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                    'Are you sure you want to clear all call history?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CallHistoryCubit>().clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CallHistoryCubit, CallHistoryState>(
        builder: (context, state) {
          if (state is CallHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 45, 95, 185),
              ),
            );
          } else if (state is CallHistoryLoaded) {
            if (state.calls.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No call history",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.calls.length,
              itemBuilder: (context, index) {
                final call = state.calls[index];
                return _buildCallTile(call, textColor);
              },
            );
          } else if (state is CallHistoryError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCallTile(CallModel call, Color? textColor) {
    final isMissed = call.isMissed();
    final isVideo = call.type == CallType.video;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMissed ? Colors.red.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMissed
              ? Colors.red.withOpacity(0.2)
              : Colors.blue.shade100,
          child: Icon(
            isVideo ? Icons.videocam : Icons.call,
            color: isMissed ? Colors.red : const Color.fromARGB(255, 45, 95, 185),
          ),
        ),
        title: Text(
          call.callerId == call.receiverId ? 'Unknown' : call.receiverName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isMissed ? Colors.red : textColor,
          ),
        ),
        subtitle: Text(
          '${_formatDate(call.createdAt)} • ${_formatDuration(call.durationInSeconds)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(
          isMissed ? Icons.call_missed : Icons.call_made,
          color: isMissed ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(date.year, date.month, date.day);

    if (callDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (callDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'Missed';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}