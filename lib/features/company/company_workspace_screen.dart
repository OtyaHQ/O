import 'package:flutter/material.dart';

import '../../core/network/next_owner_api.dart';

class CompanyWorkspaceScreen extends StatefulWidget {
  const CompanyWorkspaceScreen({
    super.key,
    required this.api,
    required this.onOwnerExpired,
  });

  final NextOwnerApi api;
  final Future<void> Function() onOwnerExpired;

  @override
  State<CompanyWorkspaceScreen> createState() => _CompanyWorkspaceScreenState();
}

class _CompanyWorkspaceScreenState extends State<CompanyWorkspaceScreen> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }
    try {
      final report = await widget.api.report();
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } on OwnerAccessExpired {
      if (!mounted) return;
      setState(() => _loading = false);
      await widget.onOwnerExpired();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'The workspace could not refresh. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Company workspace'),
              Text(
                'Private owner view · Otya ecosystem',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh workspace',
              onPressed: _loading ? null : _refresh,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
              Tab(text: 'Products', icon: Icon(Icons.apps_outlined)),
              Tab(text: 'Operations', icon: Icon(Icons.work_history_outlined)),
              Tab(text: 'Connections', icon: Icon(Icons.hub_outlined)),
            ],
          ),
        ),
        body: report == null
            ? _InitialState(loading: _loading, error: _error, onRetry: _refresh)
            : Column(
                children: [
                  if (_error.isNotEmpty)
                    MaterialBanner(
                      content: Text(_error),
                      leading: const Icon(Icons.cloud_off_outlined),
                      actions: [
                        TextButton(onPressed: _refresh, child: const Text('Retry')),
                      ],
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(report: report, onRefresh: _refresh),
                        _ProductsTab(report: report, onRefresh: _refresh),
                        _OperationsTab(report: report, onRefresh: _refresh),
                        _ConnectionsTab(report: report, onRefresh: _refresh),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const CircularProgressIndicator()
              else
                Icon(Icons.cloud_off_outlined, size: 42, color: scheme.error),
              const SizedBox(height: 18),
              Text(
                loading ? 'Loading your workspace' : 'Workspace unavailable',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.isEmpty ? 'Connecting to your private Otya operations data.' : error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              if (!loading) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.report, required this.onRefresh});

  final Map<String, dynamic> report;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final status = _asMap(report['status']);
    final ready = [
      status['database'],
      status['kv'],
      status['ai'],
      status['ai_search'],
      status['push'],
      status['email'],
    ].where((value) => value == true).length;
    final crashes = _asList(report['crashes']);
    final plugins = _asList(report['plugins']);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Text('Your ecosystem, one view.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(
            'Operational snapshot · ' + _timeLabel(report['generated_at'] ?? status['generated_at']),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Platform signals',
            subtitle: 'Figures returned by the connected operations service.',
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 4 : 2;
              final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(width: width, child: _MetricCard(label: 'Registered users', value: _count(status['users']), icon: Icons.people_outline_rounded)),
                  SizedBox(width: width, child: _MetricCard(label: 'Devices', value: _count(status['devices']), icon: Icons.devices_outlined)),
                  SizedBox(width: width, child: _MetricCard(label: 'Downloads · 7 days', value: _count(status['downloads_7d']), icon: Icons.download_outlined)),
                  SizedBox(width: width, child: _MetricCard(label: 'Crashes · 7 days', value: _count(status['crashes_7d']), icon: Icons.bug_report_outlined, warning: _number(status['crashes_7d']) > 0)),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: 'Shared service readiness',
            subtitle: ready.toString() + ' of 6 reported capabilities are available.',
          ),
          const SizedBox(height: 10),
          _SurfaceCard(
            child: Column(
              children: [
                _ServiceRow(label: 'Database', value: status['database']),
                _ServiceRow(label: 'Short-lived state', value: status['kv']),
                _ServiceRow(label: 'AI runtime', value: status['ai']),
                _ServiceRow(label: 'Private knowledge search', value: status['ai_search']),
                _ServiceRow(label: 'Push delivery', value: status['push']),
                _ServiceRow(label: 'Shared email gateway', value: status['email']),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionHeading(
            title: 'Needs attention',
            subtitle: 'Recent records from the connected operations feed.',
          ),
          const SizedBox(height: 10),
          _SurfaceCard(
            child: Column(
              children: [
                _SummaryRow(icon: Icons.bug_report_outlined, title: 'Crash groups', detail: crashes.isEmpty ? 'No groups reported' : crashes.length.toString() + ' grouped issue(s)', warning: crashes.isNotEmpty),
                _SummaryRow(icon: Icons.rate_review_outlined, title: 'Customer feedback', detail: _asList(report['feedback']).length.toString() + ' recent item(s)'),
                _SummaryRow(icon: Icons.support_agent_outlined, title: 'Support inbox', detail: _asList(report['support']).length.toString() + ' message(s) returned'),
                _SummaryRow(icon: Icons.hub_outlined, title: 'Connected services', detail: plugins.length.toString() + ' integration record(s)'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _NoticeCard(
            icon: Icons.shield_outlined,
            title: 'Separate systems, one workspace',
            text: 'OPoint shop and agency balances are not connected to this feed yet. Sales, stock, cash and float figures are deliberately not estimated or mixed with platform telemetry.',
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.report, required this.onRefresh});

  final Map<String, dynamic> report;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Text('Otya product family', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(
            'Each product keeps its own responsibilities, data and access rules.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          const _ProductCard(name: 'Otya OS', detail: 'The unified platform and shared ecosystem experience.', state: 'Platform', icon: Icons.grid_view_rounded),
          const _ProductCard(name: 'Otya End', detail: 'Shared identity, product-scoped APIs and integration services. Runtime signals appear in Overview and Connections.', state: 'Shared backend', icon: Icons.cloud_outlined),
          const _ProductCard(name: 'OPoint', detail: 'Retail, inventory and mobile-money agency operations. Its live shop records are not connected to this owner workspace yet, so sales, stock, cash and float balances are not displayed here.', state: 'Not connected', icon: Icons.storefront_outlined, warning: true),
          const _ProductCard(name: 'Omy Play', detail: 'Local-first music and video. Product-specific release telemetry is not yet attributed in this owner feed.', state: 'Local-first', icon: Icons.play_circle_outline_rounded),
          const _ProductCard(name: 'OHub', detail: 'Public developer and partner documentation. Private business operations and owner controls remain outside the public hub.', state: 'Public surface', icon: Icons.code_rounded),
          const _ProductCard(name: 'O', detail: 'This private owner assistant and company workspace. Sensitive actions remain approval-gated.', state: 'Current workspace', icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 8),
          const _NoticeCard(
            icon: Icons.lock_outline_rounded,
            title: 'No artificial roll-up',
            text: 'A product is shown as connected only when its real integration reports that state. Missing connections are marked clearly rather than filled with sample data.',
          ),
        ],
      ),
    );
  }
}

class _OperationsTab extends StatelessWidget {
  const _OperationsTab({required this.report, required this.onRefresh});

  final Map<String, dynamic> report;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final crashes = _asList(report['crashes']);
    final releases = _asList(report['releases']);
    final feedback = _asList(report['feedback']);
    final support = _asList(report['support']);
    final audit = _asList(report['audit']);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Text('Operations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text('Review what the connected services have actually recorded.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Crash groups', subtitle: 'Grouped platform crashes · last 14 days'),
          const SizedBox(height: 8),
          if (crashes.isEmpty)
            const _EmptyCard(text: 'No crash groups were returned.')
          else
            ...crashes.take(8).map((item) => _RecordCard(
                  icon: Icons.bug_report_outlined,
                  title: _firstText(item, ['error_type', 'group_id'], 'Unknown issue'),
                  detail: _count(item['count']) + ' report(s) · latest ' + _timeLabel(item['latest']),
                  warning: true,
                )),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Releases', subtitle: 'Most recent release records'),
          const SizedBox(height: 8),
          if (releases.isEmpty)
            const _EmptyCard(text: 'No release records were returned.')
          else
            ...releases.take(6).map((item) => _RecordCard(
                  icon: Icons.rocket_launch_outlined,
                  title: _firstText(item, ['version', 'tag'], 'Release'),
                  detail: _firstText(item, ['changelog', 'released_at'], 'Release details unavailable'),
                )),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Customer feedback', subtitle: 'Recent feedback records'),
          const SizedBox(height: 8),
          if (feedback.isEmpty)
            const _EmptyCard(text: 'No feedback records were returned.')
          else
            ...feedback.take(8).map((item) => _RecordCard(
                  icon: Icons.rate_review_outlined,
                  title: _firstText(item, ['category', 'sentiment'], 'Feedback'),
                  detail: _firstText(item, ['description', 'created_at'], 'Feedback details unavailable'),
                )),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Support inbox', subtitle: 'Available only when the secure mailbox connection is active'),
          const SizedBox(height: 8),
          if (support.isEmpty)
            const _EmptyCard(text: 'No support messages were returned. This may mean there are none or the mailbox is not connected.')
          else
            ...support.take(8).map((item) => _RecordCard(
                  icon: Icons.email_outlined,
                  title: _firstText(item, ['subject'], 'Support message'),
                  detail: _firstText(item, ['from'], 'Sender unavailable') + ' · ' + _timeLabel(item['created_at']),
                )),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Support activity', subtitle: 'Recent actions recorded by the support workflow'),
          const SizedBox(height: 8),
          if (audit.isEmpty)
            const _EmptyCard(text: 'No support audit entries were returned.')
          else
            ...audit.take(8).map((item) => _RecordCard(
                  icon: Icons.history_rounded,
                  title: _firstText(item, ['action', 'subject'], 'Support action'),
                  detail: _firstText(item, ['risk'], 'Risk not supplied') + ' · ' + _timeLabel(item['created_at']),
                )),
        ],
      ),
    );
  }
}

class _ConnectionsTab extends StatelessWidget {
  const _ConnectionsTab({required this.report, required this.onRefresh});

  final Map<String, dynamic> report;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final plugins = _asList(report['plugins']);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Text('Connected services', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text('Connection state is read from Otya End. No credentials or secret values are shown here.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (plugins.isEmpty)
            const _EmptyCard(text: 'The backend did not return any integration records.')
          else
            ...plugins.map((plugin) {
              final rawCapabilities = plugin['capabilities'];
              final capabilities = rawCapabilities is List
                  ? rawCapabilities.whereType<String>().where((value) => value.isNotEmpty).toList(growable: false)
                  : const <String>[];
              return _ConnectionCard(
                name: _firstText(plugin, ['name'], 'Service'),
                category: _firstText(plugin, ['category'], 'Integration'),
                state: _firstText(plugin, ['status'], 'unknown'),
                detail: _firstText(plugin, ['setup_hint'], ''),
                capabilities: capabilities,
              );
            }),
          const SizedBox(height: 8),
          const _NoticeCard(
            icon: Icons.verified_user_outlined,
            title: 'Owner-only visibility',
            text: 'Connection information is displayed after owner authentication. This screen cannot change provider settings or reveal API keys.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle?.isNotEmpty == true) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, this.warning = false});

  final String label;
  final String value;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: warning ? scheme.error : scheme.primary, size: 21),
            const SizedBox(height: 13),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ready = value == true;
    final known = value is bool;
    final color = !known ? scheme.onSurfaceVariant : ready ? scheme.primary : scheme.error;
    final state = !known ? 'Unknown' : ready ? 'Ready' : 'Unavailable';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(ready ? Icons.check_circle_outline_rounded : Icons.circle_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(state, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.title, required this.detail, this.warning = false});

  final IconData icon;
  final String title;
  final String detail;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: warning ? scheme.error : scheme.primary, size: 19),
          const SizedBox(width: 11),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Flexible(child: Text(detail, textAlign: TextAlign.end, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.name, required this.detail, required this.state, required this.icon, this.warning = false});

  final String name;
  final String detail;
  final String state;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: .55), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                        _StatePill(label: state, warning: warning),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.name, required this.category, required this.state, required this.detail, required this.capabilities});

  final String name;
  final String category;
  final String state;
  final String detail;
  final List<String> capabilities;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final good = state == 'connected';
    final caution = state == 'degraded' || state == 'setup_required';
    final label = switch (state) {
      'connected' => 'Connected',
      'ready_to_connect' => 'Ready to finish',
      'setup_required' => 'Setup needed',
      'degraded' => 'Needs attention',
      'available_next' => 'Available to add',
      _ => state.replaceAll('_', ' '),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(category, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _StatePill(label: label, warning: caution, success: good),
                ],
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 9),
                Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
              ],
              if (capabilities.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: capabilities.take(5).map((value) => Chip(
                    label: Text(value, style: Theme.of(context).textTheme.labelSmall),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  )).toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.icon, required this.title, required this.detail, this.warning = false});

  final IconData icon;
  final String title;
  final String detail;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: warning ? scheme.error : scheme.primary, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(detail, maxLines: 4, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 20),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.label, this.warning = false, this.success = false});

  final String label;
  final bool warning;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = warning ? scheme.error : success ? scheme.primary : scheme.onSurfaceVariant;
    final background = warning
        ? scheme.errorContainer.withValues(alpha: .55)
        : success
            ? scheme.primaryContainer.withValues(alpha: .55)
            : scheme.surfaceContainerHighest;
    return Container(
      constraints: const BoxConstraints(maxWidth: 155),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
  return const {};
}

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>()
      .map((row) => row.map((key, value) => MapEntry(key.toString(), value)))
      .toList(growable: false);
}

int _number(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _count(Object? value) => value == null ? '—' : _number(value).toString();

String _firstText(Map<String, dynamic> item, List<String> keys, String fallback) {
  for (final key in keys) {
    final value = item[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return fallback;
}

String _timeLabel(Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return 'time unavailable';
  final date = DateTime.tryParse(raw)?.toLocal();
  if (date == null) return raw;
  return date.toString().split('.').first;
}
