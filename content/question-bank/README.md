# Acedex Question Bank Repository

Standardized, version-controlled repository of Ethiopian secondary curriculum assessment questions (Grades 9–12) for the Ethiopian University Entrance Examination (EUEE).

---

## 1. Directory Structure

Questions are strictly partitioned by **Grade** → **Subject** → **Unit**:

The active subjects are strictly:

1. **English** (`ENG`)
2. **Mathematics** (`MAT`)
3. **Physics** (`PHY`)
4. **Chemistry** (`CHE`)
5. **Biology** (`BIO`)
6. **Geography** (`GEO`)
7. **Economics** (`ECO`)
8. **History** (`HIS`)

```
Acedex-Question-Bank/
├── Grade-09/
│   ├── Biology/
│   ├── Chemistry/
│   ├── Economics/
│   ├── English/
│   ├── Geography/
│   ├── History/
│   ├── Mathematics/
│   └── Physics/
│       ├── PHY-G09-U01.json
│       └── PHY-G09-U02.json
├── Grade-10/
│   ├── Biology/
│   ├── Chemistry/
│   ├── Economics/
│   ├── English/
│   ├── Geography/
│   ├── History/
│   ├── Mathematics/
│   └── Physics/
├── Grade-11/
│   ├── Biology/
│   ├── Chemistry/
│   ├── Economics/
│   ├── English/
│   ├── Geography/
│   ├── History/
│   ├── Mathematics/
│   └── Physics/
└── Grade-12/
    ├── Biology/
    ├── Chemistry/
    ├── Economics/
    ├── English/
    ├── Geography/
    ├── History/
    ├── Mathematics/
    └── Physics/
```

---

## 2. File Naming Convention

Every assessment file must follow the strict uppercase pattern:

```
[SUBJECT]-G[GRADE]-U[UNIT].json
```

- `[SUBJECT]`: 3-letter uppercase subject code (e.g. `PHY`, `BIO`, `CHE`, `MAT`, `ENG`, `GEO`, `ECO`, `HIS`).
- `G[GRADE]`: Two-digit zero-padded grade (`G09`, `G10`, `G11`, `G12`).
- `U[UNIT]`: Two-digit zero-padded unit number (`U01`, `U02`, `U03`, ...).

### Canonical Examples:

| Grade & Subject    | Unit   | Standard Filename                     |
| :----------------- | :----- | :------------------------------------ |
| Grade 9 Physics    | Unit 1 | `Grade-09/Physics/PHY-G09-U01.json`   |
| Grade 9 Physics    | Unit 2 | `Grade-09/Physics/PHY-G09-U02.json`   |
| Grade 10 Biology   | Unit 3 | `Grade-10/Biology/BIO-G10-U03.json`   |
| Grade 11 Economics | Unit 2 | `Grade-11/Economics/ECO-G11-U02.json` |
| Grade 12 Chemistry | Unit 1 | `Grade-12/Chemistry/CHE-G12-U01.json` |

---

## 3. Subject Code Mapping

| Subject Name | Directory Name | Code  | Curriculum ID Prefix |
| :----------- | :------------- | :---- | :------------------- |
| English      | `English`      | `ENG` | `ENG_G{X}`           |
| Mathematics  | `Mathematics`  | `MAT` | `MATH_G{X}`          |
| Physics      | `Physics`      | `PHY` | `PHYS_G{X}`          |
| Chemistry    | `Chemistry`    | `CHE` | `CHEM_G{X}`          |
| Biology      | `Biology`      | `BIO` | `BIO_G{X}`           |
| Geography    | `Geography`    | `GEO` | `GEOG_G{X}`          |
| Economics    | `Economics`    | `ECO` | `ECON_G{X}`          |
| History      | `History`      | `HIS` | `HIST_G{X}`          |

---

## 4. Question JSON Schema Specification

Each file represents a complete unit assessment (~30 questions) formatted as valid JSON:

```json
{
  "grade": 9,
  "subject": "Physics",
  "unitNumber": 1,
  "unitTitle": "Physics and Human Society",
  "questions": [
    {
      "id": "PHY-G09-U01-Q001",
      "type": "multiple_choice",
      "difficulty": "easy",
      "question": "The word 'physics' is derived from which Greek word, and what is its original meaning?",
      "options": [
        { "id": "A", "text": "Phusis, meaning nature" },
        { "id": "B", "text": "Techne, meaning art or craft" },
        { "id": "C", "text": "Logos, meaning reason or study" },
        { "id": "D", "text": "Kosmos, meaning universe" }
      ],
      "correctOptionId": "A",
      "explanation": "The word physics comes from the Greek word 'phusis', which translates directly to 'nature'.",
      "sourceReference": "Section 1.1, Page 2"
    }
  ]
}
```

### Validation Rules:

1. **Questions Count:** 30 multiple-choice questions per unit assessment.
2. **Options Integrity:** Exactly 4 options (`A`, `B`, `C`, `D`) per question.
3. **Correct Answer:** `correctOptionId` must match one of the option IDs (`A`, `B`, `C`, or `D`).
4. **Pedagogical Explanation:** A clear, concise explanation must accompany every question explaining why the correct answer is right and correcting common misconceptions.
5. **Air-Gap Security:** In client distributions (Drift SQLite cache), `correctOptionId` and `explanation` are strictly stripped before delivery to students, ensuring solutions remain air-gapped until submission.
