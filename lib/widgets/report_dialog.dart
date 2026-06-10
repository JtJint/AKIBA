import 'package:akiba/report/report_api.dart';
import 'package:flutter/material.dart';

Future<bool> showReportDialog(
  BuildContext context, {
  required int targetUserId,
  required int targetPostId,
  String reportType = 'POST',
}) async {
  final reasonController = TextEditingController();
  final detailController = TextEditingController();
  bool isSubmitting = false;

  final submitted = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> submit() async {
            final reason = reasonController.text.trim();
            final detail = detailController.text.trim();
            if (reason.isEmpty || isSubmitting) return;

            setState(() => isSubmitting = true);
            final response = await ReportApi.createReport(
              targetUserId: targetUserId,
              targetPostId: targetPostId,
              reportType: reportType,
              reason: reason,
              detail: detail,
            );
            if (!context.mounted) return;
            setState(() => isSubmitting = false);

            if (response.statusCode >= 200 && response.statusCode < 300) {
              Navigator.of(context).pop(true);
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '신고 실패 (${response.statusCode}): ${response.body}',
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: const Color(0xff1b1b1b),
            title: const Text('신고하기', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reasonController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '신고 사유',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffD0FF00)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  minLines: 3,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '상세 내용',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffD0FF00)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: isSubmitting ? null : submit,
                child: Text(isSubmitting ? '신고 중...' : '신고하기'),
              ),
            ],
          );
        },
      );
    },
  );

  reasonController.dispose();
  detailController.dispose();
  return submitted == true;
}
