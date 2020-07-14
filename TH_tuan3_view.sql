--Tuan 3: view

--1)	Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng 
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao 
--gồm ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate 
select p.ProductID, Name, Color, Size, Style, p.StandardCost, EndDate,StartDate
from Production.Product p inner join Production.ProductCostHistory h
						on p.ProductID=h.ProductID
go

-- Thêm phần khai báo view
create view vw_Products
as
	select p.ProductID, Name, Color, Size, Style, p.StandardCost, EndDate,StartDate
	from Production.Product p inner join Production.ProductCostHistory h
							on p.ProductID=h.ProductID
go

--sử dụng
select * from vw_Products
go

--2)	Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 
--đơn đặt hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin 
--gồm ProductID, Product_Name, CountOfOrderID và SubTotal. 

select p.ProductID, Name, CountOfOrderID=Count(*), SubTotal=Sum(LineTotal)
from Production.Product p inner join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
							join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where datepart(q,OrderDate)=1 and year(OrderDate)=2008
group by p.ProductID, Name
having count(*)>500 and Sum(LineTotal)>10000
go
-- Thêm phần khai báo view
create view List_Product_View
as
	select p.ProductID, Name, CountOfOrderID=Count(*), SubTotal=Sum(LineTotal)
	from Production.Product p inner join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
								join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
	where datepart(q,OrderDate)=1 and year(OrderDate)=2008
	group by p.ProductID, Name
	having count(*)>500 and Sum(LineTotal)>10000
go

--sử dụng
select * from List_Product_View
go

--3)	Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) 
--từ cột TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. 
--Thông tin gồm CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue). 

select c.CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) as SumOfTotalDue
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
						join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
group by c.CustomerID, YEAR(OrderDate), MONTH(OrderDate)
go

-- Thêm phần khai báo view
create view vw_CustomerTotals
as
	select c.CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) as SumOfTotalDue
	from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
							join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
	group by c.CustomerID, YEAR(OrderDate), MONTH(OrderDate)
go

--sử dụng
select * from vw_CustomerTotals
go

--4)	Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi 
--nhân viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty 

select SalesPersonID, OrderYear=year(OrderDate), sumOfOrderQty = Sum(OrderQty)
from Sales.SalesPerson p join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
						join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
group by SalesPersonID,year(OrderDate)
go

-- Thêm phần khai báo view
create view Total_Quantity
as
	select SalesPersonID, OrderYear=year(OrderDate), sumOfOrderQty = Sum(OrderQty)
	from Sales.SalesPerson p join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
							join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
	group by SalesPersonID,year(OrderDate)
go

--sử dụng
select * from Total_Quantity
go

--5)	Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 
--đến 2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +'  '+ LastName as FullName), 
--Số hóa đơn (CountOfOrders). 

select p.BusinessEntityID, FirstName +'  '+ LastName as FullName, CountOfOrders=Count(*)
from Person.Person p inner join Sales.Customer c on p.BusinessEntityID=c.CustomerID
						join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
where year(OrderDate)=2007 or year(OrderDate)=2008
group by p.BusinessEntityID, FirstName +'  '+ LastName 
having Count(*)>25
go

-- Thêm phần khai báo view
create view ListCustomer_view
as
	select p.BusinessEntityID, FirstName +'  '+ LastName as FullName, CountOfOrders=Count(*)
	from Person.Person p inner join Sales.Customer c on p.BusinessEntityID=c.CustomerID
							join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
	where year(OrderDate)=2007 or year(OrderDate)=2008
	group by p.BusinessEntityID, FirstName +'  '+ LastName 
	having Count(*)>25
go

--sử dụng
select * from ListCustomer_view
go

--6)	Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với ‘Bike’ và 
--‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông tin gồm ProductID, Name,
-- SumOfOrderQty, Year. 

select p.ProductID, Name, SumOfOrderQty=Sum(OrderQty), Year=Year(OrderDate)
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
						join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where Name like 'Bike%' or Name like 'Sport%'
group by p.ProductID, Name, Year(OrderDate)
having Sum(OrderQty)>50
go

