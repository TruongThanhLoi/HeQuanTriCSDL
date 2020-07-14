--Tuan6
--4)	Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các hóa đơn 
--(SalesOrderID) lập trong tháng và năm được truyền vào từ    2 tham số @thang và 
--@nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate, SubTotal, trong đ
--ó SubTotal =sum(OrderQty*UnitPrice). 

select h.SalesOrderID, OrderDate, SubTotal = Sum(OrderQty*UnitPrice)
from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d
	on h.SalesOrderID=d.SalesOrderID
--where datepart(mm,OrderDate)=@thang and datepart(yy,OrderDate)=@nam
group by h.SalesOrderID, OrderDate
--having Sum(OrderQty*UnitPrice)>70000
go

--Giai
create function SumOfOrder(@thang int,@nam int)
returns table 
as
return 
	(select h.SalesOrderID, OrderDate, SubTotal = Sum(OrderQty*UnitPrice)
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d
		on h.SalesOrderID=d.SalesOrderID
	where datepart(mm,OrderDate)=@thang and datepart(yy,OrderDate)=@nam
	group by h.SalesOrderID, OrderDate
	having Sum(OrderQty*UnitPrice)>70000
	)
go

--goi ham
select * from SumOfOrder(8,2005)
go

--5)	Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng mức 
--thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm [SalesPersonID], 
--NewBonus (thưởng mới), SumOfSubTotal. 

select p.BusinessEntityID, NewBonus=Bonus+Sum(SubTotal)*0.01, SumOfSubTotal=Sum(SubTotal)
from Sales.SalesOrderHeader h join Sales.SalesPerson p
	on h.SalesPersonID=p.BusinessEntityID
group by p.BusinessEntityID,Bonus
go
--Viet ham
create function NewBonus()
returns table 
as
return 
	(select p.BusinessEntityID, NewBonus= Bonus+Sum(SubTotal)*0.01, SumOfSubTotal=Sum(SubTotal)
	from Sales.SalesOrderHeader h join Sales.SalesPerson p
		on h.SalesPersonID=p.BusinessEntityID
	group by p.BusinessEntityID,Bonus
	)
go
--goi ham
select * from NewBonus()
go

--6)	Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID), hàm 
--dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) của các 
--sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm ProductID, 
--SumOfProduct, SumOfSubTotal 

select ProductID, SumOfProduct=Sum(OrderQty),SumOfSubTotal=Sum(SubTotal)
from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID=h.VendorID
								join Purchasing.PurchaseOrderDetail d on h.PurchaseOrderID=d.PurchaseOrderID
--where h.VendorID=@MaNCC
group by ProductID

--viet ham
create function SumOfProduct(@MaNCC int)
returns table
as
return
	(select ProductID, SumOfProduct=Sum(OrderQty),SumOfSubTotal=Sum(SubTotal)
	from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID=h.VendorID
								join Purchasing.PurchaseOrderDetail d on h.PurchaseOrderID=d.PurchaseOrderID
	where h.VendorID=@MaNCC
	group by ProductID
	)
go

--goi ham
select * from SumOfProduct(1686)
GO

--7)	Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn (SalesOrderID),
-- thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
-- như sau: 
--Nếu [SubTotal]<1000 thì Discount=0  
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal] 
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]  Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal] 

select SalesOrderID, SubTotal, Discount= case
				when SubTotal<1000 then 0
				when SubTotal>=1000 and SubTotal<5000 then SubTotal*0.05
				when SubTotal>=5000 and SubTotal<10000 then SubTotal*0.1
				else SubTotal*0.15
				end
from Sales.SalesOrderHeader
go
--viet ham
create function Discount_Func()
returns table
as 
return (select SalesOrderID, SubTotal, Discount= case
				when SubTotal<1000 then 0
				when SubTotal>=1000 and SubTotal<5000 then SubTotal*0.05
				when SubTotal>=5000 and SubTotal<10000 then SubTotal*0.1
				else SubTotal*0.15
				end
		from Sales.SalesOrderHeader
		)
