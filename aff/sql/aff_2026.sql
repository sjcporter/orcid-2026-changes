-- One row per affiliation entry (all six affiliation sections) in the 2026 public data file.
-- src = client id, or the source iD for user-sourced entries; self_asserted = the researcher's own iD is the source.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_aff_2026` AS
  SELECT t.orcid_identifier.path id, 'employment' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT t.orcid_identifier.path id, 'education' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT t.orcid_identifier.path id, 'qualification' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT t.orcid_identifier.path id, 'invited_position' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  UNION ALL
  SELECT t.orcid_identifier.path id, 'membership' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  UNION ALL
  SELECT t.orcid_identifier.path id, 'service' section,
    IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src,
    r.source.source_client_id.path IS NULL AND r.source.source_orcid.path = t.orcid_identifier.path self_asserted,
    r.source.source_name src_name,
    IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin,
    r.created_date cd, r.last_modified_date lmd,
    r.organization.name org, r.organization.address.country org_country,
    r.organization.disambiguated_organization.source org_id_type, r.organization.disambiguated_organization.identifier org_id,
    r.start_date.year sy, r.start_date.month sm, r.end_date.year ey, r.end_date.month em,
    r.role_title IS NOT NULL AND r.role_title != '' has_role, r.department_name IS NOT NULL AND r.department_name != '' has_dept
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r