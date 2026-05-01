import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Initial camera position (Lagos, Nigeria)
  static const CameraPosition _kLagos = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 14.4746,
  );

  bool _isHeatmapVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Map
          const GoogleMap(
            initialCameraPosition: _kLagos,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // 2. Custom Search and Filter Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF4FB062)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Find pharmacies near you...",
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.grey.shade300,
                          indent: 15,
                          endIndent: 15,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Color(0xFF2A6074)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hotspot Toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      onPressed: () {
                        setState(() {
                          _isHeatmapVisible = !_isHeatmapVisible;
                        });
                      },
                      backgroundColor: _isHeatmapVisible ? Colors.red : Colors.white,
                      avatar: Icon(
                        Icons.warning_rounded,
                        size: 16,
                        color: _isHeatmapVisible ? Colors.white : Colors.red,
                      ),
                      label: Text(
                        "Fake Drug Hotspots",
                        style: TextStyle(
                          fontSize: 12,
                          color: _isHeatmapVisible ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.withOpacity(0.2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Action Buttons (Right side)
          Positioned(
            right: 20,
            bottom: 220,
            child: Column(
              children: [
                _buildMapFab(Icons.my_location, () {}),
                const SizedBox(height: 12),
                _buildMapFab(Icons.layers_outlined, () {}),
              ],
            ),
          ),

          // 4. Draggable Scrollable Sheet for Pharmacy Details
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Nearby Pharmacies",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A6074)),
                    ),
                    const SizedBox(height: 15),
                    _buildPharmacyItem(
                      "HealthPlus Lekki",
                      "Admiralty Way, Lekki Phase 1",
                      "0.8 km",
                      "Open • 24hrs",
                      true,
                    ),
                    _buildPharmacyItem(
                      "Medplus Pharmacy",
                      "Ikeja City Mall, Ikeja",
                      "1.2 km",
                      "Open • Closes 10PM",
                      true,
                    ),
                    _buildPharmacyItem(
                      "Alpha Pharmacy",
                      "Victoria Island, Lagos",
                      "2.5 km",
                      "Closed • Opens 8AM",
                      false,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapFab(IconData icon, VoidCallback onTap) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(icon, color: const Color(0xFF2A6074)),
        ),
      ),
    );
  }

  Widget _buildPharmacyItem(String name, String address, String distance, String status, bool inStock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4FB062).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined, color: Color(0xFF4FB062)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (inStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FB062).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "In Stock",
                          style: TextStyle(color: Color(0xFF4FB062), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(distance, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(width: 15),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
