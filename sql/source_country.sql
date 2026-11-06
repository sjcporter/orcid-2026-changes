WITH prof AS (
  SELECT t.orcid_identifier.path id,
    (SELECT r.organization.address.country FROM UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r WHERE r.organization.address.country IS NOT NULL LIMIT 1) c
  FROM `ds-open-datasets.orcid.summaries_2026` t),
emp AS (
  SELECT r.source.source_client_id.path cid, r.organization.address.country c
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.source.source_client_id.path IS NOT NULL),
wk AS (
  SELECT r.source.source_client_id.path cid, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.source.source_client_id.path IS NOT NULL),
e AS (SELECT cid, APPROX_TOP_COUNT(c, 1)[OFFSET(0)] top, COUNT(c) n FROM emp WHERE c IS NOT NULL GROUP BY cid),
w AS (SELECT cid, APPROX_TOP_COUNT(p.c, 1)[OFFSET(0)] top, COUNT(p.c) n FROM wk JOIN prof p USING (id) WHERE p.c IS NOT NULL GROUP BY cid)
SELECT COALESCE(e.cid, w.cid) client_id,
  e.top.value emp_country, ROUND(e.top.count / e.n, 3) emp_share, e.n emp_n,
  w.top.value works_profile_country, ROUND(w.top.count / w.n, 3) works_share, w.n works_n
FROM e FULL JOIN w ON e.cid = w.cid
