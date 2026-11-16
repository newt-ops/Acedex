import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { UserModel } from '../src/modules/users/user.model';
import { RefreshTokenModel } from '../src/modules/auth/refresh-token.model';

describe('Student Phone & PIN Authentication with Onboarding Data', () => {
  const app = createApp();

  // Test phone numbers
  const testPhoneG9 = '0911223344';
  const testPhoneG11Natural = '0922334455';
  const testPhoneG12Social = '+251733445566';
  const testPin = '123456';
  const newPin = '654321';

  let g9AccessToken = '';
  let g9AcedexId = '';

  beforeAll(async () => {
    await connectDatabase();
    // Clean up test phone records
    await UserModel.deleteMany({
      phone: { $in: ['+251911223344', '+251922334455', '+251733445566'] },
    });
  });

  afterAll(async () => {
    await UserModel.deleteMany({
      phone: { $in: ['+251911223344', '+251922334455', '+251733445566'] },
    });
    await RefreshTokenModel.deleteMany({});
    await disconnectDatabase();
  });

  it('POST /api/v1/auth/register-phone should reject invalid phone numbers', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: '12345',
      pin: '123456',
      fullName: 'Invalid Student',
      gender: 'male',
      grade: 9,
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('POST /api/v1/auth/register-phone should reject PIN shorter than 6 digits', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG9,
      pin: '1234',
      fullName: 'Short Pin Student',
      gender: 'male',
      grade: 9,
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('POST /api/v1/auth/register-phone should reject Grade 11 registration without stream', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG11Natural,
      pin: testPin,
      fullName: 'Streamless Student',
      gender: 'female',
      grade: 11,
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
    expect(JSON.stringify(res.body.error.details)).toContain('stream');
  });

  it('POST /api/v1/auth/register-phone should register Grade 9 student with normalized phone and ACEDEX ID', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG9,
      pin: testPin,
      fullName: 'Abebe Bikila',
      gender: 'male',
      grade: 9,
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user).toBeDefined();

    const user = res.body.data.user;
    expect(user.acedexId).toMatch(/^ACEDEX-\d{6}$/);
    expect(user.phone).toBe('+251911223344');
    expect(user.displayName).toBe('Abebe Bikila');
    expect(user.gender).toBe('male');
    expect(user.grade).toBe(9);
    expect(user.stream).toBeNull();
    expect(user.role).toBe('student');
    expect(user.authProvider).toBe('phone');
    expect(user.pinHash).toBeUndefined(); // Security: pinHash must NEVER be exposed

    // Tokens
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();

    g9AccessToken = res.body.data.tokens.accessToken;
    g9AcedexId = user.acedexId;
  });

  it('POST /api/v1/auth/register-phone should register Grade 11 Natural Science student', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG11Natural,
      pin: testPin,
      fullName: 'Fatima Ahmed',
      gender: 'female',
      grade: 11,
      stream: 'natural',
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.grade).toBe(11);
    expect(res.body.data.user.stream).toBe('natural');
    expect(res.body.data.user.gender).toBe('female');
    expect(res.body.data.user.acedexId).toMatch(/^ACEDEX-\d{6}$/);
  });

  it('POST /api/v1/auth/register-phone should register Grade 12 Social Science student', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG12Social,
      pin: testPin,
      fullName: 'Yohannes Tesfaye',
      gender: 'male',
      grade: 12,
      stream: 'social',
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.grade).toBe(12);
    expect(res.body.data.user.stream).toBe('social');
    expect(res.body.data.user.acedexId).toMatch(/^ACEDEX-\d{6}$/);
  });

  it('POST /api/v1/auth/register-phone should reject duplicate phone with 409 Conflict', async () => {
    const res = await request(app).post('/api/v1/auth/register-phone').send({
      phone: testPhoneG9, // Already registered
      pin: '999999',
      fullName: 'Duplicate Student',
      gender: 'male',
      grade: 9,
    });

    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('CONFLICT');
  });

  it('POST /api/v1/auth/login-phone should log in student with local phone format and valid PIN', async () => {
    const res = await request(app).post('/api/v1/auth/login-phone').send({
      phone: '0911223344', // Local format
      pin: testPin,
    });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.acedexId).toBe(g9AcedexId);
    expect(res.body.data.tokens.accessToken).toBeDefined();
    expect(res.body.data.tokens.refreshToken).toBeDefined();
  });

  it('POST /api/v1/auth/login-phone should log in student with +251 format', async () => {
    const res = await request(app).post('/api/v1/auth/login-phone').send({
      phone: '+251911223344', // E.164 format
      pin: testPin,
    });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.acedexId).toBe(g9AcedexId);
  });

  it('POST /api/v1/auth/login-phone should reject incorrect PIN with 401 Unauthorized', async () => {
    const res = await request(app).post('/api/v1/auth/login-phone').send({
      phone: '0911223344',
      pin: '000000', // Incorrect PIN
    });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('POST /api/v1/auth/login-phone should reject non-existent phone with 401 Unauthorized', async () => {
    const res = await request(app).post('/api/v1/auth/login-phone').send({
      phone: '0999999999',
      pin: '123456',
    });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('GET /api/v1/auth/me should return full student profile with acedexId and onboarding fields', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${g9AccessToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.acedexId).toBe(g9AcedexId);
    expect(res.body.data.phone).toBe('+251911223344');
    expect(res.body.data.grade).toBe(9);
    expect(res.body.data.gender).toBe('male');
    expect(res.body.data.role).toBe('student');
    expect(res.body.data.authProvider).toBe('phone');
  });

  it('POST /api/v1/auth/change-pin should change PIN and require new PIN for subsequent logins', async () => {
    // 1. Change PIN
    const changeRes = await request(app)
      .post('/api/v1/auth/change-pin')
      .set('Authorization', `Bearer ${g9AccessToken}`)
      .send({
        currentPin: testPin,
        newPin: newPin,
      });

    expect(changeRes.status).toBe(200);
    expect(changeRes.body.success).toBe(true);

    // 2. Old PIN must now fail
    const oldLoginRes = await request(app).post('/api/v1/auth/login-phone').send({
      phone: testPhoneG9,
      pin: testPin,
    });
    expect(oldLoginRes.status).toBe(401);

    // 3. New PIN must succeed
    const newLoginRes = await request(app).post('/api/v1/auth/login-phone').send({
      phone: testPhoneG9,
      pin: newPin,
    });
    expect(newLoginRes.status).toBe(200);
    expect(newLoginRes.body.data.user.acedexId).toBe(g9AcedexId);
  }, 25000);
});
