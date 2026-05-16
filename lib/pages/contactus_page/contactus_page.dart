import 'package:flex_printing/models/System/system.dart';
import 'package:flutter/material.dart';

import '../../shared_widgets/ui_helper.dart';

class ContactusPage extends StatefulWidget {
  const ContactusPage({super.key});

  @override
  State<ContactusPage> createState() => _ContactusPageState();
}

class _ContactusPageState extends State<ContactusPage> {
  bool compact = false;
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
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 35),
            UiHelper.inputField(
              context: context,
              label: 'Email Address',
              requiredField: true,
              hint: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 22),
            UiHelper.inputField(
              context: context,
              label: 'Phone Number',
              hint: '+1 (555) 123-4567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 22),
            UiHelper.inputField(
              context: context,
              label: 'Service Interested In',
              requiredField: true,
              hint: 'Ex: Digital Printing',
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
              requiredField: true,
              hint: 'Tell us about your project...',
              maxLines: 8,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: compact ? 35 : 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: UiHelper.button(
                callback: () {},
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
        crossAxisAlignment: .center,
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
