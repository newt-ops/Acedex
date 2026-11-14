-- Migration: Create Assessment Platform Schema
-- Version: 20261115000000
-- Preserves existing curriculum & student tables. Introduces immutable versioned assessments,
-- multi-unit coverage, air-gapped private solutions, composite integrity, and atomic grading.

-- 1. ENUMS
DO $$ BEGIN
  CREATE TYPE public.assessment_type_enum AS ENUM ('unit', 'subject_mock', 'grade_cumulative', 'euee_mock');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.assessment_version_status_enum AS ENUM ('draft', 'published', 'archived');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.attempt_status_enum AS ENUM ('in_progress', 'submitted', 'abandoned');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. ASSESSMENTS TABLE (Logical Container)
CREATE TABLE IF NOT EXISTS public.assessments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  assessment_type public.assessment_type_enum NOT NULL DEFAULT 'unit',
  current_version_id UUID, -- Forward reference added via ALTER TABLE below
  subject_id TEXT REFERENCES public.subjects(id) ON DELETE RESTRICT,
  grade INTEGER CHECK (grade IN (9, 10, 11, 12)),
  stream TEXT CHECK (stream IN ('natural', 'social', 'common')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. ASSESSMENT VERSIONS TABLE (Immutable Snapshots)
CREATE TABLE IF NOT EXISTS public.assessment_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_id UUID NOT NULL REFERENCES public.assessments(id) ON DELETE RESTRICT,
  version_number INTEGER NOT NULL DEFAULT 1 CHECK (version_number > 0),
  status public.assessment_version_status_enum NOT NULL DEFAULT 'draft',
  total_questions INTEGER NOT NULL DEFAULT 0 CHECK (total_questions >= 0),
  total_points NUMERIC(6, 2) NOT NULL DEFAULT 0.00 CHECK (total_points >= 0),
  time_limit_minutes INTEGER CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0),
  passing_percentage NUMERIC(5, 2) CHECK (passing_percentage IS NULL OR (passing_percentage >= 0 AND passing_percentage <= 100)),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_assessment_version_number UNIQUE (assessment_id, version_number)
);

-- Circular foreign key for designated current version
DO $$ BEGIN
  ALTER TABLE public.assessments
    ADD CONSTRAINT fk_assessment_current_version
    FOREIGN KEY (current_version_id)
    REFERENCES public.assessment_versions(id)
    ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 4. ASSESSMENT VERSION CHAPTERS (Immutable Versioned Chapter Coverage)
CREATE TABLE IF NOT EXISTS public.assessment_version_chapters (
  assessment_version_id UUID NOT NULL REFERENCES public.assessment_versions(id) ON DELETE RESTRICT,
  chapter_id TEXT NOT NULL REFERENCES public.chapters(id) ON DELETE RESTRICT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (assessment_version_id, chapter_id)
);

-- 5. QUESTIONS TABLE (Public Content)
CREATE TABLE IF NOT EXISTS public.questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_version_id UUID NOT NULL REFERENCES public.assessment_versions(id) ON DELETE RESTRICT,
  chapter_id TEXT NOT NULL REFERENCES public.chapters(id) ON DELETE RESTRICT,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL DEFAULT 'single_choice' CHECK (question_type IN ('single_choice')),
  image_url TEXT,
  points NUMERIC(5, 2) NOT NULL DEFAULT 1.00 CHECK (points > 0),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_questions_version_order UNIQUE (assessment_version_id, sort_order),
  CONSTRAINT uq_questions_id_version UNIQUE (id, assessment_version_id)
);

-- 6. QUESTION OPTIONS TABLE (Public Content)
CREATE TABLE IF NOT EXISTS public.question_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  option_letter CHAR(1) NOT NULL CHECK (option_letter IN ('A', 'B', 'C', 'D')),
  option_text TEXT NOT NULL,
  image_url TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT uq_question_option_letter UNIQUE (question_id, option_letter),
  CONSTRAINT uq_question_option_id_qid UNIQUE (question_id, id)
);

-- 7. QUESTION SOLUTIONS TABLE (Private Air-Gapped Answer Key)
CREATE TABLE IF NOT EXISTS public.question_solutions (
  question_id UUID PRIMARY KEY REFERENCES public.questions(id) ON DELETE CASCADE,
  correct_option_id UUID NOT NULL,
  explanation TEXT NOT NULL,
  reference_source TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_solution_correct_option 
    FOREIGN KEY (question_id, correct_option_id) 
    REFERENCES public.question_options(question_id, id) 
    ON DELETE RESTRICT
);

-- 8. ASSESSMENT ATTEMPTS TABLE
CREATE TABLE IF NOT EXISTS public.assessment_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE RESTRICT,
  assessment_version_id UUID NOT NULL REFERENCES public.assessment_versions(id) ON DELETE RESTRICT,
  status public.attempt_status_enum NOT NULL DEFAULT 'in_progress',
  is_offline_sync BOOLEAN NOT NULL DEFAULT false,
  timing_verified BOOLEAN NOT NULL DEFAULT false,
  server_started_at TIMESTAMPTZ,
  server_submitted_at TIMESTAMPTZ,
  server_reconciled_at TIMESTAMPTZ,
  client_reported_started_at TIMESTAMPTZ,
  client_reported_submitted_at TIMESTAMPTZ,
  server_duration_seconds INTEGER CHECK (server_duration_seconds IS NULL OR server_duration_seconds >= 0),
  client_reported_duration_seconds INTEGER CHECK (client_reported_duration_seconds IS NULL OR client_reported_duration_seconds >= 0),
  idempotency_key TEXT NOT NULL,
  submission_payload_hash TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_student_attempt_idempotency UNIQUE (student_id, idempotency_key),
  CONSTRAINT uq_attempt_student_version UNIQUE (id, student_id, assessment_version_id)
);

