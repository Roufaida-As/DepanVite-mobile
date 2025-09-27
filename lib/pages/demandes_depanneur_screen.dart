import 'package:depanvite/pages/auth_screen.dart';
import 'package:depanvite/theme/app_theme.dart';
import 'package:depanvite/widgets/client_info_dialog.dart';
import 'package:depanvite/widgets/depanneur_request_card.dart';
import 'package:depanvite/widgets/header.dart';
import 'package:flutter/material.dart';

class DemandesDepanneurPage extends StatefulWidget {
  const DemandesDepanneurPage({super.key});

  @override
  State<DemandesDepanneurPage> createState() => _DemandesDepanneurPageState();
}

class _DemandesDepanneurPageState extends State<DemandesDepanneurPage> {
  // Liste de demandes actives
  final List<Map<String, dynamic>> _demandes = [
    {
      'id': '1',
      'clientName': 'AIT KACI AZZOU Sarah',
      'price': '5000 DA',
      'phone': '+213 555779817',
      'position': 'Bab Zouar, Alger, Algeria',
      'positionLat': 39.5232,
      'positionLng': -80.3426,
      'destination': 'Blida, Algeria',
      'destinationLat': 39.4532,
      'destinationLng': -80.2826,
      'distance': '5.2 km',
      'vehicleInfo': {
        'marque': 'Toyota',
        'modele': 'Corolla',
        'immatriculation': 'AB-123-CD',
        'type': 'Voiture',
      },
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': '2',
      'clientName': 'ASBAR Roufaida',
      'price': '5000 DA',
      'phone': '+213 666123456',
      'position': 'Algiers, Algeria',
      'positionLat': 36.7538,
      'positionLng': 3.0588,
      'destination': 'Oran, Algeria',
      'destinationLat': 35.6976,
      'destinationLng': -0.6337,
      'distance': '12.8 km',
      'vehicleInfo': {
        'marque': 'Renault',
        'modele': 'Clio',
        'immatriculation': 'EF-456-GH',
        'type': 'Voiture',
      },
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
    },
    {
      'id': '3',
      'clientName': 'MAAMAR Rofieda',
      'price': '5000 DA',
      'phone': '+213 777234567',
      'position': 'Constantine, Algeria',
      'positionLat': 36.3650,
      'positionLng': 6.6147,
      'destination': 'Setif, Algeria',
      'destinationLat': 36.1908,
      'destinationLng': 5.4147,
      'distance': '3.5 km',
      'vehicleInfo': {
        'marque': 'Peugeot',
        'modele': '208',
        'immatriculation': 'IJ-789-KL',
        'type': 'Voiture',
      },
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    },
  ];

  // Historique des demandes acceptées
  final List<Map<String, dynamic>> _demandesAcceptees = [];

  // Historique des demandes refusées
  final List<Map<String, dynamic>> _demandesRefusees = [];

  // Onglet actuel (0: Demandes, 1: Acceptées, 2: Refusées)
  int _currentTab = 0;

