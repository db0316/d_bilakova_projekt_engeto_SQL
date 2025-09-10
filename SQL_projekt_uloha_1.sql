WITH max_avg_wages AS
	(SELECT
		industry
		, max(average_wages) AS max_avg_wages
	FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	GROUP BY
		industry 
	),	
max_date AS 
	(SELECT
		DISTINCT industry
		, max(payroll_year) AS max_date
		, max(payroll_quarter) AS max_quarter
	FROM t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
	GROUP BY
		DISTINCT industry
	)
SELECT 
	DISTINCT dbprimar.industry
	, dbprimar.payroll_year
	, dbprimar.average_wages
	, maw.max_avg_wages
	, CASE 
		WHEN maw.max_avg_wages = dbprimar.average_wages THEN 1 
		WHEN maw.max_avg_wages >  dbprimar.average_wages THEN 0
	END AS flag_check
FROM 
	t_Daniela_Bilakova_project_SQL_primary_final AS dbprimar
JOIN max_avg_wages AS maw
	ON dbprimar.industry = maw.industry
JOIN max_date AS md
	ON dbprimar.industry = md.industry
	AND dbprimar.payroll_year = md.max_date
	AND dbprimar.payroll_quarter = md.max_quarter
ORDER BY
	flag_check ASC
;