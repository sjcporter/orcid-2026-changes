-- Employment and education entries in the 2024, 2025 and 2026 files with role and department text,
-- so an entry can be compared with the one that replaced it.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_aff_detail` AS
  SELECT 2024 yr, t.orcid_identifier.path id, 'employment' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT 2024 yr, t.orcid_identifier.path id, 'education' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT 2025 yr, t.orcid_identifier.path id, 'employment' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT 2025 yr, t.orcid_identifier.path id, 'education' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT 2026 yr, t.orcid_identifier.path id, 'employment' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT 2026 yr, t.orcid_identifier.path id, 'education' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.created_date cd, LOWER(TRIM(r.organization.name)) org, r.organization.disambiguated_organization.identifier org_id,
    LOWER(TRIM(IFNULL(r.role_title, ''))) role, LOWER(TRIM(IFNULL(r.department_name, ''))) dept,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
