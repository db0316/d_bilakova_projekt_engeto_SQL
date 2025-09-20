CREATE VIEW v_daniela_bilakova_avg_payroll_yoy AS
WITH avg_payroll_YoY AS
	(SELECT 
		industry 
		, payroll_year
		, round(avg(average_wages)::NUMERIC, 2) AS avg_payroll
		, ((avg(average_wages) - LAG(avg(average_wages)) OVER 
			(PARTITION BY industry 
			ORDER BY payroll_year, industry))
			) AS avg_payroll_YoY
	FROM t_Daniela_Bilakova_project_SQL_primary_final
	GROUP BY
		payroll_year
		, industry
	)
SELECT *
	, CASE 
		WHEN avg_payroll_YoY < 0 THEN 1
		ELSE 0
	END AS diff_flag
FROM 
	avg_payroll_YoY AS avgpay
ORDER BY
	diff_flag DESC
;
SELECT industry
FROM v_daniela_bilakova_avg_payroll_yoy
GROUP BY industry
HAVING sum(diff_flag) = 0
;