-- NSW cohort, 2026 snapshot: research staff (definition C) at each NSW university, plus every iD an NSW university
-- integration has written works to. One row per iD; uni = the university whose integration wrote to them, else staff university.
WITH uni_rx AS (
  SELECT * FROM UNNEST([
    STRUCT<uni STRING, rx STRING>('USyd', r'^(the )?university of sydney'),
    ('UNSW', r'unsw|university of new south wales'),
    ('UTS', r'university of technology,? sydney'),
    ('Macquarie', r'^macquarie university'),
    ('Western Sydney', r'western sydney university|university of western sydney'),
    ('Newcastle', r'^(the )?university of newcastle'),
    ('Wollongong', r'^(the )?university of wollongong'),
    ('Charles Sturt', r'^charles sturt university'),
    ('Southern Cross', r'^southern cross university'),
    ('New England', r'^(the )?university of new england'),
    ('Notre Dame', r'notre dame australia')])
),
clients AS (
  SELECT * FROM UNNEST([
    STRUCT<client STRING, uni STRING>('APP-LWWJS7JD173TPE94', 'USyd'), ('APP-Z2004HUVFXDAN1EK', 'USyd'),
    ('0000-0002-8446-3621', 'UNSW'), ('APP-BQO2Q6GUIRPPQFEP', 'UTS'), ('APP-UKGLZX5LPGYOXYX5', 'Macquarie'),
    ('APP-FEB9IGN79LRYBHOS', 'Western Sydney'), ('APP-A2MHMQNKG9OQFDHH', 'Newcastle'),
    ('APP-960EPY2F4TK0VIXA', 'Wollongong'), ('APP-472E03Z2PK4QX84O', 'Wollongong'),
    ('APP-VKNFGSUVT5M2SUJ5', 'Charles Sturt'), ('APP-EJGLA2YA0THTYIKZ', 'Southern Cross'),
    ('APP-G1HUWSKAF9O4SNK0', 'New England')])
),
emp AS (
  SELECT t.orcid_identifier.path id, u.uni,
    LOGICAL_OR(REGEXP_CONTAINS(LOWER(IFNULL(r.role_title, '')), r'phd|doctoral|candidate|student|master|honours|hdr|mphil|undergrad')) student
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  JOIN uni_rx u ON REGEXP_CONTAINS(LOWER(r.organization.name), u.rx)
  WHERE r.organization.address.country = 'AU' AND r.end_date IS NULL
  GROUP BY id, uni
),
doi_ids AS (SELECT DISTINCT id FROM `your-project.your_dataset.orcid_doi_2026`),
staff AS (SELECT id, ARRAY_AGG(uni ORDER BY uni) staff_unis FROM emp WHERE NOT student AND id IN (SELECT id FROM doi_ids) GROUP BY id),
pushed AS (
  SELECT d.id, ARRAY_AGG(DISTINCT c.uni ORDER BY c.uni) pushed_by
  FROM `your-project.your_dataset.orcid_doi_2026` d JOIN clients c ON c.client = d.src GROUP BY d.id
)
SELECT id, COALESCE(p.pushed_by[SAFE_OFFSET(0)], s.staff_unis[SAFE_OFFSET(0)]) uni,
  s.id IS NOT NULL is_staff, IFNULL(s.staff_unis, []) staff_unis, IFNULL(p.pushed_by, []) pushed_by
FROM staff s FULL JOIN pushed p USING (id)
