import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/System/system.dart';

class RootLayout extends StatefulWidget {
  final Widget child;
  const RootLayout({required this.child, super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactNav = System.isMobile || screenWidth < 1050;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final isHome = GoRouterState.of(context).uri.path == '/';
              final isAtTop = constraints.scrollOffset <= 100;
              final shouldRound = !isHome || !isAtTop;
              return SliverAppBar(
                shape: shouldRound
                    ? const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      )
                    : null,
                clipBehavior: Clip.antiAlias,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                pinned: false,
                floating: true,
                snap: true,
                titleSpacing: 0,
                title: const SizedBox.shrink(),
                toolbarHeight: useCompactNav ? 70 : 80,
                leadingWidth: useCompactNav ? 190 : 300,
                actionsPadding: EdgeInsets.symmetric(
                  horizontal: useCompactNav ? 20 : 40,
                ),
                leading: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () => context.go('/'),
                  child: Row(
                    crossAxisAlignment: .center,
                    mainAxisAlignment: .end,
                    children: [
                      Container(
                        //margin: EdgeInsets.only(top: 10),
                        width: useCompactNav ? 48 : 65,
                        height: useCompactNav ? 48 : 65,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: .circle,
                        ),
                        // logo.svg
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: System.isMobile ? 48 : 65,
                          height: System.isMobile ? 48 : 65,
                        )
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                'TEX PRINT',
                                style: TextStyle(
                                  fontSize: useCompactNav ? 22 : 36,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: useCompactNav ? 4 :8,left: useCompactNav ? 2 : 4),
                                child: SvgPicture.asset(
                                  'assets/images/icons/registered.svg',
                                  width: useCompactNav ? 8 : 12,
                                  height: useCompactNav ? 8 : 12,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  useCompactNav
                      ? Builder(
                    builder: (context) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final box =
                          context.findRenderObject() as RenderBox;
                          final pos = box.localToGlobal(Offset.zero);
                          showTopMenu(
                            context,
                            buttonPos: pos,
                            buttonSize: box.size,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(Icons.menu_rounded, size: 30),
                        ),
                      );
                    },
                  )
                      : Navbar(),
                ],

              );
            },
          ),
          SliverToBoxAdapter(child: widget.child),
        ],
      ),
    );
  }
}

Future<void> showTopMenu(
  BuildContext context, {
  required Offset buttonPos,
  required Size buttonSize,
}) async {
  final route = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'menu',
    barrierColor: Colors.transparent, // no dim, only shadow
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 140),
    transitionBuilder: (ctx, anim, _, child) {
      final theme = Theme.of(ctx);
      final bg = theme.colorScheme.secondary;

      // Menu position: directly under the button
      final top = buttonPos.dy + buttonSize.height + 25;
      final left = buttonPos.dx - 60;
      const width = 100.0;

      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: Stack(
          children: [
            // tap outside to close
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.pop(ctx)),
            ),

            Positioned(
              top: top,
              left: left,
              width: width,
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(90),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(-1, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItem(title: 'Home', route: '/'),
                        _MenuItem(title: 'About', route: '/?section=about'),
                        _MenuItem(title: 'Products', route: '/products'),
                        _MenuItem(title: 'Contact', route: '/contact'),
                        _MenuItem(title: 'Events', route: '/?section=events'),
                        _MenuItem(title: 'Admin', route: '/admin'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (route != null && context.mounted) {
    if (route == '/admin') {
      showAdminAuthDialog(context);
    } else {
      context.go(route);
    }
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.title, required this.route});
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          _NavButton(
            title: 'Home',
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'About',
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
            section: 'about',
          ),
          _NavButton(
            title: 'Products',
            route: '/products',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'Contact',
            route: '/contact',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'Events',
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
            section: 'events',
          ),
          _NavButton(
            title: 'Admin',
            route: '/admin',
            currentRoute: GoRouterState.of(context).uri.path,
            onTapOverride: () => showAdminAuthDialog(context),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final String route;
  final String currentRoute;
  final String? section;
  final VoidCallback? onTapOverride;

  const _NavButton({
    required this.title,
    required this.route,
    required this.currentRoute,
    this.section,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final isSelected = section == null && currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () {
          if (onTapOverride != null) {
            onTapOverride!();
            return;
          }
          if (section != null) {
            context.go('/?section=$section');
            return;
          }
          if (!isSelected) {
            context.go(route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white60 : Colors.white,
              fontWeight: FontWeight.w200,
              fontSize: screenWidth < 1050 ? 25 : 32,
            ),
          ),
        ),
      ),
    );
  }
}


// ── Admin Auth Dialog ──────────────────────────────────────────────────────

Future<void> showAdminAuthDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AdminAuthDialog(),
  );
}

class _AdminAuthDialog extends StatefulWidget {
  const _AdminAuthDialog();

  @override
  State<_AdminAuthDialog> createState() => _AdminAuthDialogState();
}

class _AdminAuthDialogState extends State<_AdminAuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get _isSignedIn =>
      Supabase.instance.client.auth.currentUser != null;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(
          () => _errorMessage = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _authErrorMessage(e);
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sign out failed. Please try again.';
        });
      }
    }
  }

  String _authErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials') ||
        msg.contains('invalid_grant')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (msg.contains('Too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('network') || msg.contains('SocketException')) {
      return 'Network error. Check your connection and try again.';
    }
    return 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signedIn = _isSignedIn;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.admin_panel_settings,
              color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(signedIn ? 'Admin' : 'Admin Sign In'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: theme.colorScheme.error.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: theme.colorScheme.error, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!signedIn) ...[
                _labeledField(
                  label: 'Email',
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onPrimary),
                    decoration: _fieldDecoration(),
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  label: 'Password',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _signIn(),
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onPrimary),
                    decoration: _fieldDecoration().copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Text('Signed in as:',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  Supabase.instance.client.auth.currentUser!.email ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      actions: _isLoading
          ? [
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ]
          : signedIn
              ? [
                  TextButton(
                    onPressed: _signOut,
                    child: Text('Sign Out',
                        style:
                            TextStyle(color: theme.colorScheme.error)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go('/admin');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Go to Admin Page'),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sign In'),
                  ),
                ],
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF909398)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
      ),
    );
  }
}
