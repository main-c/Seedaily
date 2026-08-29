import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/plans_provider.dart';
import 'home_screen.dart';
import 'create_plan_screen.dart';
import 'settings_screen.dart';

final GlobalKey<MainShellScreenState> mainShellKey =
    GlobalKey<MainShellScreenState>();

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final bool showTourOnLoad;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.showTourOnLoad = false,
  });

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  bool _tourStarted = false;

  // GlobalKeys for coach marks
  final _keyFab = GlobalKey();
  final _keyTabHome = GlobalKey();
  final _keyTabDiscover = GlobalKey();
  final _keyTabSettings = GlobalKey();
  final _keyCustomPlanBtn = GlobalKey();
  final _keyTemplateSection = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (widget.showTourOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) => startTour(context));
    }
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToDiscover() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void startTour(BuildContext ctx, {bool force = false}) {
    if (_tourStarted && !force) return;
    _tourStarted = true;

    // Go to home tab first so FAB is visible
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _launchHomeTour(ctx));
      return;
    }
    _launchHomeTour(ctx);
  }

  Widget _skipWidget() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Passer',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );

  void _launchHomeTour(BuildContext ctx) {
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'fab',
          keyTarget: _keyFab,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _TourContent(
                title: 'Créer un plan',
                body:
                    'Appuyez sur ce bouton pour accéder à la page Découvrir et choisir un modèle de plan.',
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'tabDiscover',
          keyTarget: _keyTabDiscover,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _TourContent(
                title: 'Découvrir',
                body:
                    'Retrouvez ici tous les modèles disponibles. Continuons pour les explorer.',
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'tabSettings',
          keyTarget: _keyTabSettings,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: _TourContent(
                title: 'Réglages',
                body:
                    'Thème clair / sombre, rappels quotidiens, et préférences de lecture.',
              ),
            ),
          ],
        ),
      ],
      colorShadow: AppTheme.deepNavy,
      opacityShadow: 0.88,
      skipWidget: _skipWidget(),
      onFinish: () {
        // Enchaîner sur l'onglet Découvrir
        setState(() => _currentIndex = 1);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _launchDiscoverTour(ctx));
      },
      onSkip: () {
        _onTourDone();
        return true;
      },
    ).show(context: ctx);
  }

  void _launchDiscoverTour(BuildContext ctx) {
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'customPlanBtn',
          keyTarget: _keyCustomPlanBtn,
          shape: ShapeLightFocus.RRect,
          radius: 14,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: _TourContent(
                title: 'Plan personnalisé',
                body:
                    'Créez un plan sur mesure : choisissez vous-même les livres, la durée, le rythme et les jours de lecture.',
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'templateSection',
          keyTarget: _keyTemplateSection,
          shape: ShapeLightFocus.RRect,
          radius: 10,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: _TourContent(
                title: 'Modèles prêts à l\'emploi',
                body:
                    'Plans structurés (M\'Cheyne, Horner…) et thématiques (Évangiles, Psaumes…) — choisissez et c\'est parti.',
              ),
            ),
          ],
        ),
      ],
      colorShadow: AppTheme.deepNavy,
      opacityShadow: 0.88,
      skipWidget: _skipWidget(),
      onFinish: _onTourDone,
      onSkip: () {
        _onTourDone();
        return true;
      },
    ).show(context: ctx);
  }

  void _onTourDone() {
    context.read<SettingsProvider>().markOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    final plansProvider = context.watch<PlansProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToDiscover: _navigateToDiscover),
          CreatePlanScreen(
            customPlanBtnKey: _keyCustomPlanBtn,
            templateSectionKey: _keyTemplateSection,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  itemKey: _keyTabHome,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Accueil',
                ),
                _buildNavItem(
                  itemKey: _keyTabDiscover,
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Découvrir',
                ),
                _buildNavItem(
                  itemKey: _keyTabSettings,
                  index: 2,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Réglages',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (_currentIndex == 0 && plansProvider.plans.isNotEmpty)
          ? FloatingActionButton(
              key: _keyFab,
              heroTag: 'fab_home',
              onPressed: _navigateToDiscover,
              backgroundColor: AppTheme.seedGold,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildNavItem({
    required Key itemKey,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      key: itemKey,
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppTheme.seedGold
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.seedGold
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourContent extends StatelessWidget {
  final String title;
  final String body;

  const _TourContent({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
