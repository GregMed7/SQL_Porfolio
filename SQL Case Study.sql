-- Business Case Study / Basic to Advanced Questions

-- Find the Max Quantity sold
Select MAX(Quantity) as Max_Quantity
From TR_OrderDetails

-- Unique products in all transactions
Select distinct(ProductID) as Unique_Products, Quantity
From TR_OrderDetails
Where Quantity > 2
Order By Unique_Products asc, Quantity desc

-- Find the Product Category that has Most Products
Select ProductCategory, COUNT(ProductCategory) as total
From TR_Products
Group By ProductCategory
Order By total desc

-- Find the state where most stores are present
Select PropertyState, Count(*) as total_stores
From TR_PropertyInfo
Group By PropertyState
Order By 2 desc

-- Find the top 5 Product Ids that did max sales in terms of quantity
Select Top 5 ProductID, Sum(Quantity) as total_quantity
From TR_OrderDetails
Group By ProductID
Order By 2 desc

-- Find top 5 Property ID's that did Maximum Quantity
Select Top 5 PropertyID, Sum(Quantity) as total_quantity
From TR_OrderDetails
Group By PropertyID
Order By 2 desc

-- Find the Top 5 Product names that did max sales in terms of Quantity & Sales
Select OD.*, P.ProductName, P.ProductCategory, P.Price
From TR_orderdetails as OD
Left Join TR_Products as P on OD.ProductID = P.ProductID

-- Quantity
Select Top 5 P.ProductName, SUM(OD.Quantity) as total_quantity
From TR_orderdetails as OD
Left Join TR_Products as P on OD.ProductID = P.ProductID
Group By P.ProductName
Order By 2 Desc

-- Sales
Select Top 5 P.ProductName, SUM(OD.Quantity * P.Price) as total_sales
From TR_orderdetails as OD
Left Join TR_Products as P on OD.ProductID = P.ProductID
Group By P.ProductName
Order By 2 Desc

-- Find the top 5 Cities that did max sales
Select Top 5 PRI.PropertyCity, SUM(OD.Quantity * P.Price) as total_sales
From TR_orderdetails as OD
Left Join TR_Products as P on OD.ProductID = P.ProductID
Left Join TR_PropertyInfo as PRI on OD.PropertyID = PRI.[Prop ID]
Group By PRI.PropertyCity
Order By 2 Desc

-- Find the top 5 Products in each of the cities (Example: "Arlington")
Select Top 5 PRI.PropertyCity, P.ProductName, SUM(OD.Quantity * P.Price) as total_sales
From TR_orderdetails as OD
Left Join TR_Products as P on OD.ProductID = P.ProductID
Left Join TR_PropertyInfo as PRI on OD.PropertyID = PRI.[Prop ID]
Where PRI.PropertyCity= 'Arlington'
Group By PRI.PropertyCity,P.ProductName
Order By 3 Desc