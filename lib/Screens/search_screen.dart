import 'dart:async'; // Required for Timer (Debouncing)
import 'package:flutter/material.dart';
import 'package:naijameds/Screens/medication_details_screen.dart';
import 'package:naijameds/models/medication.dart';
import 'package:naijameds/services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  bool hasSearched = false;
  Timer? _debounce; // To prevent calling Firebase on every single keystroke

  final FirestoreService firestoreService = FirestoreService();
  List<Medication> medications = [];
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ["Paracetamol", "Coartem", "Amoxicillin", "Vitamin C"];

  //  ==================================================================================
  //  Search medications from firebase with a small delay (Debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchMedications(query);
    });
  }

  Future<void> searchMedications(String query) async {
    // Prevent empty search
    if (query.trim().isEmpty) {
      setState(() {
        medications = [];
        hasSearched = false;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      // Fetch medications from firebase
      final results = await firestoreService.searchMedications(query);

      // Update state with results
      if (mounted) {
        setState(() {
          medications = results;
          isLoading = false; // Fixed: Set to false so loader disappears
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("Search Error: $e");
    }
  }
  //  ==================================================================================

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Search Medications",
          style: TextStyle(color: Color(0xFF2A6074), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Premium Search Bar with Filter
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged, // Uses the debounce function
                      decoration: InputDecoration(
                        hintText: "Search for drug, brand, or MAS code",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF4FB062)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            searchMedications("");
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 55, width: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A6074),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results UI
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: CircularProgressIndicator(color: Color(0xFF4FB062)),
                      ),
                    )
                  else if (hasSearched && medications.isEmpty)
                    _buildNoResults()
                  else if (medications.isNotEmpty)
                      _buildResultsList()
                    else
                      _buildInitialState(), // Shows categories and recent searches
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Searches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text("Clear", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: _recentSearches.map((search) => ActionChip(
                  label: Text(search, style: const TextStyle(fontSize: 14)),
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _searchController.text = search;
                    searchMedications(search);
                  }
              )).toList(),
            ),
          ),
        ],
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text("Popular Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryCard("Pain Relief", Icons.medication_rounded, Colors.orange),
              _buildCategoryCard("Antibiotics", Icons.biotech_rounded, Colors.blue),
              _buildCategoryCard("Vitamins", Icons.wb_sunny_rounded, Colors.green),
              _buildCategoryCard("First Aid", Icons.medical_services_rounded, Colors.red),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Search Results", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: medications.length,
          itemBuilder: (context, index) {

            final med = medications[index];

            return GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicationDetailsScreen(
                      medication: med,
                    ),
                  ),
                );

              },

              child: _buildMedResultCard(med),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No medication found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Check the spelling or try a different name", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 100, margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMedResultCard(Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(color: const Color(0xFF4FB062).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication, color: Color(0xFF4FB062)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(med.desc ?? "No description", style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(med.price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4FB062))),
        ],
      ),
    );
  }
}