go
--Goi ham
select * from Discount_Func()
go

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng doanh thu 
--của các nhân viên bán hàng (SalePerson) trong tháng và năm được truyền vào 2 tham số, 
--thông tin gồm [SalesPersonID], Total, với Total=Sum([SubTotal]) 
select SalesPersonID, Total=Sum(SubTotal)
from Sales.SalesOrderHeader
--where datepart(mm,OrderDate)=@MonthOrder and datepart(yy,OrderDate)=@YearOrder
group by SalesPersonID
go
--viet ham
create function TotalOfEmp(@MonthOrder int, @YearOrder int)
returns table
as 
return
	(select SalesPersonID, Total=Sum(SubTotal)
	from Sales.SalesOrderHeader
	where datepart(mm,OrderDate)=@MonthOrder and datepart(yy,OrderDate)=@YearOrder
	group by SalesPersonID
	)
go
--Goi ham
select * from TotalOfEmp(8,2005)
go

-- Multi-statement Table Valued Functions: 
--9)	Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function 

---------------------Bai 5_Multi
create function NewBonus_Multi()
returns @bang table(BusinessEntityID int, NewBonus money, SumOfSubTotal money)
as
begin
	insert @bang 
	select p.BusinessEntityID, NewBonus= Bonus+Sum(SubTotal)*0.01, SumOfSubTotal=Sum(SubTotal)
	from Sales.SalesOrderHeader h join Sales.SalesPerson p
		on h.SalesPersonID=p.BusinessEntityID
	group by p.BusinessEntityID,Bonus
	return 
end
go
--goi ham
select * from NewBonus_Multi()
go
-----------------------Bai 6_Multi
create function SumOfProduct_Multi(@MaNCC int)
returns @bang table(ProductID int, SumOfProduct int,SumOfSubTotal money)
as
begin
	insert @bang 
	select ProductID, SumOfProduct=Sum(OrderQty),SumOfSubTotal=Sum(SubTotal)
	from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID=h.VendorID
								join Purchasing.PurchaseOrderDetail d on h.PurchaseOrderID=d.PurchaseOrderID
	where h.VendorID=@MaNCC
	group by ProductID
	return 
end
go
--goi ham
select * from SumOfProduct_Multi(1686)
GO

----------------------------Bai 7_Multi
create function Discount_Func_Multi()
returns @bang table(SalesOrderID int, SubTotal money, Discount money)
as
begin
	insert @bang 
	select SalesOrderID, SubTotal, Discount= case
				when SubTotal<1000 then 0
				when SubTotal>=1000 and SubTotal<5000 then SubTotal*0.05
				when SubTotal>=5000 and SubTotal<10000 then SubTotal*0.1
				else SubTotal*0.15
				end
	from Sales.SalesOrderHeader
	return 
end
go
--goi ham
select * from Discount_Func_Multi()
GO

----------------------------Bai 8_Multi
create function TotalOfEmp_Multi(@MonthOrder int, @YearOrder int)
returns @bang table(SalesPersonID int, Total money)
as
begin
	insert @bang 
	select SalesPersonID, Total=Sum(SubTotal)
	from Sales.SalesOrderHeader
	where datepart(mm,OrderDate)=@MonthOrder and datepart(yy,OrderDate)=@YearOrder
	group by SalesPersonID
	return 
end
go
--goi ham
select * from TotalOfEmp_Multi(8,2005)
GO

--10)	Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân 
--viên, với tham số vào là @MaNV (giá trị của [BusinessEntityID]), 
--thông tin gồm BusinessEntityID, FName, LName, Salary (giá trị của cột Rate). 
--	Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết quả là bảng lương của nhân viên đó.
--	Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân viên

create function SalaryOfEmp(@MaNV int)
returns @bang table(BusinessEntityID int, FName nvarchar, LName nvarchar, Salary money)
as
begin
	if (@MaNV is NULL)
		begin
			insert @bang
			select p.BusinessEntityID, FName=FirstName, LName=LastName, Salary=Rate 
			from Person.Person p join HumanResources.EmployeePayHistory h
				on p.BusinessEntityID= h.BusinessEntityID
		end
	else
		begin
			insert @bang
			select p.BusinessEntityID, FName=FirstName, LName=LastName, Salary=Rate 
			from Person.Person p join HumanResources.EmployeePayHistory h
				on p.BusinessEntityID= h.BusinessEntityID
			where p.BusinessEntityID=@MaNV
		end
	return
end 
go

drop function SalaryOfEmp
GO
--goi ham
select * from SalaryOfEmp(288)
go

select * from SalaryOfEmp(Null)
go