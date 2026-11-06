WITH n AS (
  SELECT t.orcid_identifier.path id,
    (SELECT r.organization.address.country FROM UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r LIMIT 1) emp_country,
    (SELECT a.country FROM UNNEST(t.person.addresses.addresses) a LIMIT 1) addr_country,
    SUBSTR(t.history.submission_date, 1, 10) >= '2025-10-14' is_new
  FROM `ds-open-datasets.orcid.summaries_2026` t)
SELECT COALESCE(emp_country, addr_country) country,
  COUNTIF(is_new) new_profiles, COUNTIF(NOT is_new) older_profiles,
  ROUND(100*COUNTIF(is_new)/SUM(COUNTIF(is_new)) OVER (),1) pct_of_new,
  ROUND(100*COUNTIF(NOT is_new)/SUM(COUNTIF(NOT is_new)) OVER (),1) pct_of_older
FROM n GROUP BY 1 ORDER BY new_profiles DESC LIMIT 20
