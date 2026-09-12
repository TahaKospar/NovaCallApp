import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/data/services/call_history_service.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

class UserTile extends StatelessWidget {
  final String userId;
  final String userName;
  final bool isOnline;
  final bool showStatus;
  final CallHistoryService? callHistoryService;
  final VoidCallback? onCallFinished;

  const UserTile({
    super.key,
    required this.userId,
    required this.userName,
    required this.isOnline,
    this.showStatus = true,
    this.callHistoryService,
    this.onCallFinished,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final service = callHistoryService ?? CallHistoryService();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onLongPress: () => _showBlockDialog(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: isDark
                ? Colors.blue.shade900
                : Colors.blue.shade100,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color.fromARGB(255, 45, 95, 185),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: showStatus
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZegoSendCallInvitationButton(
                isVideoCall: false,
                resourceID: "zegouikit_call",
                invitees: [ZegoUIKitUser(id: userId, name: userName)],
                buttonSize: const Size(42, 42),
                iconSize: const Size(24, 24),
                icon: ButtonIcon(
                  icon: const Icon(
                    Icons.call,
                    color: Color.fromARGB(255, 45, 95, 185),
                  ),
                ),
                onPressed: (code, message, errorInvitees) async {
                  final callID =
                      'call_${DateTime.now().millisecondsSinceEpoch}';

                  await service.saveCallToHistory(
                    receiverId: userId,
                    receiverName: userName,
                    isVideo: false,
                    callID: callID,
                  );

                  onCallFinished?.call();
                },
              ),
              const SizedBox(width: 8),
              ZegoSendCallInvitationButton(
                isVideoCall: true,
                resourceID: "zegouikit_call",
                invitees: [ZegoUIKitUser(id: userId, name: userName)],
                buttonSize: const Size(42, 42),
                iconSize: const Size(24, 24),
                icon: ButtonIcon(
                  icon: const Icon(
                    Icons.video_call,
                    color: Color.fromARGB(255, 45, 95, 185),
                  ),
                ),
                onPressed: (code, message, errorInvitees) async {
                  final callID =
                      'call_${DateTime.now().millisecondsSinceEpoch}';

                  await service.saveCallToHistory(
                    receiverId: userId,
                    receiverName: userName,
                    isVideo: true,
                    callID: callID,
                  );

                  onCallFinished?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              context.read<ContactCubit>().blockUser(userId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$userName has been blocked'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
