 -- Investigating the data: table
 SELECT * 
	FROM HumanResources.Employee

-- Investigating the data: columns used

SELECT JobTitle, OrganizationLevel, SickLeaveHours
	FROM HumanResources.Employee

-- Investigating the data: checking for null values

SELECT JobTitle, OrganizationLevel, SickLeaveHours
	FROM HumanResources.Employee
WHERE JobTitle IS NULL 
	OR OrganizationLevel IS NULL 
	OR SickLeaveHours IS NULL

	-- No null values:
SELECT JobTitle, ISNULL(OrganizationLevel, 0) as Level, SickLeaveHours
	FROM HumanResources.Employee

-- -- Investigating the data: checking for duplicates

SELECT JobTitle, ISNULL(OrganizationLevel, 0) as Level, SickLeaveHours
	FROM HumanResources.Employee
GROUP BY JobTitle, OrganizationLevel, SickLeaveHours
HAVING COUNT(*) > 1;

	-- No duplicates:
SELECT DISTINCT JobTitle, ISNULL(OrganizationLevel, 0) as Level, SickLeaveHours
	FROM HumanResources.Employee

-- Average sick leave hours per job title:

SELECT DISTINCT JobTitle, AVG(SickLeaveHours) AS avg_slh_pt
	FROM HumanResources.Employee
GROUP BY JobTitle


-- Categorising job titles, grouping by level in the company

SELECT 
    Title_Group,
    AVG(avg_slh_pt) AS AVG_SickLeaveHours, 
    AVG(Level) AS Avg_Level
FROM (
    SELECT 
        CASE 
            WHEN JobTitle LIKE '%Manager%' THEN 'Managers'
            WHEN JobTitle LIKE '%Assistant%' THEN 'Assistants'
            WHEN JobTitle LIKE '%Specialist%' THEN 'Specialists'
            WHEN JobTitle LIKE '%Chief%' AND JobTitle NOT LIKE '%Assistant%' THEN 'Chiefs'
            WHEN JobTitle LIKE '%Vice President%' THEN 'Vice Presidents'
            WHEN JobTitle LIKE '%Supervisor%' THEN 'Supervisors'
            WHEN JobTitle LIKE '%Technician%' THEN 'Technicians'
            WHEN JobTitle LIKE '%Engineer%' THEN 'Engineers'
            WHEN JobTitle LIKE '%Designer%' THEN 'Designers'
            WHEN JobTitle LIKE '%Administrator%' THEN 'Administrators'
            WHEN JobTitle LIKE '%Scheduler%' THEN 'Schedulers'
            WHEN JobTitle LIKE '%Buyer%' THEN 'Buyers'
            WHEN JobTitle LIKE '%Janitor%' THEN 'Janitors'
            WHEN JobTitle LIKE '%Stocker%' THEN 'Stockers'
            ELSE 'Other Titles'
        END AS Title_Group, 
        ISNULL(OrganizationLevel, 0) AS Level,
        AVG(SickLeaveHours) AS avg_slh_pt
    FROM 
        HumanResources.Employee
    GROUP BY 
        JobTitle, 
        OrganizationLevel
) AS subquery
GROUP BY 
    Title_Group
ORDER BY 
    Title_Group;

-- But because of the null value in 'chiefs' group the output for 'Level' shows that AVG Level for 'chiefs' is 0, which is not true. Correction:

SELECT 
    Title_Group,
    AVG(avg_slh_pt) AS AVG_SickLeaveHours, 
    CASE 
        WHEN Title_Group = 'Chiefs' THEN AVG(CASE WHEN Level != 0 THEN Level ELSE NULL END)
        ELSE AVG(Level)
    END AS Avg_Level
