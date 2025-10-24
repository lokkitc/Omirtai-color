import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart';
import 'package:app/features/calculators/models/volume_calculator_entry.dart';
import 'package:app/features/calculators/models/volume_history_entry.dart';
import 'package:app/features/calculators/view/volume_calculator/history/volume_history_screen.dart';
import 'package:app/core/services/persistence_service.dart';

class VolumeCalculatorScreen extends StatefulWidget {
  const VolumeCalculatorScreen({super.key});

  @override
  State<VolumeCalculatorScreen> createState() => _VolumeCalculatorScreenState();
}

class _VolumeCalculatorScreenState extends State<VolumeCalculatorScreen> {
  final List<VolumeCalculatorEntry> _entries = []; // Initialize as empty list
  final List<VolumeHistoryEntry> _historyEntries = []; // History entries
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController(); // Changed from height to depth
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _lengthFocusNode = FocusNode();
  final FocusNode _widthFocusNode = FocusNode();
  final FocusNode _depthFocusNode = FocusNode(); // Changed from height to depth
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
      final history = await PersistenceService().loadVolumeHistory();
      setState(() {
        _historyEntries.addAll(history);
      });
    } catch (e) {
      // If there's an error loading history, we'll just start with an empty list
      // Error loading history: $e
    }
  }

  void _addEntry() {
    final lengthText = _lengthController.text;
    final widthText = _widthController.text;
    final depthText = _depthController.text; // Changed from height to depth
    final countText = _countController.text;
    final priceText = _priceController.text;

    if (lengthText.isEmpty || widthText.isEmpty || depthText.isEmpty || countText.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate(LocalizationKeys.enterValidNumbers)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final length = double.tryParse(lengthText);
    final width = double.tryParse(widthText);
    final depth = double.tryParse(depthText); // Changed from height to depth
    final count = double.tryParse(countText);
    final price = double.tryParse(priceText);

    if (length == null || width == null || depth == null || count == null || price == null ||
        length <= 0 || width <= 0 || depth <= 0 || count <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate(LocalizationKeys.enterValidNumbers)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Calculate volume: (length × width × depth) / 1,000,000,000 × count
    final volume = (length * width * depth) / 1000000000 * count;
    final totalPrice = volume * price;

    setState(() {
      if (_editingIndex != null) {
        // Update existing entry
        _entries[_editingIndex!] = VolumeCalculatorEntry(
          length: length,
          width: width,
          height: depth, // Using height as depth in the model
          count: count,
          price: price,
          volume: volume,
          totalPrice: totalPrice,
        );
        _editingIndex = null; // Reset editing index
      } else {
        // Add new entry
        _entries.add(VolumeCalculatorEntry(
          length: length,
          width: width,
          height: depth, // Using height as depth in the model
          count: count,
          price: price,
          volume: volume,
          totalPrice: totalPrice,
        ));
      }
      
      // Clear input fields
      _lengthController.clear();
      _widthController.clear();
      _depthController.clear(); // Changed from height to depth
      // _priceController.clear();
    });
  }

  void _editEntry(int index) {
    final entry = _entries[index];
    setState(() {
      _editingIndex = index;
      _lengthController.text = entry.length?.toString() ?? '';
      _widthController.text = entry.width?.toString() ?? '';
      _depthController.text = entry.height?.toString() ?? ''; // Using height as depth
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
          title: Text(localizations.translate(LocalizationKeys.confirmDelete)),
          content: Text(localizations.translate(LocalizationKeys.confirmDeleteSelectedEntries)
              .replaceAll('{count}', _selectedEntries.length.toString())),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.translate(LocalizationKeys.cancel)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.translate(LocalizationKeys.delete), style: const TextStyle(color: AppColors.error)),
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
          _lengthController.clear();
          _widthController.clear();
          _depthController.clear(); // Changed from height to depth
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
          content: Text(AppLocalizations.of(context).translate(LocalizationKeys.noEntriesToSave)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Store context in a local variable to avoid using it across async gaps
    final scaffoldContext = context;

    // Calculate summary totals
    double totalVolume = 0;
    double totalCount = 0;
    double totalPrice = 0;
    
    for (final entry in _entries) {
      if (entry.volume != null) totalVolume += entry.volume!;
      if (entry.count != null) totalCount += entry.count!;
      if (entry.totalPrice != null) totalPrice += entry.totalPrice!;
    }

    final historyEntry = VolumeHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      entries: List.from(_entries),
      totalVolume: totalVolume,
      totalCount: totalCount,
      totalPrice: totalPrice,
    );

    setState(() {
      _historyEntries.add(historyEntry);
    });

    // Save to persistence
    try {
      await PersistenceService().saveVolumeHistory(_historyEntries);
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(scaffoldContext).translate(LocalizationKeys.savedToHistory)),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(scaffoldContext).translate(LocalizationKeys.errorSavingHistory)}: $e'),
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
        builder: (context) => VolumeHistoryScreen(
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
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose(); // Changed from height to depth
    _countController.dispose();
    _priceController.dispose();
    _lengthFocusNode.dispose();
    _widthFocusNode.dispose();
    _depthFocusNode.dispose(); // Changed from height to depth
    _countFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Calculate summary totals
    double totalVolume = 0;
    double totalCount = 0;
    double totalPrice = 0;
    
    for (final entry in _entries) {
      if (entry.volume != null) totalVolume += entry.volume!;
      if (entry.count != null) totalCount += entry.count!;
      if (entry.totalPrice != null) totalPrice += entry.totalPrice!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate(LocalizationKeys.volumeCalculator)),
        centerTitle: true,
        actions: [
          if (_selectedEntries.isNotEmpty) ...[
            IconButton(
              onPressed: _confirmAndDeleteSelected,
              icon: const Icon(Icons.delete),
              color: AppColors.error,
              tooltip: localizations.translate(LocalizationKeys.deleteSelected),
            ),
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear),
              tooltip: localizations.translate(LocalizationKeys.clearSelection),
            ),
          ] else ...[
            if (_entries.isNotEmpty)
              IconButton(
                onPressed: _selectAll,
                icon: const Icon(Icons.select_all),
                tooltip: localizations.translate(LocalizationKeys.selectAll),
              ),
            IconButton(
              onPressed: _showHistory,
              icon: const Icon(Icons.history),
              tooltip: localizations.translate(LocalizationKeys.history),
            ),
            if (_entries.isNotEmpty)
              IconButton(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.save),
                tooltip: localizations.translate(LocalizationKeys.saveToHistory),
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
                      localizations.translate(LocalizationKeys.selectedEntries)
                          .replaceAll('{count}', _selectedEntries.length.toString()),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSelection,
                      child: Text(localizations.translate(LocalizationKeys.clearSelection)),
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
                              ? localizations.translate(LocalizationKeys.editEntry) 
                              : localizations.translate(LocalizationKeys.addEntry),
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
                            controller: _lengthController,
                            focusNode: _lengthFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate(LocalizationKeys.lengthMm),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.straighten),
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
                              labelText: localizations.translate(LocalizationKeys.widthMm),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.space_bar),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(_depthFocusNode); // Changed from height to depth
                            },
                          ),
                          const SizedBox(height: AppSpacing.s),
                          
                          TextField(
                            controller: _depthController, // Changed from height to depth
                            focusNode: _depthFocusNode, // Changed from height to depth
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.translate(LocalizationKeys.depthMm), // Changed from height to depth
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.height),
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
                              labelText: localizations.translate(LocalizationKeys.count),
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
                              labelText: localizations.translate(LocalizationKeys.pricePerM3), // Changed from m2 to m3
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            onEditingComplete: () {
                              // When on the last field, submit the entry and focus back to length
                              _addEntry();
                              FocusScope.of(context).requestFocus(_lengthFocusNode);
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
                                  ? localizations.translate(LocalizationKeys.updateEntry) 
                                  : localizations.translate(LocalizationKeys.addEntry),
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
                                  _lengthController.clear();
                                  _widthController.clear();
                                  _depthController.clear(); // Changed from height to depth
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
                                localizations.translate(LocalizationKeys.cancel),
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
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate(LocalizationKeys.entry)))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.lengthMm)))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.widthMm)))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.depthMm)))), // Changed from height to depth
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate(LocalizationKeys.count)))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.pricePerM3)))), // Changed from m2 to m3
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.volume)))),
                              Expanded(flex: 2, child: Center(child: Text(localizations.translate(LocalizationKeys.totalPrice)))),
                              Expanded(flex: 1, child: Center(child: Text(localizations.translate(LocalizationKeys.edit)))), // Only edit column now
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
                                  Expanded(flex: 2, child: Center(child: Text(entry.length?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.width?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.height?.toStringAsFixed(0) ?? '-'))), // Using height as depth
                                  Expanded(flex: 1, child: Center(child: Text(entry.count?.toStringAsFixed(0) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.price?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.volume?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(flex: 2, child: Center(child: Text(entry.totalPrice?.toStringAsFixed(2) ?? '-'))),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () => _editEntry(index),
                                      icon: Icon(Icons.edit, color: AppColors.primary),
                                      splashRadius: AppSpacing.iconS,
                                      tooltip: localizations.translate(LocalizationKeys.editEntry),
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
                      localizations.translate(LocalizationKeys.summary),
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
                        Text(localizations.translate(LocalizationKeys.totalVolume)),
                        Text(localizations.translate(LocalizationKeys.cubicMetersWithValue).replaceAll('{value}', totalVolume.toStringAsFixed(2))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.translate(LocalizationKeys.totalCount)),
                        Text(totalCount.toStringAsFixed(0)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.translate(LocalizationKeys.totalPrice)),
                        Text(localizations.translate(LocalizationKeys.currencyValue).replaceAll('{value}', totalPrice.toStringAsFixed(2))),
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