import { Body, Controller, Get, Headers, Patch } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthSupportService } from './auth-support.service';
import { PatientProfileResponse } from './auth.types';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfileService } from './profile.service';

@Controller('profile')
export class ProfileController {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly profileService: ProfileService,
  ) {}

  @Get('me')
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  async getMyProfile(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<{
    user: { id: string; email: string; profile: PatientProfileResponse };
  }> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const profile = await this.profileService.getProfileResponse(
      authenticatedUser.id,
      authenticatedUser.email,
    );

    return {
      user: {
        id: authenticatedUser.id,
        email: authenticatedUser.email,
        profile,
      },
    };
  }

  @Patch('me')
  @Throttle({ default: { ttl: 60_000, limit: 10 } })
  async updateMyProfile(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Body() dto: UpdateProfileDto,
  ): Promise<{
    user: { id: string; email: string; profile: PatientProfileResponse };
  }> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const profile = await this.profileService.saveProfileFromDto(
      authenticatedUser.id,
      authenticatedUser.email,
      dto,
    );

    return {
      user: {
        id: authenticatedUser.id,
        email: authenticatedUser.email,
        profile,
      },
    };
  }
}
