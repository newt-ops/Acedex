-- Down Migration: Rollback Assessment Platform Schema
-- Drops created assessment tables, triggers, and procedures in reverse topological order.
-- Completely preserves existing core tables (students, subjects, chapters, chapter_progress, study_sessions).

DROP FUNCTION IF EXISTS public.reconcile_and_grade_offline_attempt(UUID, UUID, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, JSONB);
DROP FUNCTION IF EXISTS public.grade_and_submit_attempt(UUID, TEXT, JSONB);
DROP FUNCTION IF EXISTS public.start_assessment_attempt(UUID, TEXT);
DROP FUNCTION IF EXISTS public.publish_assessment_version(UUID);

DROP TRIGGER IF EXISTS trg_freeze_student_answers ON public.student_answers;
DROP TRIGGER IF EXISTS trg_freeze_assessment_results ON public.assessment_results;
DROP TRIGGER IF EXISTS trg_freeze_assessment_version_chapters ON public.assessment_version_chapters;
DROP TRIGGER IF EXISTS trg_freeze_question_solutions ON public.question_solutions;
DROP TRIGGER IF EXISTS trg_freeze_question_options ON public.question_options;
DROP TRIGGER IF EXISTS trg_freeze_questions ON public.questions;
DROP TRIGGER IF EXISTS trg_freeze_assessment_versions ON public.assessment_versions;

DROP FUNCTION IF EXISTS public.trg_protect_submitted_records();
DROP FUNCTION IF EXISTS public.trg_protect_published_content();
DROP FUNCTION IF EXISTS public.trg_protect_assessment_versions();

DROP TABLE IF EXISTS public.assessment_results CASCADE;
DROP TABLE IF EXISTS public.student_answers CASCADE;
DROP TABLE IF EXISTS public.assessment_attempts CASCADE;
DROP TABLE IF EXISTS public.question_solutions CASCADE;
DROP TABLE IF EXISTS public.question_options CASCADE;
DROP TABLE IF EXISTS public.questions CASCADE;
DROP TABLE IF EXISTS public.assessment_version_chapters CASCADE;
DROP TABLE IF EXISTS public.assessment_versions CASCADE;
DROP TABLE IF EXISTS public.assessments CASCADE;

DROP TYPE IF EXISTS public.attempt_status_enum;
DROP TYPE IF EXISTS public.assessment_version_status_enum;
DROP TYPE IF EXISTS public.assessment_type_enum;
