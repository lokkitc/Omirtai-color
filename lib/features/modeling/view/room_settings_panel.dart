import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'room_controller.dart';

class RoomSettingsPanel extends StatelessWidget {
  const RoomSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final roomParams = Provider.of<RoomParameters>(context);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('roomSettings'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.m),
              
              // Размеры комнаты
              Text(
                localizations.translate('roomDimensions'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              
              _buildDimensionSlider(
                context,
                localizations.translate('roomWidth'),
                roomParams.roomWidth,
                2.0,
                10.0,
                (value) => roomParams.roomWidth = value,
              ),
              
              _buildDimensionSlider(
                context,
                localizations.translate('roomDepth'),
                roomParams.roomDepth,
                2.0,
                10.0,
                (value) => roomParams.roomDepth = value,
              ),
              
              _buildDimensionSlider(
                context,
                localizations.translate('roomHeight'),
                roomParams.roomHeight,
                2.0,
                5.0,
                (value) => roomParams.roomHeight = value,
              ),
              
              const SizedBox(height: AppSpacing.m),
              
              // Цвета поверхностей
              Text(
                localizations.translate('surfaceColors'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              
              _buildColorPicker(
                context,
                localizations.translate('floorColor'),
                roomParams.floorColor,
                (color) => roomParams.floorColor = color,
              ),
              
              _buildColorPicker(
                context,
                localizations.translate('ceilingColor'),
                roomParams.ceilingColor,
                (color) => roomParams.ceilingColor = color,
              ),
              
              _buildColorPicker(
                context,
                localizations.translate('wallColor'),
                roomParams.frontWallColor,
                (color) {
                  roomParams.frontWallColor = color;
                  roomParams.backWallColor = color;
                  roomParams.leftWallColor = color;
                  roomParams.rightWallColor = color;
                },
              ),
              
              const SizedBox(height: AppSpacing.m),
              
              // Кнопка сброса
              Center(
                child: ElevatedButton(
                  onPressed: roomParams.resetToDefault,
                  child: Text(localizations.translate('resetToDefault')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionSlider(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt() * 10,
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${value.toStringAsFixed(1)}m',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              _showColorPickerDialog(context, color, onColorChanged);
            },
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('selectColor')),
          content: SingleChildScrollView(
            child: ColorPicker(
              initialColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(AppLocalizations.of(context).translate('close')),
            ),
          ],
        );
      },
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    // Предопределенные цвета для выбора
    final List<Color> colors = [
      Colors.brown,
      Colors.grey,
      Colors.white,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            widget.onColorChanged(color);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: _selectedColor == color ? Colors.black : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }
}