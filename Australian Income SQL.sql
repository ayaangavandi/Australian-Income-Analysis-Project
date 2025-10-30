Create DATABASE Australian_Income_Analysis;

Use Australian_Income_Analysis;

Select * From income_data;

--Updating state code column name

EXEC sp_rename 'income_data.state_code','State_Code','COLUMN';

--Checking state_names are all unique

Select Distinct State_Name
From income_data;

--Deleting unwanted Data from Age_Range

Delete From income_data
Where Age_Range in ('Total');

Select Age_Range from income_data
Group by Age_Range;

--Deleting unwanted Data from Sex

Delete From income_data
Where Sex in ('Both');

Select Sex From income_data
Group by Sex;

--Removing plurals and capitalisation from sex

Update income_data
Set Sex = Case
	When Sex = 'Males' Then 'Male'
	When Sex = 'Females' Then 'Female'
	Else 'Both'
End

SELECT *
FROM income_data;

--Analysing Data

--Comparing avg median and avg mean income by sex

Select Sex,ROUND(AVG(Median_Income),0) AS Median_Income, ROUND(AVG(Mean_Income),0) AS Mean_Income
From income_data
Group By Sex;

--Comparing avg median and avg mean income by sex by year

Select Sex,Year_Ending, ROUND(AVG(Median_Income),0) AS Median_Income, ROUND(AVG(Mean_Income),0) AS Mean_Income
From income_data
Group By Sex, Year_Ending
Order By Sex, Year_Ending;

--Comparing avg median and avg mean income by age_range

Select Age_Range, ROUND(AVG(Median_Income),0) AS Median_Income, ROUND(AVG(Mean_Income),0) AS Mean_Income
From income_data
Group By Age_Range
Order By Age_Range;

--Viewing percentage salary increase
--Formula: Percentage increase → (current - previous) / previous * 100

DELETE FROM income_data
WHERE Median_Income IS NULL;


Select
	Sex,
	Year_Ending,
	Median_Income,
	ROUND(Median_Income - LAG(Median_Income) Over (PARTITION BY Sex Order By Year_Ending),2) As Salary_Increase,
	ROUND(((Median_Income - LAG(Median_Income) Over (PARTITION BY Sex Order By Year_Ending)) / 
		LAG(Median_Income) Over (PARTITION BY Sex Order By Year_Ending)) * 100, 2) As Percentage_Increase
From
	
(SELECT 
	Sex, 
    Year_Ending, 
	ROUND(AVG(Median_Income), 2) AS Median_Income
FROM income_data
GROUP BY Sex, Year_Ending) AS Summary_income
ORDER BY Sex, Year_Ending;
--NULL in 2018 means no previous year exists, which is logically accurate.

--Calculate absolute difference between mean and median income

Select ROUND(ABS(AVG(Median_Income) - AVG(Mean_Income)),2) As Mean_Median_Diff
From income_data;

--Top 10 highest median incomes by sex, age range, and state

Select Sex,
		Age_range,
		State_Name,
		ROUND(AVG(Median_Income),0) AS Median_Income_AVG
		FROM income_data
GROUP BY Sex, State_Name, Age_Range
Order BY Median_Income_AVG DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--In MSMS we cant use LIMIT so we used OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY Query

--Top 10 lowest median incomes by sex, age range, and state

Select Sex,
		Age_range,
		State_Name,
		ROUND(AVG(Median_Income),0) AS Median_Income_AVG
		FROM income_data
GROUP BY Sex, State_Name, Age_Range
Order BY Median_Income_AVG
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Top 10 No of Earners by sex, age range, and state

Select Sex,
		Age_range,
		State_Name,
		Sum(Number_of_Earners) AS Earners
		FROM income_data
GROUP BY Sex, State_Name, Age_Range
Order BY Earners DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Top 10 MAX Median Income By State, Number of Earners

Select State_Name,
		Max(Median_Income) As Max_Income,
		Sum(Number_of_Earners) As Total_Earners
		From income_data
GROUP BY State_Name
ORDER BY Max_Income
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 