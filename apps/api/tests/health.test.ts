import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';

describe('Health and Status Endpoints', () => {
  const app = createApp();

  it('GET / should return root API metadata', async () => {
    const res = await request(app).get('/');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('name', 'Acedex API');
    expect(res.body).toHaveProperty('version', '1.0.0');
    expect(res.body).toHaveProperty('endpoints');
  });

  it('GET /health should return system health structure', async () => {
    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('success', true);
    expect(res.body.data).toHaveProperty('status');
    expect(res.body.data).toHaveProperty('timestamp');
    expect(res.body.data).toHaveProperty('uptimeSeconds');
    expect(res.body.data).toHaveProperty('database');
    expect(res.body.data).toHaveProperty('memory');
    expect(typeof res.body.data.memory.heapUsedMB).toBe('number');
  });

  it('GET /ready should return readiness response', async () => {
    const res = await request(app).get('/ready');

    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      success: true,
      status: 'ready',
    });
  });

  it('GET /api/v1/health should match root health response structure', async () => {
    const res = await request(app).get('/api/v1/health');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('success', true);
    expect(res.body.data.version).toBe('1.0.0');
    expect(res.body.data.database).toHaveProperty('connected');
  });
});
