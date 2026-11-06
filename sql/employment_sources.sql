-- Employment records created in the year between snapshots, by who added them.
-- A record whose source is the profile owner (source_orcid = own iD) is self-asserted.
SELECT
  CASE WHEN r.source.source_orcid.path = t.orcid_identifier.path THEN '(self-asserted)'
       ELSE IFNULL(r.source.source_name, '(unknown)') END added_by,
  COUNT(*) records, COUNT(DISTINCT t.orcid_identifier.path) profiles,
  APPROX_TOP_COUNT(r.organization.address.country, 3) top_countries
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15'
GROUP BY 1 ORDER BY records DESC LIMIT 25
