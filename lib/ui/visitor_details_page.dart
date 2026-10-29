import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';

import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../models/visitor.dart';
import 'widgets/common_widgets.dart';

class VisitorDetailsPage extends StatelessWidget {
  const VisitorDetailsPage({super.key, required this.visitor});

  final Visitor visitor;

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Not recorded';

    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(context);
        }
      },
      child: BlocConsumer<VisitorBloc, VisitorState>(
        listenWhen: (previous, current) =>
            previous.notice != current.notice ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final message = state.errorMessage ?? state.notice;
          if (message == null) return;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
                backgroundColor:
                    state.errorMessage != null ? AppTheme.red : AppTheme.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
        },
        builder: (context, state) {
          final current = _latestVisitor(state) ?? visitor;
          final isSaving = state.status == VisitorStatus.saving;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context),
              ),
              title: const Text('Visitor details'),
              actions: [
                IconButton(
                  tooltip: 'Edit visitor',
                  onPressed: isSaving
                      ? null
                      : () => context.push('/visitors/edit', extra: current),
                  icon: const Icon(Icons.edit_outlined),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _buildVisitorHeader(current),
                const SizedBox(height: 18),
                _buildInformationCard(current),
                const SizedBox(height: 14),
                _buildTimelineCard(current),
                const SizedBox(height: 14),
                _buildQrPass(current),
                const SizedBox(height: 20),
                _buildStatusAction(context, current, isSaving),
                if (isSaving) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Visitor? _latestVisitor(VisitorState state) {
    for (final item in state.visitors) {
      if (item.id == visitor.id) {
        return item;
      }
    }

    final selected = state.selectedVisitor;

    if (selected != null && selected.id == visitor.id) {
      return selected;
    }

    return null;
  }

  Widget _buildVisitorHeader(Visitor current) {
    final initial = current.name.trim().isEmpty
        ? '?'
        : current.name.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            current.name.isEmpty ? 'Unnamed visitor' : current.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          StatusChip(status: current.status),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'VISITOR ID  ${current.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard(Visitor current) {
    return _DetailsSection(
      title: 'VISITOR INFORMATION',
      icon: Icons.badge_outlined,
      children: [
        _DetailRow(
          icon: Icons.phone_outlined,
          label: 'Mobile',
          value: current.mobile,
        ),
        _DetailRow(
          icon: Icons.mail_outline,
          label: 'Email',
          value: (current.email?.trim().isNotEmpty ?? false)
              ? current.email!.trim()
              : 'Not provided',
        ),
        _DetailRow(
          icon: Icons.category_outlined,
          label: 'Visitor type',
          value: current.visitorType,
        ),
        _DetailRow(
          icon: Icons.apartment_outlined,
          label: 'Project',
          value: current.project,
        ),
        _DetailRow(
          icon: Icons.assignment_outlined,
          label: 'Purpose',
          value: current.purpose,
        ),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'Registered',
          value: _formatDate(current.createdAt),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineCard(Visitor current) {
    return _DetailsSection(
      title: 'VISIT TIMELINE',
      icon: Icons.schedule_rounded,
      children: [
        _DetailRow(
          icon: Icons.login_rounded,
          label: 'Checked in',
          value: _formatDate(current.checkInTime),
        ),
        _DetailRow(
          icon: Icons.logout_rounded,
          label: 'Checked out',
          value: _formatDate(current.checkOutTime),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildQrPass(Visitor current) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_2_rounded,
            color: AppTheme.primary,
            size: 27,
          ),
          const SizedBox(height: 6),
          const Text(
            'VISITOR PASS',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Show this code at the entrance',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: current.id,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: AppTheme.background,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            current.id,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 14,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAction(
    BuildContext context,
    Visitor current,
    bool isSaving,
  ) {
    if (current.status == 'Registered') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isSaving
              ? null
              : () => context
                  .read<VisitorBloc>()
                  .add(VisitorCheckInRequested(current)),
          icon: const Icon(Icons.login_rounded),
          label: const Text('Check in visitor'),
        ),
      );
    }

    if (current.status == 'Checked In') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isSaving
              ? null
              : () => context
                  .read<VisitorBloc>()
                  .add(VisitorCheckOutRequested(current)),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Check out visitor'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.green.withValues(alpha: 0.22),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: AppTheme.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Visit completed. This registration cannot be checked in again.',
              style: TextStyle(
                color: AppTheme.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 9, bottom: isLast ? 8 : 11),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: AppTheme.primary),
              const SizedBox(width: 10),
              SizedBox(
                width: 88,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.border),
          ],
        ],
      ),
    );
  }
}
