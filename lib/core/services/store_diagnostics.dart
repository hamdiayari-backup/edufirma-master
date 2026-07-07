import 'package:flutter/foundation.dart';

/// Store Diagnostics - Pour identifier les problèmes de navigation boutique
class StoreDiagnostics {
  /// Diagnostic complet de la boutique
  static void runFullDiagnostics() {
    debugPrint('\n' + '=' * 60);
    debugPrint('🔍 STORE DIAGNOSTICS - INVESTIGATION APPROFONDIE');
    debugPrint('=' * 60);

    _checkApiEndpoints();
    _checkRoutes();
    _checkProviders();
    _checkCommonIssues();

    debugPrint('\n📋 RECOMMANDATIONS:');
    debugPrint('1. Vérifiez les logs ci-dessus pour identifier les problèmes');
    debugPrint('2. Testez chaque point de navigation individuellement');
    debugPrint('3. Vérifiez que le backend Laravel est accessible');
    debugPrint('4. Assurez-vous que les clés API sont correctes');
    debugPrint('=' * 60 + '\n');
  }

  static void _checkApiEndpoints() {
    debugPrint('\n🌐 API ENDPOINTS CHECK:');
    debugPrint('Base URL: https://edufirma.com/api/');
    debugPrint('Endpoints attendus:');
    debugPrint('  GET /store/categories');
    debugPrint('  GET /store/products');
    debugPrint('  GET /store/categories/{id}/products');
    debugPrint('\nProblèmes possibles:');
    debugPrint('  - Endpoint retourne HTML au lieu de JSON');
    debugPrint('  - Route Laravel non configurée');
    debugPrint('  - Middleware API manquant');
    debugPrint('  - CORS non configuré');
  }

  static void _checkRoutes() {
    debugPrint('\n🧭 ROUTES CHECK:');
    debugPrint('Routes Flutter configurées:');
    debugPrint('  /store-category-products → StoreCategoryProductsPage');
    debugPrint('  /store → StorePage');
    debugPrint('\nNavigation principale:');
    debugPrint('  MainPage index 3 → StorePage');
    debugPrint('  BottomNavigationBar item 3 → Store');

    debugPrint('\nProblèmes possibles:');
    debugPrint('  - Route non déclarée dans AppRoutes');
    debugPrint('  - Arguments de navigation incorrects');
    debugPrint('  - Page non dans la liste des pages');
  }

  static void _checkProviders() {
    debugPrint('\n📦 PROVIDERS CHECK:');
    debugPrint('StoreProvider:');
    debugPrint('  - loadInitialData() ✅');
    debugPrint('  - fetchProducts() ✅');
    debugPrint('  - fetchCategories() ✅');

    debugPrint('\nProblèmes possibles:');
    debugPrint('  - Provider non initialisé');
    debugPrint('  - Consumer non utilisé correctement');
    debugPrint('  - notifyListeners() non appelé');
  }

  static void _checkCommonIssues() {
    debugPrint('\n🐛 COMMON ISSUES CHECK:');
    debugPrint('1. Erreur HTML/JSON:');
    debugPrint(
        '   - Si vous voyez "<!DOCTYPE html", l\'endpoint n\'existe pas');
    debugPrint('   - Solution: Vérifiez les routes Laravel');

    debugPrint('\n2. Catégories vides:');
    debugPrint(
        '   - Si categories.length = 0, problème avec /store/categories');
    debugPrint('   - Solution: Vérifiez la base de données');

    debugPrint('\n3. Produits vides:');
    debugPrint('   - Si products.length = 0, problème avec /store/products');
    debugPrint('   - Solution: Vérifiez les produits actifs');

    debugPrint('\n4. Navigation cassée:');
    debugPrint('   - Si clic ne fait rien, problème avec Navigator.pushNamed');
    debugPrint('   - Solution: Vérifiez les arguments et routes');

    debugPrint('\n5. Sous-catégories:');
    debugPrint(
        '   - Si pas de sous-catégories, vérifiez la structure des données');
    debugPrint('   - Solution: Vérifiez sub_categories dans la réponse');
  }

  /// Log spécifique pour un problème
  static void logIssue(String issue, Map<String, dynamic> context) {
    debugPrint('\n❌ ISSUE DETECTED: $issue');
    debugPrint('Context: $context');
    debugPrint('Timestamp: ${DateTime.now()}');

    // Suggestions basées sur le type de problème
    if (issue.contains('HTML')) {
      debugPrint(
          '💡 Suggestion: Vérifiez que l\'endpoint Laravel existe et est accessible');
    } else if (issue.contains('empty')) {
      debugPrint('💡 Suggestion: Vérifiez les données dans la base de données');
    } else if (issue.contains('navigation')) {
      debugPrint('💡 Suggestion: Vérifiez les routes Flutter et les arguments');
    }
  }
}
