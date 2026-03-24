import '../../../core/constants/app_colors.dart';
import 'models/onboarding_page_data.dart';

class OnboardingPageRepository {
  OnboardingPageRepository._();

  static const int totalPages = 4;

  static const OnboardingPageData page1 = OnboardingPageData(
    title: 'Your health records,\nalways with you',
    subtitle:
        'View personal info, past visits, medical history, and lab results',
    backgroundImagePath: 'assets/images/onboarding/onboarding_bg_1.png',
    primaryColor: AppColors.primary,
    buttonTextColor: AppColors.primary,
    pageIndex: 0,
    totalPages: totalPages,
    actionButtonText: 'Next',
  );

  static const OnboardingPageData page2 = OnboardingPageData(
    title: 'Your daily health,\nin your control',
    subtitle:
        'Track vital signs, meds, vaccines, exercise, food, water, and sleep',
    backgroundImagePath: 'assets/images/onboarding/onboarding_bg_2.png',
    primaryColor: AppColors.secondary,
    buttonTextColor: AppColors.secondary,
    pageIndex: 1,
    totalPages: totalPages,
    actionButtonText: 'Next',
  );

  static const OnboardingPageData page3 = OnboardingPageData(
    title: 'Your appointments,\nmade simple',
    subtitle: 'Schedule prenatal, child care, lab tests, and teleconsultations',
    backgroundImagePath: 'assets/images/onboarding/onboarding_bg_3.png',
    primaryColor: AppColors.primary,
    buttonTextColor: AppColors.primary,
    pageIndex: 2,
    totalPages: totalPages,
    actionButtonText: 'Next',
  );

  static const OnboardingPageData page4 = OnboardingPageData(
    title: 'Your medications,\nalways available',
    subtitle:
        'Request refills and manage your prescriptions without visiting clinics or hospitals',
    backgroundImagePath: 'assets/images/onboarding/onboarding_bg_4.png',
    primaryColor: AppColors.secondary,
    buttonTextColor: AppColors.secondary,
    pageIndex: 3,
    totalPages: totalPages,
    actionButtonText: 'Get Started',
    isLastPage: true,
  );
}
