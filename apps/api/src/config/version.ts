/**
 * Application Version Configuration
 * Single source of truth loaded from apps/api/package.json
 */
let resolvedVersion = '1.0.0';

try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const pkg = require('../../package.json');
  if (pkg && typeof pkg.version === 'string') {
    resolvedVersion = pkg.version;
  }
} catch {
  // Fallback to default version if package.json cannot be read
}

export const API_VERSION: string = resolvedVersion;
