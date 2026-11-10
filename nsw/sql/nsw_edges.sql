-- Co-author edges inside the NSW cohort (nsw_people), for the 2024, 2025 and 2026 snapshots, same iDs throughout.
-- Edge = two iDs sharing a DOI; DOIs held by >100 iDs in that snapshot excluded.
-- needs_int = on every shared DOI, one side holds it only from an NSW university integration.
WITH clients AS (
  SELECT client FROM UNNEST(['APP-LWWJS7JD173TPE94', 'APP-Z2004HUVFXDAN1EK', '0000-0002-8446-3621', 'APP-BQO2Q6GUIRPPQFEP',
    'APP-UKGLZX5LPGYOXYX5', 'APP-FEB9IGN79LRYBHOS', 'APP-A2MHMQNKG9OQFDHH', 'APP-960EPY2F4TK0VIXA', 'APP-472E03Z2PK4QX84O',
    'APP-VKNFGSUVT5M2SUJ5', 'APP-EJGLA2YA0THTYIKZ', 'APP-G1HUWSKAF9O4SNK0']) client
),
p AS (SELECT id FROM `your-project.your_dataset.nsw_people`),
raw AS (
  SELECT '2024' snap, id, doi, src FROM `your-project.your_dataset.orcid_doi_2024` UNION ALL
  SELECT '2025', id, doi, src FROM `your-project.your_dataset.orcid_doi_2025` UNION ALL
  SELECT '2026', id, doi, src FROM `your-project.your_dataset.orcid_doi_2026`
),
size AS (SELECT snap, doi, COUNT(DISTINCT id) n FROM raw GROUP BY 1, 2),
d AS (
  SELECT snap, id, doi, LOGICAL_AND(src IN (SELECT client FROM clients)) int_only
  FROM raw WHERE id IN (SELECT id FROM p) GROUP BY 1, 2, 3
),
c AS (SELECT d.* FROM d JOIN size USING (snap, doi) WHERE n <= 100)
SELECT x.snap, x.id a, y.id b, COUNT(*) shared, LOGICAL_AND(x.int_only OR y.int_only) needs_int
FROM c x JOIN c y ON x.snap = y.snap AND x.doi = y.doi AND x.id < y.id
GROUP BY 1, 2, 3
