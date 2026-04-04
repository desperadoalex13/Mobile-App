import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(child: Text(l10n.comingSoon));
  }
}
