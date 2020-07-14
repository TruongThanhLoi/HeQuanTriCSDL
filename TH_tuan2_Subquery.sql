--II. Subquery
--1)	Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID 
--có trên 100 đơn đặt hàng trong tháng 7 năm 2008 

--Cach 1:
select ProductID, Name
from Production.Product 
where ProductID in (select ProductID
				from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h 
						on d.SalesOrderID=h.SalesOrderID
				where month(OrderDate)=7 and year(OrderDate)=2008
				group by ProductID
				having count(*)>100)
go
--Cach 2:
select p.ProductID, Name
from Production.Product P
where exists (select ProductID
				from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h 
						on d.SalesOrderID=h.SalesOrderID
				where month(OrderDate)=7 and year(OrderDate)=2008 and p.ProductID=ProductID
				group by ProductID
				having count(*)>100)
go

--2)	Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất trong tháng 7/2008 
select p.ProductID, Name
from Production.Product p join Sales.SalesOrderDetail d
		on p.ProductID = d.ProductID
		join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where month(OrderDate)=7 and year(OrderDate)=2008
group by p.ProductID, Name
having count(*) >= all (select count(*)
						from Production.Product p join Sales.SalesOrderDetail d
							on p.ProductID = d.ProductID
							join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
						where month(OrderDate)=7 and year(OrderDate)=2008
						group by p.ProductID
						)
go

--3)	Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: CustomerID, Name, CountOfOrder 
select sp.BusinessEntityID, LastName, CountOforder=Count(*)
from Sales.Customer c join Person.Person p on c.CustomerID=p.BusinessEntityID
					join Sales.SalesPerson sp on p.BusinessEntityID=sp.BusinessEntityID
					join Sales.SalesOrderHeader h on sp.BusinessEntityID=h.SalesPersonID
group by sp.BusinessEntityID, LastName
having Count(*)>=all(select Count(*)
					from Sales.Customer c join Person.Person p on c.CustomerID=p.BusinessEntityID
											join Sales.SalesPerson sp on p.BusinessEntityID=sp.BusinessEntityID
											join Sales.SalesOrderHeader h on sp.BusinessEntityID=h.SalesPersonID
					group by sp.BusinessEntityID, LastName
					)
go

--4)	Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với tên bắt đầu
-- với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS
--Cach 1: IN
select ProductID, Name
from Production.Product
where ProductID in (select p.ProductID
					from Production.Product p join Production.ProductModel m
							on p.ProductModelID=m.ProductModelID
					where m.Name like 'Long-Sleeve Logo Jersey%'
					)
go
--Cach 2: EXISTS
select p.ProductID, p.Name
from Production.Product p
where exists (select ProductModelID
				from Production.ProductModel
				where Name like 'Long-Sleeve Logo Jersey%' and p.ProductModelID=ProductModelID
				)
go

--5)	Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối đa cao hơn giá
-- trung bình của tất cả các mô hình. 
select m.ProductModelID, m.Name,MAX(ListPrice)as MaxOfListPrice
from Production.Product p join Production.ProductModel m on p.ProductModelID=m.ProductModelID
GROUP BY m.ProductModelID, m.Name
HAVING MAX(ListPrice) > (select avg(ListPrice)
					from Production.Product
					)
go

--6)	Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng đặt hàng > 5000 (dùng IN, EXISTS) 

--Cach 1: IN
select ProductID, Name
from Production.Product 
where ProductID in (select ProductID
				from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h 
						on d.SalesOrderID=h.SalesOrderID
				group by ProductID
				having sum(OrderQty)>5000)
go
--Cach 2: EXISTS
select p.ProductID, Name
from Production.Product P
where exists (select ProductID
				from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h 
						on d.SalesOrderID=h.SalesOrderID
				where p.ProductID=ProductID
				group by ProductID
				having sum(OrderQty)>5000
			)
go

--7)	Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất trong bảng Sales.SalesOrderDetail 
select p.ProductID, UnitPrice
from Sales.SalesOrderDetail d join Production.Product p
	on d.ProductID=p.ProductID
where UnitPrice >=all (select UnitPrice
					from Sales.SalesOrderDetail d join Production.Product p
						on d.ProductID=p.ProductID
					)
go

--8)	+Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, Nam; dùng 3 cách Not in, Not exists và Left join. 
--Cach 1: NOT IN
select ProductID, Name
from Production.Product 
where ProductID not in (select ProductID
						from Sales.SalesOrderDetail
						)
go
--Cach 2: NOT EXISTS
select p.ProductID, Name
from Production.Product P
where not exists (select d.ProductID
				from Sales.SalesOrderDetail d
				where p.ProductID=d.ProductID
				)
go
--CACH 3:LEFT JOIN
select p.ProductID, p.Name
from Production.Product p left join Sales.SalesOrderDetail d
		on p.ProductID=d.ProductID
where d.ProductID is null
go 

--9)	Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm 
--EmployeeID, 	FirstName, 	LastName
--Cach 1
select e.BusinessEntityID, FirstName, LastName
from HumanResources.Employee e join Person.Person p on e.BusinessEntityID=p.BusinessEntityID
where not exists (select SalesPersonID
				from Sales.SalesOrderHeader h 
				where OrderDate > 2008/05/01 and e.BusinessEntityID=h.SalesPersonID
				)
go
--Cach 2
select e.BusinessEntityID, FirstName, LastName
from HumanResources.Employee e join Person.Person p on e.BusinessEntityID=p.BusinessEntityID
								left join Sales.SalesOrderHeader h on e.BusinessEntityID = h.SalesPersonID
where h.SalesPersonID is null
go

--10)	Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng trong năm 2007 
--nhưng không có hóa đơn đặt hàng trong năm 2008. 
select sp.BusinessEntityID, LastName
from Sales.Customer c join Person.Person p on c.CustomerID=p.BusinessEntityID
					join Sales.SalesPerson sp on p.BusinessEntityID=sp.BusinessEntityID
where exists (select h.SalesPersonID
				from Sales.SalesOrderHeader h
				where p.BusinessEntityID=h.SalesPersonID and year(OrderDate)=2007
				)
	and not exists(select h.SalesPersonID
				from Sales.SalesOrderHeader h
				where p.BusinessEntityID=h.SalesPersonID and year(OrderDate)=2008
				)

go