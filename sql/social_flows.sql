CREATE TEMP FUNCTION plat(url STRING, nm STRING) AS ((
  WITH x AS (SELECT LOWER(TRIM(url)) u, REGEXP_REPLACE(IFNULL(NET.HOST(IF(REGEXP_CONTAINS(LOWER(TRIM(url)), r'^[a-z]+://'), LOWER(TRIM(url)), CONCAT('http://', LOWER(TRIM(url))))), ''), r'^(www|m|mobile)\.', '') h)
  SELECT CASE
    WHEN h = 'bsky.app' OR h = 'bsky.social' OR ENDS_WITH(h, '.bsky.social') THEN 'bluesky'
    WHEN REGEXP_CONTAINS(LOWER(IFNULL(nm,'')), r'bluesky|bsky') THEN 'bluesky_custom'
    WHEN h IN ('twitter.com','x.com') THEN 'x'
    WHEN REGEXP_CONTAINS(LOWER(IFNULL(nm,'')), r'mastodon') OR (REGEXP_CONTAINS(u, r'/@[a-z0-9_]+/?$') AND NOT REGEXP_CONTAINS(h, r'medium|youtube|tiktok|threads')) THEN 'mastodon'
    ELSE NULL END FROM x));
WITH p25 AS (SELECT orcid_identifier.path id, ARRAY(SELECT DISTINCT plat(x.url, x.url_name) FROM UNNEST(person.researcher_urls.urls) x WHERE plat(x.url, x.url_name) IS NOT NULL) s FROM `ds-open-datasets.orcid.summaries_2025`),
p26 AS (SELECT orcid_identifier.path id, ARRAY(SELECT DISTINCT plat(x.url, x.url_name) FROM UNNEST(person.researcher_urls.urls) x WHERE plat(x.url, x.url_name) IS NOT NULL) s FROM `ds-open-datasets.orcid.summaries_2026`),
j AS (SELECT p26.id, p25.id IS NOT NULL in25, IFNULL(p25.s, []) a, p26.s b FROM p26 LEFT JOIN p25 USING (id))
SELECT
  COUNTIF('bluesky_custom' IN UNNEST(b)) bsky_custom_domain_26,
  COUNTIF('bluesky_custom' IN UNNEST(a)) bsky_custom_domain_25,
  COUNTIF(in25 AND 'x' IN UNNEST(a) AND 'x' NOT IN UNNEST(b)) x_dropped,
  COUNTIF('x' NOT IN UNNEST(a) AND 'x' IN UNNEST(b)) x_added,
  COUNTIF(in25 AND 'bluesky' NOT IN UNNEST(a) AND 'bluesky' IN UNNEST(b)) bsky_added_existing,
  COUNTIF(NOT in25 AND 'bluesky' IN UNNEST(b)) bsky_on_new_profiles,
  COUNTIF(in25 AND 'bluesky' IN UNNEST(a) AND 'bluesky' NOT IN UNNEST(b)) bsky_dropped,
  COUNTIF(in25 AND 'x' IN UNNEST(a) AND 'x' NOT IN UNNEST(b) AND 'bluesky' IN UNNEST(b)) x_dropped_and_has_bsky,
  COUNTIF('x' IN UNNEST(b) AND 'bluesky' IN UNNEST(b)) both_x_bsky_26,
  COUNTIF('bluesky' IN UNNEST(b)) bsky_26,
  COUNTIF('mastodon' IN UNNEST(b)) mastodon_26, COUNTIF('mastodon' IN UNNEST(a)) mastodon_25,
  COUNTIF(in25 AND 'mastodon' IN UNNEST(a) AND 'mastodon' NOT IN UNNEST(b)) mastodon_dropped,
  COUNTIF(in25) existing_profiles, COUNTIF(NOT in25) new_profiles,
  (SELECT COUNT(*) FROM `ds-open-datasets.orcid.summaries_2025` WHERE orcid_identifier.path NOT IN (SELECT id FROM p26)) gone_from_2026
FROM j
