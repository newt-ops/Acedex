import pino from 'pino';

const isProduction = process.env.NODE_ENV === 'production';
const isTest = process.env.NODE_ENV === 'test';
const logLevel = process.env.LOG_LEVEL || (isTest ? 'silent' : isProduction ? 'info' : 'debug');

export const logger = pino({
  level: logLevel,
  transport:
    !isProduction && !isTest
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:yyyy-mm-dd HH:MM:ss.l',
            ignore: 'pid,hostname',
          },
        }
      : undefined,
  base: isProduction
    ? {
        env: process.env.NODE_ENV,
      }
    : undefined,
  timestamp: pino.stdTimeFunctions.isoTime,
});
