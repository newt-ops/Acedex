# Ethiopian National Curriculum Quick Notes (237 Units)

This directory mirrors `content/question-bank/` with a 1-to-1 matching folder hierarchy across all 4 grades and 8 secondary subjects (totaling 237 units).

## Directory Structure
```
content/quick-notes/
├── Grade-09/
│   ├── Biology/       (BIO-G09-U01.json ... BIO-G09-U06.json)
│   ├── Chemistry/     (CHE-G09-U01.json ... CHE-G09-U05.json)
│   ├── Economics/     (ECO-G09-U01.json ... ECO-G09-U07.json)
│   ├── English/       (ENG-G09-U01.json ... ENG-G09-U10.json)
│   ├── Geography/     (GEO-G09-U01.json ... GEO-G09-U07.json)
│   ├── History/       (HIS-G09-U01.json ... HIS-G09-U09.json)
│   ├── Mathematics/   (MAT-G09-U01.json ... MAT-G09-U06.json)
│   └── Physics/       (PHY-G09-U01.json ... PHY-G09-U06.json)
├── Grade-10/
├── Grade-11/
└── Grade-12/
```

## Standard Unit JSON Schema
```json
{
  "grade": 12,
  "subject": "Physics",
  "subjectCode": "PHY",
  "unitNumber": 1,
  "unitCode": "PHY-G12-U01",
  "unitTitle": "Application of Physics in Other Fields",
  "examWeight": "14% EUEE",
  "summaryPoints": [
    "Physics underpins medical imaging technologies including MRI, X-ray, and ultrasound Doppler shifts.",
    "Satellite remote sensing relies on orbital mechanics and electromagnetic spectral bands.",
    "Defense and communication technologies utilize radar wave reflection and fiber-optic total internal reflection."
  ],
  "formulas": [
    {
      "label": "Doppler Frequency Shift",
      "expr": "f′ = f · (v ± v₀) / (v ∓ vₛ)"
    },
    {
      "label": "Snell’s Law (Critical Angle)",
      "expr": "sin(θc) = n₂ / n₁  (for n₁ > n₂)"
    }
  ],
  "examTip": "EUEE frequently asks which wave phenomenon powers medical ultrasound (piezoelectric echo) vs. MRI (nuclear spin precession).",
  "keyDefinitions": [
    {
      "term": "Piezoelectric Effect",
      "definition": "Generation of electric charge across a crystal when subjected to mechanical stress."
    }
  ],
  "eueeFocusTopics": [
    "Ultrasound Doppler shifts and acoustic impedance",
    "Radar distance calculation: R = c · t / 2"
  ]
}
```

## Workflow Roadmap
1. **Ingest Textbook Content**: User provides each grade and subject textbook/chapter materials.
2. **Generate Standardized Notes**: Generate high-yield summary points, copyable formulas, definitions, and EUEE exam tips.
3. **Local Organization**: Save into `content/quick-notes/Grade-XX/Subject/CODE.json`.
4. **Offline Mobile Integration**: Package or sync directly into Flutter mobile app.
5. **Database Seeding & API**: Once all 237 units are complete, run a seed script to load into MongoDB and serve through `/api/v1/curriculum/units/:unitId/notes`.
