import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';
import 'package:hadlock_central_flutter/main.dart';
import 'package:hadlock_central_flutter/models/student_account.dart';
import 'package:hadlock_central_flutter/pages/register_page.dart';

/// The first screen people see when they open Hadlock Central.
/// It introduces the app and provides the sign-in/registration functionality.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  // Controllers let the submit method read what the person typed.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Stops the form from sending another request before the first one finishes.
  bool _isSubmitting = false;

  /// Sends the entered email and password to the existing login API.
  Future<void> _submitSignIn() async {
    if (_isSubmitting) return;

    // Keep the original validation, including rejecting whitespace-only passwords.
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      await _showMessage('Please enter your email and password.');
      return;
    }

    /// Disable the Login button during the request.
    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = await postData('/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (!mounted) return;

      if (value['success'] == true) {
        final user = value['user'];
        if (user is! Map<String, dynamic>) {
          await _showMessage('Your account details could not be loaded.');
          return;
        }

        final account = StudentAccount.fromJson(user);
        await _showMessage(value['message']?.toString() ?? 'Login successful!');
        if (!mounted) return;

        // Replace sign-in with the app so Back does not return to this screen.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppShell(account: account)),
        );
      } else {
        await _showMessage(
          value['message']?.toString() ??
              'Login failed. Please check your credentials.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      await _showMessage('Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Shows a small dialog for form feedback, such as a failed sign-in.
  Future<void> _showMessage(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    // A scroll view keeps the form usable on short screens and small phones.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _WelcomePanel(colors: colors)),
                        const SizedBox(width: 48),
                        SizedBox(width: 400, child: _buildSignInCard(colors)),
                      ],
                    )
                  : Column(
                      children: [
                        _WelcomePanel(colors: colors),
                        const SizedBox(height: 28),
                        _buildSignInCard(colors),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the white card that contains the sign-in fields and actions.
  Widget _buildSignInCard(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign in', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Use your George Fox account to continue.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Each field uses a label, a helpful icon, and a clear hint.
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'name@georgefox.edu',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitSignIn(),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            // The progress indicator tells people the login request is working.
            FilledButton(
              onPressed: _isSubmitting ? null : _submitSignIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 8),
            // New visitors can open the registration screen from here.
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
              child: const Text('Create an account here'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple introduction panel that describes what the app offers.
class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The icon is a temporary brand mark made from a built-in Material icon.
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.sports_gymnastics,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Hadlock Central',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your new easy access to Hadlock Student Center.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Find what\'s happening, plan your visit, and explore equipment '
          'available at the center.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 24),
        // These short labels give visitors a quick preview of the app sections.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _FeatureTag(
              icon: Icons.calendar_month_outlined,
              label: 'See the schedule',
            ),
            _FeatureTag(
              icon: Icons.sports_basketball_outlined,
              label: 'Reserve equipment',
            ),
            _FeatureTag(
              icon: Icons.campaign_outlined,
              label: 'Find announcements',
            ),
          ],
        ),
      ],
    );
  }
}

/// A small rounded label for one feature preview in the welcome panel.
class _FeatureTag extends StatelessWidget {
  const _FeatureTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: colors.primary),
      label: Text(label),
      side: BorderSide(color: colors.outlineVariant),
      backgroundColor: colors.surface,
    );
  }
}
