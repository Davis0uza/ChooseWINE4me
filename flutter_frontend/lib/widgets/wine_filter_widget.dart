// lib/widgets/wine_filter_widget.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Callback chamado quando o usuário pressiona “Pesquisar” dentro do filtro.
/// Recebe: preço mínimo, preço máximo, nota mínima, nota máxima e tipo de vinho selecionado.
typedef OnFilterSearch = void Function({
  required double minPrice,
  required double maxPrice,
  required double minRating,
  required double maxRating,
  String? wineType,
});

class WineFilterWidget extends StatefulWidget {
  /// Chamado ao pressionar o botão “Pesquisar”
  final OnFilterSearch onSearch;

  /// Valores iniciais, caso queira pré-configurar o filtro
  final double initialMinPrice;
  final double initialMaxPrice;
  final double initialMinRating;
  final double initialMaxRating;
  final String? initialWineType;

  const WineFilterWidget({
    super.key,
    required this.onSearch,
    this.initialMinPrice = 0,
    this.initialMaxPrice = 150,
    this.initialMinRating = 1,
    this.initialMaxRating = 5,
    this.initialWineType,
  });

  @override
  State<WineFilterWidget> createState() => _WineFilterWidgetState();
}

class _WineFilterWidgetState extends State<WineFilterWidget> {
  /// Começa aberto por padrão
  bool _isExpanded = true;

  // Estado do slider de preço
  late RangeValues _priceRange;

  // Estado do slider de classificação (nota)
  late RangeValues _ratingRange;

  // Lista de tipos de vinho vinda da API
  List<String> _wineTypes = [];

  // Tipo selecionado no dropdown (null = todos)
  String? _selectedType;

  // Indicador de carregamento dos tipos
  bool _isLoadingTypes = true;
  String? _errorLoadingTypes;

  // Cor roxa principal
  static const Color _purple = Color(0xFF52335E);

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(widget.initialMinPrice, widget.initialMaxPrice);
    _ratingRange = RangeValues(widget.initialMinRating, widget.initialMaxRating);
    _selectedType = widget.initialWineType;
    _fetchWineTypes();
  }

  Future<void> _fetchWineTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _errorLoadingTypes = null;
    });

    try {
      final response = await ApiService.instance.getWineTypes();
      final List<dynamic> raw = response.data as List<dynamic>;
      final types = raw.map((e) => e.toString()).toList();

      setState(() {
        _wineTypes = types;
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _errorLoadingTypes = 'Falha ao carregar tipos de vinho';
        _isLoadingTypes = false;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _purple, width: 2),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Cabeçalho clicável que expande/colapsa o filtro ─────────────
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              // Ícone de lupa à esquerda, texto centralizado e seta à direita
              child: Row(
                children: [
                  Icon(Icons.search, color: _purple, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesquisa Filtrada',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: _purple,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // ─── Conteúdo do filtro (visível apenas se _isExpanded) ───────────
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── SEÇÃO DE PREÇO ───────────────────────────────────────────
                  const Text(
                    'Preço (€):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 150,
                    divisions: 30,
                    labels: RangeLabels(
                      '${_priceRange.start.toStringAsFixed(0)}€',
                      '${_priceRange.end.toStringAsFixed(0)}€',
                    ),
                    activeColor: _purple,
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (newRange) {
                      setState(() {
                        _priceRange = RangeValues(
                          newRange.start.clamp(0, newRange.end),
                          newRange.end.clamp(newRange.start, 150),
                        );
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'De ${_priceRange.start.toStringAsFixed(0)}€ até ${_priceRange.end.toStringAsFixed(0)}€',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── SEÇÃO DE CLASSIFICAÇÃO (RATING) ───────────────────────────
                  const Text(
                    'Classificação (estrelas):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _ratingRange,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    labels: RangeLabels(
                      _ratingRange.start.toStringAsFixed(0),
                      _ratingRange.end.toStringAsFixed(0),
                    ),
                    activeColor: _purple,
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (newRange) {
                      setState(() {
                        _ratingRange = RangeValues(
                          newRange.start.clamp(1, newRange.end),
                          newRange.end.clamp(newRange.start, 5),
                        );
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Entre ${_ratingRange.start.toStringAsFixed(0)} e ${_ratingRange.end.toStringAsFixed(0)} estrelas',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── SEÇÃO DE TIPO DE VINHO (DROPDOWN) ─────────────────────────
                  const Text(
                    'Tipo de Vinho:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingTypes)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorLoadingTypes != null)
                    Text(
                      _errorLoadingTypes!,
                      style: const TextStyle(color: Colors.red),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Todos'),
                          value: _selectedType,
                          items: <DropdownMenuItem<String>>[
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ..._wineTypes.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }),
                          ],
                          onChanged: (novo) {
                            setState(() {
                              _selectedType = novo;
                            });
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ─── BOTÃO PESQUISAR ───────────────────────────────────────────
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: _purple, width: 2),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.onSearch(
                          minPrice: _priceRange.start,
                          maxPrice: _priceRange.end,
                          minRating: _ratingRange.start,
                          maxRating: _ratingRange.end,
                          wineType: _selectedType,
                        );
                      },
                      child: const Text(
                        'Pesquisar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _purple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
