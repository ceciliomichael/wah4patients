import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/ui/buttons/primary_button_widget.dart';

class PrivacyStatementScreen extends StatelessWidget {
  const PrivacyStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            mediaQuery.viewInsets.bottom + 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      splashRadius: 20,
                      tooltip: 'Back',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Privacy Statement',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 38.0 : 30.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Effective Date: August 1, 2026',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'WAH for Patients (WAH4P) respects your individual privacy and protects any personal information that you share with us. We commit to secure the individual\'s right to privacy and ensure the trustworthiness of processing of individual\'s personal information.\n\n'
                    'WAH for Patients (WAH4P) strives to comply with the Data Privacy Act of 2012 that is designed to protect your privacy. We intend to adhere to the principles set forth in this Privacy Statement and recognize your need for appropriate protection and management of any personal information. In other words, our goal is to provide protection for your privacy regardless of what types of device or application to access our Services. By using our Services, you consent to the collection, storage, processing, transferring, disclosure, and other usage of the Information described in this Privacy Statement and Terms of Service Agreement.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  ..._privacySections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _PrivacySection(section: section),
                    );
                  }),
                  const SizedBox(height: 8),
                  PrimaryButtonWidget(
                    text: 'Back to Profile',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        AppRoutes.profile,
                      );
                    },
                    icon: Icons.arrow_forward,
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

class _PrivacySectionData {
  const _PrivacySectionData({required this.title, required this.body});

  final String title;
  final String body;
}

