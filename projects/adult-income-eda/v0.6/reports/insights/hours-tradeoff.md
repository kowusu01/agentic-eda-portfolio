---
id: hours-income-turnover
title: "Working 80+ Hours a Week Pays Off Less Often Than Working 41-79"
phase: anomaly
priority: 2

narrative:
  short_form: "The share earning >$50K rises with hours worked through the 41-79 hour band (40.4%) but drops for the 80+ hour group (35.2%) — inconsistent with a simple 'more hours, more pay' story."
  long_form: |
    More hours worked tracks a higher >50K rate — up to a point. The relationship rises cleanly
    from part-time (6.9%) through the 41-79 hour band (40.4%), intuitive since more hours generally
    means more income and salaried professional/managerial roles cluster in that band. But it turns
    over at 80+ hours/week, dropping to 35.2% — the extreme-hours group earns less often than the
    41-79 hour group, not more. That's inconsistent with a simple "grinding harder pays off" story,
    and more consistent with at least part of that 341-person group holding down multiple
    lower-wage jobs rather than one intensely compensated one. Separately, hours_per_week heaps
    hard at exactly 40 (46.7% of the entire sample) — the culturally standard reporting number — a
    self-report rounding artifact worth keeping in mind rather than a claim that nearly half the
    workforce works precisely 40.00 hours.

evidence:
  - role: primary
    caption: "Share earning >$50K by weekly-hours band"
    numeric: { pct_under_35hrs: 6.9, pct_41to79hrs: 40.4, pct_80plus_hrs: 35.2, n_80plus_hrs: 341, pct_exactly_40hrs_of_sample: 46.7 }
    chart_ref: data/processed/chart_hours_band.rds

references: []
