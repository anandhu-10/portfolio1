import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/portfolio_state_model.dart';
import 'package:portfolio/providers/portfolio_state_provider.dart';
import 'package:portfolio/widgets/admin/edit_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
