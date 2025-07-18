import 'package:flutter/material.dart';

// Simple validation demo to test the overflow fixes
class OverflowFixValidation extends StatelessWidget {
  const OverflowFixValidation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow Fix Validation',
      home: Scaffold(
        appBar: AppBar(title: const Text('Testing Overflow Fixes')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pixel Overflow Fixes Validation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Test pie chart legend layout
              _buildTestPieChartLegend(),
              const SizedBox(height: 20),
              
              // Test navigation item layout
              _buildTestNavigationItems(),
              const SizedBox(height: 20),
              
              const Text(
                'All layouts should display without overflow errors.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestPieChartLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pie Chart Legend Test:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // Simulate narrow container for legend row
          Container(
            width: 200, // Narrow width to test overflow fix
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Very Long Substance Name That Could Cause Overflow',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // This should now be wrapped in Flexible
                Flexible(
                  child: Text(
                    '99.9%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNavigationItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Navigation Items Test:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // Simulate navigation bar
          Container(
            width: 320, // Narrow screen width
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTestNavItem('Home', Icons.home),
                _buildTestNavItem('Dosisrechner', Icons.calculate),
                _buildTestNavItem('Statistiken', Icons.analytics),
                _buildTestNavItem('Menü', Icons.menu),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNavItem(String label, IconData icon) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced padding
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 60), // Added constraint
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const OverflowFixValidation());
}