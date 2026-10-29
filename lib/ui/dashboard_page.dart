import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import 'package:visitor_management_app/models/visitor.dart';
import '../logic/visitor/visitor_bloc.dart';
import 'widgets/common_widgets.dart';

const _bg = Color(0xFFF7F7FC);
const _navy = Color(0xFF171A35);
const _purple = Color(0xFF7563F7);
const _muted = Color(0xFF8589A5);
const _border = Color(0xFFEAEBF4);

List<Visitor> _recentVisitors(VisitorState state) {
  final visitors = List<Visitor>.of(state.visitors);
  visitors.sort((a, b) {
    final aCreated = DateTime.tryParse(a.createdAt);
    final bCreated = DateTime.tryParse(b.createdAt);

    if (aCreated == null && bCreated == null) return 0;
    if (aCreated == null) return 1;
    if (bCreated == null) return -1;
    return bCreated.compareTo(aCreated);
  });

  return visitors.take(4).toList(growable: false);
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listenWhen: (a, b) => a.errorMessage != b.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFD94259),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final loading =
            state.status == VisitorStatus.loading && state.visitors.isEmpty;

        return Scaffold(
          backgroundColor: _bg,
          body: RefreshIndicator(
            color: _purple,
            onRefresh: () async {
              context.read<VisitorBloc>().add(
                    const VisitorsRequested(),
                  );
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
              children: [
                _Header(
                  onRefresh: () async {
                    final bloc = context.read<VisitorBloc>();

                    bloc.add(const VisitorsRequested());

                    await bloc.stream.firstWhere(
                      (state) =>
                          state.status == VisitorStatus.loaded ||
                          state.status == VisitorStatus.failure,
                    );
                  },
                ),
                const SizedBox(height: 26),
                _HeroCard(
                  visitorCount: state.visitors.length,
                  onRegister: () => context.push('/visitors/add'),
                ),
                const SizedBox(height: 29),
                const _SectionHeader(
                  title: 'Your overview',
                  subtitle: 'Here is what is happening today.',
                ),
                const SizedBox(height: 16),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _purple,
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 360;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: state.registeredToday,
                              title: 'Registered',
                              subtitle: 'Today',
                              icon: Icons.person_add_alt_1_rounded,
                              color: const Color(0xFF7563F7),
                              compact: compact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: state.checkedInNow,
                              title: 'Checked in',
                              subtitle: 'Currently',
                              icon: Icons.login_rounded,
                              color: const Color(0xFF14A982),
                              compact: compact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: state.checkedOutToday,
                              title: 'Checked out',
                              subtitle: 'Today',
                              icon: Icons.logout_rounded,
                              color: const Color(0xFF3988EC),
                              compact: compact,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                if (state.status == VisitorStatus.failure &&
                    state.visitors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<VisitorBloc>()
                          .add(const VisitorsRequested()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ),
                const SizedBox(height: 30),
                const _SectionHeader(
                  title: 'Shortcuts',
                  subtitle: 'Everything you need, one tap away.',
                ),
                const SizedBox(height: 16),
                _PrimaryAction(
                  onTap: () => context.push('/visitors/add'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ShortcutCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Directory',
                        subtitle: 'Browse visitors',
                        color: const Color(0xFF14A982),
                        onTap: () => context.push('/visitors'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShortcutCard(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'QR Scanner',
                        subtitle: 'Verify a pass',
                        color: const Color(0xFF3988EC),
                        onTap: () => context.push('/scanner'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 31),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: _SectionHeader(
                        title: 'Recent visitors',
                        subtitle: 'The latest visitor records.',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/visitors'),
                      child: const Text(
                        'View all  →',
                        style: TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (state.visitors.isEmpty && !loading)
                  EmptyState(
                    title: state.status == VisitorStatus.failure
                        ? 'Unable to load visitors'
                        : 'No visitors yet',
                    subtitle: state.status == VisitorStatus.failure
                        ? 'Check your connection and try again.'
                        : 'Your visitor activity will appear here after registration.',
                  )
                else
                  ..._recentVisitors(state).map(
                    (visitor) => _VisitorTile(
                      name: visitor.name,
                      project: visitor.project,
                      mobile: visitor.mobile,
                      status: visitor.status,
                      onTap: () => context.push(
                        '/visitors/details',
                        extra: visitor,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'VISITOR MANAGEMENT  •  FRONT DESK',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.75),
                      fontSize: 9,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9183FF), Color(0xFF5C49E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.24),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VISITOR MANAGEMENT',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  letterSpacing: 1.45,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.sync_rounded,
                color: _navy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.visitorCount,
    required this.onRegister,
  });

  final int visitorCount;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF171A35),
            Color(0xFF292650),
            Color(0xFF5141A8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF292650).withValues(alpha: 0.19),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -75,
            right: -45,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 35,
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 28,
            child: Icon(
              Icons.apartment_rounded,
              size: 78,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8172FF).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: Color(0xFFFFD879),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'SMARTER FRONT DESK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Make every\nwelcome count.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    height: 1.12,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Manage arrivals, verify visitors and\nkeep your workplace running smoothly.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$visitorCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total visitor records',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.66),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onRegister,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD879),
                        foregroundColor: const Color(0xFF25203E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                      ),
                      label: const Text(
                        'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 19,
            letterSpacing: -0.55,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.compact,
  });

  final int value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 17),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$value',
              style: const TextStyle(
                color: _navy,
                fontSize: 28,
                height: 1,
                letterSpacing: -1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _navy,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 11),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 25,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFDCD7FF),
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9385FF), Color(0xFF6653E8)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.23),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register a visitor',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Create a new visitor pass',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                style: const TextStyle(
                  color: _muted,
                  height: 1.4,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.arrow_outward_rounded,
                color: color,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitorTile extends StatelessWidget {
  const _VisitorTile({
    required this.name,
    required this.project,
    required this.mobile,
    required this.status,
    required this.onTap,
  });

  final String name;
  final String project;
  final String mobile;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        leading: Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAE6FF), Color(0xFFF4F2FF)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: _purple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        title: Text(
          name.trim().isEmpty ? 'Unnamed visitor' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$project • $mobile',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: StatusChip(status: status),
      ),
    );
  }
}
