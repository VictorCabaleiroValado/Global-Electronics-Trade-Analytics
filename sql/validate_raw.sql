SELECT year, COUNT(*) AS rows_loaded, COUNT(DISTINCT hs6) AS products,
 COUNTIF(weight_tonnes IS NULL) AS missing_weight,
 SUM(value_thousand_usd) AS value_thousand_usd
FROM `victor-electronics-telecom21.electronics_telecom.baci_trade_raw`
GROUP BY year ORDER BY year;
