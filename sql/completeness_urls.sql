-- Share of public records listing at least one website, in each of the last three releases.
SELECT yr, COUNT(*) profiles,
  ROUND(100*COUNTIF((SELECT COUNT(*) FROM UNNEST(person.researcher_urls.urls) z WHERE z.last_modified_date IS NOT NULL) > 0)/COUNT(*),1) pct_urls
FROM (
  SELECT '2024' yr, person, activities FROM `ds-open-datasets.orcid.summaries_2024` UNION ALL
  SELECT '2025', person, activities FROM `ds-open-datasets.orcid.summaries_2025` UNION ALL
  SELECT '2026', person, activities FROM `ds-open-datasets.orcid.summaries_2026`)
GROUP BY yr ORDER BY yr
