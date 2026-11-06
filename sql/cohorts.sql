SELECT SUBSTR(history.submission_date, 1, 4) created_year, COUNT(*) profiles,
  ROUND(100*COUNTIF((SELECT COUNT(*) FROM UNNEST(activities.employments.groups) z WHERE z.last_modified_date IS NOT NULL) > 0)/COUNT(*),1) pct_employment,
  ROUND(100*COUNTIF((SELECT COUNT(*) FROM UNNEST(activities.works.groups) z WHERE z.last_modified_date IS NOT NULL) > 0)/COUNT(*),1) pct_works,
  ROUND(100*COUNTIF((SELECT COUNT(*) FROM UNNEST(person.researcher_urls.urls) z WHERE z.last_modified_date IS NOT NULL) > 0)/COUNT(*),1) pct_urls,
  ROUND(100*COUNTIF(SUBSTR(history.last_modified_date,1,10) >= '2025-10-14')/COUNT(*),1) pct_touched_last_year
FROM `ds-open-datasets.orcid.summaries_2026`
GROUP BY 1 ORDER BY 1
