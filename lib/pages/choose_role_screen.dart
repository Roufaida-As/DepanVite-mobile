import 'package:depanvite/pages/demande_client_screen.dart';
import 'package:depanvite/theme/app_theme.dart';
import 'package:depanvite/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo en haut
              const Header(),
              const SizedBox(height: 60),
              SvgPicture.asset("assets/choose-role.svg"),

              const SizedBox(height: 40),

              // Titre
              const Text(
                'Choisissez votre rôle',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Options de rôle
              Expanded(
                child: Column(
                  children: [
                    // Option Client
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'client';
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: selectedRole == 'client'
                              ? AppTheme.beige
                              : Colors.white,
                          border: Border.all(
                            color: selectedRole == 'client'
                                ? AppTheme.yellow
                                : AppTheme.grey2,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Radio button
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedRole == 'client'
                                      ? AppTheme.yellow
                                      : AppTheme.grey2,
                                  width: 2,
                                ),
                                color: selectedRole == 'client'
                                    ? AppTheme.yellow
                                    : Colors.transparent,
                              ),
                              child: selectedRole == 'client'
                                  ? const Center(
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Texte
                            const Expanded(
                              child: Text(
                                'J\'ai une panne, je cherche un dépanneur.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Icône voiture
                            SvgPicture.asset(
                              'assets/car.svg',
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Option Dépanneur
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'depanneur';
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: selectedRole == 'depanneur'
                              ? AppTheme.beige
                              : Colors.white,
                          border: Border.all(
                            color: selectedRole == 'depanneur'
                                ? AppTheme.yellow
                                : AppTheme.grey2,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Radio button
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedRole == 'depanneur'
                                      ? AppTheme.yellow
                                      : AppTheme.grey2,
                                  width: 2,
                                ),
                                color: selectedRole == 'depanneur'
                                    ? AppTheme.yellow
                                    : Colors.transparent,
                              ),
                              child: selectedRole == 'depanneur'
                                  ? const Center(
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Texte
                            const Expanded(
                              child: Text(
                                'Je suis dépanneur, je cherche des clients.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Icône camion
                           Image.asset(
                              'assets/depanneuse.png',
                            
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Suivant
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: 
                       () {
                          if (selectedRole == "client") {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => const DemandeClient()));
                          } else if (selectedRole == "depanneur") {
                            // Navigator.push(context,MaterialPageRoute(builder: (context) => const DemandeDepanneur()));
                          }
                        },
                      
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole != null
                        ? AppTheme.yellow
                        : AppTheme.grey2,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Suivant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
