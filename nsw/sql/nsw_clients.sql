-- ORCID member clients whose source name looks like an NSW university: entries, profiles, first year, last-year activity.
WITH a AS (
SELECT 'work' section, r.source.source_client_id.path client, r.source.source_name name, t.orcid_identifier.path id,
  r.created_date >= '2025-10-14' created_ly, SUBSTR(r.created_date,1,4) yr
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
WHERE r.source.source_client_id.path IS NOT NULL AND REGEXP_CONTAINS(LOWER(r.source.source_name), r'sydney|new south wales|unsw|\\buts\\b|technology sydney|macquarie|western sydney|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
UNION ALL
SELECT 'employment' section, r.source.source_client_id.path client, r.source.source_name name, t.orcid_identifier.path id,
  r.created_date >= '2025-10-14' created_ly, SUBSTR(r.created_date,1,4) yr
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
WHERE r.source.source_client_id.path IS NOT NULL AND REGEXP_CONTAINS(LOWER(r.source.source_name), r'sydney|new south wales|unsw|\\buts\\b|technology sydney|macquarie|western sydney|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
UNION ALL
SELECT 'education' section, r.source.source_client_id.path client, r.source.source_name name, t.orcid_identifier.path id,
  r.created_date >= '2025-10-14' created_ly, SUBSTR(r.created_date,1,4) yr
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
WHERE r.source.source_client_id.path IS NOT NULL AND REGEXP_CONTAINS(LOWER(r.source.source_name), r'sydney|new south wales|unsw|\\buts\\b|technology sydney|macquarie|western sydney|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
UNION ALL
SELECT 'funding' section, r.source.source_client_id.path client, r.source.source_name name, t.orcid_identifier.path id,
  r.created_date >= '2025-10-14' created_ly, SUBSTR(r.created_date,1,4) yr
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
WHERE r.source.source_client_id.path IS NOT NULL AND REGEXP_CONTAINS(LOWER(r.source.source_name), r'sydney|new south wales|unsw|\\buts\\b|technology sydney|macquarie|western sydney|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
UNION ALL
SELECT 'external_id' section, r.source.source_client_id.path client, r.source.source_name name, t.orcid_identifier.path id,
  r.created_date >= '2025-10-14' created_ly, SUBSTR(r.created_date,1,4) yr
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.external_identifiers.identifiers) r
WHERE r.source.source_client_id.path IS NOT NULL AND REGEXP_CONTAINS(LOWER(r.source.source_name), r'sydney|new south wales|unsw|\\buts\\b|technology sydney|macquarie|western sydney|newcastle|wollongong|southern cross|charles sturt|new england|australian catholic|notre dame')
)
SELECT client, ANY_VALUE(name) name, section, COUNT(*) entries, COUNT(DISTINCT id) profiles, MIN(yr) first_yr,
  COUNTIF(created_ly) entries_last_year, COUNT(DISTINCT IF(created_ly, id, NULL)) profiles_last_year
FROM a GROUP BY client, section ORDER BY name, section
