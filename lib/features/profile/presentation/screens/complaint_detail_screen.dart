import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final number = complaint['complaint_number'] ?? 'CMP0000';
    final category = complaint['category'] ?? 'General';
    final description = complaint['description'] ?? '';
    final status = complaint['status'] ?? 'REGISTERED';
    final date = complaint['created_at']?.toString().substring(0, 10) ?? '';
    final txnRef = complaint['transaction_reference'] ?? 'N/A';
    final resolution = complaint['resolution'];
    final metadata = complaint['metadata'] as Map<String, dynamic>? ?? {};
    final attachmentName = metadata['attachment_name'];

    // Determine current step in journey
    int currentStep = 1;
    if (status == 'UNDER_REVIEW') currentStep = 2;
    if (status == 'ASSIGNED') currentStep = 3;
    if (status == 'RESOLVED' || status == 'CLOSED') currentStep = 4;

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint #$number', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      Chip(
                        label: Text(status, style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFFFEF3C7),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppTheme.border),
                  const Text('Category', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('Transaction Reference', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(txnRef, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 15, height: 1.4)),
                  if (attachmentName != null) ...[
                    const SizedBox(height: 16),
                    const Text('Attached File', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(attachmentName, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Submitted On', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 14)),
                  if (resolution != null && resolution.toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Resolution', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(resolution, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.success, fontSize: 15)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Complaint Journey / Timeline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.secondaryText)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _buildJourneyStep(
                    title: 'Complaint Registered',
                    subtitle: 'Submitted on $date',
                    isCompleted: currentStep >= 1,
                    isCurrent: currentStep == 1,
                    isLast: false,
                  ),
                  _buildJourneyStep(
                    title: 'Under Review',
                    subtitle: 'Assigned to support executive team',
                    isCompleted: currentStep >= 2,
                    isCurrent: currentStep == 2,
                    isLast: false,
                  ),
                  _buildJourneyStep(
                    title: 'Agent Investigation',
                    subtitle: 'Investigating payment gateway log',
                    isCompleted: currentStep >= 3,
                    isCurrent: currentStep == 3,
                    isLast: false,
                  ),
                  _buildJourneyStep(
                    title: 'Resolved / Closed',
                    subtitle: resolution ?? 'Awaiting final resolution',
                    isCompleted: currentStep >= 4,
                    isCurrent: currentStep == 4,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isCompleted ? AppTheme.success : (isCurrent ? AppTheme.primaryBlue : AppTheme.secondaryText);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.success.withValues(alpha: 0.15) : (isCurrent ? AppTheme.primaryBlue.withValues(alpha: 0.15) : AppTheme.border),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: AppTheme.success)
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted ? AppTheme.success : AppTheme.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isCurrent || isCompleted ? AppTheme.primaryText : AppTheme.secondaryText)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