-- 9. STUDENT ANSWERS TABLE (Server Written Only)
CREATE TABLE IF NOT EXISTS public.student_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL,
  student_id UUID NOT NULL,
  assessment_version_id UUID NOT NULL,
  question_id UUID NOT NULL,
  selected_option_id UUID,
  is_correct BOOLEAN,
  points_awarded NUMERIC(5, 2) DEFAULT 0.00 CHECK (points_awarded >= 0),
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_attempt_question UNIQUE (attempt_id, question_id),
  CONSTRAINT fk_student_answer_option 
    FOREIGN KEY (question_id, selected_option_id) 
    REFERENCES public.question_options(question_id, id) 
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_answer_question_version 
    FOREIGN KEY (question_id, assessment_version_id) 
    REFERENCES public.questions(id, assessment_version_id) 
    ON DELETE RESTRICT,
  CONSTRAINT fk_student_answer_attempt_owner 
    FOREIGN KEY (attempt_id, student_id, assessment_version_id) 
    REFERENCES public.assessment_attempts(id, student_id, assessment_version_id) 
    ON DELETE CASCADE
);

-- 10. ASSESSMENT RESULTS TABLE (Immutable Report Card)
CREATE TABLE IF NOT EXISTS public.assessment_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL UNIQUE,
  student_id UUID NOT NULL,
  assessment_version_id UUID NOT NULL,
  total_questions INTEGER NOT NULL CHECK (total_questions > 0),
  answered_questions INTEGER NOT NULL DEFAULT 0 CHECK (answered_questions >= 0),
  correct_answers INTEGER NOT NULL DEFAULT 0 CHECK (correct_answers >= 0),
  incorrect_answers INTEGER NOT NULL DEFAULT 0 CHECK (incorrect_answers >= 0),
  skipped_questions INTEGER NOT NULL DEFAULT 0 CHECK (skipped_questions >= 0),
  score_obtained NUMERIC(6, 2) NOT NULL DEFAULT 0.00 CHECK (score_obtained >= 0),
  max_score NUMERIC(6, 2) NOT NULL CHECK (max_score > 0),
  percentage NUMERIC(5, 2) NOT NULL CHECK (percentage >= 0.00 AND percentage <= 100.00),
  passed BOOLEAN,
  is_overdue BOOLEAN NOT NULL DEFAULT false,
  is_overdue_unverified BOOLEAN NOT NULL DEFAULT false,
  graded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_result_attempt_student_version 
    FOREIGN KEY (attempt_id, student_id, assessment_version_id) 
    REFERENCES public.assessment_attempts(id, student_id, assessment_version_id) 
    ON DELETE RESTRICT,
  CONSTRAINT check_question_counts 
    CHECK ((answered_questions + skipped_questions) = total_questions),
  CONSTRAINT check_answer_breakdown 
    CHECK ((correct_answers + incorrect_answers) = answered_questions),
  CONSTRAINT check_score_upper_bound 
    CHECK (score_obtained <= max_score),
  CONSTRAINT check_percentage_consistency 
    CHECK (percentage = ROUND(((score_obtained / max_score) * 100)::numeric, 2))
);

