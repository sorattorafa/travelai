import 'package:flutter/material.dart';
import '../providers/travel_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/tour_card.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/tips_section.dart';
import '../widgets/itinerary_timeline.dart';
import '../widgets/weather_card.dart';
import 'history_page.dart';
import 'itinerary_edit_page.dart';
import 'paywall_page.dart';
import '../../data/datasources/usage_repository.dart';

class HomePage extends StatefulWidget {
  final TravelProvider provider;

  const HomePage({super.key, required this.provider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cityController = TextEditingController();
  final _cityFocus = FocusNode();
  final _interestController = TextEditingController();
  final _interestFocus = FocusNode();
  int _selectedTab = 0; // 0 = Passeios, 1 = Restaurantes

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onProviderChanged);
    widget.provider.loadHistory();
    widget.provider.loadUsageState();
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    _cityController.dispose();
    _cityFocus.dispose();
    _interestController.dispose();
    _interestFocus.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;
    setState(() {});

    // Se está offline, mostra SnackBar e limpa o estado.
    if (widget.provider.offlineError != null) {
      final msg = widget.provider.offlineError!;
      widget.provider.clearOfflineError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Se atingiu o limite, abre o paywall
    if (widget.provider.limitReached) {
      widget.provider.clearLimitReached();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaywallPage(
            limitType: widget.provider.limitType,
            usageRepository: widget.provider.usageRepository,
            onRestored: () {
              widget.provider.loadUsageState();
            },
          ),
        ),
      ).then((_) {
        // Recarrega o estado de uso ao voltar do paywall
        widget.provider.loadUsageState();
      });
    }
  }

  void _searchCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      _cityFocus.unfocus();
      widget.provider.fetchSuggestionsForCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'GuIA',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF435892),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Seu guia inteligente de viagens',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      // Bot\u00e3o voltar (s\u00f3 quando h\u00e1 resultados na tela)
                      if (provider.suggestions != null)
                        Positioned(
                          left: 0,
                          top: -2,
                          child: IconButton(
                            tooltip: 'Nova busca',
                            onPressed: () => provider.reset(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF435892),
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      // Hist\u00f3rico + badge de uso empilhados
                      Positioned(
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Histórico',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HistoryPage(provider: provider),
                                ),
                              ),
                              icon: const Icon(
                                Icons.history,
                                color: Color(0xFF435892),
                                size: 26,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            if (!provider.isPremium) ...[
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaywallPage(
                                      limitType: 'search',
                                      usageRepository:
                                          provider.usageRepository,
                                    ),
                                  ),
                                ).then((_) => provider.loadUsageState()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: provider.searchesRemaining > 0
                                        ? const Color(0xFF435892)
                                            .withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${provider.aiCallsRemaining}/${UsageRepository.freeAiCallsPerDay}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: provider.searchesRemaining > 0
                                          ? const Color(0xFF435892)
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              _buildContent(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TravelProvider provider) {
    switch (provider.status) {
      case TravelStatus.idle:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildHero(provider),
        );

      case TravelStatus.loadingLocation:
      case TravelStatus.loadingSuggestions:
        return SliverFillRemaining(
          child: LoadingIndicator(status: provider.status),
        );

      case TravelStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildError(provider),
        );

      case TravelStatus.success:
        return _buildResults(provider);
    }
  }

  Widget _buildHero(TravelProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para onde vamos hoje?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Use sua localização atual ou escolha uma cidade para explorar.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Botão GPS
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.fetchSuggestions,
                icon: const Icon(Icons.my_location),
                label: const Text('Usar minha localização'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF435892),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Divider "ou"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ou escolha uma cidade',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 24),

            // Campo de busca por cidade
            TextField(
              controller: _cityController,
              focusNode: _cityFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchCity(),
              decoration: InputDecoration(
                hintText: 'Ex: Paris, Tokyo, Nova York...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _cityController,
                  builder: (_, value, __) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        _cityController.clear();
                        setState(() {});
                      },
                    );
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF435892),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão buscar cidade
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _searchCity,
                icon: const Icon(Icons.flight_takeoff),
                label: const Text('Explorar cidade'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF435892),
                  side: const BorderSide(color: Color(0xFF435892)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // Cidades recentes
            if (provider.cityHistory.isNotEmpty) ...[
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Buscas recentes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.cityHistory
                    .take(6)
                    .map(
                      (e) => ActionChip(
                        avatar: const Icon(
                          Icons.history,
                          size: 16,
                          color: Color(0xFF435892),
                        ),
                        label: Text(e.cityName),
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1F2937),
                        ),
                        backgroundColor: const Color(0xFF435892)
                            .withValues(alpha: 0.08),
                        side: BorderSide.none,
                        onPressed: () =>
                            provider.fetchSuggestionsForCity(e.cityName),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(TravelProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.red),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                provider.reset();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(TravelProvider provider) {
    final suggestions = provider.suggestions!;
    final location = provider.location;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Location header
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 22,
                      color: Color(0xFF435892),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        suggestions.location,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Weather card
          if (provider.weather != null) ...[
            WeatherCard(
              weather: provider.weather!,
              cityName: suggestions.location,
            ),
            const SizedBox(height: 24),
          ],

          // Itinerary section (above suggestions)
          _buildItinerarySection(provider),
          const SizedBox(height: 24),

          // Interest search section
          _buildInterestSearch(provider),
          const SizedBox(height: 24),

          // Toggle: Passeios / Restaurantes
          _buildCategoryToggle(),
          const SizedBox(height: 16),

          // Content based on selected tab
          if (_selectedTab == 0) ...[
            // Passeios
            _buildCardGrid(
              children: suggestions.tours
                  .map((t) => TourCard(tour: t))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildLoadMoreButton(
              loading: provider.loadingMoreTours,
              hasMore: true,
              onPressed: provider.loadMoreTours,
              label: 'Mais passeios',
            ),
          ] else ...[
            // Restaurantes
            _buildCardGrid(
              children: suggestions.restaurants
                  .map((r) => RestaurantCard(restaurant: r))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildLoadMoreButton(
              loading: provider.loadingMoreRestaurants,
              hasMore: provider.hasMoreRestaurants,
              onPressed: provider.loadMoreRestaurants,
              label: 'Mais restaurantes',
            ),
          ],
          const SizedBox(height: 16),

          // Tips section
          TipsSection(tips: suggestions.tips),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'GuIA © ${DateTime.now().year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _searchInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty) {
      _interestFocus.unfocus();
      widget.provider.searchByInterest(interest);
    }
  }

  Widget _buildInterestSearch(TravelProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            const Icon(Icons.interests_outlined, size: 22, color: Color(0xFF435892)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'O que você gosta de fazer?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (provider.currentInterest != null)
              GestureDetector(
                onTap: () {
                  _interestController.clear();
                  provider.clearInterestSearch();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Limpar',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Search field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _interestController,
                focusNode: _interestFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchInterest(),
                decoration: InputDecoration(
                  hintText: 'Ex: bike, sushi, trilha...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF435892),
                      width: 2,
                    ),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed:
                    provider.loadingInterest ? null : _searchInterest,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF435892),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: provider.loadingInterest
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search, size: 20),
              ),
            ),
          ],
        ),

        // Loading state
        if (provider.loadingInterest) ...[
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF435892),
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 12),
                Text(
                  'Buscando "${provider.currentInterest}"...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error state
        if (provider.interestError != null &&
            !provider.loadingInterest) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.interestError!,
                    style: TextStyle(fontSize: 13, color: Colors.red[700]),
                  ),
                ),
                IconButton(
                  onPressed: _searchInterest,
                  icon: Icon(Icons.refresh, color: Colors.red[400], size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],

        // Results
        if (provider.interestResults.isNotEmpty &&
            !provider.loadingInterest) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF435892).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_activity,
                    size: 16, color: Color(0xFF435892)),
                const SizedBox(width: 6),
                Text(
                  '"${provider.currentInterest}" — ${provider.interestResults.length} lugares',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF435892),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCardGrid(
            children: provider.interestResults
                .map((t) => TourCard(tour: t))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: _selectedTab == 0
                          ? const Color(0xFF435892)
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Passeios',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 0
                            ? const Color(0xFF435892)
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 18,
                      color: _selectedTab == 1
                          ? const Color(0xFF435892)
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Restaurantes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 1
                            ? const Color(0xFF435892)
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds cards in a responsive grid:
  /// - iPhone: 1 column (full width)
  /// - iPad: 2 columns side by side
  Widget _buildCardGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (!isTablet) {
          // Phone: single column
          return Column(
            children: children
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: c,
                    ))
                .toList(),
          );
        }

        // iPad: 2 columns
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final hasSecond = i + 1 < children.length;
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: children[i]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: hasSecond ? children[i + 1] : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }

  Widget _buildLoadMoreButton({
    required bool loading,
    required bool hasMore,
    required VoidCallback onPressed,
    required String label,
  }) {
    if (!hasMore) {
      return const SizedBox.shrink();
    }

    return Center(
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF435892),
                ),
              ),
            )
          : TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.expand_more, size: 20),
              label: Text(label),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF435892),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  Widget _buildItinerarySection(TravelProvider provider) {
    // Se já tem roteiro, mostra a timeline
    if (provider.itinerary != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.map_outlined, title: 'Seu Roteiro'),
          const SizedBox(height: 12),
          ItineraryTimeline(
            itinerary: provider.itinerary!,
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItineraryEditPage(provider: provider),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: provider.generateItinerary,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Gerar novo roteiro'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF435892),
                side: const BorderSide(color: Color(0xFF435892)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Se está gerando, mostra loading
    if (provider.loadingItinerary) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF435892),
            ),
            const SizedBox(height: 16),
            Text(
              'Criando seu roteiro personalizado...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Se teve erro, mostra erro + botão tentar novamente
    if (provider.itineraryError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              provider.itineraryError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: provider.generateItinerary,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Estado padrão: botão para criar roteiro
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF435892),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF435892).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.generateItinerary,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.route, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Criar Roteiro Personalizado',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rota inteligente com passeios e restaurantes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF435892)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
