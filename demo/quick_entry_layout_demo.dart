import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib/widgets/quick_entry/quick_entry_bar.dart';
import '../lib/models/quick_button_config.dart';
import '../lib/services/timer_service.dart';
import '../lib/theme/design_tokens.dart';

/// Demo app to showcase the optimized QuickEntry layout
/// This can be used to visually verify the improvements:
/// - Reduced spacing between title and buttons
/// - Centered button alignment
/// - Consistent heights
/// - Overflow prevention
void main() {
  runApp(QuickEntryLayoutDemo());
}

class QuickEntryLayoutDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerService()),
      ],
      child: MaterialApp(
        title: 'QuickEntry Layout Demo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: QuickEntryDemoScreen(),
      ),
    );
  }
}

class QuickEntryDemoScreen extends StatefulWidget {
  @override
  _QuickEntryDemoScreenState createState() => _QuickEntryDemoScreenState();
}

class _QuickEntryDemoScreenState extends State<QuickEntryDemoScreen> {
  bool isEditing = false;
  List<QuickButtonConfig> quickButtons = [
    QuickButtonConfig.create(
      substanceId: '1',
      substanceName: 'LSD',
      dosage: 100.0,
      unit: 'μg',
      cost: 15.0,
      position: 0,
    ),
    QuickButtonConfig.create(
      substanceId: '2',
      substanceName: 'MDMA',
      dosage: 120.0,
      unit: 'mg',
      cost: 25.0,
      position: 1,
    ),
    QuickButtonConfig.create(
      substanceId: '3',
      substanceName: 'Psilocybin',
      dosage: 2.5,
      unit: 'g',
      cost: 30.0,
      position: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('QuickEntry Layout Optimization Demo'),
        backgroundColor: DesignTokens.primaryIndigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo description
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Layout Optimizations Demonstrated:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('✓ Reduced vertical spacing between title and buttons'),
                    Text('✓ Centered button alignment (horizontal and vertical)'),
                    Text('✓ Consistent heights between QuickButton and Add Button'),
                    Text('✓ Height constraints to prevent overflow'),
                    Text('✓ Stable keys for ReorderableListView'),
                    Text('✓ Improved empty state handling'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Toggle button
            Row(
              children: [
                Text('Edit Mode: '),
                Switch(
                  value: isEditing,
                  onChanged: (value) {
                    setState(() {
                      isEditing = value;
                    });
                  },
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      quickButtons.clear();
                    });
                  },
                  child: Text('Clear Buttons'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      quickButtons = [
                        QuickButtonConfig.create(
                          substanceId: '1',
                          substanceName: 'LSD',
                          dosage: 100.0,
                          unit: 'μg',
                          cost: 15.0,
                          position: 0,
                        ),
                        QuickButtonConfig.create(
                          substanceId: '2',
                          substanceName: 'MDMA',
                          dosage: 120.0,
                          unit: 'mg',
                          cost: 25.0,
                          position: 1,
                        ),
                        QuickButtonConfig.create(
                          substanceId: '3',
                          substanceName: 'Psilocybin',
                          dosage: 2.5,
                          unit: 'g',
                          cost: 30.0,
                          position: 2,
                        ),
                      ];
                    });
                  },
                  child: Text('Reset Buttons'),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Demo QuickEntry widget
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: QuickEntryBar(
                  quickButtons: quickButtons,
                  onQuickEntry: (config) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quick entry: ${config.substanceName}'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  onAddButton: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Add button pressed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  onEditMode: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  isEditing: isEditing,
                  onReorder: (newButtons) {
                    setState(() {
                      quickButtons = newButtons;
                    });
                  },
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Additional test cases
            Text(
              'Additional Test Cases:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Empty state demo
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empty State (no buttons):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    QuickEntryBar(
                      quickButtons: [],
                      onQuickEntry: (config) {},
                      onAddButton: () {},
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Single button demo
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Single Button:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    QuickEntryBar(
                      quickButtons: [
                        QuickButtonConfig.create(
                          substanceId: '1',
                          substanceName: 'Test',
                          dosage: 50.0,
                          unit: 'mg',
                          position: 0,
                        ),
                      ],
                      onQuickEntry: (config) {},
                      onAddButton: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}