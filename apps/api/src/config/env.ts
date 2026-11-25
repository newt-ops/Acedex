import dotenv from 'dotenv';
import path from 'path';
import { z } from 'zod';

// Load .env from current directory or root if present
dotenv.config();
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(5000),
  API_PREFIX: z.string().default('/api/v1'),
  MONGODB_URI: z.string().optional().default(''),
  COLLECTOR_DB_NAME: z.string().default('acedex_collector'),
  COLLECTOR_MONGODB_URI: z.string().optional(),
  NOTES_DB_NAME: z.string().default('acedex_notes'),
  NOTES_MONGODB_URI: z.string().optional(),
  CORS_ORIGIN: z.string().default('http://localhost:3000,http://localhost:5173'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).default('info'),
  JWT_ACCESS_SECRET: z.string().default('development-jwt-access-secret-change-in-prod'),
  JWT_REFRESH_SECRET: z.string().default('development-jwt-refresh-secret-change-in-prod'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),
  ADMIN_EMAILS: z.string().optional().default('aymenmubarek10@gmail.com'),
  UNITY_ADS_ANDROID_GAME_ID: z.string().default('6220248'),
  UNITY_ADS_IOS_GAME_ID: z.string().default('6220249'),
  UNITY_ADS_ANDROID_PLACEMENT: z.string().default('Reward_Android_Acedex'),
  UNITY_ADS_IOS_PLACEMENT: z.string().default('Rewarded_iOS'),
  UNITY_ADS_SECRET_KEY: z.string().optional(),
  UNITY_ADS_S2S_REQUIRED: z.preprocess((val) => val === 'true' || val === true, z.boolean()).default(false),
  REQUIRE_EXAM_TICKET: z.preprocess((val) => val === 'true' || val === true, z.boolean()).default(false),
  GEMINI_API_KEY: z.string().optional(),
  GEMINI_MODEL: z.string().default('gemini-2.0-flash'),
  GEMINI_FALLBACK_MODELS: z
    .string()
    .default('gemini-1.5-flash,gemini-2.0-flash-lite,gemini-2.5-flash'),
  GEMINI_THINKING_BUDGET: z.coerce.number().int().min(0).default(0),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment configuration:', JSON.stringify(parsed.error.format(), null, 2));
  throw new Error('Environment variable validation failed');
}

export const env = parsed.data;

export const adminEmails: string[] = env.ADMIN_EMAILS
  ? env.ADMIN_EMAILS.split(',')
      .map((email) => email.trim().toLowerCase())
      .filter(Boolean)
  : [];

// In production, enforce MONGODB_URI
if (env.NODE_ENV === 'production' && !env.MONGODB_URI) {
  throw new Error('MONGODB_URI is strictly required in production mode');
}
