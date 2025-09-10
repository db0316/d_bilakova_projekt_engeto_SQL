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

SELECT *
FROM v_daniela_bilakova_avg_price
;