import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import request from 'supertest';
import { OAuth2Client } from 'google-auth-library';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { UserModel } from '../src/modules/users/user.model';
import { RefreshTokenModel } from '../src/modules/auth/refresh-token.model';

describe('Phase 2: Authentication & User Accounts', () => {
  const app = createApp();
  const testStudentEmail = `test-student-${Date.now()}@example.com`;
  const testAdminEmail = 'aymenmubarek10@gmail.com'; // In adminEmails whitelist
  let studentAccessToken = '';
  let studentRefreshToken = '';

  beforeAll(async () => {
    await connectDatabase();
    // Clean up any previous test residues
    await UserModel.deleteMany({ email: { $regex: /^test-/ } });
    await RefreshTokenModel.deleteMany({});
  });

  afterAll(async () => {
    await UserModel.deleteMany({ email: { $regex: /^test-/ } });
    await RefreshTokenModel.deleteMany({});
    await disconnectDatabase();
  });

  it('POST /api/v1/auth/google should reject requests without idToken', async () => {
    const res = await request(app).post('/api/v1/auth/google').send({});

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('POST /api/v1/auth/google should register a new student user from verified Google token', async () => {
    // Mock Google token verification ticket
    vi.spyOn(OAuth2Client.prototype, 'verifyIdToken').mockResolvedValueOnce({
      getPayload: () => ({
        sub: `google-sub-${Date.now()}`,
        email: testStudentEmail,
        name: 'Abebe Student',
        picture: 'https://example.com/avatar.jpg',
      }),
    } as any);

    const res = await request(app)
      .post('/api/v1/auth/google')
      .send({ idToken: 'valid-mock-google-token', platform: 'web' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testStudentEmail);
    expect(res.body.data.user.role).toBe('student');
    expect(res.body.data.user.status).toBe('active');
    expect(res.body.data.tokens).toHaveProperty('accessToken');
    expect(res.body.data.tokens).toHaveProperty('refreshToken');

    // Web should set acedex_rt cookie
    const cookies = res.headers['set-cookie'];
    expect(cookies).toBeDefined();
    expect(cookies[0]).toContain('acedex_rt');

    studentAccessToken = res.body.data.tokens.accessToken;
    studentRefreshToken = res.body.data.tokens.refreshToken;
  });

  it('POST /api/v1/auth/google should auto-promote whitelisted email to super_admin', async () => {
    vi.spyOn(OAuth2Client.prototype, 'verifyIdToken').mockResolvedValueOnce({
      getPayload: () => ({
        sub: 'google-sub-admin-whitelisted',
        email: testAdminEmail,
        name: 'Aymen Admin',
      }),
    } as any);

    const res = await request(app)
      .post('/api/v1/auth/google')
      .send({ idToken: 'valid-admin-token' });

    expect(res.status).toBe(200);
    expect(res.body.data.user.role).toBe('super_admin');
  });

  it('GET /api/v1/auth/me should return authenticated user profile with Bearer token', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${studentAccessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.email).toBe(testStudentEmail);
    expect(res.body.data.role).toBe('student');
  });

  it('GET /api/v1/auth/me should reject requests with invalid token', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', 'Bearer invalid-garbage-token');

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('POST /api/v1/auth/refresh should rotate refresh token and issue new session', async () => {
    const res = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: studentRefreshToken });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.tokens).toHaveProperty('accessToken');
    expect(res.body.data.tokens).toHaveProperty('refreshToken');
    expect(res.body.data.tokens.refreshToken).not.toBe(studentRefreshToken);

    // Save newly rotated refresh token
    const newRefreshToken = res.body.data.tokens.refreshToken;

    // REUSE DETECTION: Replaying the old consumed refresh token MUST fail and invalidate family
    const reuseRes = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: studentRefreshToken });

    expect(reuseRes.status).toBe(401);
    expect(reuseRes.body.error.message).toContain('reuse detection');

    // The newly rotated token should NOW also be invalidated because family was breached
    const secondRes = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: newRefreshToken });

    expect(secondRes.status).toBe(401);
  });

  it('POST /api/v1/auth/logout should revoke refresh token and clear cookie', async () => {
    // Generate a fresh session to log out
    vi.spyOn(OAuth2Client.prototype, 'verifyIdToken').mockResolvedValueOnce({
      getPayload: () => ({
        sub: `google-sub-logout-${Date.now()}`,
        email: `test-logout-${Date.now()}@example.com`,
        name: 'Logout Tester',
      }),
    } as any);

    const loginRes = await request(app)
      .post('/api/v1/auth/google')
      .send({ idToken: 'mock-token' });

    const tokenToRevoke = loginRes.body.data.tokens.refreshToken;

    const logoutRes = await request(app)
      .post('/api/v1/auth/logout')
      .set('Cookie', [`acedex_rt=${tokenToRevoke}`])
      .send();

    expect(logoutRes.status).toBe(200);
    expect(logoutRes.body.success).toBe(true);

    // Refreshing with the revoked token must now fail
    const refreshAfterLogout = await request(app)
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: tokenToRevoke });

    expect(refreshAfterLogout.status).toBe(401);
  });
});