FROM (
    SELECT 
        CASE 
            WHEN JobTitle LIKE '%Manager%' THEN 'Managers'
            WHEN JobTitle LIKE '%Assistant%' THEN 'Assistants'
            WHEN JobTitle LIKE '%Specialist%' THEN 'Specialists'
            WHEN JobTitle LIKE '%Chief%' AND JobTitle NOT LIKE '%Assistant%' THEN 'Chiefs'
            WHEN JobTitle LIKE '%Vice President%' THEN 'Vice Presidents'
            WHEN JobTitle LIKE '%Supervisor%' THEN 'Supervisors'
            WHEN JobTitle LIKE '%Technician%' THEN 'Technicians'
            WHEN JobTitle LIKE '%Engineer%' THEN 'Engineers'
            WHEN JobTitle LIKE '%Designer%' THEN 'Designers'
            WHEN JobTitle LIKE '%Administrator%' THEN 'Administrators'
            WHEN JobTitle LIKE '%Scheduler%' THEN 'Schedulers'
            WHEN JobTitle LIKE '%Buyer%' THEN 'Buyers'
            WHEN JobTitle LIKE '%Janitor%' THEN 'Janitors'
            WHEN JobTitle LIKE '%Stocker%' THEN 'Stockers'
			WHEN JobTitle LIKE '%Clerk%' THEN 'Clerks'
			WHEN JobTitle LIKE '%Accountant%' THEN 'Accountants'
			WHEN JobTitle LIKE '%Recruiter%' THEN 'Recruiters'
			WHEN JobTitle LIKE '%Representative%' THEN 'Representatives'
            ELSE 'Other Titles'
        END AS Title_Group, 
        ISNULL(OrganizationLevel, 0) AS Level,
        AVG(SickLeaveHours) AS avg_slh_pt
    FROM 
        HumanResources.Employee
    GROUP BY 
        JobTitle, 
        OrganizationLevel
) AS subquery
GROUP BY 
    Title_Group
ORDER BY 
    AVG_SickLeaveHours DESC;

-- Check thre correlation between job title, rate, avg level and sick leave hours:

SELECT 
    subquery.Title_Group,
    AVG(subquery.avg_slh_pt) AS AVG_SickLeaveHours, 
    CASE 
        WHEN subquery.Title_Group = 'Chiefs' THEN AVG(CASE WHEN subquery.Level != 0 THEN subquery.Level ELSE NULL END)
        ELSE AVG(subquery.Level)
    END AS Avg_Level,
    ROUND(AVG(eph.Rate), 2) AS Avg_Rate
FROM (
    SELECT 
        BusinessEntityID,
        CASE 
            WHEN JobTitle LIKE '%Manager%' THEN 'Managers'
            WHEN JobTitle LIKE '%Assistant%' THEN 'Assistants'
            WHEN JobTitle LIKE '%Specialist%' THEN 'Specialists'
            WHEN JobTitle LIKE '%Chief%' AND JobTitle NOT LIKE '%Assistant%' THEN 'Chiefs'
            WHEN JobTitle LIKE '%Vice President%' THEN 'Vice Presidents'
            WHEN JobTitle LIKE '%Supervisor%' THEN 'Supervisors'
            WHEN JobTitle LIKE '%Technician%' THEN 'Technicians'
            WHEN JobTitle LIKE '%Engineer%' THEN 'Engineers'
            WHEN JobTitle LIKE '%Designer%' THEN 'Designers'
            WHEN JobTitle LIKE '%Administrator%' THEN 'Administrators'
            WHEN JobTitle LIKE '%Scheduler%' THEN 'Schedulers'
            WHEN JobTitle LIKE '%Buyer%' THEN 'Buyers'
            WHEN JobTitle LIKE '%Janitor%' THEN 'Janitors'
            WHEN JobTitle LIKE '%Stocker%' THEN 'Stockers'
            WHEN JobTitle LIKE '%Clerk%' THEN 'Clerks'
            WHEN JobTitle LIKE '%Accountant%' THEN 'Accountants'
            WHEN JobTitle LIKE '%Recruiter%' THEN 'Recruiters'
            WHEN JobTitle LIKE '%Representative%' THEN 'Representatives'
            ELSE 'Other Titles'
        END AS Title_Group, 
        ISNULL(OrganizationLevel, 0) AS Level,
        AVG(SickLeaveHours) AS avg_slh_pt
    FROM 
        HumanResources.Employee
    GROUP BY 
        JobTitle, 
        OrganizationLevel,
        BusinessEntityID
) AS subquery
LEFT JOIN HumanResources.EmployeePayHistory eph 
ON subquery.BusinessEntityID = eph.BusinessEntityID
GROUP BY 
    subquery.Title_Group
ORDER BY 
    AVG_SickLeaveHours DESC, Avg_Rate;