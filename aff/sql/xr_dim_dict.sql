-- Reference for the Crossref runs: for each normalised string in the Crossref candidates, how Dimensions resolves it
-- across all authors on all its publications (modal ROR and its share).
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_dim_dict` AS
WITH s AS (SELECT DISTINCT raw FROM `your-project.your_dataset.xr_cand` WHERE run != 'dim'),
g AS (SELECT id grid_id, REGEXP_EXTRACT(external_ids.ror.preferred, r'([0-9a-z]{9})$') ror FROM `dimensions-ai.data_analytics.organizations`),
d AS (
  SELECT TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(aa.raw_affiliation), r'\s+', ' '), r'[\s.,;]+$', '')) raw, g.ror
  FROM `dimensions-ai.data_analytics.publications` p, UNNEST(p.authors) a, UNNEST(a.affiliations_address) aa
  LEFT JOIN g ON g.grid_id = aa.grid_id
  WHERE aa.raw_affiliation IS NOT NULL
), agg AS (
  SELECT d.raw, d.ror, COUNT(*) n FROM d JOIN s USING (raw) GROUP BY 1, 2
)
SELECT raw, ror ref_ror, n, n / SUM(n) OVER (PARTITION BY raw) share, SUM(n) OVER (PARTITION BY raw) n_total
FROM agg QUALIFY ROW_NUMBER() OVER (PARTITION BY raw ORDER BY n DESC) = 1
