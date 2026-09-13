import { IsEmail, IsIn, IsOptional, IsUUID, MaxLength } from 'class-validator';

export class RegisterLaunchInterestDto {
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsIn(['pt', 'es', 'en'])
  locale!: 'pt' | 'es' | 'en';

  @IsOptional()
  @IsUUID()
  analyticsSessionId?: string;
}
