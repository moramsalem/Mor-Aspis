--Mor Aspis, 2nd project
--1
with tbl1 as
(select 
year(si.invoicedate) as year,
sum(sil.Quantity*sil.UnitPrice) as IncomePerYear,
count(distinct month(si.invoicedate)) as NumberOfDistinctMonths
from sales.InvoiceLines SIL
join sales.Invoices SI
on sil.invoiceID=si.invoiceID
group by year(si.invoicedate)
),
tbl2 as
(select tbl1.*,
IncomePerYear*12/NumberOfDistinctMonths as YearlyLinearIncome,
lag(IncomePerYear*12/NumberOfDistinctMonths,1)over(order by year) as PrevYearlyLinearIncome
from tbl1)
select tbl2.Year, 
        format(tbl2.IncomePerYear,'N2'), 
        tbl2.NumberOfDistinctMonths,
        FORMAT(tbl2.YearlyLinearIncome,'N2') as YearlyLinearIncome,
        FORMAT((YearlyLinearIncome-PrevYearlyLinearIncome)/PrevYearlyLinearIncome *100 ,'N2') as GrowthRate
from tbl2
order by year;

--2
with tbl as
(select 
year(si.invoicedate) as TheYear,
datepart(qq,si.invoicedate) as TheQuarter,
c.CustomerName,
sum(sil.Quantity*sil.UnitPrice) as IncomePerYear,
dense_rank()over(partition by year(si.invoicedate),datepart(qq,si.invoicedate) order by SUM(sil.ExtendedPrice) desc) as DRNK
from sales.InvoiceLines SIL
join sales.Invoices SI
on sil.invoiceID=si.invoiceID
join sales.Customers c
on c.CustomerID=si.CustomerID
group by YEAR(si.invoicedate),
datepart(qq,si.invoicedate),c.CustomerName
)
select tbl.*
from tbl
where drnk<=5
order by theyear,thequarter;

--3
select top 10 with ties sil.StockItemID,
        sil.Description as StockItemName,
        sum(sil.ExtendedPrice-sil.TaxAmount) as TotalProfit
from sales.InvoiceLines SIL
group by sil.StockItemID,sil.Description
order by TotalProfit desc;

--4
select  ROW_NUMBER()over(order by wsi.RecommendedRetailPrice-wsi.UnitPrice desc) as Rn,
        wsi.StockItemID,
        wsi.stockitemname,
        wsi.UnitPrice,
        wsi.RecommendedRetailPrice,
        wsi.RecommendedRetailPrice-wsi.UnitPrice as NominalProductProfit,
        DENSE_RANK()OVER(order by wsi.RecommendedRetailPrice-wsi.UnitPrice desc) as DNR
from Warehouse.StockItems wsi;

--5
select concat(ps.SupplierID,' - ',ps.SupplierName) as SupplierDetails,
        string_agg(concat(wsi.StockItemID,' ',wsi.StockItemName),'/,')
from Purchasing.Suppliers ps
join Warehouse.StockItems wsi
on ps.SupplierID=wsi.SupplierID
group by ps.SupplierID,SupplierName;

--6
select top 5 with ties sc.CustomerID, 
        act.CityName,
        acn.CountryName,
        acn.Continent,
        acn.Region,
        format(sum(sil.ExtendedPrice),'N2') as TotalExtendedPrice
from Sales.Customers sc
join Application.Cities act
on act.CityID=sc.PostalCityID
join Application.StateProvinces asp
on act.StateProvinceID=asp.StateProvinceID
join Application.Countries acn
on acn.CountryID=asp.CountryID
join Sales.Invoices si
on si.CustomerID=sc.CustomerID
join Sales.InvoiceLines sil
on sil.InvoiceID=si.InvoiceID
group by sc.CustomerID, 
        act.CityName,
        acn.CountryName,
        acn.Continent,
        acn.Region
        order by sum(sil.ExtendedPrice) desc;

