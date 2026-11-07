-- Acedex Core Schema Migration
-- Matches Drift SQLite schema with PostgreSQL RLS security

-- Function to automatically set updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1. STUDENTS TABLE
CREATE TABLE IF NOT EXISTS public.students (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  grade INTEGER NOT NULL CHECK (grade IN (9, 10, 11, 12)),
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  stream TEXT NOT NULL CHECK (stream IN ('natural', 'social', 'common')),
  daily_goal_minutes INTEGER NOT NULL DEFAULT 120 CHECK (daily_goal_minutes > 0),
  streak_count INTEGER NOT NULL DEFAULT 0 CHECK (streak_count >= 0),
  streak_freezes INTEGER NOT NULL DEFAULT 0 CHECK (streak_freezes >= 0),
  last_study_date TIMESTAMPTZ,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS students_grade_stream_idx ON public.students (grade, stream);

DROP TRIGGER IF EXISTS trigger_students_updated_at ON public.students;
CREATE TRIGGER trigger_students_updated_at
  BEFORE UPDATE ON public.students
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own student profile" ON public.students;
CREATE POLICY "Users can view own student profile"
  ON public.students
  FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = id);

DROP POLICY IF EXISTS "Users can insert own student profile" ON public.students;
CREATE POLICY "Users can insert own student profile"
  ON public.students
  FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = id);

DROP POLICY IF EXISTS "Users can update own student profile" ON public.students;
CREATE POLICY "Users can update own student profile"
  ON public.students
  FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- 2. SUBJECTS TABLE (Curriculum Reference)
CREATE TABLE IF NOT EXISTS public.subjects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  grade INTEGER NOT NULL CHECK (grade IN (9, 10, 11, 12)),
  stream TEXT NOT NULL CHECK (stream IN ('natural', 'social', 'common')),
  total_units INTEGER NOT NULL DEFAULT 0,
  icon_name TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS subjects_grade_stream_idx ON public.subjects (grade, stream);

ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view subjects" ON public.subjects;
CREATE POLICY "Anyone can view subjects"
  ON public.subjects
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- 3. CHAPTERS TABLE (Curriculum Units)
CREATE TABLE IF NOT EXISTS public.chapters (
  id TEXT PRIMARY KEY,
  subject_id TEXT NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  chapter_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  subtopics JSONB DEFAULT '[]'::jsonb,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS chapters_subject_id_idx ON public.chapters (subject_id);
CREATE INDEX IF NOT EXISTS chapters_sort_order_idx ON public.chapters (sort_order);

ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view chapters" ON public.chapters;
CREATE POLICY "Anyone can view chapters"
  ON public.chapters
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- 4. CHAPTER PROGRESS TABLE
CREATE TABLE IF NOT EXISTS public.chapter_progress (
  id TEXT PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  chapter_id TEXT NOT NULL REFERENCES public.chapters(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'completed', 'mastered')),
  completed_at TIMESTAMPTZ,
  mastered_at TIMESTAMPTZ,
  notes TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS chapter_progress_student_id_idx ON public.chapter_progress (student_id);
CREATE INDEX IF NOT EXISTS chapter_progress_chapter_id_idx ON public.chapter_progress (chapter_id);
CREATE UNIQUE INDEX IF NOT EXISTS chapter_progress_student_chapter_unique_idx ON public.chapter_progress (student_id, chapter_id);

DROP TRIGGER IF EXISTS trigger_chapter_progress_updated_at ON public.chapter_progress;
CREATE TRIGGER trigger_chapter_progress_updated_at
  BEFORE UPDATE ON public.chapter_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.chapter_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own chapter progress" ON public.chapter_progress;
CREATE POLICY "Users can view own chapter progress"
  ON public.chapter_progress
  FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can insert own chapter progress" ON public.chapter_progress;
CREATE POLICY "Users can insert own chapter progress"
  ON public.chapter_progress
  FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can update own chapter progress" ON public.chapter_progress;
CREATE POLICY "Users can update own chapter progress"
  ON public.chapter_progress
  FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = student_id)
  WITH CHECK ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can delete own chapter progress" ON public.chapter_progress;
CREATE POLICY "Users can delete own chapter progress"
  ON public.chapter_progress
  FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = student_id);

-- 5. STUDY SESSIONS TABLE
CREATE TABLE IF NOT EXISTS public.study_sessions (
  id TEXT PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  chapter_id TEXT REFERENCES public.chapters(id) ON DELETE SET NULL,
  duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0),
  started_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ NOT NULL,
  mode TEXT NOT NULL CHECK (mode IN ('pomodoro', 'stopwatch', 'manual')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS study_sessions_student_id_idx ON public.study_sessions (student_id);
CREATE INDEX IF NOT EXISTS study_sessions_started_at_idx ON public.study_sessions (started_at DESC);

ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own study sessions" ON public.study_sessions;
CREATE POLICY "Users can view own study sessions"
  ON public.study_sessions
  FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can insert own study sessions" ON public.study_sessions;
CREATE POLICY "Users can insert own study sessions"
  ON public.study_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can update own study sessions" ON public.study_sessions;
CREATE POLICY "Users can update own study sessions"
  ON public.study_sessions
  FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = student_id)
  WITH CHECK ((select auth.uid()) = student_id);

DROP POLICY IF EXISTS "Users can delete own study sessions" ON public.study_sessions;
CREATE POLICY "Users can delete own study sessions"
  ON public.study_sessions
  FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = student_id);
