--I HAVING
--1)	Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong 
--tháng 6 năm 2008 có tổng tiền >70000,  tin gồm SalesOrderID,
-- Orderdate, SubTotal, trong đó SubTotal =SUM(OrderQty*UnitPrice). 
select h.SalesOrderID, OrderDate, SubTotal=SUM(OrderQty*UnitPrice)
from Sales.SalesOrderHeader h inner join Sales.SalesOrderDetail d
		on h.SalesOrderID = d.SalesOrderID
WHERE month(OrderDate)=6 and year(OrderDate)=2008
group by h.SalesOrderID, OrderDate
having SUM(OrderQty*UnitPrice)>70000
GO

use AdventureWorks2008R2

--2)	Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các 
--quốc gia có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
-- Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). 
-- Thông tin bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
--  (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice) 
select t.TerritoryID, COUNT(c.CustomerID) as CountOfCust,
		SUM(d.OrderQty*d.Unitprice) as SubTotal
FROM Sales.Customer c join Sales.SalesTerritory t on t.TerritoryID = c.TerritoryID
	JOIN Sales.SalesOrderHeader h on c.CustomerID = h.CustomerID
	join Sales.SalesOrderDetail d on h.SalesOrderID = d.SalesOrderID
WHERE t.CountryRegionCode='US'
group by t.TerritoryID

ORDER BY t.TerritoryID
GO


--3)	Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng 
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm 
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice) 
SELECT SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderDetail
where CarrierTrackingNumber like '4BD%'
group by SalesOrderID, CarrierTrackingNumber
GO

--4)	Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và 
--số lượng bán trung bình >5, thông tin gồm ProductID, Name, AverageOfQty. 
select p.ProductID, name, AVG(OrderQty) as AverageOfQty
from Production.Product p inner join Purchasing.PurchaseOrderDetail d
		on p.ProductID = d.ProductID
where UnitPrice <25
group by p.ProductID, name
having AVG(OrderQty)>5
GO

--5)	Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, 
--thông tin gồm JobTitle, CountOfPerson = Count(*) 
SELECT JobTitle, CountOfPerson=Count(*)
from HumanResources.Employee
group by JobTitle
having Count(*)>20
go

--6)	Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp 
--có tên kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal 
select v.BusinessEntityID, Name, ProductID, SumOfQty= sum(OrderQty), SubTotal=SUM(SubTotal)
from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h
	on v.BusinessEntityID=h.VendorID
	join Purchasing.PurchaseOrderDetail d on h.PurchaseOrderID=d.PurchaseOrderID
where Name like '%Bicycles'
group by v.BusinessEntityID, Name, ProductID
having SUM(SubTotal) > 800000
go

--7)	Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong 
--quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và 
--SubTotal 
select p.ProductID, Name,  CountOfOrderID=Sum(OrderQty), SubTotal=SUM(SubTotal)
from Production.Product p join Sales.SalesOrderDetail d 
	on p.ProductID=d.ProductID
	join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where datepart(q,OrderDate)=1 and year(OrderDate)=2008
group by p.ProductID, Name
having Sum(OrderQty) >500 and SUM(SubTotal) > 10000
go

--8)	Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 2008, thông tin gồm 
--mã khách (PersonID) , họ tên (FirstName +'   '+ LastName as FullName), Số hóa đơn (CountOfOrders). 
select p.BusinessEntityID, FirstName +' '+ LastName as FullName, CountOfQty= Count(*)
from Sales.Customer c join Person.Person p on c.CustomerID=p.BusinessEntityID
					join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
where YEAR(OrderDate)>2006 and YEAR(OrderDate)<2009
group by P.BusinessEntityID, FirstName +' '+ LastName
having Count(p.BusinessEntityID)>25
go

--9)	Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng bán trong 
--mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name, CountOfOrderQty, Year. 

select p.ProductID, Name, CountOrderQty=count(*), year(OrderDate) as Year
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
		join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where Name like 'Sport%' or Name like 'Bike%'
group by p.ProductID, Name, year(OrderDate)
having count(*)>500
go

--10)	Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông tin gồm
-- Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung bình (AvgofRate). 
select d.DepartmentID, Name, AvgofRate=AVG(Rate)
from HumanResources.Department d join HumanResources.EmployeeDepartmentHistory ed
		on d.DepartmentID=ed.DepartmentID
		join HumanResources.EmployeePayHistory ep on ed.BusinessEntityID=ep.BusinessEntityID
group by d.DepartmentID, Name
having AVG(Rate)>30
go
