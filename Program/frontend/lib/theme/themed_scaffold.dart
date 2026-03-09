import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/templates.dart';

class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final String? title;
  final Widget child;
  final int? currentIndex;
  final void Function(int)? onTap;
  final List<Widget>? actions;
  final Widget? leading;
  final List<BottomNavigationBarItem>? navItems;
  final Widget? titleWidget;
  final Widget? bottomNavigationBar;

  const ThemedScaffold({
    super.key,
    this.appBar,
    this.title,
    required this.child,
    this.currentIndex,
    this.onTap,
    this.actions,
    this.leading,
    this.navItems,
    this.titleWidget,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final template = context.watch<TemplateProvider>().currentTemplate;

    const double customToolbarHeight = 56.0;
    final Widget? adjustedTitle = titleWidget ?? (title != null
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title!,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    )
        : null);

    // 특정 화면(달력, 타임라인, 마이페이지)에서는 뒤로가기 버튼 숨기기
    final bool hideBack = title == '달력' || title == '타임라인' || title == '마이페이지';

    // leading이 명시적으로 제공되면 사용, hideBack이 true면 null, 그 외에는 canPop에 따라 BackButton 표시
    final Widget? effectiveLeading = hideBack
        ? null
        : (leading != null
        ? leading
        : (ModalRoute.of(context)?.canPop ?? false
        ? const BackButton()
        : null));

    return Scaffold(
      backgroundColor: template.backgroundColor,
      appBar: appBar ?? AppBar(
        backgroundColor: template.appBarColor,
        automaticallyImplyLeading: false,
        leading: effectiveLeading,
        title: adjustedTitle,
        centerTitle: true,
        actions: actions,
        toolbarHeight: customToolbarHeight,
      ),
      body: SafeArea(
        child: Stack(children: [child]),
      ),
      bottomNavigationBar: bottomNavigationBar ??
          (currentIndex != null && onTap != null && navItems != null
              ? SizedBox(
            height: 67.2,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex!,
              onTap: onTap!,
              items: navItems!,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(color: Colors.black),
              unselectedLabelStyle: const TextStyle(color: Colors.black),
              elevation: 8,
              backgroundColor: Colors.white,
            ),
          )
              : null),
    );
  }
}
