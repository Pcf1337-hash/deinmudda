// Example demonstrating how to use XtcColorPicker with selectedColor parameter
// This resolves the compilation error: "No named parameter with the name 'selectedColor'"

import 'package:flutter/material.dart';
import '../widgets/xtc_color_picker.dart';

class XtcColorPickerExample extends StatefulWidget {
  const XtcColorPickerExample({super.key});

  @override
  State<XtcColorPickerExample> createState() => _XtcColorPickerExampleState();
}

class _XtcColorPickerExampleState extends State<XtcColorPickerExample> {
  Color _selectedColor = Colors.pink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XtcColorPicker Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uncontrolled Mode (original usage)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Widget manages its own state internally:'),
            const SizedBox(height: 16),
            XtcColorPicker(
              initialColor: Colors.red,
              onColorChanged: (color) {
                // Handle color change
                print('Uncontrolled color changed to: $color');
              },
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Controlled Mode (new feature - fixes selectedColor error)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Parent component controls the selected color:'),
            const SizedBox(height: 16),
            XtcColorPicker(
              initialColor: Colors.pink,
              selectedColor: _selectedColor,  // This parameter now exists!
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
                print('Controlled color changed to: $color');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Demonstrate external control
            const Text(
              'External Control Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _selectedColor = Colors.red),
                  child: const Text('Red'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedColor = Colors.blue),
                  child: const Text('Blue'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedColor = Colors.green),
                  child: const Text('Green'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  'Selected Color: ${_selectedColor.toString()}',
                  style: TextStyle(
                    color: _selectedColor.computeLuminance() > 0.5 
                        ? Colors.black 
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}