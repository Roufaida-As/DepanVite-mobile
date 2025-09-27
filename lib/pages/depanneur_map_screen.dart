import 'package:depanvite/theme/app_theme.dart';
import 'package:depanvite/widgets/depanneur_found_dialog.dart';
import 'package:depanvite/widgets/depanneur_request_dialog.dart';
import 'package:depanvite/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Modèle pour les résultats de recherche
class SearchResult {
  final String displayName;
  final double lat;
  final double lon;
  final String type;
  final String osmType;

  SearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    required this.osmType,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']) ?? 0.0,
      lon: double.tryParse(json['lon']) ?? 0.0,
      type: json['type'] ?? '',
      osmType: json['osm_type'] ?? '',
    );
  }
}

class DepanneurMapPage extends StatefulWidget {
  const DepanneurMapPage({super.key});

  @override
  State<DepanneurMapPage> createState() => _DepanneurMapPageState();
}

class _DepanneurMapPageState extends State<DepanneurMapPage> {
  // Position par défaut (Alger)
  LatLng _currentLocation = LatLng(36.635295, 2.688579);
  final MapController _mapController = MapController();
  bool _isLocationLoading = true;
  Position? _currentPosition;
  String _locationStatus = "Localisation en cours...";

  // Liste des dépanneurs générés autour de la position actuelle
  List<LatLng> _depanneurs = [];

  // Variables pour la recherche
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  LatLng? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _generateDefaultDepanneurs(); // Générer des dépanneurs par défaut
    _getCurrentLocation();
  }

  String _currentLocationName = "Localisation en cours...";

 void _showRouteConfirmationDialog(String destinationName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (BuildContext context) {
      return RouteConfirmationDialog(
        currentPosition: _currentLocation,
        currentPositionName: _currentLocationName,
        destination: _selectedDestination!,
        destinationName: destinationName,
        onCancel: () {
          Navigator.pop(context);
          setState(() {
            _selectedDestination = null;
          });
        },
      );
    },
  );
}

void _showDepanneurFoundDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (BuildContext context) {
      return DepanneurFoundDialog(
        depanneurName: "Asbar Ahmed",
        rating: 4.8,
        vehicleType: "White Ford Tow Truck",
        matricule: "ZZARM7",
        phoneNumber: "0558872069",
        distanceText: "1km loin de vous",
        onCall: () {
          // Handle phone call action
          // You can use url_launcher package to make phone calls
          // Example: launch('tel:0558872069');
          Navigator.pop(context);
        },
        onClose: () {
          Navigator.pop(context);
        },
      );
    },
  );
}

Future<String> _getAddressFromCoordinates(double lat, double lon) async {
  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat'
      '&lon=$lon'
      '&format=json'
      '&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'DepanVite Mobile App'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String displayName = data['display_name'] ?? '';
      
      // Return short name (first two parts)
      final parts = displayName.split(',');
      if (parts.length >= 2) {
        return '${parts[0].trim()}, ${parts[1].trim()}';
      }
      return parts[0].trim();
    }
  } catch (e) {
    print('Erreur reverse geocoding: $e');
  }
  
  // Fallback to coordinates
  return "${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}";
}


  // Générer des dépanneurs par défaut autour de la position initiale
  void _generateDefaultDepanneurs() {
    _depanneurs = _generateDepanneursAroundLocation(_currentLocation);
  }

  // Générer des dépanneurs autour d'une position donnée
  List<LatLng> _generateDepanneursAroundLocation(LatLng center) {
    List<LatLng> depanneurs = [];

    // Générer 15 dépanneurs dans un rayon d'environ 5km autour de la position
    for (int i = 0; i < 15; i++) {
      // Générer des offsets aléatoires mais contrôlés
      double latOffset = (i % 4 - 1.5) * 0.02 + (i > 6 ? 0.01 : -0.01);
      double lngOffset =
          ((i ~/ 2) % 4 - 1.5) * 0.02 + (i.isEven ? 0.015 : -0.015);

      // Ajouter une petite variation aléatoire
      latOffset += (i * 0.0001) * (i.isOdd ? 1 : -1);
      lngOffset += (i * 0.0001) * (i % 3 == 0 ? 1 : -1);

      depanneurs.add(
        LatLng(center.latitude + latOffset, center.longitude + lngOffset),
      );
    }

    return depanneurs;
  }

  // Méthode pour rechercher des lieux via l'API Nominatim
  Future<List<SearchResult>> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Construire l'URL de recherche avec focus sur l'Algérie
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=10'
        '&countrycodes=dz'
        '&addressdetails=1'
        '&extratags=1'
        '&namedetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'DepanVite Mobile App'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => SearchResult.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
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
      // Ouvrir les paramètres de l'application
      await openAppSettings();
      return false;
    }

    return true;
  }

  // Méthode pour obtenir la position actuelle
  // Méthode pour obtenir la position actuelle
