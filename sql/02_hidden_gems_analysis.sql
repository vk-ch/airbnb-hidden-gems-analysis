-- ============================================================
-- Airbnb US 2023 | Hidden Gems Analysis
-- Author: Venkat Kowshik | UW Foster School of Business
-- Identifies underpriced, high-demand listings in SF and Seattle
-- ============================================================

-- City-specific tables
CREATE TABLE new_york_listing    AS SELECT * FROM ab_us_2023 WHERE City = 'New York City';
CREATE TABLE los_angeles_listings AS SELECT * FROM ab_us_2023 WHERE City = 'Los Angeles';
CREATE TABLE seattle_listings     AS SELECT * FROM ab_us_2023 WHERE City = 'Seattle';
CREATE TABLE san_francisco_listings AS SELECT * FROM ab_us_2023 WHERE City = 'San Francisco';

-- ============================================================
-- CORE HIDDEN GEMS QUERY
-- Logic: price below neighbourhood median + high demand + limited supply
-- ============================================================
WITH ranked AS (
  SELECT
    neighbourhood_group, neighbourhood, room_type,
    price, availability_365, number_of_reviews, reviews_per_month, city,
    ROW_NUMBER() OVER (
      PARTITION BY neighbourhood, room_type ORDER BY price
    ) AS rn,
    COUNT(*) OVER (
      PARTITION BY neighbourhood, room_type
    ) AS cnt
  FROM ab_us_2023
  WHERE price > 0
    AND price < 10000
    AND neighbourhood IS NOT NULL
    AND room_type IS NOT NULL
    AND city IN ('San Francisco', 'Seattle')
),
medians AS (
  SELECT
    neighbourhood, room_type,
    CASE
      WHEN cnt % 2 = 1
        THEN MAX(CASE WHEN rn = (cnt + 1) / 2 THEN price END)
      ELSE AVG(CASE WHEN rn IN (cnt / 2, (cnt / 2) + 1) THEN price END)
    END AS median_price
  FROM ranked
  GROUP BY neighbourhood, room_type, cnt
),
hidden_gems AS (
  SELECT
    r.neighbourhood_group, r.neighbourhood, r.room_type,
    r.price, m.median_price, r.number_of_reviews,
    COALESCE(r.reviews_per_month, r.number_of_reviews / 12.0) AS reviews_per_month,
    r.availability_365, r.city,
    (COALESCE(r.reviews_per_month, r.number_of_reviews / 12.0) / NULLIF(r.price, 0)) AS performance_ratio
  FROM ranked r
  JOIN medians m ON r.neighbourhood = m.neighbourhood AND r.room_type = m.room_type
  WHERE m.median_price IS NOT NULL
    AND r.price < m.median_price
    AND r.availability_365 < 100
    AND (COALESCE(r.reviews_per_month, r.number_of_reviews / 12.0) / NULLIF(r.price, 0)) > 0.01
)
SELECT
  neighbourhood_group, neighbourhood, room_type,
  COUNT(*)                                    AS hidden_gem_count,
  ROUND(AVG(price), 2)                        AS avg_price,
  ROUND(AVG(median_price), 2)                 AS avg_market_price,
  ROUND(AVG(median_price) - AVG(price), 2)    AS avg_price_gap,
  ROUND(AVG(reviews_per_month), 2)            AS avg_reviews_per_month,
  ROUND(AVG(availability_365), 0)             AS avg_availability,
  ROUND(AVG(performance_ratio), 4)            AS avg_performance_ratio,
  ROUND(AVG(median_price - price), 2)         AS avg_revenue_opportunity,
  city
FROM hidden_gems
GROUP BY neighbourhood_group, neighbourhood, room_type, city
HAVING COUNT(*) >= 2
ORDER BY avg_performance_ratio DESC, hidden_gem_count DESC;
