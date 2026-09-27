import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onComplete;
  final String localeCode;
  final Future<void> Function(String) onLocaleCodeChanged;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.localeCode = 'ru',
    this.onLocaleCodeChanged = _ignoreLocaleChange,
  });

  static Future<void> _ignoreLocaleChange(String _) async {}

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _saving = false;
  late String _localeCode = widget.localeCode;

  @override
  void didUpdateWidget(covariant OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localeCode != widget.localeCode) {
      _localeCode = widget.localeCode;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectLocale(String code) async {
    final previous = _localeCode;
    setState(() => _localeCode = code);
    try {
      await widget.onLocaleCodeChanged(code);
    } catch (_) {
      if (!mounted) return;
      setState(() => _localeCode = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.localeSaveError)),
      );
    }
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      await widget.onComplete();
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.onboardingSaveError),
          backgroundColor: context.floraqua.error,
        ),
      );
    }
  }

  void _next() {
    if (_page == 2) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  String _titleForPage(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.onboardingTitle1,
      1 => l10n.onboardingTitle2,
      _ => l10n.onboardingTitle3,
    };
  }

  String _descriptionForPage(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.onboardingDescription1,
      1 => l10n.onboardingDescription2,
      _ => l10n.onboardingDescription3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const icons = [
      Icons.eco_rounded,
      Icons.water_drop_rounded,
      Icons.notifications_active_rounded,
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.spa_rounded, color: context.floraqua.primary),
                      const SizedBox(width: 8),
                      Text(
                        'FLORAQUA',
                        style: TextStyle(
                          color: context.floraqua.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _localeCode,
                          icon: const Icon(Icons.language_rounded),
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: 'ru',
                              child: Text(l10n.languageRussian),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.languageEnglish),
                            ),
                          ],
                          onChanged: _saving
                              ? null
                              : (code) {
                                  if (code != null) _selectLocale(code);
                                },
                        ),
                      ),
                      TextButton(
                        onPressed: _saving ? null : _complete,
                        child: Text(l10n.onboardingSkip),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) => LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 156,
                                    height: 156,
                                    decoration: BoxDecoration(
                                      color: context.floraqua.primaryLight,
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    child: Icon(
                                      icons[index],
                                      size: 78,
                                      color: context.floraqua.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    _titleForPage(context, index),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _descriptionForPage(context, index),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: context.floraqua.textSecondary,
                                          height: 1.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < 3; index++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _page
                                ? context.floraqua.primary
                                : context.floraqua.divider,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _next,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_page == 2
                              ? l10n.onboardingFinish
                              : l10n.onboardingNext),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingProgress(_page + 1, 3),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.floraqua.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
