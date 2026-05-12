# WAH4P Draft User Acceptance Test (UAT) Guide

## Purpose

This document is a draft UAT guide for WAH staff who will test the WAH4P app.

Its goal is to help testers verify that the app works end to end from the first launch flow through the main patient features, and to make it easy to record clear pass/fail results.

## Test objective

Confirm that a WAH staff member can:

- launch the app successfully
- move through onboarding and authentication flows
- view and update patient profile information
- access the main dashboard and patient-facing sections
- open health record, appointment, and medication screens
- complete the expected actions without crashes, blocked navigation, or broken data displays

## Who should use this guide

Use this guide if you are:

- a WAH staff member testing the app in a UAT environment
- a product owner or QA reviewer validating readiness for release
- a support or operations reviewer confirming the app behaves as expected on a real device

## Before you begin

### Required access

Make sure you have:

- a test device or emulator with the WAH4P app installed
- access to the correct UAT/test environment
- a valid test account for login and profile checks
- any required OTP, sync code, or gateway test credentials
- a test provider or facility selection value if the flow requires one

### Test data to prepare

Use realistic but non-sensitive test data only.

Suggested test data:

- full name
- date of birth
- phone number and email
- sample patient identifier
- sample facility name or code
- sample medication and appointment data
- sample lab result or record data if the feature is available in the build

Do not use real patient data unless the environment and policy explicitly allow it.

### Test environment check

Before testing, confirm:

- the app opens to the correct starting screen
- the backend or API environment is reachable
- the app version/build number is the expected UAT build
- the tester can access any required login or verification flow
- screenshots are allowed if your team wants evidence for defects

## UAT rules for testers

- Test every step exactly as written before assuming a bug.
- Record the actual result, not just whether the screen opened.
- If something fails, note the screen, button, message, and the exact action that caused the issue.
- Retest after any fix before marking the test as passed.
- Do not skip optional fields without noting that they were intentionally left blank.
- If the build differs from this guide, record the difference and continue with the closest available flow.

## Pass / fail criteria

A test case passes only if:

- the screen loads correctly
- the intended action works
- the app shows the expected result or message
- no crash, freeze, logout, or broken navigation occurs
- the displayed data matches the test input or expected test output

A test case fails if:

- the app crashes, hangs, or becomes unusable
- the wrong screen opens
- data is lost, not saved, or saved incorrectly
- validation messages are missing, incorrect, or unclear
- the app shows an error that prevents the user from continuing

## Test execution checklist

Use this table to track status:

| Status | Meaning |
| --- | --- |
| Not started | The test has not been run yet. |
| In progress | The test is being run or retested. |
| Passed | The expected behavior was observed. |
| Failed | The expected behavior did not happen. |
| Blocked | The test could not be completed because of missing data, access, or an environment issue. |

---

## Test scenarios

### 1) App launch and startup flow

**Goal:** Confirm the app starts correctly and routes to the expected first screen.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-01 | Open the app from a fresh start. | The splash screen appears without errors. |
| UAT-02 | Wait for the app to finish its startup check. | The app routes to the correct next screen based on the user state. |
| UAT-03 | Relaunch the app after it has already been used. | The app returns to the expected authenticated or onboarding path without looping. |

### 2) Onboarding flow

**Goal:** Confirm new users can move through onboarding without confusion or dead ends.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-04 | Start from the first onboarding screen. | The onboarding content is readable and the page layout is correct. |
| UAT-05 | Tap through each onboarding page in sequence. | Each next screen loads correctly and the controls work. |
| UAT-06 | Move back to a previous onboarding page if that option is available. | Back navigation works and preserves the current flow state. |
| UAT-07 | Complete onboarding to the final step. | The app proceeds to the next intended screen without error. |

### 3) Registration, login, and password recovery

**Goal:** Confirm a user can register, log in, and recover access when needed.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-08 | Open the registration flow. | Registration screens load in the correct order. |
| UAT-09 | Enter valid registration details. | The app accepts the data and continues to the next step. |
| UAT-10 | Verify the email or OTP step, if included in the build. | The app accepts the code and advances correctly. |
| UAT-11 | Set a password that meets the validation rules. | The password is accepted and saved. |
| UAT-12 | Log out, then log back in with valid credentials. | Login succeeds and the user returns to the expected landing screen. |
| UAT-13 | Use the forgot-password flow with a valid account. | The reset flow starts and the user receives the expected next-step instruction. |
| UAT-14 | Complete the reset-password/new-password flow if available. | The new password is accepted and the account can log in again. |
| UAT-15 | Test the sync code or verification code screen if it is included in the build. | The code is accepted and the user continues without error. |

### 4) Patient record linking

**Goal:** Confirm the app can link a patient to the correct facility or identifier.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-16 | Open the patient record linking introduction screen. | The screen explains the linking flow clearly. |
| UAT-17 | Enter a valid patient identifier. | The identifier is accepted without format errors. |
| UAT-18 | Select a facility or provider from the list. | The correct target can be selected and confirmed. |
| UAT-19 | Complete the linking flow. | The app shows the link as completed or pending as expected. |
| UAT-20 | Try an invalid or incomplete identifier. | The app shows a clear validation message and blocks submission. |

### 5) Dashboard and navigation

