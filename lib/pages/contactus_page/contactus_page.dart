import 'package:flex_printing/models/System/system.dart';
import 'package:flutter/material.dart';

import '../../shared_widgets/ui_helper.dart';

class ContactusPage extends StatefulWidget {
  const ContactusPage({super.key});

  @override
  State<ContactusPage> createState() => _ContactusPageState();
}

class _ContactusPageState extends State<ContactusPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide ? 1100.0 : constraints.maxWidth - 32;

        Widget leftColumn() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiHelper.inputField(
                context: context,
                label: 'Full Name',
                requiredField: true,
                hint: 'John Doe',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 22),
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
          );
        }

        Widget rightColumn() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiHelper.inputField(
                context: context,
                label: 'Message',
                requiredField: true,
                hint: 'Tell us about your project...',
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: isWide ? 360 : double.infinity,
                height: 56,
                child: UiHelper.button(
                  callback: () {},
                  filled: true,
                  color: Colors.black,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.send, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send us a Message',
                    style: TextStyle(
                      fontSize: isWide ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftColumn()),
                        const SizedBox(width: 36),
                        Expanded(child: rightColumn()),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftColumn(),
                        const SizedBox(height: 22),
                        rightColumn(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
