import 'package:flutter/material.dart';

/// Demo app showing the fixed layout constraints
void main() {
  runApp(LayoutFixDemoApp());
}

class LayoutFixDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout Fixes Demo',
      theme: ThemeData.dark(),
      home: LayoutFixDemoScreen(),
    );
  }
}

class LayoutFixDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Layout Constraint Fixes Demo'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo: Fixed ActiveTimerBar
            _buildSection(
              'Fixed ActiveTimerBar',
              'No more infinite height constraints',
              _DemoActiveTimerBar(),
            ),
            
            SizedBox(height: 32),
            
            // Demo: Fixed Substance Grid
            _buildSection(
              'Fixed Substance Grid',
              'No more 50px overflow - uses Wrap with fixed heights',
              _DemoSubstanceGrid(),
            ),
            
            SizedBox(height: 32),
            
            // Demo: Constraint Validation
            _buildSection(
              'Constraint Safety',
              'Graceful handling of problematic constraints',
              _DemoConstraintValidation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget demo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 16),
        demo,
      ],
    );
  }
}

/// Demonstrates the fixed ActiveTimerBar layout
class _DemoActiveTimerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // This is the fix: safe height handling
        final safeHeight = constraints.maxHeight.isFinite 
            ? constraints.maxHeight.clamp(50.0, 100.0)
            : 80.0;
            
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          height: safeHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan.withOpacity(0.3),
                Colors.cyan.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.cyan.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timer_rounded,
                    color: Colors.cyan,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Test Substance',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Timer läuft',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '45:30',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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

/// Demonstrates the fixed substance grid layout
class _DemoSubstanceGrid extends StatelessWidget {
  final List<String> substances = ['MDMA', 'LSD', 'Cannabis', 'Psilocybin'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: substances.map((substance) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 64) / 2,
          height: 240, // Fixed height prevents overflow
          child: _DemoSubstanceCard(substance),
        );
      }).toList(),
    );
  }
}

class _DemoSubstanceCard extends StatelessWidget {
  final String substanceName;
  
  const _DemoSubstanceCard(this.substanceName);

  @override
  Widget build(BuildContext context) {
    final colors = {
      'MDMA': Colors.pink,
      'LSD': Colors.purple,
      'Cannabis': Colors.green,
      'Psilocybin': Colors.orange,
    };
    
    final color = colors[substanceName] ?? Colors.blue;
    
    return Container(
      height: 240, // Fixed height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.science_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Oral',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            substanceName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Empfohlene Dosis:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '85.0 mg',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '6-8 Stunden',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Demonstrates constraint validation
class _DemoConstraintValidation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ConstraintDemo(
          'Normal Constraints',
          BoxConstraints(maxWidth: 300, maxHeight: 100),
          Colors.green,
        ),
        SizedBox(height: 12),
        _ConstraintDemo(
          'Infinite Height (Fixed)',
          BoxConstraints(maxWidth: 300, maxHeight: double.infinity),
          Colors.orange,
        ),
        SizedBox(height: 12),
        _ConstraintDemo(
          'Very Small Constraints',
          BoxConstraints(maxWidth: 200, maxHeight: 30),
          Colors.blue,
        ),
      ],
    );
  }
}

class _ConstraintDemo extends StatelessWidget {
  final String label;
  final BoxConstraints constraints;
  final Color color;
  
  const _ConstraintDemo(this.label, this.constraints, this.color);

  @override
  Widget build(BuildContext context) {
    // This demonstrates the fix: safe constraint handling
    final safeHeight = constraints.maxHeight.isFinite 
        ? constraints.maxHeight.clamp(30.0, 100.0)
        : 50.0; // Fallback for infinite
        
    return Container(
      width: constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
      height: safeHeight,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Text(
            'Height: ${constraints.maxHeight.isFinite ? constraints.maxHeight.toStringAsFixed(0) : "∞"} → ${safeHeight.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}