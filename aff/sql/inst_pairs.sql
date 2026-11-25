-- One row per researcher and institution system: every dated assertion the system made (any item, any snapshot),
-- first_seen and last_seen are the earliest and latest of those dates. Next to them is the explicit employment entry it wrote, if any. Member Portal entries count for the institution they were made for.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_inst_pairs` AS
WITH i AS (
  SELECT DISTINCT id, IF(src = 'APP-4B3XYWJHXCC1VLVV', CONCAT('MP:', IFNULL(origin, '?')), src) inst, src = 'APP-4B3XYWJHXCC1VLVV' via_mp,
    kind, cd, DATE(SUBSTR(cd, 1, 10)) d, yr
  FROM `your-project.your_dataset.orcid_inst_items`
), emp AS (
  SELECT id, IF(src = 'APP-4B3XYWJHXCC1VLVV', CONCAT('MP:', IFNULL(origin, '?')), src) inst,
    LOGICAL_OR(sy IS NOT NULL) has_start, LOGICAL_OR(sm IS NOT NULL) has_start_month,
    LOGICAL_OR(ey IS NOT NULL) has_end, LOGICAL_AND(ey IS NULL) any_open, MAX(SAFE_CAST(ey AS INT64)) end_year, MIN(SAFE_CAST(sy AS INT64)) start_year
  FROM `your-project.your_dataset.orcid_aff_2026`
  WHERE section = 'employment' AND NOT self_asserted GROUP BY 1, 2
), p AS (
  SELECT id, inst, LOGICAL_OR(via_mp) via_mp, COUNT(DISTINCT CONCAT(kind, cd)) n_items,
    COUNTIF(kind IN ('employment', 'education', 'qualification', 'invited_position', 'membership', 'service')) > 0 any_aff,
    COUNTIF(kind = 'employment') > 0 any_emp, COUNTIF(kind = 'work') > 0 any_work,
    STRING_AGG(DISTINCT kind ORDER BY kind) kinds, MIN(d) first_seen, MAX(d) last_seen,
    MAX(IF(kind NOT IN ('employment', 'education', 'qualification', 'invited_position', 'membership', 'service'), d, NULL)) last_seen_non_aff,
    COUNT(DISTINCT FORMAT_DATE('%Y-%m', d)) n_months, COUNT(DISTINCT EXTRACT(YEAR FROM d)) n_years,
    LOGICAL_OR(yr = 2024) in_2024, LOGICAL_OR(yr = 2025) in_2025, LOGICAL_OR(yr = 2026) in_2026,
    LOGICAL_OR(d > '2023-09-24' AND d <= '2024-09-24') new_24, LOGICAL_OR(d > '2024-09-24' AND d <= '2025-10-02') new_25,
    LOGICAL_OR(d > '2025-10-02' AND d <= '2026-10-14') new_26
  FROM i GROUP BY 1, 2
)
SELECT p.*, e.id IS NOT NULL emp_2026, e.has_start, e.has_start_month, e.has_end, e.any_open, e.end_year, e.start_year,
  MIN(p.first_seen) OVER (PARTITION BY p.inst) inst_first_seen
FROM p LEFT JOIN emp e USING (id, inst)
