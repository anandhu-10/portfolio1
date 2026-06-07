import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/portfolio_state_model.dart';
import 'package:portfolio/widgets/admin/edit_dialogs.dart';

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
}
