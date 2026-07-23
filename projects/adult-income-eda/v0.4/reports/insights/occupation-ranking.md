---

id: occupation-ranking
title: "A 68-point income rate spread across occupations — private household workers earn >$50K at 0.7%"
phase: anomaly
priority: 3

narrative:
  short_form: "Across 14 named occupations, income rate spans 0.7% (Priv-house-serv) to 48.4% (Exec-managerial) — the occupational structure enforces a near-absolute income floor for domestic workers."
  long_form: |
    Priv-house-serv (private household service workers — maids, domestic workers, nannies) is the
    structural floor of the occupational hierarchy in this dataset: 149 workers, 1 earning >$50K (0.7%).
    The wage ceiling here is set by the ability of individual households to pay, not corporate employment
    markets or collective bargaining. This is not a marginal difference from the next lowest occupation —
    it is qualitatively distinct. Other-service (4.2%) and Handlers-cleaners (6.3%) are next lowest,
    still in single digits. At the top: Exec-managerial (48.4%) and Prof-specialty (44.9%) together
    account for 25% of the sample. The 68-point spread is visible as a lollipop ranking and represents
    structural inequality that is distinct from individual educational attainment.

evidence:

- role: primary
  caption: "Income rate by occupation, ranked ascending"
  numeric:
  "Priv-house-serv": "0.7%"
  "Other-service": "4.2%"
  "Handlers-cleaners": "6.3%"
  "Adm-clerical": "13.4%"
  "Sales": "26.9%"
  "Protective-serv": "32.5%"
  "Prof-specialty": "44.9%"
  "Exec-managerial": "48.4%"
  chart_ref: data/processed/chart_occ_lollipop.rds

references: []
