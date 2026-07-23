# Agentic EDA Portfolio

A collection of exploratory data analysis (EDA) dashboards, built with Quarto and published to [Posit Connect Cloud](https://connect.posit.cloud/).

Each analysis was produced with the help of custom agent skills I curated myself. This repo holds only the finished, publishable output of each analysis (the `.qmd` dashboard, its data/assets, and its `manifest.json`) — not the agent, skill, or automation code used to produce it.

## Repo Structure

This is a monorepo — one repo hosts multiple independent EDA projects. Each project lives in its own folder under `projects/` and is deployed as a separate piece of content on Connect, so updates to one project redeploy only that dashboard.

```
agentic-eda-portfolio/
├── README.md
├── .gitignore
├── projects/
│   ├── project-one/
|   |   |   ├── v0/
|   |   |   |   ├── src/
|   |   |   |   |   |   ├── src1.R/src1.py
|   |   |   |   |   |   ├── src1.R/src2.py
|   |   |   |   ├── reports/
|   |   |   |   |   |   ├── manifest.json
|   |   |   |   |   |   ├── report.qmd
|   |   |   |   |   |   ├── data/
|   |   |   |   |   |   ├── insights/
|   |   |   |   |   |   ├── styles/
|   |   |   ├── v1/
|   |   |   |   ├── src/
|   |   |   |   |   |   ├── src1.R/src1.py
|   |   |   |   |   |   ├── src1.R/src2.py
|   |   |   |   ├── reports/
|   |   |   |   |   |   ├── manifest.json
|   |   |   |   |   |   ├── report.qmd
|   |   |   |   |   |   ├── data/
|   |   |   |   |   |   ├── insights/
|   |   |   |   |   |   ├── styles/
│   |   └── manifest.json
│   ├── project-two/
|   |   |   ├── v0/
|   |   |   |   ├── src/
|   |   |   |   ├── reports/
|   |   |   |   |
└── renv.lock          # optional, shared or per-project
```

## Adding a New EDA Project

1. Create a new folder under `projects/` (e.g. `projects/new-analysis/`)
2. Add the `.qmd` file and any supporting data/scripts
3. From inside the folder, run:
   ```
   quarto publish connect
   ```
4. This generates a `manifest.json` and links the project to Connect Cloud, tracking this folder's branch/path — future commits to this folder trigger redeploys automatically

## Notes

- Each project folder needs its own `manifest.json` — Connect deploys per-manifest, not per-repo
- Shared helper code, if any, can live in a top-level `R/` folder and be sourced by individual `.qmd` files
- Prefer per-project `renv.lock` files over one shared lockfile to keep dependencies isolated per analysis
