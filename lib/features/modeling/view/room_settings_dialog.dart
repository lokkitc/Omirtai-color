import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/services/ral_color_service.dart';
import 'package:app/core/models/ral_color.dart';
import 'package:app/core/models/texture.dart' as texture_model;
import 'room_controller.dart';

class RoomSettingsDialog extends StatelessWidget {
  final RoomParameters roomParams;

  const RoomSettingsDialog({super.key, required this.roomParams});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.translate('roomSettings')),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: ChangeNotifierProvider.value(
          value: roomParams,
          child: Consumer<RoomParameters>(
            builder: (context, roomParams, child) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      1000.0, // 1 meter
                      10000.0, // 10 meters
                      (value) => roomParams.roomWidth = value,
                    ),
                    
                    _buildDimensionSlider(
                      context,
                      localizations.translate('roomDepth'),
                      roomParams.roomDepth,
                      1000.0, // 1 meter
                      10000.0, // 10 meters
                      (value) => roomParams.roomDepth = value,
                    ),
                    
                    _buildDimensionSlider(
                      context,
                      localizations.translate('roomHeight'),
                      roomParams.roomHeight,
                      1000.0, // 1 meter
                      5000.0, // 5 meters
                      (value) => roomParams.roomHeight = value,
                    ),
                    
                    const SizedBox(height: AppSpacing.m),
                    
                    // Цвета поверхностей
                    Text(
                      localizations.translate('surfaceColors'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    
                    _buildColorAndTexturePicker(
                      context,
                      localizations.translate('floorColor'),
                      roomParams.floorColor,
                      roomParams.floorTexture,
                      (color) => roomParams.floorColor = color,
                      (texture) => roomParams.floorTexture = texture,
                    ),
                    
                    _buildColorAndTexturePicker(
                      context,
                      localizations.translate('ceilingColor'),
                      roomParams.ceilingColor,
                      roomParams.ceilingTexture,
                      (color) => roomParams.ceilingColor = color,
                      (texture) => roomParams.ceilingTexture = texture,
                    ),
                    
                    _buildColorAndTexturePicker(
                      context,
                      localizations.translate('wallColor'),
                      roomParams.frontWallColor,
                      roomParams.frontWallTexture,
                      (color) {
                        roomParams.frontWallColor = color;
                        roomParams.backWallColor = color;
                        roomParams.leftWallColor = color;
                        roomParams.rightWallColor = color;
                      },
                      (texture) {
                        roomParams.frontWallTexture = texture;
                        roomParams.backWallTexture = texture;
                        roomParams.leftWallTexture = texture;
                        roomParams.rightWallTexture = texture;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.m),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.translate('close')),
        ),
        ElevatedButton(
          onPressed: () {
            roomParams.resetToDefault();
          },
          child: Text(localizations.translate('resetToDefault')),
        ),
      ],
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
                divisions: (max - min).toInt() ~/ 100, // divisions every 100mm
                label: '${(value / 1000.0).toStringAsFixed(2)}m',
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                '${(value / 1000.0).toStringAsFixed(2)}m',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorAndTexturePicker(
    BuildContext context,
    String label,
    Color color,
    texture_model.Texture? texture,
    Function(Color) onColorChanged,
    Function(texture_model.Texture?) onTextureChanged,
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
              image: texture != null 
                ? DecorationImage(
                    image: AssetImage(texture.assetPath),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              _showColorPickerDialog(context, color, onColorChanged);
            },
          ),
          IconButton(
            icon: const Icon(Icons.texture),
            onPressed: () {
              _showTexturePickerDialog(context, texture, onTextureChanged);
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

  void _showTexturePickerDialog(
    BuildContext context,
    texture_model.Texture? currentTexture,
    Function(texture_model.Texture?) onTextureChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('selectTexture')),
          content: SizedBox(
            width: 300,
            height: 300,
            child: TexturePicker(
              initialTexture: currentTexture,
              onTextureChanged: onTextureChanged,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Предопределенные цвета для выбора
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            children: _getPredefinedColors().map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  widget.onColorChanged(color);
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
          ),
        ),
        const SizedBox(height: 16),
        // RAL цвета
        SizedBox(
          height: 200,
          child: FutureBuilder<List<RalColor>>(
            future: RalColorService().getAllRalColors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Error loading RAL colors'));
              }
              
              final ralColors = snapshot.data!;
              
              return GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                children: ralColors.take(20).map((ralColor) {
                  final color = Color(ralColor.colorValue);
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
                      child: Center(
                        child: Text(
                          ralColor.code,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
  
  List<Color> _getPredefinedColors() {
    return [
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
      Colors.black,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.teal,
    ];
  }
}

class TexturePicker extends StatefulWidget {
  final texture_model.Texture? initialTexture;
  final Function(texture_model.Texture?) onTextureChanged;

  const TexturePicker({
    super.key,
    required this.initialTexture,
    required this.onTextureChanged,
  });

  @override
  State<TexturePicker> createState() => _TexturePickerState();
}

class _TexturePickerState extends State<TexturePicker> {
  texture_model.Texture? _selectedTexture;

  @override
  void initState() {
    super.initState();
    _selectedTexture = widget.initialTexture;
  }

  @override
  Widget build(BuildContext context) {
    final textures = texture_model.Texture.getAvailableTextures();
    
    return Column(
      children: [
        // None option
        ListTile(
          title: const Text('None'),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.clear, size: 20),
          ),
          selected: _selectedTexture == null,
          onTap: () {
            setState(() {
              _selectedTexture = null;
            });
            widget.onTextureChanged(null);
            Navigator.of(context).pop();
          },
        ),
        // Available textures
        Expanded(
          child: ListView.builder(
            itemCount: textures.length,
            itemBuilder: (context, index) {
              final texture = textures[index];
              return ListTile(
                title: Text(texture.displayName),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: AssetImage(texture.assetPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                selected: _selectedTexture?.name == texture.name,
                onTap: () {
                  setState(() {
                    _selectedTexture = texture;
                  });
                  widget.onTextureChanged(texture);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}