**Goal:** Confirm the main dashboard and navigation options are usable.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-21 | Open the dashboard after login. | The dashboard loads correctly and the layout is stable. |
| UAT-22 | Tap each visible card, menu item, or shortcut. | Each item opens the correct section. |
| UAT-23 | Return to the dashboard from a child screen. | The app returns to the correct place without losing state unexpectedly. |
| UAT-24 | Rotate the device or change screen size if supported. | The layout remains readable and usable. |

### 6) Profile and personal information

**Goal:** Confirm profile details display correctly and can be updated.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-25 | Open the profile screen. | The user profile screen loads successfully. |
| UAT-26 | Open personal information. | The personal information screen loads and shows the current values. |
| UAT-27 | Edit a supported field such as name or phone number. | The app accepts the change and saves it correctly. |
| UAT-28 | Save with a required field missing or invalid. | The app blocks the save and shows a helpful validation message. |
| UAT-29 | Reopen the profile after saving. | The saved values persist and match the input. |

### 7) Personal health record screens

**Goal:** Confirm the PHR screens open and show the expected record content.

#### BMI

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-30 | Open the BMI screen. | The BMI screen loads correctly. |
| UAT-31 | Enter a height and weight sample value if editing is available. | The app accepts valid values and shows the expected BMI result. |

#### Blood pressure

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-32 | Open the blood pressure screen. | The screen loads correctly. |
| UAT-33 | Enter a valid blood pressure reading if editing is available. | The app accepts the values and displays the record properly. |

#### Temperature

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-34 | Open the temperature screen. | The screen loads correctly. |
| UAT-35 | Enter a valid temperature reading if editing is available. | The app accepts the value and displays it correctly. |

#### Medicine intake

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-36 | Open the medicine intake screen. | The screen loads correctly. |
| UAT-37 | Record or review a medication intake entry if available. | The entry is saved or displayed as expected. |

### 8) EHR screens

**Goal:** Confirm health record screens open and show the correct information.

#### Medical history

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-38 | Open the medical history screen. | The screen loads without errors. |
| UAT-39 | Review any available history cards or entries. | The entries are readable and correctly formatted. |

#### Immunization records

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-40 | Open the immunization records screen. | The screen loads without errors. |
| UAT-41 | Review any available immunization entries. | Each record shows the correct vaccine details and dates. |

#### Medical consultations

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-42 | Open the medical consultations screen. | The screen loads correctly. |
| UAT-43 | Review any consultation entries. | The consultation details are visible and accurate. |

#### Laboratory test results

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-44 | Open the laboratory test results screen. | The screen loads correctly. |
| UAT-45 | Open a lab result if one is present. | The result details, status, and attachment links display correctly. |

### 9) Medication resupply flow

**Goal:** Confirm users can review prescriptions and submit a resupply request.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-46 | Open the medication resupply landing screen. | The screen loads correctly. |
| UAT-47 | Open active prescriptions. | The prescription list appears with the expected items. |
| UAT-48 | Open the prescription viewer. | The selected prescription opens correctly and remains read-only. |
| UAT-49 | Open the request form. | The request form loads with the correct fields. |
| UAT-50 | Enter valid quantity and notes, then submit. | The request is accepted and confirmation is shown. |
| UAT-51 | Try submitting an incomplete request. | The app shows validation messages and blocks submission. |
| UAT-52 | Open the resupply history screen. | Submitted or test entries appear with the correct status. |

### 10) Appointment booking

**Goal:** Confirm appointment request screens work for onsite and teleconsultation flows.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-53 | Open the onsite consultation screen. | The screen loads correctly. |
| UAT-54 | Enter the required appointment information and submit. | The app accepts the request and shows a confirmation or next step. |
| UAT-55 | Open the teleconsultation screen. | The screen loads correctly. |
| UAT-56 | Enter valid teleconsultation details and submit. | The request is accepted without errors. |
| UAT-57 | Try submitting with missing required appointment details. | The app blocks submission and explains what is missing. |

### 11) Support / legal / informational screens

**Goal:** Confirm informational pages open and display expected content.

| Test ID | Steps | Expected result |
| --- | --- | --- |
| UAT-58 | Open About Us from profile or menu. | The page loads and text is readable. |
| UAT-59 | Open About App from profile or menu. | The page loads and text is readable. |
| UAT-60 | Open Privacy Statement if it is included in the build. | The page loads and displays the correct policy content. |

## Evidence to capture

For each failed case, record:

- test ID
- screen name
- device model and OS version
- app build/version
- time of test
- steps performed
- what you expected to happen
- what actually happened
- screenshot or screen recording, if available
- severity: low, medium, high, or critical

## Defect logging template

Use this format when reporting an issue:

- **Title:** short description of the problem
- **Test ID:** the related UAT case number
- **Environment:** UAT / device / OS / app version
- **Steps to reproduce:** numbered steps
- **Expected result:** what should have happened
- **Actual result:** what happened instead
- **Attachment:** screenshot or video, if available
- **Priority:** low / medium / high / critical
- **Notes:** any extra context

## UAT sign-off section

Use this section when the test cycle is complete.

- **Build tested:** ____________________
- **Environment:** ____________________
- **Tester name:** ____________________
- **Test date:** ____________________
- **Overall result:** Pass / Pass with issues / Fail
- **Open defects:** ____________________
- **Business sign-off:** ____________________

## Notes for the next draft

This is a draft UAT guide. If the team wants, the next version can be split into:

- a shorter tester handout
- a detailed QA execution checklist
- a defect log spreadsheet template
- a release sign-off checklist
