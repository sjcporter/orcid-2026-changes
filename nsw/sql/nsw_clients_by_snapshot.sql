-- NSW university integrations across the 2024, 2025 and 2026 public data files: what each had written by each snapshot.
-- Member Portal entries counted only where the organisation is an NSW university.
WITH clients AS (
  SELECT * FROM UNNEST([
    STRUCT<client STRING, uni STRING>('APP-LWWJS7JD173TPE94', 'USyd'), ('APP-Z2004HUVFXDAN1EK', 'USyd'),
    ('0000-0002-8446-3621', 'UNSW'), ('APP-BQO2Q6GUIRPPQFEP', 'UTS'), ('APP-UKGLZX5LPGYOXYX5', 'Macquarie'),
    ('APP-FEB9IGN79LRYBHOS', 'Western Sydney'), ('APP-A2MHMQNKG9OQFDHH', 'Newcastle'),
    ('APP-960EPY2F4TK0VIXA', 'Wollongong'), ('APP-472E03Z2PK4QX84O', 'Wollongong'),
    ('APP-VKNFGSUVT5M2SUJ5', 'Charles Sturt'), ('APP-EJGLA2YA0THTYIKZ', 'Southern Cross'),
    ('APP-G1HUWSKAF9O4SNK0', 'New England'), ('APP-E7C6PUGSWG56L99M', 'Notre Dame')])
),
snap AS (
  SELECT '2024' yr, orcid_identifier, activities FROM `ds-open-datasets.orcid.summaries_2024` UNION ALL
  SELECT '2025', orcid_identifier, activities FROM `ds-open-datasets.orcid.summaries_2025` UNION ALL
  SELECT '2026', orcid_identifier, activities FROM `ds-open-datasets.orcid.summaries_2026`
),
w AS (
  SELECT s.yr, c.uni, 'work' section, s.orcid_identifier.path id
  FROM snap s, UNNEST(s.activities.works.groups) g, UNNEST(g.records) r JOIN clients c ON c.client = r.source.source_client_id.path
),
e AS (
  SELECT s.yr, IFNULL(c.uni, 'Member Portal: ' || r.organization.name) uni, 'employment' section, s.orcid_identifier.path id
  FROM snap s, UNNEST(s.activities.employments.groups) g, UNNEST(g.records) r
  LEFT JOIN clients c ON c.client = r.source.source_client_id.path
  WHERE c.client IS NOT NULL OR (r.source.source_client_id.path = 'APP-4B3XYWJHXCC1VLVV' AND r.organization.address.country = 'AU'
    AND REGEXP_CONTAINS(LOWER(r.organization.name), r'sydney|new south wales|unsw|macquarie|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame'))
)
SELECT uni, section, yr, COUNT(*) entries, COUNT(DISTINCT id) profiles
FROM (SELECT * FROM w UNION ALL SELECT * FROM e)
GROUP BY uni, section, yr ORDER BY uni, section, yr