-- Thêm phần khai báo view
create view ListProduct_view
as
	select p.ProductID, Name, SumOfOrderQty=Sum(OrderQty), Year=Year(OrderDate)
	from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
							join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
	where Name like 'Bike%' or Name like 'Sport%'
	group by p.ProductID, Name, Year(OrderDate)
	having Sum(OrderQty)>50
go

--sử dụng
select * from ListProduct_view
go

--7)	Tạo view List_department_View chứa danh sách các phòng ban có lương 
--(Rate: lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). 

select d.DepartmentID, Name, AvgOfRate = avg(Rate)
from HumanResources.Department d join HumanResources.EmployeeDepartmentHistory h
									on d.DepartmentID=h.DepartmentID
								join HumanResources.EmployeePayHistory p
									on h.BusinessEntityID=p.BusinessEntityID
group by  d.DepartmentID, Name
having avg(Rate)>30
go

-- Thêm phần khai báo view
create view List_department_View
as
	select d.DepartmentID, Name, AvgOfRate = avg(Rate)
	from HumanResources.Department d join HumanResources.EmployeeDepartmentHistory h
										on d.DepartmentID=h.DepartmentID
									join HumanResources.EmployeePayHistory p
										on h.BusinessEntityID=p.BusinessEntityID
	group by  d.DepartmentID, Name
	having avg(Rate)>30
go

--sử dụng
select * from List_department_View
go

--8. Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm 
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal (tổng tiền). 
--Sau đó xem thông tin và trợ giúp về mã lệnh của view này 

select OrderYear=year(OrderDate), OrderMonth=Month(OrderDate), OrderTotal=SubTotal
from Sales.SalesOrderHeader
go

--Tạo view
Create view Sales.vw_OrderSummary
WITH ENCRYPTION
as
	select OrderYear=year(OrderDate), OrderMonth=Month(OrderDate), OrderTotal=SubTotal
	from Sales.SalesOrderHeader
go

--Kiểm tra view
select * from Sales.vw_OrderSummary
go

sp_helptext 'Sales.vw_OrderSummary'
go ---- KHÔNG XEM ĐƯỢC VÌ BỊ RÀNG BUỘC 'WITH ENCRYPTION'

--9)	Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING gồm 
--ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng 
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng Product. 
--Có xóa được không? Vì sao? 

--Tạo view
Create view Production.vwProducts
WITH SCHEMABINDING
as
	select p.ProductID, Name, StartDate,EndDate,ListPrice
	from Production.Product p join Production.ProductCostHistory c
						on p.ProductID=c.ProductID
go

--Kiểm tra view
select * from Production.vwProducts
go
--Xem thông tin của view
sp_helptext 'Production.vwProducts'
go

--Xóa cột ListPrice của bảng Product
alter table Production.Product
drop column ListPrice
go --- Không được

--10)	Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các phòng thuộc 
--nhóm có tên (GroupName) là “Manufacturing” và “Quality Assurance”, thông tin gồm: 
--DepartmentID, Name, GroupName. 

Create view view_Department
as
	select DepartmentID, Name, GroupName
	from HumanResources.Department
	where GroupName in ('Manufacturing', 'Quality Assurance')
WITH CHECK OPTION
go
--Kiểm tra view
select * from view_Department
go

--a.	Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm “Manufacturing” và 
--“Quality Assurance” thông qua view vừa tạo. Có chèn được không? Giải thích. 

insert view_Department(Name, GroupName)
values ('New Dept', 'Inventory Management')
go ---- Không chèn được vì vi phạm ràng buộc WITH CHECK OPTION. GroupName không phải 
	---				 “Manufacturing” hoặc “Quality Assurance”

--b.	Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một phòng thuộc nhóm “Quality Assurance”. 

insert view_Department(Name, GroupName)
values 
('New Dept', 'Manufacturing'),
('New Dept1', 'Quality Assurance')
go

--c.	Dùng câu lệnh Select xem kết quả trong bảng Department. 

select DepartmentID, Name, GroupName
from HumanResources.Department
go