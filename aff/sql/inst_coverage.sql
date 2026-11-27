-- 2026 file: what the implicit signal adds. For each researcher-institution pair, is the link already explicit
-- (an affiliation the system wrote), entered by the researcher (matched on any ID or name form of the
-- organisation, see inst_org_keys.sql), or visible only through other items?
-- Systems with no organisation (researchers rarely name it, so a service, not an employer) are left out.
WITH keys AS (SELECT * FROM `your-project.your_dataset.orcid_inst_org_keys`),
p AS (
  SELECT * FROM `your-project.your_dataset.orcid_inst_pairs`
  WHERE in_2026 AND NOT via_mp AND inst IN (SELECT inst FROM keys)
), selfemp AS (
  SELECT p.id, p.inst, LOGICAL_OR(a.ey IS NULL) open_entry
  FROM p JOIN `your-project.your_dataset.orcid_aff_2026` a ON a.id = p.id AND a.section = 'employment' AND a.self_asserted
  JOIN keys k ON k.inst = p.inst AND ((k.key_type = 'id' AND k.k = a.org_id) OR (k.key_type = 'name' AND k.k = LOWER(TRIM(a.org))))
  GROUP BY 1, 2
), anyemp AS (SELECT DISTINCT id FROM `your-project.your_dataset.orcid_aff_2026` WHERE section = 'employment')
SELECT
  CASE WHEN p.any_aff THEN '1 affiliation written by the system'
       WHEN s.id IS NOT NULL AND s.open_entry THEN '2 researcher entered it, current'
       WHEN s.id IS NOT NULL THEN '3 researcher entered it, ended'
       WHEN e.id IS NOT NULL THEN '4 only other employment on the record'
       ELSE '5 no employment on the record at all' END link,
  COUNT(*) pairs, COUNT(DISTINCT p.id) researchers, COUNTIF(p.new_26) seen_last_year,
  APPROX_QUANTILES(p.n_months, 2)[OFFSET(1)] median_months_seen,
  COUNTIF(p.last_seen < '2024-10-14') not_seen_2y
FROM p LEFT JOIN selfemp s USING (id, inst) LEFT JOIN anyemp e ON e.id = p.id
GROUP BY 1 ORDER BY 1
