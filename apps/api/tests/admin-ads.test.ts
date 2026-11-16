import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UserModel } from '../src/modules/users/user.model';
import { AdSessionModel } from '../src/modules/ads/models/ad-session.model';
import { AdConfigModel } from '../src/modules/ads/models/ad-config.model';
import { AuditLogModel } from '../src/modules/audit/audit-log.model';
import { env } from '../src/config/env';

describe('Admin Rewarded Ads Analytics & Remote Configuration (RBAC Protected)', () => {
  const app = createApp();

  let studentToken = '';
  let adminToken = '';
  let adminUserId = '';

  beforeAll(async () => {
    await connectDatabase();
    await CurriculumSeederService.seedCurriculum();

    // 1. Create Student User
    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Admin Ads Student',
      grade: 11,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    studentToken = jwt.sign(
      {
        sub: studentUser._id.toString(),
        acedexId: studentUser.acedexId,
        role: studentUser.role,
        displayName: studentUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 2. Create Admin User
    const adminUser = await UserModel.create({
      acedexId: `ACEDEX-${(Date.now() + 1).toString().slice(-6)}`,
      email: `ad-admin-${Date.now()}@example.com`,
      displayName: 'Ads Super Admin',
      role: 'admin',
      status: 'active',
      authProvider: 'google',
    });

    adminUserId = adminUser._id.toString();

    adminToken = jwt.sign(
      {
        sub: adminUserId,
        email: adminUser.email,
        role: adminUser.role,
        displayName: adminUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 3. Seed some mock sessions for analytics testing
    await AdSessionModel.create([
      {
        userId: studentUser._id,
        adSessionId: `adsess_test_1_${Date.now()}`,
        rewardType: 'streak_repair',
        platform: 'android',
        status: 'claimed',
        startedAt: new Date(),
        expiresAt: new Date(Date.now() + 600000),
        claimedAt: new Date(),
      },
      {
        userId: studentUser._id,
        adSessionId: `adsess_test_2_${Date.now()}`,
        rewardType: 'exam_access',
        platform: 'ios',
        status: 'claimed',
        startedAt: new Date(),
        expiresAt: new Date(Date.now() + 600000),
        claimedAt: new Date(),
      },
      {
        userId: studentUser._id,
        adSessionId: `adsess_test_3_${Date.now()}`,
        rewardType: 'offline_pack',
        platform: 'android',
        status: 'pending',
        startedAt: new Date(),
        expiresAt: new Date(Date.now() + 600000),
      },
    ]);
  }, 60000);

  afterAll(async () => {
    await AdSessionModel.deleteMany({ adSessionId: /adsess_test_/ });
    await UserModel.deleteMany({ displayName: /Admin Ads Student|Ads Super Admin/ });
    await AuditLogModel.deleteMany({ action: 'UPDATE_AD_CONFIG' });
    await disconnectDatabase();
  });

  it('GET /api/v1/admin/ads/analytics should reject non-admin users with 403 Forbidden', async () => {
    const res = await request(app)
      .get('/api/v1/admin/ads/analytics')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
  });

  it('GET /api/v1/admin/ads/analytics should return ad completions, funnel, and platform split', async () => {
    const res = await request(app)
      .get('/api/v1/admin/ads/analytics')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body.data;
    expect(data.summary).toBeDefined();
    expect(data.summary.totalAdsCompleted).toBeGreaterThanOrEqual(2);
    expect(data.summary.totalSessionsStarted).toBeGreaterThanOrEqual(3);
    expect(data.summary.completionFunnelRate).toBeGreaterThanOrEqual(0);
    expect(data.summary.uniqueViewersToday).toBeGreaterThanOrEqual(1);

    expect(data.byRewardType).toBeDefined();
    expect(data.byRewardType.streakRepair).toBeGreaterThanOrEqual(1);
    expect(data.byRewardType.examAccess).toBeGreaterThanOrEqual(1);

    expect(data.byPlatform).toBeDefined();
    expect(data.byPlatform.android).toBeGreaterThanOrEqual(1);
    expect(data.byPlatform.ios).toBeGreaterThanOrEqual(1);

    expect(data.timeSeries).toBeDefined();
    expect(data.timeSeries.today).toBeGreaterThanOrEqual(2);
  });

  it('GET /api/v1/admin/ads/sessions should return paginated ad sessions stream', async () => {
    const res = await request(app)
      .get('/api/v1/admin/ads/sessions?page=1&limit=10')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(res.body.meta).toBeDefined();
    expect(res.body.meta.page).toBe(1);
    expect(res.body.meta.limit).toBe(10);
  });

  it('GET /api/v1/admin/ads/config should return current remote configuration', async () => {
    const res = await request(app)
      .get('/api/v1/admin/ads/config')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.enabled).toBeDefined();
    expect(res.body.data.unityAds.androidGameId).toBe('6220248');
    expect(res.body.data.policies.offlinePack.durationHours).toBe(24);
  });

  it('PUT /api/v1/admin/ads/config should update remote config and record audit log', async () => {
    const res = await request(app)
      .put('/api/v1/admin/ads/config')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        isAdsEnabled: true,
        policies: {
          streakRepair: { cooldownHours: 12 },
          examAccess: { ticketsPerAd: 2 },
        },
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.policies.streakRepair.cooldownHours).toBe(12);
    expect(res.body.data.policies.examAccess.ticketsPerAd).toBe(2);

    // Verify Audit Log was recorded
    const auditEntry = await AuditLogModel.findOne({
      action: 'UPDATE_AD_CONFIG',
      userId: adminUserId,
    });
    expect(auditEntry).toBeDefined();
    expect(auditEntry?.resource).toBe('ad_config');
  });
});
