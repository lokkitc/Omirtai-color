import 'package:flutter/material.dart';
import 'package:app/features/colors/models/color_model.dart';
import 'package:app/features/colors/services/ral_color_service.dart';
import 'package:app/features/colors/view/collection/color_detail_page.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/localization_keys.dart';

class ColorCollectionPage extends StatefulWidget {
  final String collectionName;

  const ColorCollectionPage({super.key, required this.collectionName});

  @override
  State<ColorCollectionPage> createState() => _ColorCollectionPageState();
}

class _ColorCollectionPageState extends State<ColorCollectionPage> {
  List<UnifiedRALColor> _colors = [];
  List<UnifiedRALColor> _filteredColors = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadColors() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final colors = await RALColorService.loadColorsForCollection(widget.collectionName);
      setState(() {
        _colors = colors;
        _filteredColors = colors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load colors: $e';
        _isLoading = false;
      });
    }
  }

  void _filterColors(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredColors = _colors;
      });
      return;
    }

    final filtered = _colors.where((color) {
      final lowercaseQuery = query.toLowerCase();
      return color.name.toLowerCase().contains(lowercaseQuery) ||
          color.code.toLowerCase().contains(lowercaseQuery) ||
          color.hex.toLowerCase().contains(lowercaseQuery);
    }).toList();

    setState(() {
      _filteredColors = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.collectionName} ${localizations.translate(LocalizationKeys.colors)}'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: AppSpacing.m),
                      ElevatedButton(
                        onPressed: _loadColors,
                        child: Text(localizations.translate(LocalizationKeys.retry)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterColors,
                        decoration: InputDecoration(
                          hintText: localizations.translate(LocalizationKeys.searchHint),
                          prefixIcon: const Icon(Icons.search),
                          hintStyle: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.s,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).appBarTheme.backgroundColor,
   
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildColorGrid(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s,
        mainAxisSpacing: AppSpacing.s,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredColors.length,
      itemBuilder: (context, index) {
        final color = _filteredColors[index];
        return _buildColorCard(color);
      },
    );
  }

  Widget _buildColorCard(UnifiedRALColor color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColorDetailPage(color: color),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color swatch
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.hex.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      color.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Color name
              Text(
                color.name,
                style: const TextStyle(
                  fontSize: AppFonts.bodyMedium,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Color hex value
              Text(
                color.hex,
                style: const TextStyle(
                  fontSize: AppFonts.bodySmall,
                  color: AppColors.gray,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}