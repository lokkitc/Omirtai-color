import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/features/calculators/models/area_history_entry.dart';
import 'package:app/features/calculators/view/area_calculator/history/history_screen.dart';
import 'package:app/core/services/persistence_service.dart';

// Data model for calculator entries
class AreaCalculatorEntry {
  final String id;
  double? height;
  double? width;
  double? count;
  double? price;
  double? area;
  double? totalPrice;

  AreaCalculatorEntry({
    String? id,
    this.height, 
    this.width, 
    this.count, 
    this.price, 
    this.area, 
    this.totalPrice,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'height': height,
      'width': width,
      'count': count,
      'price': price,
      'area': area,
      'totalPrice': totalPrice,
    };
  }

  // Create from map
  factory AreaCalculatorEntry.fromMap(Map<String, dynamic> map) {
    return AreaCalculatorEntry(
      id: map['id'] as String,
      height: map['height'] as double?,
      width: map['width'] as double?,
      count: map['count'] as double?,
      price: map['price'] as double?,
      area: map['area'] as double?,
      totalPrice: map['totalPrice'] as double?,
    );
  }
}

class AreaCalculatorScreen extends StatefulWidget {
  const AreaCalculatorScreen({super.key});

  @override
  State<AreaCalculatorScreen> createState() => _AreaCalculatorScreenState();
}

