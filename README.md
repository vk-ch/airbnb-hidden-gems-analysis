# Airbnb Hidden Gems Analysis

**SQL + Python | UW Foster School of Business **

Identifying underpriced, high-demand Airbnb listings across San Francisco and Seattle using SQL-based feature engineering and Python visualizations.

---

## The Business Question

Which Airbnb listings are priced below their neighbourhood median but show strong demand signals? These "hidden gems" represent the highest revenue opportunity for new hosts entering the market.

## What's In Here

| File | What it does |
|---|---|
| `notebook/AirbnbData.ipynb` | Full analysis with 45 embedded visualizations |
| `sql/01_data_cleaning.sql` | Complete data cleaning pipeline (6 phases) |
| `sql/02_hidden_gems_analysis.sql` | Core hidden gem scoring query using CTEs and window functions |

## Key Findings

- Hidden gems in **Seattle's Capitol Hill** neighbourhood outperform market listings by 3x on the performance ratio (reviews per dollar)
- **Entire home/apt** listings priced below neighbourhood median with under 100 days availability show the strongest revenue signals
- SF hidden gems cluster in **Mission District** and **Inner Sunset**, with average price gaps of $40 to $80 below market
- Listings with fewer than 100 days of annual availability generate disproportionately high review frequency, indicating strong repeat demand

## Visualizations (from notebook)

The notebook renders directly on GitHub and includes:
- Scatter plots: price vs performance ratio by city
- Heatmaps: feature correlation matrices for SF and Seattle
- Bar charts: average metrics by neighbourhood and room type
- Distribution plots: price, availability, and review frequency
- Combined city comparisons

## SQL Approach

The hidden gem scoring uses a three-stage CTE pipeline:
1. **Ranked** — row-number window function to compute neighbourhood medians
2. **Medians** — conditional aggregation to handle odd and even counts
3. **Hidden Gems** — filter on below-median price, high demand (performance ratio > 0.01), and limited supply (availability < 100 days)

## Tools

`MySQL` `Python` `pandas` `matplotlib` `seaborn` `plotly`

## Dataset

Airbnb US 2023 listings across NYC, LA, SF, and Seattle. Data cleaned and transformed as documented in `sql/01_data_cleaning.sql`.

---

*Business Analytics portfolio.*
