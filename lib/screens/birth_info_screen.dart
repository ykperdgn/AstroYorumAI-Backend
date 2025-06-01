import 'package:flutter/material.dart';
import '../models/user_birth_info.dart';
import '../models/user_profile.dart';
import 'natal_chart_screen.dart';
import '../services/geocoding_service.dart';
import '../services/user_preferences_service.dart';
import 'package:intl/intl.dart';
import '../widgets/loading_indicator.dart';

class BirthInfoScreen extends StatefulWidget {
  final UserBirthInfo? initialBirthInfo;
  final UserProfile? prefilledProfile;
  final Function(UserBirthInfo)? onComplete;
  final UserPreferencesService? preferencesService;
  final GeocodingService? geocodingService;
  final bool alwaysAutoValidate;

  const BirthInfoScreen({
    Key? key, 
    this.initialBirthInfo,
    this.prefilledProfile,
    this.onComplete,
    this.preferencesService,
    this.geocodingService,
    this.alwaysAutoValidate = false,
  }) : super(key: key);

  @override
  _BirthInfoScreenState createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends State<BirthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  late final UserPreferencesService _prefsService;
  late final GeocodingService _geocodingService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isProcessing = false;
  bool _autoValidate = false;  @override
  void initState() {
    super.initState();
    // Test ortamı için her zaman form doğrulaması yapılmasını istiyorsak
    _autoValidate = widget.alwaysAutoValidate;
    
    // Initialize services with dependency injection support
    _prefsService = widget.preferencesService ?? UserPreferencesService();
    _geocodingService = widget.geocodingService ?? GeocodingService();
    
    // Handle UserProfile prefilling
    if (widget.prefilledProfile != null) {
      final profile = widget.prefilledProfile!;
      _nameController.text = profile.name;
      _selectedDate = profile.birthDate;
      if (profile.birthTime != null) {
        final timeParts = profile.birthTime!.split(':');
        if (timeParts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
      _birthPlaceController.text = profile.birthPlace ?? '';
      _latitudeController.text = profile.latitude?.toString() ?? '';
      _longitudeController.text = profile.longitude?.toString() ?? '';
    }
    // Handle UserBirthInfo prefilling (legacy support)
    else if (widget.initialBirthInfo != null) {
      _nameController.text = widget.initialBirthInfo!.name ?? '';
      _selectedDate = widget.initialBirthInfo!.birthDate;
      if (widget.initialBirthInfo!.birthTime?.isNotEmpty == true) {
        final timeParts = widget.initialBirthInfo!.birthTime!.split(':');
        if (timeParts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
      _birthPlaceController.text = widget.initialBirthInfo!.birthPlace ?? '';      _latitudeController.text = widget.initialBirthInfo!.latitude?.toString() ?? '';
      _longitudeController.text = widget.initialBirthInfo!.longitude?.toString() ?? '';
    }
    
    // If alwaysAutoValidate is true, trigger validation after the first frame
    if (widget.alwaysAutoValidate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'), // For Turkish DatePicker localization
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) { // For Turkish TimePicker localization
        return Localizations.override(
          context: context,
          locale: const Locale('tr', 'TR'),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleFormSubmission() async {
    print('=== DEBUG: _handleFormSubmission called ===');
    FocusScope.of(context).unfocus();

    // Basic required field checks first
    if (_nameController.text.trim().isEmpty) {
      print('DEBUG: Name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen adınızı ve soyadınızı girin.')),
      );
      return;
    }

    if (_selectedDate == null) {
      print('DEBUG: Date is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen doğum tarihinizi seçin.')),
      );
      return;
    }

    if (_selectedTime == null) {
      print('DEBUG: Time is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen doğum saatinizi seçin. Astroloji haritası hesaplaması için bu bilgi gereklidir.')),
      );
      return;
    }

    // Check if coordinates are provided (either manual or to be geocoded)
    String birthPlace = _birthPlaceController.text.trim();
    bool manualCoordsProvided = _latitudeController.text.trim().isNotEmpty && 
                                _longitudeController.text.trim().isNotEmpty;
    
    // If manual coordinates are provided, validate them immediately
    if (manualCoordsProvided) {
      // First set autovalidate to true to ensure errors show
      if (mounted) {
        setState(() {
          _autoValidate = true;
        });
        // Give Flutter a chance to rebuild with validation
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      // Then validate - this will now display errors due to autovalidate being true
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    bool attemptedGeocoding = false;

    // If coordinates are empty, try geocoding from birth place
    if (birthPlace.isNotEmpty && !manualCoordsProvided) {
      if (mounted) {
        setState(() { _isProcessing = true; }); // Show loading for geocoding
      }
      attemptedGeocoding = true;
      Map<String, double>? geocodedCoordinates;
      bool geocodingSuccess = false;

      try {
        geocodedCoordinates = await _geocodingService.getCoordinates(birthPlace);
        if (geocodedCoordinates != null) {
          _latitudeController.text = geocodedCoordinates['lat']!.toStringAsFixed(6);
          _longitudeController.text = geocodedCoordinates['lon']!.toStringAsFixed(6);
          geocodingSuccess = true;
          // SnackBar for success will be shown after validation below
        } else {
          // Geocoding failed to find coordinates (not an exception)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Doğum yeri için koordinatlar bulunamadı. Lütfen yeri kontrol edin veya enlem/boylam bilgilerini manuel olarak girin.')),
            );
          }
          // geocodingSuccess remains false
        }
      } catch (e) {
        print("Geocoding error in BirthInfoScreen: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Koordinatlar alınırken bir hata oluştu. Lütfen internet bağlantınızı kontrol edin veya enlem/boylam bilgilerini manuel olarak girin.')),
          );
        }
        // geocodingSuccess remains false
      }

      // Regardless of geocoding outcome, ensure Form is visible for next steps or if returning
      if (mounted) {
        setState(() { _isProcessing = false; });
        // Ensure the frame is rendered with Form visible before proceeding
        await WidgetsBinding.instance.endOfFrame;
      }

      if (!geocodingSuccess) {
        return; // Exit if geocoding failed or errored. _isProcessing is false, form is visible.
      }

      // Geocoding was successful, controllers are populated. Now validate.
      // _isProcessing is false, so Form is in the tree.
      if (mounted) {
        setState(() { _autoValidate = true; }); // Ensure validation messages are shown
      }
      
      if (!_formKey.currentState!.validate()) {
        // Validation of geocoded coordinates failed. _isProcessing is false.
        // Errors are displayed by the form.
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Otomatik doldurulan enlem/boylam değerleri geçersiz. Lütfen kontrol edin veya manuel olarak düzeltin.')),
            );
        }
        return; 
      } else {
        // Geocoded coordinates are valid. Show success message for geocoding.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Doğum yeri koordinatları bulundu ve otomatik olarak dolduruldu. Gerekirse düzenleyebilirsiniz.')),
          );
        }
        // Proceed to final submission steps. _isProcessing is currently false.
        // The code further down will set _isProcessing = true for the save operation.
      }
    } else if (birthPlace.isEmpty && !manualCoordsProvided) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen doğum yerini veya enlem/boylam bilgilerini girin.')),
        );
      }
      return;
    }

    double finalLatitude = double.parse(_latitudeController.text.trim());
    double finalLongitude = double.parse(_longitudeController.text.trim());

    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }

    final birthInfo = UserBirthInfo(
      name: _nameController.text.trim(),
      birthDate: _selectedDate,
      birthTime: "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
      birthPlace: birthPlace.isNotEmpty ? birthPlace : null,
      latitude: finalLatitude,
      longitude: finalLongitude,
    );

    try {
      await _prefsService.saveUserBirthInfo(birthInfo); // Save the birth info
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doğum bilgileriniz kaydedildi.')),
        );
      }
    } catch (e) {
      print("Error saving birth info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doğum bilgileriniz kaydedilirken bir hata oluştu.')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // If onComplete callback is provided, use it instead of navigation
      if (widget.onComplete != null) {
        widget.onComplete!(birthInfo);
        Navigator.of(context).pop();
      } else {
        // Default behavior: navigate to NatalChartScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NatalChartScreen(
              name: birthInfo.name!,
              birthDate: birthInfo.birthDate!,
              birthTime: birthInfo.birthTime,
              birthPlace: birthInfo.birthPlace,
              latitude: birthInfo.latitude,
              longitude: birthInfo.longitude,
            ),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    print('DEBUG: build() called, _isProcessing = $_isProcessing');
    return Scaffold(
      appBar: AppBar(
        title: Text('Doğum Bilgilerini Girin'),
      ),
      body: _isProcessing 
        ? LoadingIndicator(message: 'Bilgiler işleniyor...')
        : Padding(
            padding: const EdgeInsets.all(16.0),            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    key: const Key('name_field'),
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Ad Soyad'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen adınızı ve soyadınızı girin.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Doğum Tarihi Seçilmedi'
                              : 'Doğum Tarihi: ${DateFormat('dd/MM/yyyy', 'tr_TR').format(_selectedDate!)}',
                        ),
                      ),
                      TextButton(
                        key: const Key('birth_date_field'),
                        onPressed: () => _selectDate(context),
                        child: Text('Tarih Seç'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? 'Doğum Saati Seçilmedi'
                              : 'Doğum Saati: ${_selectedTime!.format(context)}',
                        ),
                      ),
                      TextButton(
                        key: const Key('birth_time_field'),
                        onPressed: () => _selectTime(context),
                        child: Text('Saat Seç'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    key: const Key('birth_place_field'),
                    controller: _birthPlaceController,
                    decoration: InputDecoration(labelText: 'Doğum Yeri (Şehir, Ülke)', hintText: 'Örn: Ankara, Türkiye (İsteğe bağlı)'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Doğum yerini girerseniz, enlem ve boylam otomatik olarak doldurulmaya çalışılacaktır. Dilerseniz bu alanları manuel olarak da girebilir veya düzeltebilirsiniz.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(labelText: 'Enlem (Latitude)', hintText: 'Örn: 39.925533'),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen enlem girin (Örn: 39.925533)';
                      }
                      final lat = double.tryParse(value.trim());
                      if (lat == null) {
                        return 'Geçerli bir sayı girin';
                      }
                      if (lat < -90 || lat > 90) {
                        return 'Enlem -90 ile 90 arasında olmalıdır';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(labelText: 'Boylam (Longitude)', hintText: 'Örn: 32.866287'),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen boylam girin (Örn: 32.866287)';
                      }
                      final lon = double.tryParse(value.trim());
                      if (lon == null) {
                        return 'Geçerli bir sayı girin';
                      }
                      if (lon < -180 || lon > 180) {
                        return 'Boylam -180 ile 180 arasında olmalıdır';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    key: const Key('submit_button'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isProcessing ? null : _handleFormSubmission,
                    child: Text('Natal Haritamı Hesapla', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
