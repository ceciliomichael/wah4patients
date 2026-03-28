import { Injectable, ServiceUnavailableException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Resend } from "resend";

@Injectable()
export class MailerService {
  private readonly resendClient: Resend;
  private readonly fromEmail: string;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.getOrThrow<string>("RESEND_API_KEY");
    this.fromEmail = this.configService.getOrThrow<string>("RESEND_FROM_EMAIL");
    this.resendClient = new Resend(apiKey);
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
      subject: "Your WAH4P verification code",
      text: `Your WAH4P verification code is ${otpCode}. It expires in ${expiresInMinutes} minutes.`,
    });

    if (response.error !== null) {
      throw new ServiceUnavailableException(
        "Failed to deliver verification code email",
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
      subject: "Your WAH4P password reset code",
      text: `Your WAH4P password reset code is ${otpCode}. It expires in ${expiresInMinutes} minutes.`,
    });

    if (response.error !== null) {
      throw new ServiceUnavailableException(
        "Failed to deliver password reset code email",
      );
    }
  }
}
