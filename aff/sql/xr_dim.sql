-- Dimensions side ("cheating" run): every affiliation string on every DOI for Dimensions researchers that match
-- exactly one ORCID iD (and vice versa), with the ROR ID Dimensions resolved that string to.
-- Strings are normalised (lower case, single spaces, no trailing punctuation); DOIs are lower-cased.
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_dim` AS
WITH r AS (
  SELECT id researcher_id, REGEXP_EXTRACT(o, r'(\d{4}-\d{4}-\d{4}-\d{3}[\dX])') orcid
  FROM `dimensions-ai.data_analytics.researchers`, UNNEST(orcid_ids) o
), r1 AS (
  SELECT * FROM r WHERE orcid IS NOT NULL
  QUALIFY COUNT(*) OVER (PARTITION BY researcher_id) = 1 AND COUNT(*) OVER (PARTITION BY orcid) = 1
), g AS (
  SELECT id grid_id, REGEXP_EXTRACT(external_ids.ror.preferred, r'([0-9a-z]{9})$') ror FROM `dimensions-ai.data_analytics.organizations`
)
SELECT LOWER(p.doi) doi, p.year, a.researcher_id, r1.orcid id, LOWER(TRIM(a.last_name)) family,
  ARRAY_LENGTH(a.affiliations_address) n_aff,
  TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(aa.raw_affiliation), r'\s+', ' '), r'[\s.,;]+$', '')) raw,
  aa.grid_id, g.ror ror_truth
FROM `dimensions-ai.data_analytics.publications` p, UNNEST(p.authors) a, UNNEST(a.affiliations_address) aa
JOIN r1 ON r1.researcher_id = a.researcher_id
LEFT JOIN g ON g.grid_id = aa.grid_id
WHERE p.doi IS NOT NULL AND aa.raw_affiliation IS NOT NULL
