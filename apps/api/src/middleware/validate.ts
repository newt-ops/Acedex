import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';
import { ValidationError } from '../common/errors/app-error';

interface RequestValidationSchema {
  body?: AnyZodObject;
  query?: AnyZodObject;
  params?: AnyZodObject;
}

export function validate(schema: RequestValidationSchema) {
  return async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      if (schema.body) {
        req.body = await schema.body.parseAsync(req.body);
      }
      if (schema.query) {
        req.query = await schema.query.parseAsync(req.query);
      }
      if (schema.params) {
        req.params = await schema.params.parseAsync(req.params);
      }
      next();
    } catch (error: any) {
      if (
        error instanceof ZodError ||
        error?.name === 'ZodError' ||
        Array.isArray(error?.issues)
      ) {
        const issues = error.issues || error.errors || [];
        const details = issues.map((err: any) => ({
          field: Array.isArray(err.path) ? err.path.join('.') : err.path,
          message: err.message,
          code: err.code,
        }));
        return next(new ValidationError('Request validation failed', details));
      }
      next(error);
    }
  };
}
