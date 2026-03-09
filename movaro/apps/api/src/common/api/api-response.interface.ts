import { ApiError } from './api-error.interface';

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
}