class _AreaCalculatorScreenState extends State<AreaCalculatorScreen> {
  final List<AreaCalculatorEntry> _entries = []; // Initialize as empty list
  final List<AreaHistoryEntry> _historyEntries = []; // History entries
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _widthFocusNode = FocusNode();
  final FocusNode _countFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  int? _editingIndex; // Track which entry is being edited
  final Set<int> _selectedEntries = <int>{}; // Track selected entries
  bool _isInputExpanded = true; // Track if input fields are expanded or collapsed

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await PersistenceService().loadHistory();
      setState(() {
        _historyEntries.addAll(history);
      });
    } catch (e) {
      // If there's an error loading history, we'll just start with an empty list
      // Error loading history: $e
    }
  }

  void _addEntry() {
    final heightText = _heightController.text;
    final widthText = _widthController.text;
    final countText = _countController.text;
    final priceText = _priceController.text;

    if (heightText.isEmpty || widthText.isEmpty || countText.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('enter_valid_numbers')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final height = double.tryParse(heightText);
    final width = double.tryParse(widthText);
    final count = double.tryParse(countText);
    final price = double.tryParse(priceText);

    if (height == null || width == null || count == null || price == null ||
        height <= 0 || width <= 0 || count <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('enter_valid_numbers')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Calculate area: (height × width) / 1,000,000 × count
    final area = (height * width) / 1000000 * count;
    final totalPrice = area * price;

    setState(() {
      if (_editingIndex != null) {
        // Update existing entry
        _entries[_editingIndex!] = AreaCalculatorEntry(
          height: height,
          width: width,
          count: count,
          price: price,
          area: area,
          totalPrice: totalPrice,
        );
        _editingIndex = null; // Reset editing index
      } else {
        // Add new entry
        _entries.add(AreaCalculatorEntry(
          height: height,
          width: width,
          count: count,
          price: price,
          area: area,
          totalPrice: totalPrice,
        ));
      }
      
      // Clear input fields
      _heightController.clear();
      _widthController.clear();
      _countController.clear();
      // _priceController.clear();
    });
  }

  void _editEntry(int index) {
    final entry = _entries[index];
    setState(() {
      _editingIndex = index;
      _heightController.text = entry.height?.toString() ?? '';
      _widthController.text = entry.width?.toString() ?? '';
      _countController.text = entry.count?.toString() ?? '';
      _priceController.text = entry.price?.toString() ?? '';
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedEntries.contains(index)) {
        _selectedEntries.remove(index);
      } else {
        _selectedEntries.add(index);
      }
    });
  }

  Future<void> _confirmAndDeleteSelected() async {
    if (_selectedEntries.isEmpty) return;

    final localizations = AppLocalizations.of(context);
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_delete')),
          content: Text(localizations.translate('confirm_delete_selected_entries')
              .replaceAll('{count}', _selectedEntries.length.toString())),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.translate('delete'), style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        // Remove selected entries in reverse order to maintain correct indices
        final sortedIndices = _selectedEntries.toList()..sort((a, b) => b.compareTo(a));
        for (final index in sortedIndices) {
          _entries.removeAt(index);
        }
        
        // Clear selection
        _selectedEntries.clear();
        
        // If we were editing a deleted entry, cancel edit mode
        if (_editingIndex != null && sortedIndices.contains(_editingIndex)) {
          _editingIndex = null;
          _heightController.clear();
          _widthController.clear();
          _countController.clear();
          _priceController.clear();
        }
      });
    }
  }

  void _selectAll() {
    setState(() {
      _selectedEntries.clear();
      for (int i = 0; i < _entries.length; i++) {
        _selectedEntries.add(i);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedEntries.clear();
    });
  }

  void _saveToHistory() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('no_entries_to_save')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Store context in a local variable to avoid using it across async gaps
    final scaffoldContext = context;

    // Calculate summary totals
    double totalArea = 0;
    double totalCount = 0;
    double totalPrice = 0;
    
    for (final entry in _entries) {
      if (entry.area != null) totalArea += entry.area!;
      if (entry.count != null) totalCount += entry.count!;
      if (entry.totalPrice != null) totalPrice += entry.totalPrice!;
    }

    final historyEntry = AreaHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      entries: List.from(_entries),
      totalArea: totalArea,
      totalCount: totalCount,
      totalPrice: totalPrice,
    );

    setState(() {
      _historyEntries.add(historyEntry);
    });

    // Save to persistence
    try {
      await PersistenceService().saveHistory(_historyEntries);
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(scaffoldContext).translate('saved_to_history')),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(scaffoldContext).translate('error_saving_history')}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          historyEntries: _historyEntries,
          onLoadEntries: (entries) {
            setState(() {
              _entries.clear();
              _entries.addAll(entries);
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    _countController.dispose();
    _priceController.dispose();
    _heightFocusNode.dispose();
    _widthFocusNode.dispose();
    _countFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Calculate summary totals
    double totalArea = 0;
    double totalCount = 0;
    double totalPrice = 0;
    
    for (final entry in _entries) {
      if (entry.area != null) totalArea += entry.area!;
      if (entry.count != null) totalCount += entry.count!;
      if (entry.totalPrice != null) totalPrice += entry.totalPrice!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('area_calculator')),
        centerTitle: true,
        actions: [
          if (_selectedEntries.isNotEmpty) ...[
            IconButton(
              onPressed: _confirmAndDeleteSelected,
              icon: const Icon(Icons.delete),
              color: AppColors.error,
              tooltip: localizations.translate('delete_selected'),
            ),
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear),
              tooltip: localizations.translate('clear_selection'),
            ),
          ] else ...[
            if (_entries.isNotEmpty)
              IconButton(
                onPressed: _selectAll,
                icon: const Icon(Icons.select_all),
                tooltip: localizations.translate('select_all'),
              ),
            IconButton(
              onPressed: _showHistory,
              icon: const Icon(Icons.history),
              tooltip: localizations.translate('history'),
            ),
            if (_entries.isNotEmpty)
              IconButton(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.save),
                tooltip: localizations.translate('save_to_history'),
              ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection info
            if (_selectedEntries.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.translate('selected_entries')
                          .replaceAll('{count}', _selectedEntries.length.toString()),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSelection,
                      child: Text(localizations.translate('clear_selection')),
                    ),
                  ],
                ),
              ),
            ],
            
            // Collapsible input fields container
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with toggle button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isInputExpanded = !_isInputExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.gray.withValues(alpha: 0.5))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _editingIndex != null 
                              ? localizations.translate('edit_entry') 
                              : localizations.translate('add_entry'),
                            style: TextStyle(
                              fontSize: AppFonts.titleMedium,
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                          Icon(
                            _isInputExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Collapsible content
                  if (_isInputExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _heightController,
                            focusNode: _heightFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate('height_mm'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.height),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_widthFocusNode);
                            },
                          ),
                          const SizedBox(height: AppSpacing.s),
                          
                          TextField(
                            controller: _widthController,
                            focusNode: _widthFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate('width_mm'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.space_bar),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_countFocusNode);
                            },
                          ),
                          const SizedBox(height: AppSpacing.s),
                          
                          TextField(
                            controller: _countController,
                            focusNode: _countFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate('count'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_priceFocusNode);
                            },
                          ),
                          const SizedBox(height: AppSpacing.s),
                          
                          TextField(
                            controller: _priceController,
                            focusNode: _priceFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate('price_per_m2'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            onEditingComplete: () {
                              // When on the last field, submit the entry and focus back to height
                              _addEntry();
                              FocusScope.of(context).requestFocus(_heightFocusNode);
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.m),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addEntry,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                                backgroundColor: _editingIndex != null ? AppColors.secondary : AppColors.primary,
                                foregroundColor: _editingIndex != null ? AppColors.onSecondary : AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                                ),
                              ),
                              child: Text(
                                _editingIndex != null 
                                  ? localizations.translate('update_entry') 
                                  : localizations.translate('add_entry'),
                                style: TextStyle(
                                  fontSize: AppFonts.bodyMedium,
                                  fontWeight: AppFonts.semiBold,
                                ),
                              ),
                            ),
                          ),
                          
                          // Cancel edit button
                          if (_editingIndex != null) ...[
                            const SizedBox(height: AppSpacing.s),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _editingIndex = null;
                                  _heightController.clear();
                                  _widthController.clear();
                                  _countController.clear();
                                  _priceController.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                                ),
                                side: const BorderSide(color: AppColors.error),
                              ),
                              child: Text(
                                localizations.translate('cancel'),
                                style: TextStyle(
                                  fontSize: AppFonts.titleMedium,
                                  fontWeight: AppFonts.semiBold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Entries table
            Expanded(
              child: Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                child: Column(
                  children: [
                    // Table header
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context);
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.s),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.gray.withValues(alpha: 0.5))),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate('entry')))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate('height_mm')))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate('width_mm')))),
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate('count')))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate('price_per_m2')))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate('area')))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate('total_price')))),
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate('edit')))), // Only edit column now
                            ],
                          ),
                        );
                      }
                    ),
                    
                    // Table body
                    Expanded(
                      child: ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          final isSelected = _selectedEntries.contains(index);
                          return GestureDetector(
                            onTap: () => _toggleSelection(index),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColors.gray.withValues(alpha: 0.2))),
                                color: isSelected 
                                  ? AppColors.primary.withAlpha(51) 
                                  : Theme.of(context).appBarTheme.backgroundColor,
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: Center(child: Text((index + 1).toString()))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.height?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.width?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 1, child: Center(child: Text(entry.count?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.price?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.area?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.totalPrice?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () => _editEntry(index),
                                      icon: Icon(Icons.edit, color: AppColors.primary),
                                      splashRadius: AppSpacing.iconS,
                                      tooltip: localizations.translate('edit_entry'),
                                      padding: const EdgeInsets.all(4.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Summary section
            if (_entries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('summary'),
                      style: TextStyle(
                        fontSize: AppFonts.titleMedium,
                        fontWeight: AppFonts.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.translate('total_area')),
                        Text(localizations.translate('square_meters_with_value').replaceAll('{value}', totalArea.toStringAsFixed(2))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.translate('total_count')),
                        Text(totalCount.toStringAsFixed(0)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.translate('total_price')),
                        Text(localizations.translate('currency_value').replaceAll('{value}', totalPrice.toStringAsFixed(2))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}