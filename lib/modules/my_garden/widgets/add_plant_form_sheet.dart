import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/database/garden_db.dart';
import '../provider/garden_provider.dart';
import '../db/model/garden_plant.dart';
import '../../scan/provider/scan_provider.dart';

class AddPlantFormSheet extends StatefulWidget {
  final String plantName;
  final String imageUrl;
  final String? description;
  final String? scanId;

  const AddPlantFormSheet({
    super.key,
    required this.plantName,
    required this.imageUrl,
    this.description,
    this.scanId,
  });

  @override
  State<AddPlantFormSheet> createState() => _AddPlantFormSheetState();
}

class _AddPlantFormSheetState extends State<AddPlantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedType = 'Indoor';
  int _health = 80;
  bool _isLoading = false;

  final List<String> _plantTypes = ['Indoor', 'Outdoor'];
  final List<String> _careLevels = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.plantName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Add Plant to Garden',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// Plant preview
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImagePreview(widget.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plantName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.description != null)
                          Text(
                            widget.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plant name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Plant Name',
                  hintText: 'Enter a custom name for your plant',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Plant type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Plant Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                items: _plantTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Care level dropdown
              const SizedBox(height: 16),

              // Health slider
              Text(
                'Plant Health: $_health%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: _health.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _health = value.round();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addPlantToGarden,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Add to Garden', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ Build image preview supporting both network & file images
  Widget _buildImagePreview(String imageUrlOrPath) {
    final isNetworkImage =
        imageUrlOrPath.startsWith('http') || imageUrlOrPath.startsWith('https');

    if (isNetworkImage) {
      return Image.network(
        imageUrlOrPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (File(imageUrlOrPath).existsSync()) {
      return Image.file(
        File(imageUrlOrPath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  /// 🌸 Placeholder when image fails
  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_florist, color: Colors.green),
    );
  }

  Future<void> _addPlantToGarden() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nameToCheck = _nameController.text.trim();
      final gardenProvider = Provider.of<GardenProvider>(
        context,
        listen: false,
      );

      // ✅ Double-check at DB level too
      final alreadyExists = GardenDB.plantExists(nameToCheck);

      if (alreadyExists) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Plant "$nameToCheck" is already in your garden!'),
                ],
              ),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // ✅ If not duplicate, create the plant
      final plant = GardenPlant(
        id: gardenProvider.generateId(),
        name: nameToCheck,
        type: _selectedType,
        imagePath: widget.imageUrl,
        addedDate: DateTime.now(),
        health: _health,
        reminders: [],
        scanId: widget.scanId,
      );

      // Add via provider (which internally uses Hive)
      await gardenProvider.addPlant(plant);

      // 📤 [Community Upload] Push to community if enabled
      try {
        final scanProvider = Provider.of<ScanProvider>(context, listen: false);
        final isNetwork = widget.imageUrl.startsWith('http');
        
        await scanProvider.pushToCommunity(
          context,
          plant.name,
          "plant",
          isNetwork ? null : File(widget.imageUrl),
          description: widget.description ?? "Added a new plant to my garden: ${plant.name}",
          existingImageUrl: isNetwork ? widget.imageUrl : null,
        );
      } catch (ce) {
        debugPrint("⚠️ Community post failed in AddPlantFormSheet: $ce");
      }

// ✅ Instead of showing snackbar here, return success to parent
      if (mounted) {
        Navigator.pop(context, {
          'name': plant.name,
          'status': 'added',
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add plant: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
