import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/portfolio_state_model.dart';
import 'package:portfolio/providers/portfolio_state_provider.dart';
import 'package:portfolio/widgets/admin/edit_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/utils/platform_helper.dart';

void main() {
  testWidgets('test EditSkillDialog build', (WidgetTester tester) async {
    final skill = SkillModel(
      name: 'Flutter',
      percentage: 0.9,
      iconCodePoint: Icons.phone_android.codePoint,
      iconFontFamily: Icons.phone_android.fontFamily ?? 'MaterialIcons',
      colorHex: '0xFF38BDF8',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditSkillDialog(
            initialSkill: skill,
            onSave: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    debugPrint('EditSkillDialog built successfully!');
  });

  test('PortfolioStateProvider authentication and guard tests', () async {
    // Initialize mock shared preferences
    SharedPreferences.setMockInitialValues({});

    final provider = PortfolioStateProvider();

    // Initial state
    expect(provider.isAdminAuthenticated, isFalse);
    expect(provider.editMode, isFalse);

    // Attempt invalid authentication
    bool success = await provider.authenticate('admin123');
    expect(success, isFalse);
    expect(provider.isAdminAuthenticated, isFalse);

    // Attempt enabling edit mode without auth
    provider.setEditMode(true);
    expect(provider.editMode, isFalse);

    // Authenticate with correct password
    success = await provider.authenticate('A1N1A1N1D1H1U1');
    expect(success, isTrue);
    expect(provider.isAdminAuthenticated, isTrue);

    // Enable edit mode now that we are authenticated
    provider.setEditMode(true);
    expect(provider.editMode, isTrue);

    // Logout
    provider.logoutAdmin();
    expect(provider.isAdminAuthenticated, isFalse);
    expect(provider.editMode, isFalse);

    // Fail authentication 5 times to trigger lockout
    for (int i = 0; i < 5; i++) {
      expect(provider.isLockoutActive, isFalse);
      await provider.authenticate('wrong_pass');
    }

    // Now lockout should be active
    expect(provider.isLockoutActive, isTrue);
    expect(provider.lockoutUntil, isNotNull);

    // Correct password should fail during active lockout
    bool successLocked = await provider.authenticate('A1N1A1N1D1H1U1');
    expect(successLocked, isFalse);
    expect(provider.isAdminAuthenticated, isFalse);
  });

  test('PortfolioStateProvider session persistence on init', () async {
    // Mock active session expiry (2 hours from now)
    final activeExpiry = DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      'admin_session_expiry': activeExpiry,
    });

    final provider = PortfolioStateProvider();
    
    // Allow async _initData to execute
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    expect(provider.isAdminAuthenticated, isTrue);
  });

  test('sanitizeUrl utility tests', () {
    expect(sanitizeUrl('www.linkedin.com/in/anandhuanil10'), 'https://www.linkedin.com/in/anandhuanil10');
    expect(sanitizeUrl('https://linkedin.com'), 'https://linkedin.com');
    expect(sanitizeUrl('http://linkedin.com'), 'http://linkedin.com');
    expect(sanitizeUrl('  github.com/AnandhuAnil  '), 'https://github.com/AnandhuAnil');
    expect(sanitizeUrl('mailto:test@gmail.com'), 'mailto:test@gmail.com');
    expect(sanitizeUrl('tel:+911234567890'), 'tel:+911234567890');
    expect(sanitizeUrl(''), '');
  });
}
