-- For employment entries written by integrations: were "gone" entries replaced by a new entry from the same system
-- (delete-and-recreate), and how many of this year's additions are rewrites for researchers the system already covered?
WITH prev AS (
  SELECT t.orcid_identifier.path id, r.source.source_client_id.path client, r.source.source_name src, r.created_date cd,
    LOWER(r.organization.name) org
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.source.source_client_id.path IS NOT NULL
), cur AS (
  SELECT t.orcid_identifier.path id, r.source.source_client_id.path client, r.source.source_name src, r.created_date cd,
    LOWER(r.organization.name) org
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.source.source_client_id.path IS NOT NULL
), ids AS (SELECT DISTINCT orcid_identifier.path id FROM `ds-open-datasets.orcid.summaries_2026`),
pk AS (SELECT DISTINCT id, client, cd FROM prev), ck AS (SELECT DISTINCT id, client, cd FROM cur),
pc AS (SELECT DISTINCT id, client FROM prev), cc AS (SELECT DISTINCT id, client FROM cur),
pco AS (SELECT DISTINCT id, client, org FROM prev), cco AS (SELECT DISTINCT id, client, org FROM cur),
gone AS (
  SELECT p.client, p.src,
    CASE WHEN i.id IS NULL THEN 'record_not_public'
         WHEN cco.id IS NOT NULL THEN 'recreated_same_org'
         WHEN cc.id IS NOT NULL THEN 'system_still_writes_other_org'
         ELSE 'removed' END fate
  FROM prev p
  LEFT JOIN ck ON ck.id = p.id AND ck.client = p.client AND ck.cd = p.cd
  LEFT JOIN ids i ON i.id = p.id
  LEFT JOIN cc ON cc.id = p.id AND cc.client = p.client
  LEFT JOIN cco ON cco.id = p.id AND cco.client = p.client AND cco.org = p.org
  WHERE ck.id IS NULL
), added AS (
  SELECT c.client, c.src, IF(pc.id IS NULL, 'new_researcher', 'researcher_already_covered') kind
  FROM cur c LEFT JOIN pc ON pc.id = c.id AND pc.client = c.client
  WHERE c.cd >= '2025-10-14' AND c.cd < '2026-10-15'
)
SELECT client, ANY_VALUE(src) source_name, 'gone' part, fate k, COUNT(*) n FROM gone GROUP BY 1, 3, 4
UNION ALL
SELECT client, ANY_VALUE(src), 'added_this_window', kind, COUNT(*) FROM added GROUP BY 1, 3, 4
