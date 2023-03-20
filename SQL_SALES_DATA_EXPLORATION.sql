--Inspecting Data
Select *
From sales_data_sample

--Checking Unique Values
Select distinct STATUS from sales_data_sample  --Great for plotting
Select distinct YEAR_ID from sales_data_sample
Select distinct PRODUCTLINE from sales_data_sample  --Great for plotting
Select distinct Country from sales_data_sample   -- Great for plotting
Select distinct DEALSIZE from sales_data_sample  --Great for plotting
Select distinct TERRITORY from sales_data_sample  -- Great for plotting

-- Analysis

-- Grouping sales by product line
Select PRODUCTLINE, sum(sales) as Revenue
From sales_data_sample
Group By PRODUCTLINE
Order by 2 desc


Select YEAR_ID, sum(sales) as Revenue
From sales_data_sample
Group By YEAR_ID
Order by 2 desc

-- 2005 Total Revenue was low, checking if they operated the full year
Select distinct MONTH_ID 
from sales_data_sample
Where YEAR_ID = '2005'

Select distinct MONTH_ID 
from sales_data_sample
Where YEAR_ID = '2003'

Select DEALSIZE, sum(sales) as Revenue
From sales_data_sample
Group By DEALSIZE
Order by 2 desc

--Best month of Sale for a specific year and how much was earned?
Select MONTH_ID, sum(SALES) as Revune, count(ORDERNUMBER) as MONTHLY_ORDERS
From sales_data_sample
Where YEAR_ID = '2003'  --Change year to see 04 & 05
Group BY MONTH_ID
Order By 2 Desc

-- Later months in the year seem to bring in more revenue but in particular November. So what Product is responsible for this upstring of revnue?
Select MONTH_ID, PRODUCTLINE, sum(SALES) as Revune, count(ORDERNUMBER) as ORDER_FREQUENCY
From sales_data_sample
Where YEAR_ID = '2003' AND MONTH_ID = '11' --Change year to see 04 & 05
Group BY MONTH_ID, PRODUCTLINE
Order By 3 Desc

-- Who is the best customer?? *USING RECENCY/FREQUENCY/MONETARY VALUE  (RFM)
DROP TABLE IF EXISTS #rfm
;with rfm as
(
	Select 
		CUSTOMERNAME, 
		SUM(SALES) AS MONETARY_VALUE, 
		AVG(SALES) AS AVG_MONETARY_VALUE, 
		COUNT(ORDERNUMBER) AS FREQUENCY, 
		MAX(ORDERDATE) AS LAST_ORDER_DATE,
		(Select MAX(ORDERDATE) From sales_data_sample) AS MAX_ORDER_DATE,
		DATEDIFF(DD,MAX(ORDERDATE),(Select MAX(ORDERDATE) From sales_data_sample)) AS RECENCY
	From sales_data_sample
	GROUP BY CUSTOMERNAME
),
rfm_calc AS
(
	select *,
		NTILE(4) OVER (Order By RECENCY DESC) AS RFM_RECENCY,
		NTILE(4) OVER (Order By FREQUENCY) AS RFM_FREQUENCY,
		NTILE(4) OVER (Order By MONETARY_VALUE) AS RFM_MONETARY
	From rfm
)
Select *, RFM_RECENCY + RFM_FREQUENCY + RFM_MONETARY as RFM_CELL, CAST(RFM_RECENCY as VARCHAR) + CAST(RFM_FREQUENCY as VARCHAR) + CAST(RFM_MONETARY as VARCHAR) as RFM_CELL_STRING
INTO #RFM
From rfm_calc


-- How to cateogrize your customers so we know which customers to target for any specific marketing campaigns
Select CUSTOMERNAME, RFM_RECENCY, RFM_FREQUENCY, RFM_MONETARY,
	Case
		WHEN RFM_CELL_STRING in (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost Customers'    -- Lost Customers
		WHEN RFM_CELL_STRING in (133, 134, 143, 144, 244, 334, 343, 344) THEN 'Slipping Away/Cannot Lose'   --Big Spenders who havent purchased lately
		WHEN RFM_CELL_STRING in (311, 411, 331) THEN 'New Customers'
		WHEN RFM_CELL_STRING in (222, 223, 233, 322) THEN 'Potential Bigger Clients'
		WHEN RFM_CELL_STRING in (323, 333, 321, 422, 332, 432) THEN 'Active' -- Customers who buy off often and recently but low price points
		WHEN RFM_CELL_STRING in (433, 434, 443, 444) THEN 'Loyal'
	end as RFM_SEGMENT
From #RFM


-- What products are most often sold together?

--Select * From sales_data_sample Where ORDERNUMBER = 10411

Select DISTINCT ORDERNUMBER, STUFF(

	(Select ',' + PRODUCTCODE
	From sales_data_sample as D
	Where ORDERNUMBER in
		(
			Select ORDERNUMBER
			From (
				Select ORDERNUMBER, Count(*) as RN
				From sales_data_sample
				Where Status = 'Shipped'
				Group By ORDERNUMBER
			) as x
			Where rn = 2    -- You can switch with 3 etc.
		)
		and D.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))
		, 1, 1, '')  as PRODUCT_CODES  -- Starting position, chart to extract, '' replace with nothing for STUFF function to convert the results from xml to a string
From sales_data_sample as s
Order By 2 DESC   