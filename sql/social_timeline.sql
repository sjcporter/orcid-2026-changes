WITH x AS (
  SELECT SUBSTR(x.created_date, 1, 7) ym,
    REGEXP_REPLACE(IFNULL(NET.HOST(IF(REGEXP_CONTAINS(LOWER(TRIM(x.url)), r'^[a-z]+://'), LOWER(TRIM(x.url)), CONCAT('http://', LOWER(TRIM(x.url))))), ''), r'^(www|m|mobile)\.', '') h
  FROM `ds-open-datasets.orcid.summaries_2026`, UNNEST(person.researcher_urls.urls) x)
SELECT ym,
  COUNTIF(h = 'bsky.app' OR h = 'bsky.social' OR ENDS_WITH(h, '.bsky.social')) bluesky,
  COUNTIF(h IN ('twitter.com','x.com')) x_twitter,
  COUNTIF(h = 'x.com') x_dot_com,
  COUNTIF(ENDS_WITH(h, 'linkedin.com')) linkedin,
  COUNT(*) all_links
FROM x WHERE ym >= '2022-01' GROUP BY ym ORDER BY ym
