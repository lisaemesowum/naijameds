import 'dart:async';
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
  Timer? _debounce;

  final FirestoreService firestoreService = FirestoreService();
  List<Medication> medications = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Stores your real search history
  final List<String> _recentSearches = [];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().isNotEmpty) {
        _addToRecentSearches(query);
        searchMedications(query);
      }
    });
  }

  void _addToRecentSearches(String query) {
    setState(() {
      String trimmed = query.trim();
      _recentSearches.remove(trimmed); // Remove if exists to move to top
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 5) _recentSearches.removeLast(); // Keep only last 5
    });
  }

  Future<void> searchMedications(String query) async {
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
      final results = await firestoreService.searchMedications(query);
      if (mounted) {
        setState(() {
          medications = results;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Search Error: $e");
    }
  }

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
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2A6074), size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Find Medication",
          style: TextStyle(color: Color(0xFF2A6074), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF17B169)))
                : medications.isEmpty && hasSearched
                    ? _buildNoResults()
                    : medications.isNotEmpty
                        ? _buildResultsList()
                        : _buildInitialState(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search drug, brand, or code...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF17B169)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 20),
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
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Searches", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
                  TextButton(
                    onPressed: () => setState(() => _recentSearches.clear()),
                    child: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: _recentSearches.map((s) => ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 13)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    _searchController.text = s;
                    searchMedications(s);
                  },
                )).toList(),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
            child: Text("Popular Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategory("Pain Relief", Icons.medication_rounded, Colors.orange),
                _buildCategory("Antibiotics", Icons.biotech_rounded, Colors.blue),
                _buildCategory("Vitamins", Icons.wb_sunny_rounded, Colors.green),
                _buildCategory("First Aid", Icons.medical_services_rounded, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon, Color color) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF17B169).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.medication_rounded, color: Color(0xFF17B169)),
            ),
            title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(med.desc ?? "Quality approved", style: const TextStyle(fontSize: 12)),
            trailing: Text(med.price, style: const TextStyle(color: Color(0xFF17B169), fontWeight: FontWeight.bold)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationDetailsScreen(medication: med))),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No medications found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
