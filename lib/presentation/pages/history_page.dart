import 'package:flutter/material.dart';
import '../providers/travel_provider.dart';
import '../widgets/itinerary_timeline.dart';
import '../../data/datasources/history_datasource.dart';

class HistoryPage extends StatefulWidget {
  final TravelProvider provider;

  const HistoryPage({super.key, required this.provider});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.provider.loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Histórico',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF435892),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF435892),
              tabs: const [
                Tab(icon: Icon(Icons.location_city), text: 'Cidades'),
                Tab(icon: Icon(Icons.route), text: 'Roteiros'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _CitiesTab(provider: widget.provider),
              _ItinerariesTab(provider: widget.provider),
            ],
          ),
        );
      },
    );
  }
}

// ─── Aba de Cidades ────────────────────────────────────────────────────────

class _CitiesTab extends StatelessWidget {
  final TravelProvider provider;

  const _CitiesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cities = provider.cityHistory;

    if (cities.isEmpty) {
      return _EmptyState(
        icon: Icons.location_city_outlined,
        message: 'Nenhuma cidade visitada ainda',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _CityTile(
              entry: cities[i],
              onTap: () {
                Navigator.pop(context);
                provider.fetchSuggestionsForCity(cities[i].cityName);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Limpar histórico'),
                  content: const Text(
                      'Deseja apagar todo o histórico de cidades?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Apagar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) provider.clearCityHistory();
            },
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text(
              'Limpar histórico',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _CityTile extends StatelessWidget {
  final CityHistoryEntry entry;
  final VoidCallback onTap;

  const _CityTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(entry.visitedAt);
    final label = diff.inDays == 0
        ? 'Hoje'
        : diff.inDays == 1
            ? 'Ontem'
            : '${diff.inDays} dias atrás';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF435892).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.location_on,
              color: Color(0xFF435892), size: 22),
        ),
        title: Text(
          entry.cityName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey),
      ),
    );
  }
}

// ─── Aba de Roteiros ───────────────────────────────────────────────────────

class _ItinerariesTab extends StatelessWidget {
  final TravelProvider provider;

  const _ItinerariesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final itineraries = provider.itineraryHistory;

    if (itineraries.isEmpty) {
      return _EmptyState(
        icon: Icons.route_outlined,
        message: 'Nenhum roteiro gerado ainda',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: itineraries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _ItineraryTile(entry: itineraries[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Limpar roteiros'),
                  content: const Text(
                      'Deseja apagar todos os roteiros salvos?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Apagar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) provider.clearItineraryHistory();
            },
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text(
              'Limpar roteiros',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItineraryTile extends StatelessWidget {
  final ItineraryHistoryEntry entry;

  const _ItineraryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(entry.generatedAt);
    final dateLabel = diff.inDays == 0
        ? 'Hoje'
        : diff.inDays == 1
            ? 'Ontem'
            : '${diff.inDays} dias atrás';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF435892), Color(0xFFBCAA8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.route, color: Colors.white, size: 22),
        ),
        title: Text(
          entry.itinerary.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${entry.cityName} · $dateLabel',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        children: [
          ItineraryTimeline(itinerary: entry.itinerary),
        ],
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
