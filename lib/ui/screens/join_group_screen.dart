import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';

class JoinGroupScreen extends StatefulWidget {
  final String initialCode;
  const JoinGroupScreen({super.key, this.initialCode = ''});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  late final TextEditingController _codeCtrl;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.initialCode);
    if (widget.initialCode.length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoJoinWhenReady());
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _autoJoinWhenReady() {
    final auth = context.read<AuthProvider>();
    if (auth.status != AuthStatus.unknown) {
      _join();
      return;
    }
    // Auth pas encore résolu (cold start via deep link) → attendre
    late VoidCallback listener;
    listener = () {
      if (auth.status != AuthStatus.unknown) {
        auth.removeListener(listener);
        if (mounted) _join();
      }
    };
    auth.addListener(listener);
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit faire 6 caractères.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.uid == null) {
      setState(() => _isJoining = true);
      final ok = await auth.signInWithGoogle();
      if (!mounted) return;
      if (!ok) {
        setState(() => _isJoining = false);
        return;
      }
    }

    setState(() => _isJoining = true);

    final groupsProvider = context.read<GroupsProvider>();
    final plansProvider = context.read<PlansProvider>();

    final result = await groupsProvider.joinGroup(
      inviteCode: code,
      userId: auth.uid!,
      displayName: auth.displayName,
      avatarUrl: auth.avatarUrl,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => _isJoining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(groupsProvider.error ?? 'Code invalide ou expiré.')),
      );
      groupsProvider.clearError();
      return;
    }

    // Sauvegarde le plan reconstruit dans Hive
    await plansProvider.importGroupPlan(result.plan);

    if (!mounted) return;
    context.go('/group/${result.group.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un groupe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.seedGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group_add_outlined,
                    size: 36, color: AppTheme.seedGold),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Entrez le code d\'invitation',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Demandez le code à l\'administrateur de votre groupe.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55), height: 1.5),
            ),
            const SizedBox(height: 32),

            // Champ code
            TextFormField(
              controller: _codeCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: AppTheme.seedGold,
                  ),
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                      color: cs.onSurface.withValues(alpha: 0.2),
                    ),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed:
                    (_isJoining || _codeCtrl.text.trim().length != 6)
                        ? null
                        : _join,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.seedGold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.seedGold.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isJoining
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Rejoindre',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
