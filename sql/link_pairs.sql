-- Which link platforms are listed together? Lift = observed profiles listing both / expected if independent,
-- among 2026 profiles with at least one website. Platform rules as in urls_platforms.sql.
WITH u AS (
  SELECT '2026' yr, orcid_identifier.path id, LOWER(TRIM(x.url)) url, LOWER(x.url_name) nm, x.created_date
  FROM `ds-open-datasets.orcid.summaries_2026`, UNNEST(person.researcher_urls.urls) x
), h AS (
  SELECT *, REGEXP_REPLACE(IFNULL(NET.HOST(IF(REGEXP_CONTAINS(url, r'^[a-z]+://'), url, CONCAT('http://', url))), ''), r'^(www|m|mobile)\.', '') host FROM u
), c AS (
  SELECT *, CASE
    WHEN host = 'bsky.app' OR ENDS_WITH(host, '.bsky.social') OR host = 'bsky.social' THEN 'Bluesky'
    WHEN host IN ('twitter.com','x.com') THEN 'X/Twitter'
    WHEN REGEXP_CONTAINS(url, r'/@[a-z0-9_]+/?$') AND NOT REGEXP_CONTAINS(host, r'medium|youtube|tiktok|threads') OR REGEXP_CONTAINS(host, r'^(mastodon\.|fediscience|scholar\.social|mstdn|sciences\.social|ecoevo\.social|hcommons\.social|mas\.to|mathstodon)') THEN 'Mastodon/fediverse'
    WHEN host = 'threads.net' OR host = 'threads.com' THEN 'Threads'
    WHEN ENDS_WITH(host, 'linkedin.com') THEN 'LinkedIn'
    WHEN host = 'scholar.google.com' OR REGEXP_CONTAINS(host, r'^scholar\.google\.') THEN 'Google Scholar'
    WHEN host = 'researchgate.net' THEN 'ResearchGate'
    WHEN host = 'github.com' OR ENDS_WITH(host, '.github.io') THEN 'GitHub'
    WHEN host = 'gitlab.com' THEN 'GitLab'
    WHEN ENDS_WITH(host, 'academia.edu') THEN 'Academia.edu'
    WHEN host IN ('scopus.com') THEN 'Scopus'
    WHEN host IN ('webofscience.com','publons.com','researcherid.com') THEN 'Web of Science/Publons'
    WHEN host IN ('facebook.com','fb.com') THEN 'Facebook'
    WHEN host = 'instagram.com' THEN 'Instagram'
    WHEN host IN ('youtube.com','youtu.be') THEN 'YouTube'
    WHEN host = 'tiktok.com' THEN 'TikTok'
    WHEN host = 'medium.com' OR ENDS_WITH(host, '.medium.com') THEN 'Medium'
    WHEN ENDS_WITH(host, 'substack.com') THEN 'Substack'
    WHEN host = 'semanticscholar.org' THEN 'Semantic Scholar'
    WHEN host IN ('loop.frontiersin.org') THEN 'Frontiers Loop'
    WHEN host IN ('osf.io') THEN 'OSF'
    WHEN host IN ('zenodo.org') THEN 'Zenodo'
    WHEN host IN ('figshare.com') OR ENDS_WITH(host, '.figshare.com') THEN 'Figshare'
    WHEN host IN ('dimensions.ai','app.dimensions.ai') THEN 'Dimensions'
    WHEN host IN ('wikipedia.org') OR ENDS_WITH(host, '.wikipedia.org') THEN 'Wikipedia'
    WHEN host = 'wikidata.org' THEN 'Wikidata'
    WHEN host = 'lattes.cnpq.br' OR host = 'buscatextual.cnpq.br' THEN 'Lattes (Brazil)'
    WHEN host = 'kaggle.com' THEN 'Kaggle'
    WHEN host = 'huggingface.co' THEN 'Hugging Face'
    WHEN host = 'ssrn.com' OR ENDS_WITH(host, '.ssrn.com') THEN 'SSRN'
    WHEN host = 'sites.google.com' THEN 'Google Sites'
    WHEN host = 'linktr.ee' THEN 'Linktree'
    WHEN host = 'mendeley.com' THEN 'Mendeley'
    WHEN host = 'arxiv.org' THEN 'arXiv'
    WHEN host = 'doi.org' OR host = 'dx.doi.org' THEN 'DOI link'
    WHEN host = 'orcid.org' THEN 'ORCID'
    WHEN host = '' THEN '(unparseable)'
    ELSE 'Other' END platform FROM h
)
, p AS (SELECT DISTINCT id, platform FROM c WHERE platform NOT IN ('Other', '(unparseable)')),
n AS (SELECT COUNT(DISTINCT id) tot FROM c),
m AS (SELECT platform, COUNT(*) cnt FROM p GROUP BY 1)
SELECT a.platform pa, b.platform pb, COUNT(*) both_n, ANY_VALUE(ma.cnt) n_a, ANY_VALUE(mb.cnt) n_b, ANY_VALUE(n.tot) tot,
  ROUND(COUNT(*) * ANY_VALUE(n.tot) / (ANY_VALUE(ma.cnt) * ANY_VALUE(mb.cnt)), 2) lift
FROM p a JOIN p b ON a.id = b.id AND a.platform < b.platform
JOIN m ma ON ma.platform = a.platform JOIN m mb ON mb.platform = b.platform CROSS JOIN n
GROUP BY 1, 2 HAVING both_n >= 20 ORDER BY lift DESC
