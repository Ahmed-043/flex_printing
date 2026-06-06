import 'package:flex_printing/models/System/system.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared_widgets/ui_helper.dart';

class ContactusPage extends StatefulWidget {
  const ContactusPage({super.key});

  @override
  State<ContactusPage> createState() => _ContactusPageState();
}

class _ContactusPageState extends State<ContactusPage> {
  bool compact = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    serviceController.dispose();
    messageController.dispose();
    super.dispose();
  }
  
  Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return;
    String url = 'https://wa.me/$normalized';
    if (message != null) {
      url += '?text=${Uri.encodeComponent(message)}';
    }
    await openSocial(url);
  }
  Future<void> openSocial(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    compact = MediaQuery.of(context).size.width < 1200 ;
    final theme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Center(
            child: compact
                ? _form(context)
                : Container(
              width: 1150,
              padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 20 : 50, vertical: 28),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: _form(context),
            ),
          ),
        ),
      ),
    );
  }
  Widget _form(BuildContext context){
    final theme = Theme.of(context).colorScheme;
    Widget leftColumn() {
      return SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: .start,
          children: [
            SizedBox(
              width: compact ? 500 : 1050,
              child: Text(
                'Send us a Message',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            UiHelper.inputField(
              context: context,
              label: 'Full Name',
              requiredField: true,
              hint: 'John Doe',
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 22),
            UiHelper.inputField(
              context: context,
              label: 'Email Address',
              requiredField: false,
              hint: 'john@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            // const SizedBox(height: 22),
            // UiHelper.inputField(
            //   context: context,
            //   label: 'Phone Number',
            //   hint: '+1 (555) 123-4567',
            //   keyboardType: TextInputType.phone,
            // ),
            const SizedBox(height: 22),
            UiHelper.inputField(
              context: context,
              label: 'Service Interested In',
              requiredField: false,
              hint: 'Ex: Digital Printing',
              controller: serviceController,
            ),
          ],
        ),
      );
    }

    Widget rightColumn() {
      return SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            UiHelper.inputField(
              context: context,
              label: 'Message',
              requiredField: false,
              hint: 'Tell us about your project...',
              maxLines: 8,
              controller: messageController,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: compact ? 35 : 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: UiHelper.button(
                callback: () {
                  final String name = nameController.text.trim();
                  final String email = emailController.text.trim();
                  final String service = serviceController.text.trim();
                  final String message = messageController.text.trim();

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please fill in the required field (Name)'),
                        backgroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    );
                    return;
                  }

                  String whatsappMessage = "Hello, I'm reaching out from the contact form on your website texprinttp.com.\n\n";
                  whatsappMessage += "*Name:* $name\n";
                  if (email.isNotEmpty) whatsappMessage += "*Email:* $email\n\n";
                  if (service.isNotEmpty) whatsappMessage += "*Inquiry:* I'm interested in your services for *$service*.\n";
                  whatsappMessage += "*Message:*\n$message";

                  openWhatsApp('+92 312 7665130', message: whatsappMessage);
                },
                filled: true,
                color: Colors.black,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.send, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 50,
        crossAxisAlignment: .start,
        runAlignment: .center,
        alignment: .center,
        children: [
          leftColumn(),
          rightColumn(),
        ],
      ),
    );
  }
}
