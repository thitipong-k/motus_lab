import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:motus_lab/core/protocol/protocol_engine.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_theme.dart';
import 'package:motus_lab/core/theme/app_style.dart';
import 'package:motus_lab/features/service/presentation/pages/service_catalog_page.dart';
import 'package:motus_lab/features/crm/presentation/pages/customer_list_page.dart';
import 'package:motus_lab/features/remote/presentation/pages/remote_expert_page.dart';
import 'package:motus_lab/features/profile/presentation/pages/wallet_page.dart';

void main() {
  // ตั้งค่า Locator ก่อนรันทดสอบ (ใช้ Mock หรือ Setup จริงที่ปรับจูนแล้ว)
  setUpAll(() {
    final locator = GetIt.instance;
    if (!locator.isRegistered<ProtocolEngine>()) {
      setupLocator();
    }
  });

  group('UI Screens Verification (การทดสอบหน้าจอต่างๆ)', () {
    testWidgets('Service Catalog Page should display maintenance items',
        (WidgetTester tester) async {
      // ทดสอบหน้าจอเลือกงานบริการ
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.getTheme(AppStyle.cyberpunk),
        home: const ServiceCatalogPage(),
      ));

      expect(find.text('SERVICE FUNCTIONS'), findsOneWidget);
      expect(find.text('OIL RESET'), findsOneWidget);
      expect(find.text('EPB SERVICE'), findsOneWidget);

      // ทดสอบการกดเลือก
      await tester.tap(find.text('OIL RESET'));
      await tester.pumpAndSettle();

      expect(find.textContaining('เริ่มขั้นตอน'), findsOneWidget);
    });

    testWidgets('Customer List Page should display workshop clients',
        (WidgetTester tester) async {
      // ทดสอบหน้าจอจัดการลูกค้า
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.getTheme(AppStyle.cyberpunk),
        home: const CustomerListPage(),
      ));

      expect(find.text('WORKSHOP CRM'), findsOneWidget);
      expect(find.text('สมชาย รักรถ'), findsOneWidget);

      // ทดสอบการเปิดประวัติ (History)
      await tester.tap(find.text('สมชาย รักรถ'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ประวัติของ'), findsOneWidget);
    });

    testWidgets('Remote Expert Page should show session code',
        (WidgetTester tester) async {
      // ทดสอบหน้าจอ Remote Expert
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.getTheme(AppStyle.cyberpunk),
        home: const RemoteExpertPage(),
      ));

      expect(find.text('REMOTE EXPERT'), findsOneWidget);
      expect(find.text('MOTUS-889-X'), findsOneWidget);
      expect(find.text('START SMARTLINK'), findsOneWidget);
    });

    testWidgets('Wallet Page should display credit balance',
        (WidgetTester tester) async {
      // ทดสอบหน้าจอประเป๋าเงิน
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.getTheme(AppStyle.cyberpunk),
        home: const WalletPage(),
      ));

      expect(find.text('MY WALLET'), findsOneWidget);
      expect(find.textContaining('Credits'), findsOneWidget);
      expect(find.text('TOP UP CREDITS'), findsOneWidget);
    });
  });
}