-- 11. INDEXES
CREATE INDEX IF NOT EXISTS idx_assessments_subject ON public.assessments(subject_id);
CREATE INDEX IF NOT EXISTS idx_assessment_versions_assessment ON public.assessment_versions(assessment_id, status);
CREATE INDEX IF NOT EXISTS idx_assessment_version_chapters_chapter ON public.assessment_version_chapters(chapter_id);
CREATE INDEX IF NOT EXISTS idx_questions_version_sort ON public.questions(assessment_version_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_questions_chapter ON public.questions(chapter_id);
CREATE INDEX IF NOT EXISTS idx_question_options_question ON public.question_options(question_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_attempts_student_status ON public.assessment_attempts(student_id, status);
CREATE INDEX IF NOT EXISTS idx_attempts_idempotency ON public.assessment_attempts(student_id, idempotency_key);
CREATE INDEX IF NOT EXISTS idx_student_answers_attempt ON public.student_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_assessment_results_student ON public.assessment_results(student_id, assessment_version_id);

-- 12. PUBLICATION VALIDATION PROCEDURE
CREATE OR REPLACE FUNCTION public.publish_assessment_version(p_version_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_version RECORD;
  v_assessment RECORD;
  v_question RECORD;
  v_count INTEGER := 0;
  v_points NUMERIC(6, 2) := 0.00;
  v_opt_count INTEGER;
  v_sol_count INTEGER;
  v_chap_count INTEGER;
  v_invalid_chapter TEXT;
BEGIN
  SELECT * INTO v_version 
  FROM public.assessment_versions 
  WHERE id = p_version_id 
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assessment version % not found.', p_version_id;
  END IF;

  IF v_version.status = 'published' THEN
    RAISE EXCEPTION 'Assessment version % is already published.', p_version_id;
  END IF;

  IF v_version.status = 'archived' THEN
    RAISE EXCEPTION 'Cannot publish an archived assessment version.';
  END IF;

  SELECT * INTO v_assessment 
  FROM public.assessments 
  WHERE id = v_version.assessment_id 
  FOR UPDATE;

  SELECT pg_catalog.count(*) INTO v_chap_count 
  FROM public.assessment_version_chapters 
  WHERE assessment_version_id = p_version_id;
  
  IF v_chap_count = 0 THEN
    RAISE EXCEPTION 'Publication rejected: Version must declare at least 1 covered chapter.';
  END IF;

  IF v_assessment.assessment_type = 'unit' THEN
    IF v_chap_count != 1 THEN
      RAISE EXCEPTION 'Publication rejected: Unit assessments must cover exactly 1 chapter (declared %).', v_chap_count;
    END IF;
  ELSIF v_assessment.assessment_type = 'subject_mock' THEN
    SELECT c.id INTO v_invalid_chapter
    FROM public.assessment_version_chapters avc
    JOIN public.chapters c ON c.id = avc.chapter_id
    WHERE avc.assessment_version_id = p_version_id
      AND c.subject_id != v_assessment.subject_id
    LIMIT 1;
    IF v_invalid_chapter IS NOT NULL THEN
      RAISE EXCEPTION 'Publication rejected: Chapter % does not belong to subject %.', v_invalid_chapter, v_assessment.subject_id;
    END IF;
  ELSIF v_assessment.assessment_type = 'grade_cumulative' THEN
    SELECT c.id INTO v_invalid_chapter
    FROM public.assessment_version_chapters avc
    JOIN public.chapters c ON c.id = avc.chapter_id
    JOIN public.subjects s ON s.id = c.subject_id
    WHERE avc.assessment_version_id = p_version_id
      AND s.grade != v_assessment.grade
    LIMIT 1;
    IF v_invalid_chapter IS NOT NULL THEN
      RAISE EXCEPTION 'Publication rejected: Chapter % is not in Grade %.', v_invalid_chapter, v_assessment.grade;
    END IF;
  END IF;

  FOR v_question IN 
    SELECT q.id, q.points, q.sort_order, q.chapter_id
    FROM public.questions q 
    WHERE q.assessment_version_id = p_version_id 
    ORDER BY q.sort_order ASC
  LOOP
    v_count := v_count + 1;
    v_points := v_points + v_question.points;

    IF NOT EXISTS (
      SELECT 1 FROM public.assessment_version_chapters 
      WHERE assessment_version_id = p_version_id AND chapter_id = v_question.chapter_id
    ) THEN
      RAISE EXCEPTION 'Question % references chapter % which is not covered by this version.', v_question.id, v_question.chapter_id;
    END IF;

    SELECT pg_catalog.count(*) INTO v_opt_count 
    FROM public.question_options 
    WHERE question_id = v_question.id;
    
    IF v_opt_count != 4 THEN
      RAISE EXCEPTION 'Question % (Order %) has % options; exactly 4 required.', v_question.id, v_question.sort_order, v_opt_count;
    END IF;

    SELECT pg_catalog.count(*) INTO v_sol_count 
    FROM public.question_solutions 
    WHERE question_id = v_question.id AND pg_catalog.btrim(explanation) != '';
    
    IF v_sol_count != 1 THEN
      RAISE EXCEPTION 'Question % (Order %) lacks an air-gapped solution or explanation.', v_question.id, v_question.sort_order;
    END IF;
  END LOOP;

  IF v_count = 0 THEN
    RAISE EXCEPTION 'Publication rejected: Assessment version contains 0 questions.';
  END IF;

  UPDATE public.assessment_versions
  SET status = 'published',
      total_questions = v_count,
      total_points = v_points,
      published_at = pg_catalog.clock_timestamp(),
      updated_at = pg_catalog.clock_timestamp()
  WHERE id = p_version_id;

  UPDATE public.assessments
  SET current_version_id = p_version_id,
      updated_at = pg_catalog.clock_timestamp()
  WHERE id = v_version.assessment_id;
END;
$$;

ALTER FUNCTION public.publish_assessment_version(UUID) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.publish_assessment_version(UUID) FROM PUBLIC, anon, authenticated;

-- 13. IMMUTABILITY TRIGGERS
CREATE OR REPLACE FUNCTION public.trg_protect_assessment_versions()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.status IN ('published', 'archived') THEN
      RAISE EXCEPTION 'Deletion prohibited: Published and archived assessment versions are permanently preserved.';
    END IF;
    RETURN OLD;
  END IF;

  IF OLD.status IN ('published', 'archived') AND NEW.status = 'draft' THEN
    RAISE EXCEPTION 'Status violation: A published or archived version cannot be reverted to draft.';
  END IF;

  IF OLD.status IN ('published', 'archived') THEN
    IF NEW.total_questions != OLD.total_questions OR
       NEW.total_points != OLD.total_points OR
       NEW.time_limit_minutes IS DISTINCT FROM OLD.time_limit_minutes OR
       NEW.passing_percentage IS DISTINCT FROM OLD.passing_percentage OR
       NEW.version_number != OLD.version_number OR
       NEW.assessment_id != OLD.assessment_id THEN
      RAISE EXCEPTION 'Immutability violation: Published version configuration is permanently frozen.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_freeze_assessment_versions ON public.assessment_versions;
CREATE TRIGGER trg_freeze_assessment_versions
  BEFORE UPDATE OR DELETE ON public.assessment_versions
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_assessment_versions();

CREATE OR REPLACE FUNCTION public.trg_protect_published_content()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_old_version_id UUID;
  v_new_version_id UUID;
  v_status public.assessment_version_status_enum;
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    IF TG_TABLE_NAME = 'questions' OR TG_TABLE_NAME = 'assessment_version_chapters' THEN
      v_old_version_id := OLD.assessment_version_id;
    ELSIF TG_TABLE_NAME = 'question_options' OR TG_TABLE_NAME = 'question_solutions' THEN
      SELECT assessment_version_id INTO v_old_version_id FROM public.questions WHERE id = OLD.question_id;
    END IF;

    IF v_old_version_id IS NOT NULL THEN
      SELECT status INTO v_status FROM public.assessment_versions WHERE id = v_old_version_id;
      IF v_status IN ('published', 'archived') THEN
        RAISE EXCEPTION 'Modification prohibited: Content belongs to a frozen published version.';
      END IF;
    END IF;
  END IF;

  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    IF TG_TABLE_NAME = 'questions' OR TG_TABLE_NAME = 'assessment_version_chapters' THEN
      v_new_version_id := NEW.assessment_version_id;
    ELSIF TG_TABLE_NAME = 'question_options' OR TG_TABLE_NAME = 'question_solutions' THEN
      SELECT assessment_version_id INTO v_new_version_id FROM public.questions WHERE id = NEW.question_id;
    END IF;

    IF v_new_version_id IS NOT NULL THEN
      SELECT status INTO v_status FROM public.assessment_versions WHERE id = v_new_version_id;
      IF v_status IN ('published', 'archived') THEN
        RAISE EXCEPTION 'Insertion prohibited: Target assessment version is published and frozen.';
      END IF;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_freeze_questions ON public.questions;
CREATE TRIGGER trg_freeze_questions
  BEFORE INSERT OR UPDATE OR DELETE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_published_content();

DROP TRIGGER IF EXISTS trg_freeze_question_options ON public.question_options;
CREATE TRIGGER trg_freeze_question_options
  BEFORE INSERT OR UPDATE OR DELETE ON public.question_options
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_published_content();

DROP TRIGGER IF EXISTS trg_freeze_question_solutions ON public.question_solutions;
CREATE TRIGGER trg_freeze_question_solutions
  BEFORE INSERT OR UPDATE OR DELETE ON public.question_solutions
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_published_content();

DROP TRIGGER IF EXISTS trg_freeze_assessment_version_chapters ON public.assessment_version_chapters;
CREATE TRIGGER trg_freeze_assessment_version_chapters
  BEFORE INSERT OR UPDATE OR DELETE ON public.assessment_version_chapters
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_published_content();

CREATE OR REPLACE FUNCTION public.trg_protect_submitted_records()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Deletion prohibited: Graded results and student answers cannot be deleted.';
  END IF;
  IF TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION 'Update prohibited: Graded results and student answers are permanently immutable.';
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_freeze_assessment_results ON public.assessment_results;
CREATE TRIGGER trg_freeze_assessment_results
  BEFORE UPDATE OR DELETE ON public.assessment_results
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_submitted_records();

DROP TRIGGER IF EXISTS trg_freeze_student_answers ON public.student_answers;
CREATE TRIGGER trg_freeze_student_answers
  BEFORE UPDATE OR DELETE ON public.student_answers
  FOR EACH ROW EXECUTE FUNCTION public.trg_protect_submitted_records();

-- 14. ATTEMPT CREATION & GRADING FUNCTIONS
CREATE OR REPLACE FUNCTION public.start_assessment_attempt(
  p_assessment_id UUID,
  p_idempotency_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_student_id UUID;
  v_assessment RECORD;
  v_version RECORD;
  v_existing_attempt RECORD;
  v_attempt_id UUID;
  v_now TIMESTAMPTZ := pg_catalog.clock_timestamp();
BEGIN
  v_student_id := auth.uid();
  IF v_student_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User authentication required.' USING ERRCODE = '42501';
  END IF;

  IF p_idempotency_key IS NULL OR pg_catalog.btrim(p_idempotency_key) = '' THEN
    RAISE EXCEPTION 'Invalid idempotency key.' USING ERRCODE = '23505';
  END IF;

  SELECT * INTO v_existing_attempt
  FROM public.assessment_attempts
  WHERE student_id = v_student_id AND idempotency_key = p_idempotency_key;

  IF FOUND THEN
    SELECT * INTO v_version FROM public.assessment_versions WHERE id = v_existing_attempt.assessment_version_id;
    RETURN pg_catalog.jsonb_build_object(
      'status', 'existing',
      'attempt_id', v_existing_attempt.id,
      'assessment_version_id', v_existing_attempt.assessment_version_id,
      'server_started_at', v_existing_attempt.server_started_at,
      'time_limit_minutes', v_version.time_limit_minutes,
      'total_questions', v_version.total_questions
    );
  END IF;

  SELECT * INTO v_assessment
  FROM public.assessments
  WHERE id = p_assessment_id AND is_archived = false;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assessment % not found or is archived.', p_assessment_id;
  END IF;

  IF v_assessment.current_version_id IS NULL THEN
    RAISE EXCEPTION 'Assessment has no published current version.';
  END IF;

  SELECT * INTO v_version
  FROM public.assessment_versions
  WHERE id = v_assessment.current_version_id AND status = 'published';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Designated current version is not published.';
  END IF;

  v_attempt_id := pg_catalog.gen_random_uuid();

  INSERT INTO public.assessment_attempts (
    id,
    student_id,
    assessment_version_id,
    status,
    is_offline_sync,
    timing_verified,
    server_started_at,
    idempotency_key
  ) VALUES (
    v_attempt_id,
    v_student_id,
    v_version.id,
    'in_progress',
    false,
    true,
    v_now,
    p_idempotency_key
  );

  RETURN pg_catalog.jsonb_build_object(
    'status', 'created',
    'attempt_id', v_attempt_id,
    'assessment_version_id', v_version.id,
    'server_started_at', v_now,
    'time_limit_minutes', v_version.time_limit_minutes,
    'total_questions', v_version.total_questions
  );
END;
$$;

ALTER FUNCTION public.start_assessment_attempt(UUID, TEXT) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.start_assessment_attempt(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.start_assessment_attempt(UUID, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.grade_and_submit_attempt(
  p_attempt_id UUID,
  p_idempotency_key TEXT,
  p_answers JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_student_id UUID;
  v_attempt RECORD;
  v_version RECORD;
  v_server_now TIMESTAMPTZ := pg_catalog.clock_timestamp();
  v_duration_seconds INTEGER;
  v_is_overdue BOOLEAN := false;
  v_payload_hash TEXT;
  v_item JSONB;
  v_q_id UUID;
  v_opt_id UUID;
  v_question RECORD;
  v_is_correct BOOLEAN;
  v_points_awarded NUMERIC(5, 2);
  v_total_questions INTEGER := 0;
  v_answered_questions INTEGER := 0;
  v_correct_answers INTEGER := 0;
  v_incorrect_answers INTEGER := 0;
  v_skipped_questions INTEGER := 0;
  v_score_obtained NUMERIC(6, 2) := 0.00;
  v_max_score NUMERIC(6, 2) := 0.00;
  v_percentage NUMERIC(5, 2) := 0.00;
  v_passed BOOLEAN := NULL;
  v_corrections JSONB := '[]'::jsonb;
  v_uuid_regex TEXT := '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
  v_seen_questions UUID[] := ARRAY[]::UUID[];
  v_key_text TEXT;
BEGIN
  v_student_id := auth.uid();
  IF v_student_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User authentication required.' USING ERRCODE = '42501';
  END IF;

  IF p_answers IS NULL OR pg_catalog.jsonb_typeof(p_answers) != 'array' THEN
    RAISE EXCEPTION 'Malformed payload: p_answers must be a JSON array.' USING ERRCODE = '22023';
  END IF;

  v_payload_hash := pg_catalog.md5(p_answers::text);

  SELECT * INTO v_attempt
  FROM public.assessment_attempts
  WHERE id = p_attempt_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Attempt % not found.', p_attempt_id USING ERRCODE = 'P0002';
  END IF;

  IF v_attempt.student_id != v_student_id THEN
    RAISE EXCEPTION 'Forbidden: You do not own this attempt.' USING ERRCODE = '42501';
  END IF;

  IF p_idempotency_key IS NULL OR pg_catalog.btrim(p_idempotency_key) = '' OR
     v_attempt.idempotency_key IS DISTINCT FROM p_idempotency_key THEN
    RAISE EXCEPTION 'Invalid idempotency key.' USING ERRCODE = '23505';
  END IF;

  IF v_attempt.status = 'submitted' THEN
    IF v_attempt.submission_payload_hash IS NOT NULL AND v_attempt.submission_payload_hash IS DISTINCT FROM v_payload_hash THEN
      RAISE EXCEPTION 'Idempotency violation: Payload does not match original submission.' USING ERRCODE = '23505';
    END IF;

    SELECT r.*, 
           pg_catalog.jsonb_agg(pg_catalog.jsonb_build_object(
             'question_id', a.question_id,
             'selected_option_id', a.selected_option_id,
             'correct_option_id', s.correct_option_id,
             'is_correct', a.is_correct,
             'points_awarded', a.points_awarded,
             'explanation', s.explanation
           ) ORDER BY q.sort_order ASC) as corrections
    INTO v_version
    FROM public.assessment_results r
    JOIN public.student_answers a ON a.attempt_id = r.attempt_id
    JOIN public.questions q ON q.id = a.question_id
    JOIN public.question_solutions s ON s.question_id = a.question_id
    WHERE r.attempt_id = p_attempt_id
    GROUP BY r.id;

    RETURN pg_catalog.jsonb_build_object(
      'status', 'already_submitted',
      'attempt_id', p_attempt_id,
      'score_obtained', v_version.score_obtained,
      'max_score', v_version.max_score,
      'percentage', v_version.percentage,
      'passed', v_version.passed,
      'is_overdue', v_version.is_overdue,
      'corrections', v_version.corrections
    );
  END IF;

  IF v_attempt.status != 'in_progress' THEN
    RAISE EXCEPTION 'Attempt cannot be submitted (Status: %).', v_attempt.status USING ERRCODE = '22000';
  END IF;

  SELECT * INTO v_version
  FROM public.assessment_versions
  WHERE id = v_attempt.assessment_version_id;

  IF v_version.status NOT IN ('published', 'archived') THEN
    RAISE EXCEPTION 'Attempt references an invalid assessment version status: %', v_version.status;
  END IF;

  IF v_attempt.timing_verified THEN
    v_duration_seconds := GREATEST(0, pg_catalog.extract('epoch', (v_server_now - v_attempt.server_started_at))::INTEGER);
    IF v_version.time_limit_minutes IS NOT NULL THEN
      IF v_duration_seconds > ((v_version.time_limit_minutes * 60) + 30) THEN
        v_is_overdue := true;
      END IF;
    END IF;
  ELSE
    v_duration_seconds := v_attempt.client_reported_duration_seconds;
    IF v_version.time_limit_minutes IS NOT NULL AND v_duration_seconds IS NOT NULL THEN
      IF v_duration_seconds > (v_version.time_limit_minutes * 60) THEN
        v_is_overdue := true;
      END IF;
    END IF;
  END IF;

  IF pg_catalog.jsonb_array_length(p_answers) > v_version.total_questions THEN
    RAISE EXCEPTION 'Payload rejected: Answer count exceeds assessment question count.';
  END IF;

  FOR v_item IN SELECT * FROM pg_catalog.jsonb_array_elements(p_answers)
  LOOP
    FOR v_key_text IN SELECT pg_catalog.jsonb_object_keys(v_item)
    LOOP
      IF v_key_text NOT IN ('question_id', 'selected_option_id') THEN
        RAISE EXCEPTION 'Malformed answer item contains invalid field: %', v_key_text;
      END IF;
    END LOOP;

    IF NOT (v_item ? 'question_id') THEN
      RAISE EXCEPTION 'Answer item missing question_id.';
    END IF;

    IF (v_item->>'question_id') !~ v_uuid_regex THEN
      RAISE EXCEPTION 'Invalid question_id UUID format.';
    END IF;
    v_q_id := (v_item->>'question_id')::UUID;

    IF v_q_id = ANY(v_seen_questions) THEN
      RAISE EXCEPTION 'Duplicate answer submission for question %.', v_q_id;
    END IF;
    v_seen_questions := pg_catalog.array_append(v_seen_questions, v_q_id);

    IF NOT EXISTS (
      SELECT 1 FROM public.questions 
      WHERE id = v_q_id AND assessment_version_id = v_attempt.assessment_version_id
    ) THEN
      RAISE EXCEPTION 'Question % does not belong to this assessment version.', v_q_id;
    END IF;

    IF v_item->>'selected_option_id' IS NOT NULL THEN
      IF (v_item->>'selected_option_id') !~ v_uuid_regex THEN
        RAISE EXCEPTION 'Invalid selected_option_id UUID format.';
      END IF;
      v_opt_id := (v_item->>'selected_option_id')::UUID;

      IF NOT EXISTS (
        SELECT 1 FROM public.question_options 
        WHERE id = v_opt_id AND question_id = v_q_id
      ) THEN
        RAISE EXCEPTION 'Option % does not belong to question %.', v_opt_id, v_q_id;
      END IF;
    END IF;
  END LOOP;

  FOR v_question IN 
    SELECT q.id, q.points, q.sort_order, s.correct_option_id, s.explanation
    FROM public.questions q
    LEFT JOIN public.question_solutions s ON s.question_id = q.id
    WHERE q.assessment_version_id = v_attempt.assessment_version_id
    ORDER BY q.sort_order ASC
  LOOP
    IF v_question.correct_option_id IS NULL THEN
      RAISE EXCEPTION 'Integrity Failure: Published question % lacks a solution key.', v_question.id;
    END IF;

    v_total_questions := v_total_questions + 1;
    v_max_score := v_max_score + v_question.points;
    v_opt_id := NULL;
    v_is_correct := false;
    v_points_awarded := 0.00;

    FOR v_item IN SELECT * FROM pg_catalog.jsonb_array_elements(p_answers)
    LOOP
      IF (v_item->>'question_id')::UUID = v_question.id THEN
        IF v_item->>'selected_option_id' IS NOT NULL THEN
          v_opt_id := (v_item->>'selected_option_id')::UUID;
        END IF;
        EXIT;
      END IF;
    END LOOP;

    IF v_opt_id IS NOT NULL THEN
      v_answered_questions := v_answered_questions + 1;
      IF v_opt_id = v_question.correct_option_id THEN
        v_is_correct := true;
        v_points_awarded := v_question.points;
        v_correct_answers := v_correct_answers + 1;
        v_score_obtained := v_score_obtained + v_points_awarded;
      ELSE
        v_incorrect_answers := v_incorrect_answers + 1;
      END IF;
    ELSE
      v_skipped_questions := v_skipped_questions + 1;
    END IF;

    INSERT INTO public.student_answers (
      attempt_id,
      student_id,
      assessment_version_id,
      question_id,
      selected_option_id,
      is_correct,
      points_awarded,
      answered_at
    ) VALUES (
      p_attempt_id,
      v_student_id,
      v_attempt.assessment_version_id,
      v_question.id,
      v_opt_id,
      v_is_correct,
      v_points_awarded,
      v_server_now
    );

    v_corrections := v_corrections || pg_catalog.jsonb_build_object(
      'question_id', v_question.id,
      'selected_option_id', v_opt_id,
      'correct_option_id', v_question.correct_option_id,
      'is_correct', v_is_correct,
      'points_awarded', v_points_awarded,
      'explanation', v_question.explanation
    );
  END LOOP;

  IF v_total_questions != v_version.total_questions OR v_max_score != v_version.total_points THEN
    RAISE EXCEPTION 'Assessment integrity mismatch: Graded totals (% questions, % pts) do not match frozen version (% questions, % pts).',
      v_total_questions, v_max_score, v_version.total_questions, v_version.total_points;
  END IF;

  IF v_max_score > 0 THEN
    v_percentage := pg_catalog.round(((v_score_obtained / v_max_score) * 100)::numeric, 2);
  ELSE
    v_percentage := 0.00;
  END IF;

  IF v_version.passing_percentage IS NOT NULL THEN
    v_passed := (v_percentage >= v_version.passing_percentage);
  END IF;

  INSERT INTO public.assessment_results (
    attempt_id,
    student_id,
    assessment_version_id,
    total_questions,
    answered_questions,
    correct_answers,
    incorrect_answers,
    skipped_questions,
    score_obtained,
    max_score,
    percentage,
    passed,
    is_overdue,
    is_overdue_unverified,
    graded_at
  ) VALUES (
    p_attempt_id,
    v_student_id,
    v_attempt.assessment_version_id,
    v_total_questions,
    v_answered_questions,
    v_correct_answers,
    v_incorrect_answers,
    v_skipped_questions,
    v_score_obtained,
    v_max_score,
    v_percentage,
    v_passed,
    v_is_overdue,
    (NOT v_attempt.timing_verified AND v_is_overdue),
    v_server_now
  );

  UPDATE public.assessment_attempts
  SET status = 'submitted',
      server_submitted_at = v_server_now,
      server_duration_seconds = CASE WHEN v_attempt.timing_verified THEN v_duration_seconds ELSE NULL END,
      submission_payload_hash = v_payload_hash
  WHERE id = p_attempt_id;

  RETURN pg_catalog.jsonb_build_object(
    'status', 'success',
    'attempt_id', p_attempt_id,
    'total_questions', v_total_questions,
    'answered_questions', v_answered_questions,
    'correct_answers', v_correct_answers,
    'score_obtained', v_score_obtained,
    'max_score', v_max_score,
    'percentage', v_percentage,
    'passed', v_passed,
    'is_overdue', v_is_overdue,
    'timing_verified', v_attempt.timing_verified,
    'duration_seconds', v_duration_seconds,
    'corrections', v_corrections
  );
END;
$$;

ALTER FUNCTION public.grade_and_submit_attempt(UUID, TEXT, JSONB) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.grade_and_submit_attempt(UUID, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.grade_and_submit_attempt(UUID, TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION public.reconcile_and_grade_offline_attempt(
  p_assessment_version_id UUID,
  p_attempt_id UUID,
  p_idempotency_key TEXT,
  p_client_started_at TIMESTAMPTZ,
  p_client_submitted_at TIMESTAMPTZ,
  p_answers JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_student_id UUID;
  v_existing_attempt RECORD;
  v_reported_duration INTEGER;
  v_server_now TIMESTAMPTZ := pg_catalog.clock_timestamp();
  v_version RECORD;
BEGIN
  v_student_id := auth.uid();
  IF v_student_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User authentication required.' USING ERRCODE = '42501';
  END IF;

  IF p_idempotency_key IS NULL OR pg_catalog.btrim(p_idempotency_key) = '' THEN
    RAISE EXCEPTION 'Invalid idempotency key.' USING ERRCODE = '23505';
  END IF;

  SELECT * INTO v_version
  FROM public.assessment_versions
  WHERE id = p_assessment_version_id AND status IN ('published', 'archived');

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assessment version % is not a valid published version.', p_assessment_version_id;
  END IF;

  SELECT * INTO v_existing_attempt
  FROM public.assessment_attempts
  WHERE student_id = v_student_id AND idempotency_key = p_idempotency_key
  FOR UPDATE;

  IF FOUND THEN
    IF v_existing_attempt.id IS DISTINCT FROM p_attempt_id OR
       v_existing_attempt.assessment_version_id IS DISTINCT FROM p_assessment_version_id THEN
      RAISE EXCEPTION 'Idempotency conflict: Key was bound to a different attempt or assessment version.' USING ERRCODE = '23505';
    END IF;

    RETURN public.grade_and_submit_attempt(v_existing_attempt.id, p_idempotency_key, p_answers);
  END IF;

  IF p_client_submitted_at < p_client_started_at THEN
    RAISE EXCEPTION 'Invalid timestamps: submitted_at cannot precede started_at.';
  END IF;

  v_reported_duration := GREATEST(0, pg_catalog.extract('epoch', (p_client_submitted_at - p_client_started_at))::INTEGER);

  INSERT INTO public.assessment_attempts (
    id,
    student_id,
    assessment_version_id,
    status,
    is_offline_sync,
    timing_verified,
    server_reconciled_at,
    client_reported_started_at,
    client_reported_submitted_at,
    client_reported_duration_seconds,
    idempotency_key
  ) VALUES (
    p_attempt_id,
    v_student_id,
    p_assessment_version_id,
    'in_progress',
    true,
    false,
    v_server_now,
    p_client_started_at,
    p_client_submitted_at,
    v_reported_duration,
    p_idempotency_key
  );

  RETURN public.grade_and_submit_attempt(p_attempt_id, p_idempotency_key, p_answers);
END;
$$;

ALTER FUNCTION public.reconcile_and_grade_offline_attempt(UUID, UUID, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, JSONB) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.reconcile_and_grade_offline_attempt(UUID, UUID, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.reconcile_and_grade_offline_attempt(UUID, UUID, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, JSONB) TO authenticated;

-- 15. PERMISSIONS & GRANTS
REVOKE ALL ON public.assessments FROM anon, authenticated;
REVOKE ALL ON public.assessment_versions FROM anon, authenticated;
REVOKE ALL ON public.assessment_version_chapters FROM anon, authenticated;
REVOKE ALL ON public.questions FROM anon, authenticated;
REVOKE ALL ON public.question_options FROM anon, authenticated;
REVOKE ALL ON public.question_solutions FROM anon, authenticated, public;
REVOKE ALL ON public.assessment_attempts FROM anon, authenticated;
REVOKE ALL ON public.student_answers FROM anon, authenticated;
REVOKE ALL ON public.assessment_results FROM anon, authenticated;

GRANT SELECT ON public.assessments TO anon, authenticated;
GRANT SELECT ON public.assessment_versions TO anon, authenticated;
GRANT SELECT ON public.assessment_version_chapters TO anon, authenticated;
GRANT SELECT ON public.questions TO anon, authenticated;
GRANT SELECT ON public.question_options TO anon, authenticated;
GRANT SELECT ON public.assessment_attempts TO authenticated;
GRANT SELECT ON public.student_answers TO authenticated;
GRANT SELECT ON public.assessment_results TO authenticated;

-- 16. ROW LEVEL SECURITY
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_version_chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_solutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "View active assessments" ON public.assessments;
CREATE POLICY "View active assessments"
  ON public.assessments FOR SELECT TO authenticated, anon
  USING (is_archived = false);

DROP POLICY IF EXISTS "View published versions" ON public.assessment_versions;
CREATE POLICY "View published versions"
  ON public.assessment_versions FOR SELECT TO authenticated, anon
  USING (status IN ('published', 'archived'));

DROP POLICY IF EXISTS "View coverage for published versions" ON public.assessment_version_chapters;
CREATE POLICY "View coverage for published versions"
  ON public.assessment_version_chapters FOR SELECT TO authenticated, anon
  USING (
    EXISTS (
      SELECT 1 FROM public.assessment_versions av
      WHERE av.id = assessment_version_chapters.assessment_version_id
        AND av.status IN ('published', 'archived')
    )
  );

DROP POLICY IF EXISTS "View published questions" ON public.questions;
CREATE POLICY "View published questions"
  ON public.questions FOR SELECT TO authenticated, anon
  USING (
    EXISTS (
      SELECT 1 FROM public.assessment_versions av 
      WHERE av.id = questions.assessment_version_id 
        AND av.status IN ('published', 'archived')
    )
  );

DROP POLICY IF EXISTS "View published options" ON public.question_options;
CREATE POLICY "View published options"
  ON public.question_options FOR SELECT TO authenticated, anon
  USING (
    EXISTS (
      SELECT 1 FROM public.questions q
      JOIN public.assessment_versions av ON av.id = q.assessment_version_id
      WHERE q.id = question_options.question_id 
        AND av.status IN ('published', 'archived')
    )
  );

DROP POLICY IF EXISTS "Deny all client access to solutions" ON public.question_solutions;
CREATE POLICY "Deny all client access to solutions"
  ON public.question_solutions FOR ALL TO authenticated, anon
  USING (false);

DROP POLICY IF EXISTS "View own attempts" ON public.assessment_attempts;
CREATE POLICY "View own attempts"
  ON public.assessment_attempts FOR SELECT TO authenticated
  USING ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "View own answers post submission" ON public.student_answers;
CREATE POLICY "View own answers post submission"
  ON public.student_answers FOR SELECT TO authenticated
  USING (
    (select auth.uid()) = student_id AND
    EXISTS (
      SELECT 1 FROM public.assessment_attempts att
      WHERE att.id = student_answers.attempt_id AND att.status = 'submitted'
    )
  );

DROP POLICY IF EXISTS "View own results" ON public.assessment_results;
CREATE POLICY "View own results"
  ON public.assessment_results FOR SELECT TO authenticated
  USING ((select auth.uid()) = student_id);
