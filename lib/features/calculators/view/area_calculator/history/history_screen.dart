import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/features/calculators/models/area_history_entry.dart';
import 'package:app/features/calculators/view/area_calculator/area_calculator_screen.dart';
import 'package:app/core/services/persistence_service.dart';

class HistoryScreen extends StatefulWidget {
  final List<AreaHistoryEntry> historyEntries;
  final Function(List<AreaCalculatorEntry>) onLoadEntries;

  const HistoryScreen({
    super.key,
    required this.historyEntries,
    required this.onLoadEntries,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<AreaHistoryEntry> _historyEntries;

  @override
  void initState() {
    super.initState();
    _historyEntries = List.from(widget.historyEntries);
  }

  void _loadEntries(int index) {
    final entries = _historyEntries[index].entries;
    widget.onLoadEntries(entries);
    Navigator.pop(context);
  }

  Future<void> _deleteEntry(int index) async {
    final localizations = AppLocalizations.of(context);
    final scaffoldContext = context;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_delete')),
          content: Text(localizations.translate('confirm_delete_history_entry')),
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
        _historyEntries.removeAt(index);
      });
      
      // Save updated history
      try {
        await PersistenceService().saveHistory(_historyEntries);
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('history_entry_deleted')),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text('${localizations.translate('error_deleting_history')}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final localizations = AppLocalizations.of(context);
    final scaffoldContext = context;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_clear_history')),
          content: Text(localizations.translate('confirm_clear_all_history')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.translate('clear'), style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _historyEntries.clear();
      });
      
      // Save updated history
      try {
        await PersistenceService().saveHistory(_historyEntries);
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('history_cleared')),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text('${localizations.translate('error_clearing_history')}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('history')),
        centerTitle: true,
        actions: [
          if (_historyEntries.isNotEmpty)
            IconButton(
              onPressed: _clearAllHistory,
              icon: const Icon(Icons.delete_sweep),
              tooltip: localizations.translate('clear_history'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: _historyEntries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: AppSpacing.iconXl,
                      color: AppColors.gray,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      localizations.translate('no_history_entries'),
                      style: TextStyle(
                        fontSize: AppFonts.bodyLarge,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _historyEntries.length,
                itemBuilder: (context, index) {
                  final entry = _historyEntries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s),
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppSpacing.m),
                      title: Text(
                        '${localizations.translate('history_entry')} #${_historyEntries.length - index}',
                        style: TextStyle(
                          fontSize: AppFonts.titleMedium,
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatDateTime(entry.timestamp),
                            style: TextStyle(
                              fontSize: AppFonts.bodySmall,
                              color: AppColors.gray,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${localizations.translate('total_area')}: ${entry.totalArea.toStringAsFixed(2)} m²',
                                style: TextStyle(
                                  fontSize: AppFonts.bodySmall,
                                ),
                              ),
                              Text(
                                '${localizations.translate('total_price')}: ${entry.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: AppFonts.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${localizations.translate('entry_count')}: ${entry.entries.length}',
                            style: TextStyle(
                              fontSize: AppFonts.bodySmall,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _deleteEntry(index),
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            splashRadius: AppSpacing.iconS,
                            tooltip: localizations.translate('delete'),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: AppSpacing.iconS,
                            color: AppColors.gray,
                          ),
                        ],
                      ),
                      onTap: () => _loadEntries(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}