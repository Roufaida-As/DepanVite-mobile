import 'package:depanvite/pages/demandes_depanneur_screen.dart';
import 'package:depanvite/theme/app_theme.dart';
import 'package:depanvite/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class AccesDepanneur extends StatefulWidget {
  const AccesDepanneur({super.key});

  @override
  State<AccesDepanneur> createState() => _AccesDepanneurState();
}

class _AccesDepanneurState extends State<AccesDepanneur> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _immatriculationController =
      TextEditingController();
  final TextEditingController _permisController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _capaciteController = TextEditingController();

  String? _selectedMarque;
  String? _selectedSpecialisation;
  String _localisationActuelle = "Localisation en cours...";
  bool _isLocationLoading = false;
  Position? _currentPosition;

  final List<String> _marques = [
    'Toyota',
    'Renault',
    'Peugeot',
    'Hyundai',
    'Volkswagen',
    'Mercedes',
    'BMW',
    'Audi',
    'Nissan',
    'Ford',
    'Iveco',
    'MAN',
    'Scania',
    'Volvo',
  ];

  final List<String> _specialisations = [
    'Voitures légères',
    'Motos',
    'Poids lourds',
    'Véhicules utilitaires',
    'Tous types de véhicules',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _immatriculationController.dispose();
    _permisController.dispose();
    _modeleController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  // Méthode pour vérifier et demander les permissions de localisation
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return true;
  }

  // Méthode pour obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _localisationActuelle = "Localisation en cours...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _localisationActuelle = "Service de localisation désactivé";
          _isLocationLoading = false;
        });
        _showLocationServiceDialog();
        return;
      }

      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _localisationActuelle = "Permission de localisation refusée";
          _isLocationLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        setState(() {
          _localisationActuelle = address.isNotEmpty
              ? address
              : "Adresse inconnue";
          _isLocationLoading = false;
        });
      } else {
        setState(() {
          _localisationActuelle = "Adresse non trouvée";
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _localisationActuelle = "Erreur lors de la localisation";
        _isLocationLoading = false;
      });
      print("Erreur de localisation: $e");
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Service de localisation"),
          content: const Text(
            "Veuillez activer les services de localisation pour utiliser cette fonctionnalité.",
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Paramètres"),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppTheme.yellow, width: 2),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppTheme.yellow, width: 2),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.yellow),
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Adresse complète",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppTheme.yellow, width: 2),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _localisationActuelle,
                  style: const TextStyle(fontSize: 14, color: AppTheme.black),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isLocationLoading ? null : _getCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isLocationLoading ? Colors.grey : AppTheme.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLocationLoading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 14,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isLocationLoading ? 'GPS...' : 'GPS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_currentPosition != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
              'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCapacityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Capacité de remorquage",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppTheme.yellow, width: 2),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _capaciteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Entrez votre capacité en tonne",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "t",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Header(),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Informations personnelles",
                          style: TextStyle(fontSize: 18, color: AppTheme.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          label: "Nom",
                          controller: _nomController,
                          hintText: "Entrez votre nom",
                        ),

                        _buildTextField(
                          label: "Prénom",
                          controller: _prenomController,
                          hintText: "Entrez votre prénom",
                        ),

                        _buildTextField(
                          label: "Numéro Téléphone",
                          controller: _telephoneController,
                          hintText: "Entrez votre numéro de téléphone",
                          keyboardType: TextInputType.phone,
                        ),

                        _buildLocationField(),

                        const SizedBox(height: 20),
                        const Text(
                          "Informations de votre Voiture",
                          style: TextStyle(fontSize: 18, color: AppTheme.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          label: "Plaque d'Immatriculation de la dépanneuse",
                          controller: _immatriculationController,
                          hintText: "Entrez votre plaque d'immatriculation",
                        ),

                        _buildTextField(
                          label: "Numéro de Permis de Conduire",
                          controller: _permisController,
                          hintText: "Entrez votre numéro de Permis",
                        ),

                        _buildDropdown(
                          label: "Spécialisations",
                          value: _selectedSpecialisation,
                          items: _specialisations,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSpecialisation = newValue;
                            });
                          },
                          hintText: "Choisissez votre spécialisation",
                        ),

                        _buildDropdown(
                          label: "Marque de la dépanneuse",
                          value: _selectedMarque,
                          items: _marques,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMarque = newValue;
                            });
                          },
                          hintText: "Choisissez votre marque",
                        ),

                        _buildTextField(
                          label: "Modèle de la dépanneuse",
                          controller: _modeleController,
                          hintText: "Entrez votre modèle",
                        ),

                        _buildCapacityField(),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: AppTheme.yellow,
                                    width: 2,
                                  ),
                                  color: Colors.white,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Retour",
                                    style: TextStyle(
                                      color: AppTheme.yellow,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: AppTheme.yellow,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _showSuccessDialog();
                                    }
                                  },
                                  child: const Text(
                                    "Suivant",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 16),
                const Text(
                  "Inscription réussie ! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Votre demande d'inscription en tant que dépanneur a été envoyée avec succès.\n\nVous recevrez une confirmation par email une fois votre compte validé.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DemandesDepanneurPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
