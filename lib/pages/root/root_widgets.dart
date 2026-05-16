
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MenuItem extends StatelessWidget {
  const MenuItem({super.key, required this.title, required this.route});
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Material(
      color: theme.secondary,
      child: InkWell(
        splashColor: theme.onSecondary.withAlpha(100),
        highlightColor: Colors.transparent,
        hoverColor: theme.onSecondary.withAlpha(50),
        onTap: () {
          Navigator.pop(context, route);
        },
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 1.2,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


class NavButton extends StatelessWidget {
  final String title;
  final String route;
  final String currentRoute;
  final String? section;
  final VoidCallback? onTapOverride;
  final VoidCallback? onTapWhileSelected;

  const NavButton({
    super.key,
    required this.title,
    required this.route,
    required this.currentRoute,
    this.section,
    this.onTapOverride,
    this.onTapWhileSelected,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Match exact route or route prefix (e.g., /admin/create-product matches /admin)
    final isSelected = section == null &&
        (currentRoute == route || currentRoute.startsWith('$route/'));

    return HoverRotate(
      degrees: 10,
      uniDirectional: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
      
          onTap: () {
            if (onTapOverride != null && !isSelected) {
              onTapOverride!();
              return;
            }
            if (isSelected && onTapWhileSelected != null) {
              onTapWhileSelected!();
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
                color: Colors.white,
                fontWeight: FontWeight.w200,
      
                fontSize: screenWidth < 1050 ? 25 : 32,
              ),
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
    builder: (_) =>  AdminAuthDialog(),
  );
}

class AdminAuthDialog extends StatefulWidget {
  final VoidCallback ? onSuccess;
  const AdminAuthDialog({super.key, this.onSuccess});

  @override
  State<AdminAuthDialog> createState() => _AdminAuthDialogState();
}

class _AdminAuthDialogState extends State<AdminAuthDialog> {
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
      if (mounted) {
        setState(() {
        _isLoading = false;
      });
      widget.onSuccess?.call();
      }
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
      backgroundColor: theme.colorScheme.onPrimary.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.admin_panel_settings,
              color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Text(signedIn ? 'Admin' : 'Admin Sign In',style: TextStyle(color: theme.colorScheme.onSecondary),),
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
                    cursorColor:  theme.colorScheme.onSecondary,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSecondary),
                    decoration: _fieldDecoration(),
                  ),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  label: 'Password',
                  child: TextField(

                    cursorColor:  theme.colorScheme.onSecondary,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _signIn(),
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSecondary),
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
                        fontSize: 14, color: theme.colorScheme.surfaceContainer)),
                const SizedBox(height: 4),
                Text(
                  Supabase.instance.client.auth.currentUser!.email ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400,letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      actions: _isLoading
          ? [
         Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5,color: theme.colorScheme.secondary.withAlpha(200)),
          ),
        ),
      ]
          : signedIn
          ? [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            backgroundColor: theme.colorScheme.errorContainer.withAlpha(20),
          ),
          onPressed: _signOut,
          child: Text('Sign Out',
              style:
              TextStyle(color: theme.colorScheme.secondary)),
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
    final theme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: theme.onSecondary,
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
