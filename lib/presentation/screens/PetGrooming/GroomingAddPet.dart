import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';

class PetDetails {
  final String name;
  final String type;
  final String breed;
  final String dob;
  final String gender;
  final File? image;

  PetDetails({
    required this.name,
    required this.type,
    required this.breed,
    required this.dob,
    required this.gender,
    this.image,
  });
}

class AddPetBottomSheet extends StatefulWidget {
  const AddPetBottomSheet({super.key});

  @override
  State<AddPetBottomSheet> createState() => _AddPetBottomSheetState();
}

class _AddPetBottomSheetState extends State<AddPetBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _dobController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedType;
  String? _selectedBreed;
  String? _selectedGender;
  File? _selectedImage;

  final List<String> _petTypes = [
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Other',
  ];

  final List<String> _dogBreeds = [
    'Labrador Retriever',
    'Golden Retriever',
    'German Shepherd',
    'Beagle',
    'Pug',
    'Indian Pariah',
    'Other',
  ];

  final List<String> _catBreeds = [
    'Persian',
    'Siamese',
    'Maine Coon',
    'Indian Domestic',
    'Other',
  ];

  List<String> get _availableBreeds {
    if (_selectedType == 'Dog') return _dogBreeds;
    if (_selectedType == 'Cat') return _catBreeds;

    if (_selectedType == null) return [];

    return ['Other'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select pet date of birth',
    );

    if (date != null) {
      setState(() {
        _dobController.text =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      });
    }
  }

  void _savePet() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null ||
        _selectedBreed == null ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all pet details'),
        ),
      );
      return;
    }

    final pet = PetDetails(
      name: _nameController.text.trim(),
      type: _selectedType!,
      breed: _selectedBreed!,
      dob: _dobController.text,
      gender: _selectedGender!,
      image: _selectedImage,
    );

    Navigator.pop(context, pet);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colours.brownColour,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colours.brownColour,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colours.primarycolour,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration(hint),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          validator: (value) =>
              value == null ? 'Please select $label' : null,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
  height: MediaQuery.of(context).size.height * 0.80,
  child: SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 1,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Add Pet Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colours.brownColour,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _fieldLabel('Pet Name'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Enter pet name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                _dropdown(
                  label: 'Pet Type',
                  hint: 'Select pet type',
                  value: _selectedType,
                  items: _petTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _selectedBreed = null;
                    });
                  },
                ),
                const SizedBox(height: 18),

                _dropdown(
                  label: 'Pet Breed',
                  hint: 'Select pet breed',
                  value: _selectedBreed,
                  items: _availableBreeds,
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                ),
                const SizedBox(height: 18),

                _fieldLabel('Pet DOB'),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _inputDecoration('Select date of birth')
                      .copyWith(
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                _dropdown(
                  label: 'Pet Gender',
                  hint: 'Select pet gender',
                  value: _selectedGender,
                  items: const ['Male', 'Female'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 18),

                _fieldLabel('Pet Image'),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colours.brownColour,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (_selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 35,
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImage == null
                                ? 'Add pet image'
                                : 'Change pet image',
                          ),
                        ),
                        Icon(
                          Icons.add,
                          color: Colours.primarycolour,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _savePet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colours.primarycolour,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Pet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),),
      ),
    );
  }
}
