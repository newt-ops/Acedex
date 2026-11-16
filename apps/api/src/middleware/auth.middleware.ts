import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthUserProfile, UserRole, StudentStream } from '@acedex/contracts';
import { UserModel } from '../modules/users/user.model';
import { AuthService } from '../modules/auth/auth.service';
import { env } from '../config/env';
import { UnauthorizedError, ForbiddenError } from '../common/errors/app-error';

export interface AuthenticatedRequest extends Request {
  user?: AuthUserProfile;
}

interface JwtPayload {
  sub: string;
  acedexId?: string;
  email?: string;
  phone?: string;
  role: UserRole;
  grade?: number;
  stream?: StudentStream | null;
  displayName: string;
}

export async function requireAuth(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Missing or invalid Authorization header'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as JwtPayload;

    const user = await UserModel.findById(decoded.sub);
    if (!user) {
      return next(new UnauthorizedError('User account not found'));
    }

    if (user.status === 'suspended') {
      return next(new ForbiddenError('Account is suspended. Please contact support.'));
    }

    req.user = AuthService.mapUserToProfile(user);
    next();
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      return next(new UnauthorizedError('Access token expired. Please refresh your session.'));
    }
    return next(new UnauthorizedError('Invalid access token'));
  }
}

export async function optionalAuth(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET) as JwtPayload;
    const user = await UserModel.findById(decoded.sub);
    if (user && user.status !== 'suspended') {
      req.user = AuthService.mapUserToProfile(user);
    }
    next();
  } catch {
    next();
  }
}

export function requireRole(...allowedRoles: UserRole[]) {
  return (req: AuthenticatedRequest, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new UnauthorizedError('Authentication required'));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(
        new ForbiddenError(
          `Access forbidden: Requires one of the following roles: [${allowedRoles.join(', ')}]`
        )
      );
    }

    next();
  };
}
