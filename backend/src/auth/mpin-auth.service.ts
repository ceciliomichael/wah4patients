import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { compare, hash } from "bcryptjs";
import { AuthSettingsService } from "./auth-settings.service";
import { AuthSupportService } from "./auth-support.service";
import { SetMpinResponse, VerifyMpinResponse } from "./auth.types";
import { SetMpinDto } from "./dto/set-mpin.dto";
import { VerifyMpinDto } from "./dto/verify-mpin.dto";
import { UserMpinRepository } from "./user-mpin.repository";

@Injectable()
export class MpinAuthService {
  constructor(
    private readonly userMpinRepository: UserMpinRepository,
    private readonly settings: AuthSettingsService,
    private readonly support: AuthSupportService,
  ) {}

  async setMpin(
    authorizationHeader: string | undefined,
    dto: SetMpinDto,
  ): Promise<SetMpinResponse> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);

    const mpin = dto.mpin.trim();
    const confirmMpin = dto.confirmMpin.trim();
    const deviceId = dto.deviceId.trim();

    if (mpin !== confirmMpin) {
      throw new BadRequestException("MPIN confirmation does not match");
    }

    const mpinHash = await hash(
      this.support.buildMpinComparisonValue(
        authenticatedUser.id,
        deviceId,
        mpin,
      ),
      this.settings.mpinBcryptRounds,
    );

    await this.userMpinRepository.upsert({
      userId: authenticatedUser.id,
      deviceId,
      mpinHash,
      failedAttempts: 0,
      lockedUntil: null,
      lastVerifiedAt: null,
    });

    return {
      message: "MPIN configured successfully",
    };
  }

  async verifyMpin(
    authorizationHeader: string | undefined,
    dto: VerifyMpinDto,
  ): Promise<VerifyMpinResponse> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);

    const mpin = dto.mpin.trim();
    const deviceId = dto.deviceId.trim();
    const record = await this.userMpinRepository.findByUserId(
      authenticatedUser.id,
    );

    if (record === null) {
      throw new UnauthorizedException(
        "MPIN is not configured for this account",
      );
    }

    if (record.deviceId !== deviceId) {
      throw new UnauthorizedException(
        "MPIN login is only allowed on the registered device",
      );
    }

    const now = new Date();
    if (record.lockedUntil !== null && new Date(record.lockedUntil) > now) {
      throw new HttpException(
        {
          message: "MPIN is temporarily locked",
          lockedUntil: record.lockedUntil,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const isValid = await compare(
      this.support.buildMpinComparisonValue(
        authenticatedUser.id,
        deviceId,
        mpin,
      ),
      record.mpinHash,
    );

    if (!isValid) {
      const nextFailedAttempts = record.failedAttempts + 1;
      const shouldLock =
        nextFailedAttempts >= this.settings.mpinMaxFailedAttempts;
      const lockedUntil = shouldLock
        ? this.support
            .addMinutes(now, this.settings.mpinLockDurationMinutes)
            .toISOString()
        : null;

      await this.userMpinRepository.updateFailureState(
        authenticatedUser.id,
        nextFailedAttempts,
        lockedUntil,
      );

      if (shouldLock) {
        throw new HttpException(
          {
            message: "MPIN is temporarily locked",
            lockedUntil,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new UnauthorizedException(
        `Invalid MPIN. ${this.settings.mpinMaxFailedAttempts - nextFailedAttempts} attempts remaining`,
      );
    }

    await this.userMpinRepository.markVerified(authenticatedUser.id);

    return {
      message: "MPIN verified successfully",
      remainingAttempts: this.settings.mpinMaxFailedAttempts,
      lockedUntil: null,
    };
  }
}
