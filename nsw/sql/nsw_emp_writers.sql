-- Which member clients write employment entries for NSW universities (by organisation name), 2026 snapshot.
SELECT r.source.source_client_id.path client, ANY_VALUE(r.source.source_name) name,
  APPROX_TOP_COUNT(r.organization.name, 1)[OFFSET(0)].value top_org, COUNT(*) entries
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
WHERE r.source.source_client_id.path IS NOT NULL AND r.organization.address.country = 'AU'
  AND REGEXP_CONTAINS(LOWER(r.organization.name), r'sydney|new south wales|unsw|macquarie|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
GROUP BY client HAVING entries >= 20 ORDER BY entries DESC