  void _showClientInfoDialog(Map<String, dynamic> demande) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientInfoDialog(
        clientName: demande['clientName'],
        phoneNumber: demande['phone'],
        position: demande['position'],
        destination: demande['destination'],
        distance: demande['distance'],
        vehicleInfo: demande['vehicleInfo'],
      ),
    );
  }

  void _handleAccept(String demandeId) {
    final demande = _demandes.firstWhere((d) => d['id'] == demandeId);

    setState(() {
      _demandes.removeWhere((d) => d['id'] == demandeId);
      // Ajouter à l'historique des acceptées avec la date/heure d'action
      _demandesAcceptees.insert(0, {
        ...demande,
        'actionDate': DateTime.now(),
        'status': 'Acceptée',
      });
    });

    _showClientInfoDialog(demande);
  }

  void _handleRefuse(String demandeId) {
    final demande = _demandes.firstWhere((d) => d['id'] == demandeId);

    setState(() {
      _demandes.removeWhere((d) => d['id'] == demandeId);
      // Ajouter à l'historique des refusées avec la date/heure d'action
      _demandesRefusees.insert(0, {
        ...demande,
        'actionDate': DateTime.now(),
        'status': 'Refusée',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande refusée'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Header(),                     
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppTheme.black,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined),
                        color: AppTheme.black,
                      ),
                       IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Se déconnecter"),
                          content: const Text("Êtes-vous sûr de vouloir vous déconnecter?"),
                          actions: [
                          TextButton(
                            child: const Text("Annuler"),
                            onPressed: () {
                            Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Déconnecter"),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                            },
                          ),
                          ],
                        );
                        },
                      );
                      },
                    ),
                    ],
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentTab == 0 
                      ? 'Demandes' 
                      : _currentTab == 1 
                          ? 'Acceptées' 
                          : 'Refusées',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildTab('Demandes', 0, _demandes.length),
                  const SizedBox(width: 12),
                  _buildTab('Acceptées', 1, _demandesAcceptees.length),
                  const SizedBox(width: 12),
                  _buildTab('Refusées', 2, _demandesRefusees.length),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // List of requests based on current tab
            Expanded(
              child: _buildListForCurrentTab(),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', true),
                  _buildNavItem(Icons.support_agent_outlined, 'Support', false),
                  _buildNavItem(Icons.settings_outlined, 'Settings', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.yellow : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppTheme.yellow : AppTheme.grey2,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.black,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : AppTheme.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.yellow : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListForCurrentTab() {
    List<Map<String, dynamic>> currentList;
    String emptyMessage;
    IconData emptyIcon;

    switch (_currentTab) {
      case 0:
        currentList = _demandes;
        emptyMessage = 'Aucune demande pour le moment';
        emptyIcon = Icons.inbox_outlined;
        break;
      case 1:
        currentList = _demandesAcceptees;
        emptyMessage = 'Aucune demande acceptée';
        emptyIcon = Icons.check_circle_outline;
        break;
      case 2:
        currentList = _demandesRefusees;
        emptyMessage = 'Aucune demande refusée';
        emptyIcon = Icons.cancel_outlined;
        break;
      default:
        currentList = [];
        emptyMessage = '';
        emptyIcon = Icons.inbox_outlined;
    }

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final demande = currentList[index];
        
        if (_currentTab == 0) {
          // Demandes actives
          return DepanneurRequestCard(
            clientName: demande['clientName'],
            phoneNumber: demande['phone'],
            position: demande['position'],
            destination: demande['destination'],
            distance: demande['distance'],
            onAccept: () => _handleAccept(demande['id']),
            onRefuse: () => _handleRefuse(demande['id']),
            price: demande['price'],
          );
        } else {
          // Historique (acceptées ou refusées)
          return _buildHistoryCard(demande);
        }
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> demande) {
    final isAccepted = demande['status'] == 'Acceptée';
    final actionDate = demande['actionDate'] as DateTime;
    final now = DateTime.now();
    final difference = now.difference(actionDate);
    
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      timeAgo = 'Il y a ${difference.inHours}h';
    } else {
      timeAgo = 'Il y a ${difference.inDays}j';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                demande['clientName'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAccepted 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAccepted ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isAccepted ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      demande['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAccepted ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            timeAgo,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),

          const SizedBox(height: 16),

          // Position et destination
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  demande['position'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  demande['destination'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Distance et prix
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${demande['distance']} • ${demande['price']}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.yellow,
                ),
              ),
            ],
          ),

          // Bouton pour voir les détails (seulement pour les acceptées)
          if (isAccepted) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showClientInfoDialog(demande),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.yellow),
                ),
                child: const Center(
                  child: Text(
                    'Voir les détails',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.yellow,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppTheme.yellow : Colors.grey, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.yellow : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}