--7
WITH tbl AS (
    SELECT
        YEAR(si.InvoiceDate)  AS InvoiceYear,
        MONTH(si.InvoiceDate) AS InvoiceMonth,
        SUM(sil.Quantity * sil.UnitPrice) AS MonthlyTotal
    FROM Sales.Invoices si
    JOIN Sales.InvoiceLines sil
        ON si.InvoiceID = sil.InvoiceID
    GROUP BY
        YEAR(si.InvoiceDate),
        MONTH(si.InvoiceDate)
),
tbl2 AS (
    SELECT
        tbl.InvoiceYear,
        CAST(tbl.InvoiceMonth AS varchar(2)) AS InvoiceMonth,
        MonthlyTotal,
        SUM(MonthlyTotal) OVER (
            PARTITION BY InvoiceYear
            ORDER BY tbl.InvoiceMonth
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeTotal,
        tbl.InvoiceYear AS SortYear,
        tbl.InvoiceMonth AS SortMonth
    FROM tbl

    UNION ALL

    SELECT
        InvoiceYear,
        'Grand Total' AS InvoiceMonth,
        SUM(MonthlyTotal) AS MonthlyTotal,
        SUM(MonthlyTotal) AS CumulativeTotal,
        InvoiceYear AS SortYear,
        13 AS SortMonth
    FROM tbl
    GROUP BY InvoiceYear
)
SELECT
    InvoiceYear,
    InvoiceMonth,
    FORMAT(MonthlyTotal, 'N2') AS MonthlyTotal,
    FORMAT(CumulativeTotal, 'N2') AS CumulativeTotal
FROM tbl2
ORDER BY SortYear, SortMonth;

--8
with tbl as
(select year(orderdate) as OrderYear,
         month(orderdate) as OrderMonth,
         OrderID
from Sales.Orders)
select *
from tbl
pivot(
count(orderid)
for orderyear
in ([2013],[2014],[2015],[2016])
)
as pvt
order by OrderMonth;

--9
with tbl1 as
(select sc.CustomerID, 
        sc.CustomerName,
        so.OrderDate,
        lag(so.orderdate,1)over(partition by sc.customerid order by so.orderdate) as PreviousOrderDate
from sales.orders so
join sales.Customers sc
on so.CustomerID=sc.CustomerID),
tbl2 as
(select sc.customerid,
        min(so.orderdate) as FirstOrder,
        max(so.orderdate) as LastOrder,
        datediff(day,min(so.orderdate),max(so.orderdate))/count(orderdate) as AvgDaysBetweenOrders
from sales.orders so
join sales.Customers sc
on so.CustomerID=sc.CustomerID
group by sc.CustomerID)
select tbl1.CustomerID,
        tbl1.CustomerName,
        tbl1.OrderDate,
        tbl1.PreviousOrderDate,
        tbl2.AvgDaysBetweenOrders,
        tbl2.LastOrder as LastCustOrderDate,
        MAX(tbl1.OrderDate) OVER () AS LastOrderDateAll,
        datediff(dd,tbl2.LastOrder,MAX(tbl1.OrderDate) OVER ()) as DaysSinceLastOrder,
        case
        when datediff(dd,tbl2.LastOrder,MAX(tbl1.OrderDate) OVER ())>2*tbl2.AvgDaysBetweenOrders
        then 'Potential Churn'
        ELSE 'Active'
        END As CustomerStatus
        from tbl1
join tbl2
on tbl1.CustomerID=tbl2.CustomerID
order by tbl1.CustomerID ,tbl1.OrderDate;

--10
with tbl1 as
(select 
distinct case
when sc.customername like 'Tailspin%' then 'tail'
when sc.customername like 'Wingtip%' then 'wing'
else sc.customername
end as CustomerIdentify,
scc.CustomerCategoryName
FROM sales.Customers sc
join Sales.CustomerCategories scc
on sc.CustomerCategoryID=scc.CustomerCategoryID
),
tbl2 as
(SELECT CustomerCategoryName,
count (CustomerIdentify) as CustomerCOUNT
FROM tbl1
group by CustomerCategoryName),
tbl3 as
(SELECT tbl1.CustomerCategoryName,
        tbl2.CustomerCOUNT,
count (tbl1.CustomerIdentify) over() as TotalCustCount
FROM tbl1
join tbl2
on tbl1.CustomerCategoryName=tbl2.CustomerCategoryName)
select distinct tbl3.*,
        concat(cast(cast(tbl3.CustomerCOUNT as decimal (5,2))/tbl3.TotalCustCount *100 as decimal (5,2)),'%') as DistributionFactor
from tbl3












select tbl.*,
    sum(tbl.customerid)over() as TotalCustCount
from tbl

select count(*)
from Sales.Customers sc
where sc.customername like 'Tailspin%' or sc.CustomerName like 'Wingtip%'

select count (distinct case
when customername like 'Tailspin%' then 'tail'
when customername like 'Wingtip%' then 'wing'
else customername
end) as TotalCustCount
from sales.Customers


