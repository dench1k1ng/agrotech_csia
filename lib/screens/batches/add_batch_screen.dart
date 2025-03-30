import 'package:agrotech_hacakaton/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBatchScreen extends StatefulWidget {
  @override
  _AddBatchScreenState createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _specialConditionsController =
      TextEditingController(); // Особые условия

  DateTime? _selectedDate; // Дата посева
  DateTime? _harvestDate; // Дата созревания
  TimeOfDay _wateringTime = TimeOfDay(hour: 8, minute: 0); // Время полива
  double _initialHeight = 0.0; // Начальная высота для batch
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  // Выбор даты посева
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Выбор времени полива
  Future<void> _selectWateringTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wateringTime,
    );
    if (picked != null && picked != _wateringTime) {
      setState(() => _wateringTime = picked);
    }
  }

  // Выбор даты созревания с валидацией
  Future<void> _selectHarvestDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: _selectedDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _harvestDate) {
      setState(() => _harvestDate = picked);
    }
  }

  // Загрузка сохранённого изображения
  Future<void> _loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('lastImagePath');
      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        setState(() => _image = File(savedImagePath));
      }
    } catch (e) {
      debugPrint('Error loading saved image: $e');
    }
  }

  // Выбор изображения из галереи или камеры
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastImagePath', pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выборе изображения: ${e.toString()}'),
        ),
      );
    }
  }

  // Сохранение данных
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> _saveBatch() async {
    // Проверка формы
    if (!_formKey.currentState!.validate()) return;

    // Проверка на пустую дату посева
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите дату посева')),
      );
      return; // Остановим выполнение, если дата не выбрана
    }

    // Проверка других обязательных полей
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return; // Остановим выполнение, если поля пустые
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Здесь добавьте логику для сохранения данных в базу данных или API
      await Future.delayed(Duration(seconds: 1)); // Имитация загрузки

      // Переход на предыдущий экран с данными
      Navigator.pop(context, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text,
        'date': DateFormat('dd MMM yyyy').format(_selectedDate!),
        'harvestDate':
            _harvestDate != null
                ? DateFormat('dd MMM yyyy').format(_harvestDate!)
                : 'Не указано', // Обработка пустой даты
        'status': 'Прорастает',
        'location': _locationController.text,
        'wateringTime': _wateringTime.format(context),
        'initialHeight': _initialHeight,
        'specialConditions':
            _specialConditionsController.text, // Особые условия
        'imagePath': _image?.path,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить партию'),
        backgroundColor: Colors.green[700],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Название
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Название',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Введите название'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Субстрат
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Субстрат',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Введите местоположение'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Начальная высота
                      TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: 'Начальная высота (см)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите начальную высоту';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Введите корректную высоту больше 0';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _initialHeight = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Дата посева
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Дата посева',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Выберите дату'
                                    : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_selectedDate!),
                              ),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Время полива
                      InkWell(
                        onTap: () => _selectWateringTime(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Время полива',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_wateringTime.format(context)),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Дата созревания
                      InkWell(
                        onTap: () => _selectHarvestDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Дата созревания',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _harvestDate == null
                                    ? 'Выберите дату'
                                    : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_harvestDate!),
                              ),
                              Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Особые условия
                      TextFormField(
                        controller: _specialConditionsController,
                        decoration: InputDecoration(
                          labelText: 'Особые условия',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Кнопка для выбора изображения
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.photo_library),
                              label: Text('Галерея'),
                              onPressed: () => _pickImage(ImageSource.gallery),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt),
                              label: Text('Камера'),
                              onPressed: () => _pickImage(ImageSource.camera),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Кнопка для сохранения
                      ElevatedButton(
                        onPressed: _saveBatch,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'СОХРАНИТЬ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _heightController.dispose();
    _specialConditionsController.dispose();
    super.dispose();
  }
}

@override
Widget build(BuildContext context) {
  throw UnimplementedError();
}
