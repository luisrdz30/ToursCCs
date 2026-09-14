import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminAddTourScreen extends StatelessWidget {
  const AdminAddTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add New Tour',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Tour Title'),
            _buildTextField(hintText: 'e.g. Historic Downtown Walking Tour', controller: _titleController),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Category'),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select a category', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                  items: const [],
                  onChanged: (val) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Duration (Hours)'),
            _buildTextField(hintText: 'e.g. 2.5', suffixIcon: Icons.access_time),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Price per person (\$)'),
            _buildTextField(hintText: '\$ 0.00'),
            const SizedBox(height: 24),
            
            const Divider(color: AppTheme.outlineVariant),
            const SizedBox(height: 24),
            
            _buildFieldLabel('Description'),
            _buildTextField(hintText: 'Describe the experience in detail...', maxLines: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('0 / 1000 characters', style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Itinerary / Stops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 16),
                  label: const Text('Add Stop', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildItineraryStop(1, 'Meeting Point', 'Brief description of activity here...', '09:00'),
            const SizedBox(height: 12),
            _buildItineraryStop(2, 'Stop Title (e.g. Central Plaza)', 'Brief description of activity here...', '--:--'),
            const SizedBox(height: 24),
            
            _buildFieldLabel('Cover Image'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.tertiary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Upload Cover Image', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  const SizedBox(height: 4),
                  const Text('PNG, JPG up to 5MB\nRecommended size: 1200x800px', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                    final data = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'category': selectedCategory,
                      'durationMinutes': selectedDuration != null ? (double.parse(selectedDuration!) * 60).toInt() : 120,
                      'price': double.tryParse(_priceController.text) ?? 0.0,
                      'maxCapacity': int.tryParse(_maxCapacityController.text) ?? 10,
                      'isActive': true,
                      'pointsToEarn': 150,
                      'createdAt': FieldValue.serverTimestamp(),
                      'stops': stops,
                    };
                    await FirebaseFirestore.instance.collection('tours').add(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tour guardado exitosamente')));
                      context.pop();
                    }
                  },
                icon: const Icon(Icons.save_outlined, color: AppTheme.onPrimary),
                label: const Text('Save Tour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Text('Save as Draft', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Changes are automatically saved locally.', style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1, IconData? suffixIcon}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppTheme.surfaceContainerLowest,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppTheme.onSurfaceVariant, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildItineraryStop(int index, String titleHint, String descHint, String timeHint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.tertiary,
              shape: BoxShape.circle,
            ),
            child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: titleHint,
                    hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: descHint,
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeHint, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                    const Icon(Icons.check_circle_outline, color: AppTheme.onSurfaceVariant, size: 16),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
