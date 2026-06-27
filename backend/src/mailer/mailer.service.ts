import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

@Injectable()
export class MailerService {
  private readonly resendClient: Resend;
  private readonly fromEmail: string;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.getOrThrow<string>('RESEND_API_KEY');
    this.fromEmail = this.configService.getOrThrow<string>('RESEND_FROM_EMAIL');
    this.resendClient = new Resend(apiKey);
  }

  private buildHtmlTemplate(title: string, otpCode: string, expiresInMinutes: number): string {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@800&family=Inter:wght@400;600&display=swap');
    body {
      margin: 0; padding: 0; background-color: #f5f4f1;
      -webkit-font-smoothing: antialiased;
    }
    table { border-collapse: collapse; }
  </style>
</head>
<body style="margin: 0; padding: 0; background-color: #f5f4f1; font-family: 'Inter', Helvetica, Arial, sans-serif; color: #1c1c1c;">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #f5f4f1; padding: 64px 20px;">
    <tr>
      <td align="center">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.04); overflow: hidden; max-width: 600px; margin: 0 auto;">
          <!-- Hero Section -->
          <tr>
            <td style="background-color: #46017D; padding: 56px 40px; text-align: left;">
              <h1 style="font-family: 'Outfit', Helvetica, Arial, sans-serif; color: #ffffff; margin: 0; font-size: 32px; font-weight: 800; letter-spacing: -0.02em; line-height: 1.1;">WAH for Patients</h1>
            </td>
          </tr>
          <!-- Content Section -->
          <tr>
            <td style="padding: 48px 40px; text-align: left;">
              <h2 style="font-family: 'Outfit', Helvetica, Arial, sans-serif; font-size: 24px; font-weight: 800; margin: 0 0 16px 0; color: #1c1c1c; letter-spacing: -0.02em;">${title}</h2>
              <p style="font-family: 'Inter', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 1.65; margin: 0 0 40px 0; color: #4a4a4a;">
                Use the secure code below to proceed. Do not share this code with anyone.
              </p>
              
              <!-- Code Block -->
              <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #f5f4f1; border-radius: 12px; margin-bottom: 40px; border: 1px solid rgba(0,0,0,0.04);">
                <tr>
                  <td style="padding: 32px 24px; text-align: center;">
                    <span style="font-family: 'Outfit', Courier, monospace; font-size: 48px; font-weight: 800; color: #46017D; letter-spacing: 0.15em; line-height: 1;">${otpCode}</span>
                  </td>
                </tr>
              </table>

              <p style="font-family: 'Inter', Helvetica, Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #888888; margin: 0;">
                Expires in <strong style="color: #1c1c1c; font-weight: 600;">${expiresInMinutes} minutes</strong>. If you didn't request this action, you can safely ignore this email.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background-color: #f9f8f6; padding: 32px 40px; text-align: left; border-top: 1px solid rgba(0,0,0,0.04);">
              <p style="font-family: 'Inter', Helvetica, Arial, sans-serif; font-size: 13px; color: #888888; margin: 0;">
                &copy; ${new Date().getFullYear()} WAH for Patients. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `.trim();
  }

  async sendRegistrationOtpEmail(params: {
    email: string;
    otpCode: string;
    expiresInMinutes: number;
  }): Promise<void> {
    const { email, otpCode, expiresInMinutes } = params;

    const response = await this.resendClient.emails.send({
      from: this.fromEmail,
      to: email,
      subject: 'Your WAH4P verification code',
      text: `Your WAH4P verification code is ${otpCode}. It expires in ${expiresInMinutes} minutes.`,
      html: this.buildHtmlTemplate('Your Verification Code', otpCode, expiresInMinutes),
    });

    if (response.error !== null) {
      throw new ServiceUnavailableException(
        'Failed to deliver verification code email',
      );
    }
  }

  async sendPasswordResetOtpEmail(params: {
    email: string;
    otpCode: string;
    expiresInMinutes: number;
  }): Promise<void> {
    const { email, otpCode, expiresInMinutes } = params;

    const response = await this.resendClient.emails.send({
      from: this.fromEmail,
      to: email,
      subject: 'Your WAH4P password reset code',
      text: `Your WAH4P password reset code is ${otpCode}. It expires in ${expiresInMinutes} minutes.`,
      html: this.buildHtmlTemplate('Your Password Reset Code', otpCode, expiresInMinutes),
    });

    if (response.error !== null) {
      throw new ServiceUnavailableException(
        'Failed to deliver password reset code email',
      );
    }
  }

  async sendSecurityVerificationOtpEmail(params: {
    email: string;
    otpCode: string;
    expiresInMinutes: number;
  }): Promise<void> {
    const { email, otpCode, expiresInMinutes } = params;

    const response = await this.resendClient.emails.send({
      from: this.fromEmail,
      to: email,
      subject: 'Your WAH4P verification code',
      text: `Your WAH4P verification code is ${otpCode}. It expires in ${expiresInMinutes} minutes.`,
      html: this.buildHtmlTemplate('Your Security Verification Code', otpCode, expiresInMinutes),
    });

    if (response.error !== null) {
      throw new ServiceUnavailableException(
        'Failed to deliver verification code email',
      );
    }
  }
}
