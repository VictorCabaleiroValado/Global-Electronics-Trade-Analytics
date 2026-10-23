ASSERT (WITH expected AS (SELECT * FROM UNNEST([STRUCT(2012 AS year, 73518 AS rows_loaded, 6565 AS missing_weight, CAST('766950179.3740000000001' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2013 AS year, 78376 AS rows_loaded, 6204 AS missing_weight, CAST('769870644.81799999999' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2014 AS year, 80979 AS rows_loaded, 6133 AS missing_weight, CAST('839094836.200000000000501' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2015 AS year, 84874 AS rows_loaded, 7088 AS missing_weight, CAST('841297176.49999999999999' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2016 AS year, 85412 AS rows_loaded, 6839 AS missing_weight, CAST('857453456.5010000000001' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2017 AS year, 87259 AS rows_loaded, 6422 AS missing_weight, CAST('973957481.301' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2018 AS year, 87935 AS rows_loaded, 6939 AS missing_weight, CAST('1062668372.86599999999' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2019 AS year, 88313 AS rows_loaded, 7039 AS missing_weight, CAST('1048401766.887' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2020 AS year, 85992 AS rows_loaded, 7046 AS missing_weight, CAST('1112499768.73100000000157' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2021 AS year, 89852 AS rows_loaded, 5958 AS missing_weight, CAST('1350987855.923999999999' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2022 AS year, 90308 AS rows_loaded, 8536 AS missing_weight, CAST('1416128029.6759999999979' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2023 AS year, 89887 AS rows_loaded, 8469 AS missing_weight, CAST('1256487223.579000000001' AS BIGNUMERIC) AS value_thousand_usd),
STRUCT(2024 AS year, 84572 AS rows_loaded, 8575 AS missing_weight, CAST('1382362717.2710000000000' AS BIGNUMERIC) AS value_thousand_usd)])), actual AS (
SELECT year,COUNT(*) AS rows_loaded,COUNTIF(weight_tonnes IS NULL) AS missing_weight,SUM(value_thousand_usd) AS value_thousand_usd
FROM `victor-electronics-telecom21.electronics_telecom.baci_trade_history` GROUP BY year)
SELECT COUNT(*) FROM expected e FULL JOIN actual a USING(year)
WHERE e.year IS NULL OR a.year IS NULL OR e.rows_loaded!=a.rows_loaded OR e.missing_weight!=a.missing_weight OR e.value_thousand_usd!=a.value_thousand_usd)=0 AS 'Per-year exact reconciliation';
ASSERT (SELECT COUNT(*) FROM `victor-electronics-telecom21.electronics_telecom.country_year_benchmark` WHERE hhi < 0 OR hhi > 10000.000001 OR top_partner_share < 0 OR top_partner_share > 1.000001)=0 AS 'Concentration bounds';
-- Import this view as Trade. Country and Partner are role-playing dimensions.
-- Direction must be single-select. Measures also enforce one direction.
CREATE OR REPLACE VIEW `victor-electronics-telecom21.electronics_telecom.fact_country_trade` AS
SELECT year, importer_code AS country_code, exporter_code AS partner_code,
       hs6, 'Imports' AS direction, trade_value_usd, weight_tonnes, has_weight
FROM `victor-electronics-telecom21.electronics_telecom.fact_trade`
UNION ALL
SELECT year, exporter_code, importer_code, hs6, 'Exports',
       trade_value_usd, weight_tonnes, has_weight
FROM `victor-electronics-telecom21.electronics_telecom.fact_trade`;

SELECT direction, COUNT(*) AS rows_loaded, SUM(trade_value_usd) AS value_usd
FROM `victor-electronics-telecom21.electronics_telecom.fact_country_trade`
GROUP BY direction;