Future<void> _getCurrentLocation() async {
  setState(() {
    _isLocationLoading = true;
    _locationStatus = "Localisation en cours...";
  });

  try {
    // Vérifier si le service de localisation est activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = "Service de localisation désactivé";
        _isLocationLoading = false;
      });
      _showLocationServiceDialog();
      return;
    }

    // Vérifier les permissions
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      setState(() {
        _locationStatus = "Permission de localisation refusée";
        _isLocationLoading = false;
      });
      return;
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
      // ignore: deprecated_member_use
      timeLimit: Duration(seconds: 10),
    );

    _currentPosition = position;

    // Get address name from coordinates - THIS IS NEW!
    String addressName = await _getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _currentLocationName = addressName; // THIS IS NEW!
      _locationStatus = "Position trouvée";
      _isLocationLoading = false;

      // Régénérer les dépanneurs autour de la nouvelle position
      _depanneurs = _generateDepanneursAroundLocation(_currentLocation);
    });

    // Centrer la carte sur la position actuelle
    _mapController.move(_currentLocation, 15.0);
  } catch (e) {
    setState(() {
      _locationStatus = "Erreur lors de la localisation";
      _isLocationLoading = false;
    });

    // Afficher un message d'erreur à l'utilisateur
    _showLocationErrorDialog();
  }
}

  // Dialog pour informer l'utilisateur d'activer les services de localisation
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Service de localisation"),
          content: const Text(
            "Veuillez activer les services de localisation pour voir votre position sur la carte.",
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

  // Dialog pour les erreurs de localisation
  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur de localisation"),
          content: const Text(
            "Impossible d'obtenir votre position actuelle. La carte affichera une position par défaut.",
          ),
          actions: [
            TextButton(
              child: const Text("Réessayer"),
              onPressed: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour recentrer la carte sur la position actuelle
  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentLocation, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  // Méthode pour afficher le bottom sheet de destination avec recherche
  void _showDestinationBottomSheet() {
    final TextEditingController destinationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barre de glissement
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Titre
                    const Text(
                      "Rechercher une destination",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Champ de saisie avec recherche en temps réel
                    TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        hintText: "Où voulez-vous aller ?",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.yellow),
                        ),
                      ),
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) async {
                        if (value.length > 2) {
                          setModalState(() {
                            _isSearching = true;
                          });

                          final results = await _searchPlaces(value);

                          setModalState(() {
                            _searchResults = results;
                            _isSearching = false;
                          });
                        } else {
                          setModalState(() {
                            _searchResults = [];
                          });
                        }
                      },
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          setModalState(() {
                            _isSearching = true;
                          });

                          final results = await _searchPlaces(value);

                          setModalState(() {
                            _searchResults = results;
                            _isSearching = false;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Résultats de recherche ou suggestions
                    Expanded(
                      child: _searchResults.isNotEmpty
                          ? ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final result = _searchResults[index];
                                return ListTile(
                                  leading: Icon(
                                    _getIconForType(result.type),
                                    color: AppTheme.yellow,
                                  ),
                                  title: Text(
                                    _getShortName(result.displayName),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    result.displayName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    _selectDestination(result);
                                    Navigator.pop(context);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                );
                              },
                            )
                          : _buildSuggestions(setModalState),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget pour afficher les suggestions par défaut
  Widget _buildSuggestions(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Adresses récentes :",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ...["Alger Centre", "Bab Ezzouar", "Hussein Dey", "Tipasa"].map(
          (suggestion) => ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(suggestion),
            onTap: () async {
              setModalState(() {
                _isSearching = true;
              });

              final results = await _searchPlaces(suggestion);

              setModalState(() {
                _searchResults = results;
                _isSearching = false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // Sélectionner une destination et l'afficher sur la carte
  void _selectDestination(SearchResult result) {
    setState(() {
      _selectedDestination = LatLng(result.lat, result.lon);
    });

    // Centrer la carte sur la destination sélectionnée
    _mapController.move(_selectedDestination!, 15.0);
    // Afficher la notification
    _showDepanneurSearchNotification();

    // Après 7 secondes, afficher le dialog de confirmation
   Future.delayed(const Duration(seconds: 7), () {
    _showRouteConfirmationDialog(_getShortName(result.displayName));
  });
    // Après 14 secondes, afficher le dialog de dépanneur trouvé
    Future.delayed(const Duration(seconds: 14), () {
      _showDepanneurFoundDialog();
    });
  }

  // Obtenir une icône appropriée selon le type de lieu
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'city':
      case 'town':
      case 'village':
        return Icons.location_city;
      case 'hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'restaurant':
        return Icons.restaurant;
      case 'gas_station':
        return Icons.local_gas_station;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  // Extraire le nom court du nom d'affichage complet
  String _getShortName(String displayName) {
    final parts = displayName.split(',');
    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return parts[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13,
            ),
            children: [
              // Fond de carte OpenStreetMap
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.depanvite',
              ),
              // Marqueurs
              MarkerLayer(
                markers: [
                  // Position utilisateur
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.3),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                  // Destination sélectionnée
                  if (_selectedDestination != null)
                    Marker(
                      point: _selectedDestination!,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.3),
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),
                  // Dépanneurs
                  ..._depanneurs.map(
                    (pos) => Marker(
                      point: pos,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.yellow.withOpacity(0.2),
                          border: Border.all(color: AppTheme.yellow, width: 2),
                        ),
                        child: const Icon(
                          Icons.car_repair,
                          color: AppTheme.yellow,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Indicateur de chargement de localisation
          if (_isLocationLoading)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationStatus,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Logo + actions en haut
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Header(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton de recentrage sur la position GPS
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: _centerOnCurrentLocation,
              child: _isLocationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Bouton flottant en bas
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _showDestinationBottomSheet,
              child: const Text(
                "Rechercher un dépanneur",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // Barre de navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        selectedItemColor: AppTheme.yellow,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Méthode pour afficher la notification en bas
  void _showDepanneurSearchNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: const [
            Icon(Icons.notifications, color: AppTheme.yellow),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Le plus proche dépanneur libre est sous la recherche, "
                "S’il accepte, il recevra une notification avec toutes vos informations "
                "ainsi que votre numéro de téléphone.",
                style: TextStyle(color: AppTheme.black),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 7),
      ),
    );
  }
}
