-- Which university's integration delivered the co-author links that are new since 2024 and visible only via an integration (2026 snapshot).
-- A link is credited to every university whose integration is the sole source of a shared DOI on one side.
WITH clients AS (
  SELECT * FROM UNNEST([
    STRUCT<client STRING, uni STRING>('APP-LWWJS7JD173TPE94', 'USyd'), ('APP-Z2004HUVFXDAN1EK', 'USyd'),
    ('0000-0002-8446-3621', 'UNSW'), ('APP-BQO2Q6GUIRPPQFEP', 'UTS'), ('APP-UKGLZX5LPGYOXYX5', 'Macquarie'),
    ('APP-FEB9IGN79LRYBHOS', 'Western Sydney'), ('APP-A2MHMQNKG9OQFDHH', 'Newcastle'),
    ('APP-960EPY2F4TK0VIXA', 'Wollongong'), ('APP-472E03Z2PK4QX84O', 'Wollongong'),
    ('APP-VKNFGSUVT5M2SUJ5', 'Charles Sturt'), ('APP-EJGLA2YA0THTYIKZ', 'Southern Cross'),
    ('APP-G1HUWSKAF9O4SNK0', 'New England')])
),
e AS (
  SELECT n.a, n.b FROM `your-project.your_dataset.nsw_edges` n
  LEFT JOIN `your-project.your_dataset.nsw_edges` o ON o.snap = '2024' AND o.a = n.a AND o.b = n.b
  WHERE n.snap = '2026' AND n.needs_int AND o.a IS NULL
),
ids AS (SELECT a id FROM e UNION DISTINCT SELECT b FROM e),
size AS (SELECT doi FROM `your-project.your_dataset.orcid_doi_2026` GROUP BY doi HAVING COUNT(DISTINCT id) <= 100),
d AS (
  SELECT id, doi, ARRAY_AGG(DISTINCT IFNULL(c.uni, '-')) srcs
  FROM `your-project.your_dataset.orcid_doi_2026` x LEFT JOIN clients c ON c.client = x.src
  WHERE id IN (SELECT id FROM ids) AND doi IN (SELECT doi FROM size) GROUP BY id, doi
),
sole AS (SELECT id, doi, srcs[OFFSET(0)] uni FROM d WHERE ARRAY_LENGTH(srcs) = 1 AND srcs[OFFSET(0)] != '-'),
credit AS (
  SELECT DISTINCT e.a, e.b, s.uni
  FROM e JOIN d x ON x.id = e.a JOIN d y ON y.id = e.b AND y.doi = x.doi
  JOIN sole s ON s.doi = x.doi AND s.id IN (e.a, e.b)
)
SELECT uni, COUNT(*) new_links_credited, (SELECT COUNT(*) FROM e) total_new_int_links
FROM credit GROUP BY uni ORDER BY new_links_credited DESC
