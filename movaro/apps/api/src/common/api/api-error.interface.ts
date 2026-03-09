export interface ApiError {
  code: string;
  message: string;
  userMessage: string;
  status: number;
  traceId?: string;
}
