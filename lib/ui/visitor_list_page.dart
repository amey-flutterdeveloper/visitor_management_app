import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../logic/visitor/visitor_event.dart';
import '../logic/visitor/visitor_state.dart';
import '../models/visitor.dart';
import '../util/visitor_enum.dart';
import 'widgets/common_widgets.dart';

class VisitorListPage extends StatefulWidget {
  const VisitorListPage({super.key});

  @override
  State<VisitorListPage> createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: context.read<VisitorBloc>().state.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshVisitors() async {
    final bloc = context.read<VisitorBloc>();

    final completedRequest = bloc.stream.firstWhere(
      (state) =>
          state.status == VisitorStatus.loaded ||
          state.status == VisitorStatus.failure,
    );

    bloc.add(const VisitorsRequested());

    await completedRequest;
  }

  void _onSearchChanged(String query) {
    context.read<VisitorBloc>().add(
          VisitorSearchChanged(query),
        );
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitors'),
        actions: [
          IconButton(
            tooltip: 'Refresh visitors',
            onPressed: _refreshVisitors,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Register visitor',
            onPressed: () => context.push('/visitors/add'),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocConsumer<VisitorBloc, VisitorState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.notice != current.notice,
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
              ),
            );
        },
        builder: (context, state) {
          final visitors = state.filteredVisitors;

          final isInitialLoading =
              state.status == VisitorStatus.loading && state.visitors.isEmpty;

          return Column(
            children: [
              _buildSearchHeader(state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshVisitors,
                  child: _buildListContent(
                    context,
                    state,
                    visitors,
                    isInitialLoading,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(VisitorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.visitors.length} visitor'
            '${state.visitors.length == 1 ? '' : 's'} registered',
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search name, mobile, project or status',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          if (state.status == VisitorStatus.loading &&
              state.visitors.isNotEmpty) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    VisitorState state,
    List<Visitor> visitors,
    bool isInitialLoading,
  ) {
    if (isInitialLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (state.status == VisitorStatus.failure && state.visitors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 280,
            child: EmptyState(
              title: 'Could not load visitors',
              subtitle: state.errorMessage ??
                  'Check your network connection and API configuration.',
              icon: Icons.cloud_off_rounded,
            ),
          ),
          Center(
            child: OutlinedButton.icon(
              onPressed: _refreshVisitors,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (visitors.isEmpty) {
      return _buildEmptyResults(state);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];

        return VisitorCard(
          visitor: visitor,
          onTap: () {
            context.push(
              '/visitors/details',
              extra: visitor,
            );
          },
          onEdit: () {
            context.push(
              '/visitors/edit',
              extra: visitor,
            );
          },
          onDelete: () {
            _confirmDelete(context, visitor);
          },
        );
      },
    );
  }

  Widget _buildEmptyResults(VisitorState state) {
    final hasSearch = state.searchQuery.trim().isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          height: 280,
          child: EmptyState(
            title: hasSearch ? 'No matching visitors' : 'No visitors yet',
            subtitle: hasSearch
                ? 'Try another name, mobile number, project or status.'
                : 'Register your first visitor to see the record here.',
            icon: hasSearch
                ? Icons.search_off_rounded
                : Icons.people_outline_rounded,
          ),
        ),
        if (!hasSearch)
          Center(
            child: FilledButton.icon(
              onPressed: () => context.push('/visitors/add'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Register visitor'),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    Visitor visitor,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.red,
            size: 30,
          ),
          title: const Text('Delete visitor?'),
          content: Text(
            'Delete ${visitor.name} from the visitor records? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<VisitorBloc>().add(
                      VisitorDeleted(visitor.id),
                    );
              },
              child: const Text('Delete visitor'),
            ),
          ],
        );
      },
    );
  }
}
