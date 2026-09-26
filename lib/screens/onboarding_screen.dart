import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _saving = false;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.eco_rounded,
      title: 'Ваш сад — в одном месте',
      description:
          'Добавляйте любимые растения и находите их по фото. Floraqua сохранит карточки и важную информацию о каждом.',
    ),
    _OnboardingPageData(
      icon: Icons.water_drop_rounded,
      title: 'Уход с учётом сезона',
      description:
          'Для растений есть подсказки и ориентиры по поливу. Перед поливом всё равно проверяйте влажность грунта.',
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active_rounded,
      title: 'Напоминания под ваш ритм',
      description:
          'Выберите удобное время уведомлений. Для распознавания растений понадобится ваш личный ключ Gemini — он хранится на этом устройстве.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      await widget.onComplete();
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить первый запуск: $error'),
          backgroundColor: context.floraqua.error,
        ),
      );
    }
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      TextButton(
                        onPressed: _saving ? null : _complete,
                        child: const Text('Пропустить'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) {
                        final item = _pages[index];
                        return LayoutBuilder(
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
                                        item.icon,
                                        size: 78,
                                        color: context.floraqua.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      item.title,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item.description,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: context
                                                .floraqua.textSecondary,
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < _pages.length; index++)
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
                          : Text(
                              _page == _pages.length - 1
                                  ? 'Перейти к настройке ключа'
                                  : 'Дальше',
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_page + 1} из ${_pages.length}',
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

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
