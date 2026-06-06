import 'package:flutter/material.dart';

class ScrollControllerProvider extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  
  // 7 keys corresponding to 7 main UI sections
  final List<GlobalKey> sectionKeys = List.generate(7, (index) => GlobalKey());
  
  final List<String> sectionNames = [
    'Home',
    'About',
    'Skills',
    'Projects',
    'Certifications',
    'Experience',
    'Contact',
  ];

  int _activeSection = 0;
  int get activeSection => _activeSection;

  bool _isManualScroll = false;

  void scrollToSection(int index) {
    if (index < 0 || index >= sectionKeys.length) return;
    
    _isManualScroll = true;
    _activeSection = index;
    notifyListeners();

    final context = sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        // Reset manual scroll override flag
        Future.delayed(const Duration(milliseconds: 100), () {
          _isManualScroll = false;
        });
      });
    } else {
      _isManualScroll = false;
    }
  }

  void updateActiveSection(int index) {
    if (_isManualScroll) return; // Prevent scroll observer from causing UI jitter while scrolling programmatically
    if (_activeSection != index) {
      _activeSection = index;
      notifyListeners();
    }
  }
}
