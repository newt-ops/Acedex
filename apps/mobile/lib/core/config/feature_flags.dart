/// Centralized feature flags for the Acedex mobile application.
///
/// Disables features whose content is not yet authored/seeded (e.g. Flashcards, Smart Notes)
/// without deleting any existing widgets, tests, or models.
class FeatureFlags {
  FeatureFlags._();

  /// Formula and Concept Flashcards Carousel.
  /// Disabled for now as requested; re-enable once flashcard decks are authored.
  static bool enableFlashcards = false;

  /// Smart Notes Reader sheets and summary tabs.
  /// Disabled for now as requested; re-enable once concise notes are authored.
  /// When disabled, hero buttons and subtopic actions direct students directly to the
  /// authentic 15-question unit drill/assessment.
  static bool enableSmartNotes = false;
}
