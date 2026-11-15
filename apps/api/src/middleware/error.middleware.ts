import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { ApiErrorResponse } from '@acedex/contracts';
import { AppError } from '../common/errors/app-error';
import { logger } from '../common/utils/logger';
import { env } from '../config/env';

export function errorHandler(
  err: Error | AppError,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): Response {
  let statusCode = 500;
  let code = 'INTERNAL_SERVER_ERROR';
  let message = 'An unexpected server error occurred';
  let details: unknown = undefined;

  // 1. Handled AppError instances
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    code = err.code;
    message = err.message;
    details = err.details;
  }
  // 2. Body Parser JSON Syntax Error
  else if (err instanceof SyntaxError && 'status' in err && err.status === 400 && 'body' in err) {
    statusCode = 400;
    code = 'MALFORMED_JSON';
    message = 'Invalid JSON in request payload';
  }
  // 3. Zod Schema Validation Error
  else if (err.name === 'ZodError' || 'issues' in (err as any)) {
    statusCode = 422;
    code = 'VALIDATION_ERROR';
    message = 'Request validation failed';
    details = (err as any).issues?.map((e: any) => ({
      field: Array.isArray(e.path) ? e.path.join('.') : e.path,
      message: e.message,
    }));
  }
  // 3. Mongoose Validation Error
  else if (err instanceof mongoose.Error.ValidationError) {
    statusCode = 422;
    code = 'VALIDATION_ERROR';
    message = 'Database validation error';
    details = Object.values(err.errors).map((e) => ({
      field: e.path,
      message: e.message,
    }));
  }
  // 4. Mongoose Cast Error (invalid ObjectId, number, etc.)
  else if (err instanceof mongoose.Error.CastError) {
    statusCode = 400;
    code = 'INVALID_ID';
    message = `Invalid ${err.kind} format for parameter: '${err.path}'`;
  }
  // 5. MongoDB Duplicate Key (E11000)
  else if ('code' in err && (err as { code: number }).code === 11000) {
    statusCode = 409;
    code = 'DUPLICATE_KEY';
    message = 'A record with this unique identifier or field already exists';
  }
  // 6. Generic / Unhandled error
  else {
    statusCode = 500;
    code = 'INTERNAL_SERVER_ERROR';
    message = env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  }

  // Structured log for 5xx errors or unexpected failures
  if (statusCode >= 500) {
    logger.error(
      {
        err,
        path: req.originalUrl,
        method: req.method,
        statusCode,
      },
      `Server Error: ${err.message}`
    );
  } else {
    logger.warn(
      {
        path: req.originalUrl,
        method: req.method,
        statusCode,
        code,
        message,
      },
      `Client Error: ${message}`
    );
  }

  const responsePayload: ApiErrorResponse = {
    success: false,
    error: {
      code,
      message,
      ...(details ? { details } : {}),
      timestamp: new Date().toISOString(),
      path: req.originalUrl,
    },
  };

  return res.status(statusCode).json(responsePayload);
}
