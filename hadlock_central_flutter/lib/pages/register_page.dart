import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';
import 'package:hadlock_central_flutter/pages/sign_in_page.dart';

/// RegisterPage is a StatefulWidget that allows users to create an account.
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fnController = TextEditingController();
  TextEditingController lnController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  // Prevents multiple requests at the same time.
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    // Do not submit if a request is already running.
    if (_isSubmitting) {
      return;
    }

    // Check that all required fields contain information.
    if (fnController.text.trim().isEmpty ||
        lnController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showMessage('Please fill in all required fields.');
      return;
    }

    // Check that the email belongs to George Fox University.
    if (!emailController.text.trim().toLowerCase().endsWith('@georgefox.edu')) {
      _showMessage('Please use a George Fox University email (@georgefox.edu).');
      return;
    }

    // Disable the submit button while the request runs.
    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = await postData('/register', {
        'email': emailController.text.trim(),
        'firstName': fnController.text.trim(),
        'lastName': lnController.text.trim(),
        'password': passwordController.text,
      });

      if (!mounted) return;

      if (value['success'] == true) {
        // Registration was successful.
        await _showMessage(
          value['message']?.toString() ??
              'Registration successful!',
        );

        if (!mounted) return;

        // Navigate to the sign-in page.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ),
        );
      } else {
        // Registration failed; stay on the form.
        await _showMessage(
          value['message']?.toString() ??
              'Registration failed. Please try again.',
        );
      }
    } catch (error) {
      // Handle failed requests or unexpected errors.
      if (!mounted) return;

      await _showMessage(
        'Unable to complete registration. Please try again.',
      );
    } finally {
      // Allow another submission after the request finishes.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  /// Displays a dialog with the provided message.
  Future<void> _showMessage(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    fnController.dispose();
    lnController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    // The scroll view prevents the form from being cut off on small screens.
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
                        Expanded(child: _buildWelcomePanel(colors)),
                        const SizedBox(width: 48),
                        SizedBox(
                          width: 460,
                          child: _buildRegistrationCard(),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWelcomePanel(colors),
                          const SizedBox(height: 24),
                          _buildRegistrationCard(),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// A short introduction keeps registration visually connected to sign-in.
  Widget _buildWelcomePanel(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reuse the same center icon and theme color as the sign-in page.
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.sports_gymnastics,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Create your account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join Hadlock Central with your George Fox email.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// The card groups the four fields and the registration actions together.
  Widget _buildRegistrationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign up', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            // Each field keeps using the controller read by _submitRegistration.
            TextField(
              controller: fnController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'First name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: lnController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Last name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'George Fox email',
                hintText: 'name@georgefox.edu',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitRegistration(),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // The button shows progress while the existing API request runs.
            FilledButton(
              onPressed: _isSubmitting ? null : _submitRegistration,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
            ),
            const SizedBox(height: 8),
            // Existing users can return to sign-in from this link.
            // TextButton(//TODO),
          ],
        ),
      ),
    );
  }
}
