import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { UserModel } from '../src/modules/users/user.model';
import { RefreshTokenModel } from '../src/modules/auth/refresh-token.model';

describe('Phase 2: Authentication & User Accounts (Phone & PIN)', () => {
  const app = createApp();
  const testStudentPhone = '0912999888';
  const testPin = '123456';
  let studentAccessToken = '';
  let studentRefreshToken = '';

  beforeAll(async () => {
    await connectDatabase();
    await UserModel.deleteMany({ phone: { $regex: /^(\+251|0)912/ } });
    await RefreshTokenModel.deleteMany({});
  });

  afterAll(async () => {
    await UserModel.deleteMany({ phone: { $regex: /^(\+251|0)912/ } });
    await RefreshTokenModel.deleteMany({});
    await disconnectDatabase();
  });

  it('POST /api/v1/auth/register-phone should reject invalid phone formats', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register-phone')
      .send({
        phone: '12345',
        pin: testPin,
        fullName: 'Test Student',
        gender: 'male',
        grade: 12,
        stream: 'natural',
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/v1/auth/register-phone should register a new student user and return tokens', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register-phone')
      .send({
        phone: testStudentPhone,
        pin: testPin,
        fullName: 'Abebe Kebede',
        gender: 'male',
        grade: 12,
        stream: 'natural',
        candidateId: 'ACX-26-9999',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.phone).toBe('+251912999888');
    expect(res.body.data.user.acedexId).toBe('ACX-26-9999');
    expect(res.body.data.user.role).toBe('student');
    expect(res.body.data.user.status).toBe('active');
    expect(res.body.data.tokens).toHaveProperty('accessToken');
    expect(res.body.data.tokens).toHaveProperty('refreshToken');

    studentAccessToken = res.body.data.tokens.accessToken;
    studentRefreshToken = res.body.data.tokens.refreshToken;
  });

  it('POST /api/v1/auth/login-phone should authenticate student with phone and PIN', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login-phone')
      .send({
        phone: testStudentPhone,
        pin: testPin,
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.phone).toBe('+251912999888');
    expect(res.body.data.tokens).toHaveProperty('accessToken');
    expect(res.body.data.tokens).toHaveProperty('refreshToken');
  });

  it('GET /api/v1/auth/me should return authenticated user profile with Bearer token', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${studentAccessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.phone).toBe('+251912999888');
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
    // Generate a fresh session via login to log out
    const loginRes = await request(app)
      .post('/api/v1/auth/login-phone')
      .send({
        phone: testStudentPhone,
        pin: testPin,
      });

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
