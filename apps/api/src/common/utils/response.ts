import { Response } from 'express';
import { ApiSuccessResponse, ApiErrorResponse } from '@acedex/contracts';
import { AppError } from '../errors/app-error';

export function sendSuccess<T>(
  res: Response,
  data: T,
  statusCode = 200,
  meta?: ApiSuccessResponse<T>['meta']
): Response {
  const payload: ApiSuccessResponse<T> = {
    success: true,
    data,
    ...(meta ? { meta } : {}),
  };

  return res.status(statusCode).json(payload);
}

export function sendError(
  res: Response,
  err: AppError | Error,
  overrideStatus?: number
): Response {
  const isAppError = err instanceof AppError;
  const statusCode = overrideStatus || (isAppError ? err.statusCode : 500);
  const code = isAppError ? err.code : 'INTERNAL_SERVER_ERROR';
  const details = isAppError ? err.details : undefined;

  const payload: ApiErrorResponse = {
    success: false,
    error: {
      code,
      message: err.message || 'An unexpected error occurred',
      ...(details ? { details } : {}),
      timestamp: new Date().toISOString(),
    },
  };

  return res.status(statusCode).json(payload);
}
