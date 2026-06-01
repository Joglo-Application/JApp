import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Form page for creating or editing a [Product].
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  late final TextEditingController _stockController;

  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _descController = TextEditingController(text: p?.description ?? '');
    _stockController =
        TextEditingController(text: p?.stock?.toString() ?? '');
    _selectedCategoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'New Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Name ──────────────────────────────────────────────────────
            AppTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g. Iced Latte',
              prefixIcon: Icons.inventory_2_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Price ─────────────────────────────────────────────────────
            AppTextField(
              controller: _priceController,
              label: 'Price (Rp)',
              hint: '15000',
              prefixIcon: Icons.attach_money_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Category ──────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              hint: const Text('Select category'),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) =>
                  v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────────
            AppTextField(
              controller: _descController,
              label: 'Description (optional)',
              hint: 'Short description',
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // ── Stock ─────────────────────────────────────────────────────
            AppTextField(
              controller: _stockController,
              label: 'Stock (optional)',
              hint: 'Leave blank for unlimited',
              prefixIcon: Icons.layers_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (int.tryParse(v.trim()) == null) {
                  return 'Enter a whole number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // ── Availability ──────────────────────────────────────────────
            SwitchListTile.adaptive(
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
              title: const Text('Available for sale'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            AppButton(
              label: _isEditing ? 'Save Changes' : 'Create Product',
              icon: _isEditing ? Icons.save_outlined : Icons.add,
              isLoading: _isSaving,
              onPressed: _submit,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ProductProvider>();

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          categoryId: _selectedCategoryId!,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          stock: _stockController.text.trim().isEmpty
              ? null
              : int.parse(_stockController.text.trim()),
          isAvailable: _isAvailable,
        );
        await provider.updateProduct(updated);
      } else {
        await provider.addProduct(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          categoryId: _selectedCategoryId!,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          stock: _stockController.text.trim().isEmpty
              ? null
              : int.parse(_stockController.text.trim()),
          isAvailable: _isAvailable,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
