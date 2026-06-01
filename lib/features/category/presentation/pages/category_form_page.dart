import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Form page for creating or editing a [Category].
///
/// Pass [existing] to enter edit mode; leave null for create mode.
class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key, this.existing});

  final Category? existing;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  bool get _isEditing => widget.existing != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    _descController =
        TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Category Name',
              hint: 'e.g. Beverages',
              prefixIcon: Icons.label_outline,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descController,
              label: 'Description (optional)',
              hint: 'Short description',
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Create Category',
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

    final provider = context.read<CategoryProvider>();

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
        );
        await provider.updateCategory(updated);
      } else {
        await provider.addCategory(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
