CREATE VIEW v_daniela_bilakova_avg_price AS
WITH avg_price_YoY AS
	(SELECT 
		payroll_year
		, round(avg(price)::NUMERIC, 2) AS avg_price
		, ((avg(price) - LAG(avg(price)) OVER (ORDER BY payroll_year)) / LAG(avg(price)) OVER (ORDER BY payroll_year)) * 100 AS avg_price_YoY
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	GROUP BY
		payroll_year
	),
avg_payroll_YoY AS
	(SELECT 
		payroll_year
		, round(avg(average_wages)::NUMERIC, 2) AS avg_payroll
		, ((avg(average_wages) - LAG(avg(average_wages)) OVER (ORDER BY payroll_year)) / LAG(avg(average_wages)) OVER (ORDER BY payroll_year)) * 100 AS avg_payroll_YoY
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	GROUP BY
		payroll_year
	)
SELECT 
	avgp.payroll_year AS "year"
	, round(avgp.avg_price_yoy::NUMERIC, 2) AS avg_price_YoY
	, round(avgpay.avg_payroll_yoy::NUMERIC, 2) AS avg_payroll_YoY
	, round((avgp.avg_price_yoy - avgpay.avg_payroll_yoy)::NUMERIC, 2) AS diff
	, CASE 
		WHEN (avgp.avg_price_yoy - avgpay.avg_payroll_yoy) > 10 THEN 1
		ELSE 0
	END AS diff_flag
FROM 
	avg_price_YoY AS avgp
JOIN 
	avg_payroll_YoY AS avgpay
	ON avgp.payroll_year = avgpay.payroll_year
WHERE 
	avg_payroll_yoy IS NOT NULL 
ORDER BY
	diff_flag DESC
	, diff DESC
;

CREATE VIEW v_daniela_bilakova_yoy AS
WITH gdp_yoy AS
	(SELECT
		country
		, "year"
		, gdp 
		, round(((gdp - LAG(gdp) OVER (ORDER BY "year")) / LAG(gdp) OVER (ORDER BY "year") * 100)::NUMERIC, 2) AS gdp_YoY
	FROM t_Daniela_Bilakova_project_SQL_secondary_final
	WHERE
		country LIKE 'Cz%'
		AND "year" BETWEEN 2003 AND 2018
	GROUP BY
		country
		, "year"
		, gdp
	)
SELECT 
	gdp."year"
	, gdp.gdp_yoy
	, vavgp.avg_price_yoy
	, vavgp.avg_payroll_yoy
FROM gdp_yoy AS gdp
LEFT JOIN 
	v_daniela_bilakova_avg_price AS vavgp
	ON gdp."year" = vavgp."year"
WHERE
	gdp.gdp_yoy IS NOT NULL
ORDER BY
	gdp."year" ASC
;

SELECT *
FROM v_daniela_bilakova_yoy
;

WITH gdp_act AS
	(SELECT 
		"year"
		, gdp_yoy
		, avg_price_yoy
		, avg_payroll_yoy
		, CASE 
			WHEN gdp_yoy > 5 AND avg_price_yoy > 5 THEN 1
			WHEN gdp_yoy > 5 AND avg_payroll_yoy > 5 THEN 1
			ELSE 0
		END AS flag_act
	FROM v_daniela_bilakova_yoy	
	ORDER BY
		flag_act DESC 
	),
gdp_prev AS 
	(SELECT 
		"year"
		, gdp_yoy
		, avg_price_yoy
		, avg_payroll_yoy
		, CASE 
			WHEN LAG(gdp_yoy) OVER (ORDER BY "year") > 5 AND avg_price_yoy > 5 THEN 1
			WHEN LAG(gdp_yoy) OVER (ORDER BY "year") > 5 AND avg_payroll_yoy > 5 THEN 1
			ELSE 0
		END AS flag_prev
	FROM v_daniela_bilakova_yoy	
	ORDER BY
		flag_prev DESC  
	)
SELECT 
	act.*
	, prev.flag_prev
FROM 
	gdp_prev AS prev
LEFT JOIN
	gdp_act AS act
	ON act."year" = prev."year"
ORDER BY 
	act."year"
;