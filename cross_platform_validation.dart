import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'lib/utils/platform_helper.dart' show PlatformHelper, HapticFeedbackType;
import 'lib/widgets/platform_adaptive_widgets.dart';
import 'lib/widgets/platform_adaptive_fab.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'lib/theme/design_tokens.dart';

/// Manual validation app for cross-platform features
class CrossPlatformValidationApp extends StatelessWidget {
  const CrossPlatformValidationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
      ],
      child: Consumer<PsychedelicThemeService>(
        builder: (context, psychedelicService, child) {
          return MaterialApp(
            title: 'Cross-Platform Validation',
            theme: psychedelicService.isInitialized ? psychedelicService.getTheme() : ThemeData.light(),
            darkTheme: psychedelicService.isInitialized ? psychedelicService.darkTheme : ThemeData.dark(),
            home: const CrossPlatformValidationScreen(),
          );
        },
      ),
    );
  }
}

class CrossPlatformValidationScreen extends StatefulWidget {
  const CrossPlatformValidationScreen({super.key});

  @override
  State<CrossPlatformValidationScreen> createState() => _CrossPlatformValidationScreenState();
}

class _CrossPlatformValidationScreenState extends State<CrossPlatformValidationScreen> {
  final _textController = TextEditingController();
  bool _switchValue = false;
  double _sliderValue = 0.5;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformAdaptiveAppBar(
        title: 'Cross-Platform Validation',
        subtitle: 'Platform: ${PlatformHelper.isIOS ? 'iOS' : 'Android'}',
        systemOverlayStyle: PlatformHelper.getStatusBarStyle(
          isDark: Theme.of(context).brightness == Brightness.dark,
          isPsychedelicMode: false,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: PlatformHelper.getScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlatformInfoCard(),
              const SizedBox(height: 24),
              _buildUIComponentsSection(),
              const SizedBox(height: 24),
              _buildInteractionSection(),
              const SizedBox(height: 24),
              _buildThemeSection(),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: PlatformAdaptiveFAB(
        onPressed: () {
          _showPlatformModal();
        },
        child: Icon(
          Icons.add,
          size: PlatformHelper.getPlatformIconSize(),
        ),
      ),
    );
  }

  Widget _buildPlatformInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Platform', PlatformHelper.isIOS ? 'iOS' : 'Android'),
            _buildInfoRow('Is Mobile', PlatformHelper.isMobile.toString()),
            _buildInfoRow('Is Web', PlatformHelper.isWeb.toString()),
            _buildInfoRow('Is Desktop', PlatformHelper.isDesktop.toString()),
            _buildInfoRow('Icon Size', '${PlatformHelper.getPlatformIconSize()}px'),
            _buildInfoRow('Elevation', '${PlatformHelper.getPlatformElevation()}px'),
            _buildInfoRow('Border Radius', PlatformHelper.getPlatformBorderRadius().toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUIComponentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UI Components',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Platform Adaptive Button
            PlatformAdaptiveButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Platform adaptive button pressed!')),
                );
              },
              child: const Text('Platform Adaptive Button'),
            ),
            
            const SizedBox(height: 16),
            
            // Platform Adaptive Text Field
            PlatformAdaptiveTextField(
              controller: _textController,
              placeholder: 'Enter text here...',
              label: 'Platform Adaptive Text Field',
              keyboardType: TextInputType.text,
              onChanged: (value) {
                // Handle text change
              },
            ),
            
            const SizedBox(height: 16),
            
            // Platform Adaptive Switch
            Row(
              children: [
                Text(
                  'Platform Adaptive Switch:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                PlatformAdaptiveSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Platform Adaptive Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Adaptive Slider: ${_sliderValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                PlatformAdaptiveSlider(
                  value: _sliderValue,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Platform Adaptive Loading Indicator
            const Row(
              children: [
                Text('Platform Adaptive Loading Indicator:'),
                SizedBox(width: 16),
                PlatformAdaptiveLoadingIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Haptic Feedback Test
            PlatformAdaptiveButton(
              onPressed: () {
                PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Light haptic feedback triggered!')),
                );
              },
              child: const Text('Test Light Haptic Feedback'),
            ),
            
            const SizedBox(height: 12),
            
            PlatformAdaptiveButton(
              onPressed: () {
                PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medium haptic feedback triggered!')),
                );
              },
              child: const Text('Test Medium Haptic Feedback'),
            ),
            
            const SizedBox(height: 12),
            
            PlatformAdaptiveButton(
              onPressed: () {
                PlatformHelper.performHapticFeedback(HapticFeedbackType.heavyImpact);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Heavy haptic feedback triggered!')),
                );
              },
              child: const Text('Test Heavy Haptic Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Controls',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            Consumer<PsychedelicThemeService>(
              builder: (context, psychedelicService, child) {
                return Column(
                  children: [
                    PlatformAdaptiveButton(
                      onPressed: () {
                        psychedelicService.toggleDarkMode();
                      },
                      child: Text(
                        psychedelicService.isDarkMode 
                          ? 'Switch to Light Mode' 
                          : 'Switch to Dark Mode',
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    PlatformAdaptiveButton(
                      onPressed: () {
                        psychedelicService.togglePsychedelicMode();
                      },
                      child: Text(
                        psychedelicService.isPsychedelicMode 
                          ? 'Disable Trippy Mode' 
                          : 'Enable Trippy Mode',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlatformModal() {
    PlatformAdaptiveModalBottomSheet.show(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Platform Adaptive Modal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This modal is displayed using platform-specific presentation:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• iOS: CupertinoModalPopup',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '• Android: ModalBottomSheet',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PlatformAdaptiveButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPlatformDialog();
                  },
                  child: const Text('Show Dialog'),
                ),
                PlatformAdaptiveButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlatformDialog() {
    PlatformAdaptiveDialog.show(
      context: context,
      title: 'Platform Adaptive Dialog',
      content: 'This dialog uses platform-specific styling:\n\n'
          '• iOS: CupertinoAlertDialog\n'
          '• Android: AlertDialog',
      actions: [
        PlatformAdaptiveButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

void main() {
  runApp(const CrossPlatformValidationApp());
}