const List<_PrivacySectionData> _privacySections = <_PrivacySectionData>[
  _PrivacySectionData(
    title: '1. Personal Data Collected',
    body:
        'We may collect, store and process the following information:\n'
        '• Personal data and employment details\n'
        '• Contact information including email address\n'
        '• Demographic information such as postcode, preferences and interests\n'
        '• Other information relevant to individual\'s request and/or offers',
  ),
  _PrivacySectionData(
    title: '2. Purpose of Collected Data',
    body:
        'You consent that your collected Personal Information may be used:\n'
        '• To improve healthcare service delivery and enhance patient care;\n'
        '• To help improve our data and services and customize user experience;\n'
        '• To participate in and facilitate transactions;\n'
        '• To engage in data mining and build up activities;\n'
        '• To deliver the products and services that you have requested;\n'
        '• To perform research and analysis about your use of, or interest in, our products, services, or content, or products, services or content offered by others;\n'
        '• To communicate about relevant services, ads and/or advisories through whichever means are available the Provincial Government;\n'
        '• To provide better customer experience to the Provincial Government clients and improve, develop, identify and implement services;\n'
        '• To follow safety, security, public service or legal requirements and processes;\n'
        '• To process information for statistical, analytical, and research purposes;\n'
        '• To identify and prevent errors and inefficiencies due to misuse of the platform; andR\n'
        '• To enforce our terms and conditions;',
  ),
  _PrivacySectionData(
    title: '3. How data is collected',
    body:
        'Wireless Access for Health utilizes a registration website to collect personal information from healthcare providers. The registration website serves as a platform where individuals can provide their personal details, such as name, contact information and other relevant information necessary for effective health care service delivery.\n\n'
        'By collecting personal information through the registration website, Wireless Access for Health can effectively manage patient data, facilitate communication between health care providers and patients, and enable the delivery of tailored health care services. Individuals should be provided with transparent information about the purpose of data collection, how their personal information will be processed, collected and stored.',
  ),
  _PrivacySectionData(
    title: '4. Our Disclosure of your Personal Information to Third Parties',
    body:
        'We may share your personal information with third parties only in the ways that are described in this Privacy Statement:\n'
        '• We may allow a potential acquirer or merger partner to review our databases, although we would restrict their use and disclosure of this data during the diligence phase;\n'
        '• As required by law enforcement, government officials, or other third parties pursuant to a subpoena, court order, or other legal process or requirement applicable to our Agency;\n'
        '• We may transfer personal information to third parties for any legally permissible purpose at our sole discretion; and\n'
        '• We may share your information with third parties with your consent or direction to do so.',
  ),
  _PrivacySectionData(
    title: '5. Limiting Use, Disclosure, Retention',
    body:
        'WAH for Patients (WAH4P) identifies the purposes for which the information is being collected before or at the time of collection. The collection of your personal information will be limited to that which is needed for the purposes identified by us. Unless you consent or we are required by law, we will only use the information for the purposes for which it was collected. If we will be processing your personal data for another purpose later on, we will seek your further legal permission or consent; except where the other purpose is compatible with the original purpose. We will keep your personal data only as long as required to serve those purposes. We will also retain and use your personal data for as long as necessary to comply with our legal obligations, resolve disputes, and enforce our agreements.',
  ),
  _PrivacySectionData(
    title: '6. Accuracy of Personal data',
    body:
        'We do our best to ensure that the personal data we hold and use is accurate. We rely on the clients we do business with to disclose to us all relevant information and to inform us of any changes.',
  ),
  _PrivacySectionData(
    title:
        '7. How data is protected (Storage, Security, Disposal and Retention)',
    body:
        'We prioritize the security of your information and have implemented comprehensive measures to prevent unauthorized access or disclosure. These measures encompass organizational, physical, and technical security protocols, which adhere to established security standards. We employ a combination of electronic and managerial procedures to safeguard and secure the information we collect, ensuring its confidentiality and integrity.\n\n'
        'Wireless Access for Health store your personal information with third-party data storage providers (cloud), we shall ensure that proper measures are adopted to protect your information. According to the Privacy Guidelines for the Implementation of the Philippine Health Information Exchange (PHIE), all personal health information collected and stored in the system should be retained for as long as necessary to serve the declared purposes. However, after a period of fifteen (15) years of inactivity from the last transaction, electronic copies of all records should be securely destroyed following established protocols.',
  ),
  _PrivacySectionData(
    title: '8. Changes to our Privacy Statement',
    body:
        'WAH for Patients (WAH4P) may amend this statement at any time by posting a new version. It is your responsibility to review this statement periodically as your continued use of our products and services represents your agreement with the then-current statement.',
  ),
  _PrivacySectionData(
    title: '9. Rights of the Data Subject (RA 10173 Data Privacy Act of 2012)',
    body:
        '• Right of erasure or blocking. You may have a broader right to erasure of personal data that we hold about you.\n'
        '• Right to object. You may have the right to request that we stop processing your personal data and/or to stop sending you marketing communications.\n'
        '• Right to restrict processing. You may have the right to request that we restrict processing of your personal data in certain circumstances.\n'
        '• Right to access. In certain circumstances, you may have the right to be provided with your personal data in a structured, machine readable and commonly used format and to request that we transfer the personal data to another data controller without hindrance.\n'
        '• If you would like to exercise any of the above rights, please contact our support team or contact our Data Protection Officer. We will consider your request in accordance with applicable laws. To protect your privacy and security, we may take steps to verify your identity before complying with the request.\n'
        '• You also have the right to complain to a data protection authority about our collection and use of your personal data.',
  ),
  _PrivacySectionData(
    title: '10. How to file a complaint',
    body:
        'If there is a complaint regarding the processing of personal data, please contact the Data Protection Officer listed below. It is the right of the Data subject to lodge a complaint with the Wireless Access for Health to protect its personal information.\n\n'
        'If you have any questions regarding the Wireless Access for Health please send an email to: wah.pilipinas@wah.ph',
  ),
  _PrivacySectionData(
    title: '11. Data Protection Officer Contact Details',
    body:
        'You may get in touch with Wireless Access for Health through our Data Protection Officer with the contact details listed below:\n\n'
        'Name: Kevin Greg Alvarado\n'
        'Tel.no: (045) 985-5607\n'
        'Email: privacy@wah.ph\n'
        'Address: 2nd Floor Diwa ng tarlac building, San Vicente, Tarlac City, 2300',
  ),
];

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.section});

  final _PrivacySectionData section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          section.body,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
