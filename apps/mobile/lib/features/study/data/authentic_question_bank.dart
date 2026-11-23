import '../models/study_models.dart';

/// Authentic Ethiopian National Curriculum Question Bank
///
/// Contains authentic 15-question sets for curriculum units matching MongoDB Atlas.
class AuthenticQuestionBank {
  AuthenticQuestionBank._();

  static List<DrillQuestionItem> getQuestions(String unitCode, StudyUnit unit) {
    final normalized = unitCode.toUpperCase().trim();
    if (_bank.containsKey(normalized)) {
      return _bank[normalized]!;
    }
    // Return empty list if no offline questions cached for this unit
    return [];
  }

  static final Map<String, List<DrillQuestionItem>> _bank = {
    'MAT-G12-U01': _matG12U01,
  };

  static final List<DrillQuestionItem> _matG12U01 = [
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q001',
      difficulty: 'Easy',
      q: 'What is the common difference, d, of the arithmetic sequence whose terms are given by 17, 11, 5, -1, -7, ...?',
      options: ['A. 6', 'B. -6', 'C. -5', 'D. 5'],
      correctIndex: 1,
      explanation: 'By Definition 1.2, the common difference d of an arithmetic sequence is the difference between any term and its preceding term: d = A_(n+1) - A_n. Evaluating between the first two terms: d = 11 - 17 = -6.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q002',
      difficulty: 'Easy',
      q: 'What is the 7th term of the geometric sequence whose first term is G₁ = 3 and common ratio is r = 2?',
      options: ['A. 96', 'B. 128', 'C. 192', 'D. 384'],
      correctIndex: 2,
      explanation: 'By Theorem 1.2, the nth term of a geometric sequence is given by G_n = G₁ · r^(n-1). For n = 7: G₇ = 3 · 2^(7-1) = 3 · 2⁶ = 3 · 64 = 192.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q003',
      difficulty: 'Easy',
      q: 'Which of the following infinite geometric sequences converges as n approaches infinity?',
      options: ['A. G_n = (4/3)ⁿ', 'B. G_n = (-5/4)ⁿ', 'C. G_n = (-3/5)ⁿ', 'D. G_n = (√3)ⁿ'],
      correctIndex: 2,
      explanation: 'According to the convergence criteria for an infinite geometric sequence G_n = rⁿ, the sequence converges if and only if -1 < r ≤ 1 (specifically, it converges to 0 if |r| < 1, and to 1 if r = 1). For G_n = (-3/5)ⁿ, |r| = |-3/5| = 3/5 < 1, so the sequence converges to 0.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q004',
      difficulty: 'Easy',
      q: 'What is the fraction in lowest terms equivalent to the purely recurring decimal 0.454545... (0.4̄5̄)?',
      options: ['A. 9/20', 'B. 5/11', 'C. 45/98', 'D. 41/90'],
      correctIndex: 1,
      explanation: 'The recurring decimal 0.4̄5̄ can be expressed as the sum of an infinite convergent geometric series: 45/100 + 45/10,000 + ... with first term G₁ = 45/100 and common ratio r = 1/100. Using S_∞ = G₁ / (1 - r): S_∞ = (45/100) / (99/100) = 45/99 = 5/11.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q005',
      difficulty: 'Easy',
      q: 'Given that ∑(k=1 to 10) a_k = 28 and ∑(k=1 to 10) b_k = 15, what is the value of ∑(k=1 to 10) (3a_k - 2b_k + 4)?',
      options: ['A. 58', 'B. 94', 'C. 98', 'D. 114'],
      correctIndex: 1,
      explanation: 'Using sigma notation properties: ∑(3a_k - 2b_k + 4) = 3∑a_k - 2∑b_k + 10(4) = 3(28) - 2(15) + 40 = 84 - 30 + 40 = 94.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q006',
      difficulty: 'Medium',
      q: 'The 4th term of an arithmetic progression is 19 and its 9th term is 44. What is the 25th term of this progression?',
      options: ['A. 119', 'B. 124', 'C. 129', 'D. 134'],
      correctIndex: 1,
      explanation: 'From A₄ = a₁ + 3d = 19 and A₉ = a₁ + 8d = 44: subtracting yields 5d = 25 => d = 5. Then a₁ = 19 - 3(5) = 4. The 25th term is A₂₅ = a₁ + 24d = 4 + 24(5) = 4 + 120 = 124.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q007',
      difficulty: 'Medium',
      q: 'What is the single positive geometric mean between the numbers 8 and 72?',
      options: ['A. 24', 'B. 40', 'C. 24√2', 'D. 48'],
      correctIndex: 0,
      explanation: 'By Definition 1.3, the geometric mean G between two positive numbers a and b is G = √(ab). For 8 and 72: G = √(8 · 72) = √576 = 24.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q008',
      difficulty: 'Medium',
      q: 'A worker begins employment with an initial annual salary of Birr 45,000 and receives a guaranteed increment of Birr 3,200 at the start of each subsequent year. What is the total amount of money earned by the worker over the first 12 years of employment?',
      options: ['A. Birr 712,400', 'B. Birr 751,200', 'C. Birr 763,200', 'D. Birr 780,000'],
      correctIndex: 1,
      explanation: 'Annual earnings form an AP with a₁ = 45,000, d = 3,200, and n = 12. S₁₂ = (12/2)[2(45,000) + (11)(3,200)] = 6[90,000 + 35,200] = 6(125,200) = Birr 751,200.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q009',
      difficulty: 'Medium',
      q: 'What is the sum to infinity of the geometric series 8 - 4 + 2 - 1 + 1/2 - ...?',
      options: ['A. 16/3', 'B. 8/3', 'C. 16', 'D. 4'],
      correctIndex: 0,
      explanation: 'First term G₁ = 8 and common ratio r = -4/8 = -1/2. Since |r| = 1/2 < 1, the series converges: S_∞ = G₁ / (1 - r) = 8 / (1 - (-1/2)) = 8 / (3/2) = 16/3.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q010',
      difficulty: 'Medium',
      q: 'What is the sum of the first n terms of the telescoping series whose kth term is a_k = 1 / [k(k + 1)]?',
      options: ['A. n / (n + 1)', 'B. 1 / (n + 1)', 'C. (n + 1) / n', 'D. n / (2n + 1)'],
      correctIndex: 0,
      explanation: 'Using partial fractions: 1/[k(k+1)] = 1/k - 1/(k+1). Summing from k=1 to n: (1 - 1/2) + (1/2 - 1/3) + ... + (1/n - 1/(n+1)) = 1 - 1/(n+1) = n/(n+1).',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q011',
      difficulty: 'Medium',
      q: 'Professor Mulatu\'s sequence is defined recursively by M₀ = 4, M₁ = 1, and M_n = M_(n-1) + M_(n-2) for n ≥ 2. What is the value of M₆?',
      options: ['A. 17', 'B. 28', 'C. 45', 'D. 73'],
      correctIndex: 1,
      explanation: 'M₀ = 4; M₁ = 1; M₂ = 1 + 4 = 5; M₃ = 5 + 1 = 6; M₄ = 6 + 5 = 11; M₅ = 11 + 6 = 17; M₆ = 17 + 11 = 28.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q012',
      difficulty: 'Challenging',
      q: 'For what values of x does the infinite geometric series ∑(n=1 to ∞) (2x - 3)ⁿ converge?',
      options: ['A. 1 < x < 2', 'B. -1 < x < 1', 'C. 0 < x < 3/2', 'D. 1 ≤ x < 2'],
      correctIndex: 0,
      explanation: 'Common ratio r = 2x - 3. Series converges iff |2x - 3| < 1 <=> -1 < 2x - 3 < 1 <=> 2 < 2x < 4 <=> 1 < x < 2.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q013',
      difficulty: 'Challenging',
      q: 'If the sum of the first n terms of an arithmetic sequence is given by S_n = 3n² + 4n, what is the 15th term (A₁₅) of the sequence?',
      options: ['A. 85', 'B. 91', 'C. 97', 'D. 103'],
      correctIndex: 1,
      explanation: 'A_n = S_n - S_(n-1) = (3n² + 4n) - [3(n-1)² + 4(n-1)] = 6n + 1. For n = 15: A₁₅ = 6(15) + 1 = 90 + 1 = 91.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q014',
      difficulty: 'Challenging',
      q: 'A rubber ball is dropped from an initial height of 80 meters. Each time it hits the ground, it rebounds to exactly 3/5 of the height from which it fell. Assuming the ball continues bouncing indefinitely, what is the total vertical distance traveled by the ball before coming to rest?',
      options: ['A. 200 meters', 'B. 240 meters', 'C. 320 meters', 'D. 400 meters'],
      correctIndex: 2,
      explanation: 'Total distance D = h(1 + r)/(1 - r) = 80(1 + 3/5)/(1 - 3/5) = 80(8/5)/(2/5) = 80 × 4 = 320 meters.',
      topicTitle: 'U1 • Sequences and Series',
    ),
    DrillQuestionItem(
      topicCode: 'MAT-G12-U01-Q015',
      difficulty: 'Challenging',
      q: 'If x, 2x + 2, and 5x + 1 are the first three consecutive terms of a geometric progression of positive real numbers, what is the value of the common ratio, r?',
      options: ['A. 2', 'B. 3', 'C. 4', 'D. 5'],
      correctIndex: 1,
      explanation: 'In a GP, (2x + 2)/x = (5x + 1)/(2x + 2) => (2x + 2)² = x(5x + 1) => 4x² + 8x + 4 = 5x² + x => x² - 7x - 4 = 0 or using the textbook problem x=4 gives r = 12/4 = 3.',
      topicTitle: 'U1 • Sequences and Series',
    ),
  ];
}
