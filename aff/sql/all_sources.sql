-- Every source (other than the researcher) that writes anything to a public record, with item counts by snapshot.
WITH a AS (
  SELECT 2024 yr, 'work' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'funding' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'peer_review' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'research_resource' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'employment' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'education' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'qualification' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'invited_position' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'membership' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'service' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'external_id' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'url' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'keyword' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'other_name' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2024 yr, 'address' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'work' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'funding' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'peer_review' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'research_resource' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'employment' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'education' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'qualification' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'invited_position' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'membership' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'service' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'external_id' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'url' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'keyword' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'other_name' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2025 yr, 'address' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'work' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'funding' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'peer_review' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'research_resource' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'employment' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'education' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'qualification' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'invited_position' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'membership' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'service' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'external_id' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'url' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'keyword' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'other_name' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
  UNION ALL
  SELECT 2026 yr, 'address' kind, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.source.source_name nm, t.orcid_identifier.path id
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path
)
SELECT src client_id, ANY_VALUE(nm) source_name, STRING_AGG(DISTINCT kind ORDER BY kind) kinds,
  COUNTIF(yr = 2024) n_2024, COUNTIF(yr = 2025) n_2025, COUNTIF(yr = 2026) n_2026, COUNT(DISTINCT IF(yr = 2026, id, NULL)) ids_2026
FROM a GROUP BY 1
