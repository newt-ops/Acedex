import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

interface AnswerPayload {
  question_id: string;
  selected_option_id?: string | null;
}

interface GradeAssessmentRequest {
  attempt_id?: string;
  assessment_id?: string;
  assessment_version_id: string;
  idempotency_key: string;
  answers: AnswerPayload[];
  client_started_at?: string;
  client_submitted_at?: string;
}

Deno.serve(async (req: Request) => {
  // 1. Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: 'Missing backend environment variables' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Service-role client for privileged operations (accessing air-gapped solutions)
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);

    // Authenticate user via Authorization header
    const authHeader = req.headers.get('Authorization');
    let studentId: string | null = null;

    if (authHeader) {
      const token = authHeader.replace('Bearer ', '');
      const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
      if (!authError && user) {
        studentId = user.id;
      }
    }

    // Parse and validate payload
    const body: GradeAssessmentRequest = await req.json();
    const {
      attempt_id,
      assessment_version_id,
      idempotency_key,
      answers,
      client_started_at,
      client_submitted_at,
    } = body;

    if (!assessment_version_id || !idempotency_key || !Array.isArray(answers)) {
      return new Response(
        JSON.stringify({
          error: 'Invalid payload: assessment_version_id, idempotency_key, and answers array are required.',
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Verify assessment version exists and is published
    const { data: version, error: versionErr } = await adminClient
      .from('assessment_versions')
      .select('id, assessment_id, version_number, status, total_questions, total_points, passing_percentage, time_limit_minutes')
      .eq('id', assessment_version_id)
      .single();

    if (versionErr || !version) {
      return new Response(
        JSON.stringify({ error: `Assessment version ${assessment_version_id} not found.` }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (version.status !== 'published' && version.status !== 'archived') {
      return new Response(
        JSON.stringify({ error: 'Assessment version is not published for student evaluation.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Check idempotency if studentId is present
    if (studentId) {
      const { data: existingAttempt } = await adminClient
        .from('assessment_attempts')
        .select('id, status')
        .eq('student_id', studentId)
        .eq('idempotency_key', idempotencyKey)
        .maybeSingle();

      if (existingAttempt && existingAttempt.status === 'submitted') {
        // Return existing result
        const { data: existingResult } = await adminClient
          .from('assessment_results')
          .select('*')
          .eq('attempt_id', existingAttempt.id)
          .maybeSingle();

        if (existingResult) {
          // Fetch corrections
          const { data: existingAnswers } = await adminClient
            .from('student_answers')
            .select(`
              question_id,
              selected_option_id,
              points_awarded,
              is_correct,
              solution:question_solutions!question_id (
                correct_option_id,
                explanation,
                reference_source
              )
            `)
            .eq('attempt_id', existingAttempt.id);

          const corrections = (existingAnswers || []).map((a: any) => ({
            question_id: a.question_id,
            selected_option_id: a.selected_option_id,
            correct_option_id: a.solution?.correct_option_id,
            is_correct: a.is_correct,
            points_awarded: Number(a.points_awarded),
            explanation: a.solution?.explanation || '',
            reference_source: a.solution?.reference_source || null,
          }));

          return new Response(
            JSON.stringify({
              status: 'already_submitted',
              attempt_id: existingAttempt.id,
              total_questions: existingResult.total_questions,
              answered_questions: existingResult.answered_questions,
              correct_answers: existingResult.correct_answers,
              score_obtained: Number(existingResult.score_obtained),
              max_score: Number(existingResult.max_score),
              percentage: Number(existingResult.percentage),
              passed: existingResult.passed,
              is_overdue: existingResult.is_overdue,
              timing_verified: true,
              duration_seconds: existingResult.duration_seconds,
              corrections,
            }),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }
      }
    }

    // Fetch all questions and air-gapped solutions for this version
    const { data: questions, error: qErr } = await adminClient
      .from('questions')
      .select(`
        id,
        points,
        sort_order,
        solution:question_solutions!id (
          correct_option_id,
          explanation,
          reference_source
        )
      `)
      .eq('assessment_version_id', assessment_version_id)
      .order('sort_order', { ascending: true });

    if (qErr || !questions || questions.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No questions or solutions found for this assessment version.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Map student answers by question_id
    const answerMap = new Map<string, string | null>();
    for (const a of answers) {
      answerMap.set(a.question_id, a.selected_option_id || null);
    }

    // Evaluate answers
    let correctCount = 0;
    let answeredCount = 0;
    let scoreObtained = 0.0;
    let maxScore = 0.0;
    const corrections: any[] = [];
    const studentAnswerRecords: any[] = [];

    const now = new Date();
    const effectiveAttemptId = attempt_id || crypto.randomUUID();

    for (const q of questions) {
      const qPoints = Number(q.points) || 1.0;
      maxScore += qPoints;

      const sol = (q as any).solution;
      const correctOptionId = sol?.correct_option_id;
      const explanation = sol?.explanation || '';
      const referenceSource = sol?.reference_source || null;

      const selectedOptionId = answerMap.get(q.id) || null;
      const isAnswered = selectedOptionId !== null;
      if (isAnswered) answeredCount++;

      const isCorrect = isAnswered && selectedOptionId === correctOptionId;
      const pointsAwarded = isCorrect ? qPoints : 0.0;
      if (isCorrect) {
        correctCount++;
        scoreObtained += qPoints;
      }

      corrections.push({
        question_id: q.id,
        selected_option_id: selectedOptionId,
        correct_option_id: correctOptionId,
        is_correct: isCorrect,
        points_awarded: pointsAwarded,
        explanation,
        reference_source: referenceSource,
      });

      if (studentId) {
        studentAnswerRecords.push({
          attempt_id: effectiveAttemptId,
          student_id: studentId,
          question_id: q.id,
          selected_option_id: selectedOptionId,
          is_correct: isCorrect,
          points_awarded: pointsAwarded,
        });
      }
    }

    const percentage = maxScore > 0 ? (scoreObtained / maxScore) * 100.0 : 0.0;
    const passingThreshold = version.passing_percentage ? Number(version.passing_percentage) : 70.0;
    const isPassed = percentage >= passingThreshold;

    let durationSeconds: number | null = null;
    if (client_started_at && client_submitted_at) {
      const startMs = new Date(client_started_at).getTime();
      const endMs = new Date(client_submitted_at).getTime();
      if (!isNaN(startMs) && !isNaN(endMs) && endMs >= startMs) {
        durationSeconds = Math.round((endMs - startMs) / 1000);
      }
    }

    // Persist attempt & result if student is authenticated
    if (studentId) {
      // Upsert attempt
      await adminClient.from('assessment_attempts').upsert({
        id: effectiveAttemptId,
        student_id: studentId,
        assessment_version_id,
        status: 'submitted',
        server_started_at: client_started_at ? new Date(client_started_at).toISOString() : now.toISOString(),
        server_submitted_at: now.toISOString(),
        idempotency_key: idempotencyKey,
        server_duration_seconds: durationSeconds,
      });

      // Insert student answers
      if (studentAnswerRecords.length > 0) {
        await adminClient.from('student_answers').insert(studentAnswerRecords);
      }

      // Insert result record
      await adminClient.from('assessment_results').upsert({
        attempt_id: effectiveAttemptId,
        student_id: studentId,
        assessment_version_id,
        total_questions: questions.length,
        answered_questions: answeredCount,
        correct_answers: correctCount,
        score_obtained: scoreObtained,
        max_score: maxScore,
        percentage: Math.round(percentage * 100) / 100,
        passed: isPassed,
        is_overdue: false,
        duration_seconds: durationSeconds,
      });
    }

    const responsePayload = {
      status: 'success',
      attempt_id: effectiveAttemptId,
      total_questions: questions.length,
      answered_questions: answeredCount,
      correct_answers: correctCount,
      score_obtained: Math.round(scoreObtained * 100) / 100,
      max_score: Math.round(maxScore * 100) / 100,
      percentage: Math.round(percentage * 100) / 100,
      passed: isPassed,
      is_overdue: false,
      timing_verified: true,
      duration_seconds: durationSeconds,
      corrections,
    };

    return new Response(JSON.stringify(responsePayload), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || 'Internal server error during assessment grading.' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
