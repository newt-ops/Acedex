import { Request, Response, NextFunction } from 'express';
import { NotFoundError } from '../common/errors/app-error';

export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  next(new NotFoundError(`Endpoint '${req.method} ${req.originalUrl}' not found on this server`));
}
