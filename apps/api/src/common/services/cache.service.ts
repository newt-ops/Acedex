import { PublicQuestionItem } from '@acedex/contracts';
import { logger } from '../utils/logger';

interface CacheEntry<T> {
  value: T;
  expiresAt: number;
}

export class ContentCacheService {
  private static store = new Map<string, CacheEntry<any>>();
  private static hitCount = 0;
  private static missCount = 0;

  /**
   * Default TTL: 1 hour (3600 seconds) for curriculum content
   */
  private static DEFAULT_TTL_SECONDS = 3600;

  /**
   * Retrieves an item from cache if present and not expired
   */
  public static get<T>(key: string): T | null {
    const entry = this.store.get(key);
    if (!entry) {
      this.missCount++;
      return null;
    }

    if (Date.now() > entry.expiresAt) {
      this.store.delete(key);
      this.missCount++;
      return null;
    }

    this.hitCount++;
    return entry.value as T;
  }

  /**
   * Stores an item with a time-to-live in seconds
   */
  public static set<T>(key: string, value: T, ttlSeconds = this.DEFAULT_TTL_SECONDS): void {
    // Evict oldest entries if map exceeds 5000 items to prevent memory bloat
    if (this.store.size >= 5000) {
      const firstKey = this.store.keys().next().value;
      if (firstKey) this.store.delete(firstKey);
    }

    this.store.set(key, {
      value,
      expiresAt: Date.now() + ttlSeconds * 1000,
    });
  }

  /**
   * Deletes a specific cache key
   */
  public static del(key: string): void {
    this.store.delete(key);
  }

  /**
   * Deletes all keys matching a given prefix
   */
  public static delPrefix(prefix: string): void {
    for (const key of this.store.keys()) {
      if (key.startsWith(prefix)) {
        this.store.delete(key);
      }
    }
  }

  /**
   * Clears entire in-memory cache
   */
  public static clear(): void {
    this.store.clear();
    this.hitCount = 0;
    this.missCount = 0;
  }

  /**
   * Returns cache metrics
   */
  public static stats() {
    return {
      size: this.store.size,
      hits: this.hitCount,
      misses: this.missCount,
      hitRatio:
        this.hitCount + this.missCount > 0
          ? Math.round((this.hitCount / (this.hitCount + this.missCount)) * 1000) / 10
          : 0,
    };
  }

  // ==========================================
  // Domain-Specific Specialized Cache Accessors
  // ==========================================

  public static getUnitQuestions(unitId: string): PublicQuestionItem[] | null {
    return this.get<PublicQuestionItem[]>(`unit_questions:${unitId}`);
  }

  public static setUnitQuestions(unitId: string, questions: PublicQuestionItem[]): void {
    this.set(`unit_questions:${unitId}`, questions, 3600);
  }

  public static getUnitAnswerKeys(
    unitId: string
  ): Map<string, { correctOptionId: 'A' | 'B' | 'C' | 'D'; explanation: string }> | null {
    const raw = this.get<Array<[string, { correctOptionId: 'A' | 'B' | 'C' | 'D'; explanation: string }]>>(
      `unit_keys:${unitId}`
    );
    if (!raw) return null;
    return new Map(raw);
  }

  public static setUnitAnswerKeys(
    unitId: string,
    keysMap: Map<string, { correctOptionId: 'A' | 'B' | 'C' | 'D'; explanation: string }>
  ): void {
    this.set(`unit_keys:${unitId}`, Array.from(keysMap.entries()), 3600);
  }

  /**
   * Invalidates all cached content for a unit (used when admin publishes, updates, or imports questions)
   */
  public static invalidateUnit(unitId: string): void {
    this.del(`unit_questions:${unitId}`);
    this.del(`unit_keys:${unitId}`);
    this.del(`unit_summary:${unitId}`);
    this.delPrefix('subjects:');
    this.delPrefix('units:');
    logger.info({ unitId }, 'Content cache invalidated for unit');
  }
}
