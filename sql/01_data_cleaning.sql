-- ============================================================
-- Airbnb US 2023 | Data Cleaning Pipeline
-- Author: Venkat Kowshik | UW Foster School of Business
-- ============================================================

-- PHASE 1: INITIAL SETUP
create schema airbnb;

-- Verify base record count
select count(*) from ab_us_2023;
select count(id) from ab_us_2023;

-- PHASE 2: IDENTIFY DATA ISSUES
select neighbourhood_group, count(*) from ab_us_2023 where neighbourhood_group = '';
select count(*) from ab_us_2023 where last_review = '';
select count(*) from ab_us_2023 where reviews_per_month = '';
select count(*) from ab_us_2023 where number_of_reviews = 0;

-- Distribution of listings without reviews by city
select city, count(*) from ab_us_2023
where number_of_reviews = 0
group by city
order by count(*) desc;

-- PHASE 3: CLEAN AND STANDARDIZE
update ab_us_2023 set neighbourhood_group = null where neighbourhood_group = '';
update ab_us_2023 set last_review = null where last_review = '';
update ab_us_2023 set reviews_per_month = 0.0 where reviews_per_month = '';

alter table ab_us_2023
  modify column reviews_per_month float,
  modify column last_review date,
  modify column latitude float,
  modify column longitude float;

-- PHASE 4: REMOVE OUTLIERS
-- Extreme minimum stay requirements
select minimum_nights, count(*) from ab_us_2023
group by minimum_nights order by minimum_nights desc;
delete from ab_us_2023 where minimum_nights > 91;

-- Suspiciously low prices
select price, count(*) from ab_us_2023
group by price order by price;
delete from ab_us_2023 where price < 25;

-- PHASE 5: VALIDATE
select count(*) from ab_us_2023;
select room_type, count(*) from ab_us_2023 group by room_type;
select city, count(*) from ab_us_2023 group by city order by count(*) desc;

-- PHASE 6: ENGINEER ANALYTICAL METRICS
alter table ab_us_2023 add column performance_ratio float;
update ab_us_2023 set performance_ratio = reviews_per_month / price;

alter table ab_us_2023 add column est_annual_revenue int;
update ab_us_2023 set est_annual_revenue = price * (365 - availability_365);

-- City-level median prices
alter table ab_us_2023 add column city_median_price float;
update ab_us_2023 a
join (
  select city, avg(price) as median_price
  from (
    select city, price,
           row_number() over (partition by city order by price) as rn,
           count(*) over (partition by city) as total_rows
    from ab_us_2023
  ) as ranked
  where rn between (total_rows - 1) / 2.0 and (total_rows + 2) / 2.0
  group by city
) as m on a.city = m.city
set a.city_median_price = m.median_price;

-- Verify
select city, city_median_price from ab_us_2023 group by city, city_median_price;
select * from ab_us_2023 limit 10;
