-- Per NSW university, 2026 snapshot: research staff on ORCID (definition C: current employment at the university,
-- at least one DOI work, no student role), how many the university's own integration has written works to,
-- who wrote their employment entry, and where the works added in the last year came from.
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
    ('APP-G1HUWSKAF9O4SNK0', 'New England'), ('APP-E7C6PUGSWG56L99M', 'Notre Dame')])
),
emp AS (
  SELECT t.orcid_identifier.path id, u.uni,
    LOGICAL_OR(r.source.source_client_id.path IS NULL) emp_self,
    LOGICAL_OR(IFNULL(c.uni = u.uni, FALSE)) emp_own_cris,
    LOGICAL_OR(IFNULL(r.source.source_client_id.path = 'APP-4B3XYWJHXCC1VLVV', FALSE)) emp_portal,
    LOGICAL_OR(REGEXP_CONTAINS(LOWER(IFNULL(r.role_title, '')), r'phd|doctoral|candidate|student|master|honours|hdr|mphil|undergrad')) student
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  JOIN uni_rx u ON REGEXP_CONTAINS(LOWER(r.organization.name), u.rx)
  LEFT JOIN clients c ON c.client = r.source.source_client_id.path
  WHERE r.organization.address.country = 'AU' AND r.end_date IS NULL
  GROUP BY id, uni
),
wk AS (
  SELECT t.orcid_identifier.path id,
    LOGICAL_OR(EXISTS(SELECT 1 FROM UNNEST(r.external_ids.identifiers) x WHERE x.type = 'doi')) has_doi,
    ARRAY_AGG(DISTINCT c.uni IGNORE NULLS) pushed_by,
    COUNTIF(r.created_date >= '2025-10-14') works_ly,
    COUNTIF(r.created_date >= '2025-10-14' AND r.source.source_client_id.path IS NULL) works_ly_hand
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  LEFT JOIN clients c ON c.client = r.source.source_client_id.path
  GROUP BY id
)
SELECT e.uni,
  COUNT(*) research_staff,
  COUNTIF(e.uni IN UNNEST(w.pushed_by)) reached_by_own_integration,
  ROUND(100 * COUNTIF(e.uni IN UNNEST(w.pushed_by)) / COUNT(*), 1) pct_reached,
  COUNTIF(e.emp_own_cris OR e.emp_portal) emp_written_by_uni,
  ROUND(100 * COUNTIF(NOT (e.emp_own_cris OR e.emp_portal)) / COUNT(*), 1) pct_emp_self_only,
  SUM(w.works_ly) works_added_ly, SUM(w.works_ly_hand) works_ly_by_hand,
  ROUND(100 * (1 - SUM(w.works_ly_hand) / NULLIF(SUM(w.works_ly), 0)), 1) pct_works_ly_integrated
FROM emp e JOIN wk w USING (id)
WHERE w.has_doi AND NOT e.student
GROUP BY e.uni ORDER BY research_staff DESC
