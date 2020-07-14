--I) Batch
--1)	Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm có 
--ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có trên 500 đơn 
--hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt hàng” 

--Xem thong tin hoa don
select * from Sales.SalesOrderDetail
go

--Viet batch

declare @tongsoHD int, @maSP int

set @maSP=778
set @tongsoHD = (select count(*)
				from Sales.SalesOrderDetail
				where ProductID = @maSP)

select @maSP as MaSP, @tongsoHD as TongHD

if @tongsoHD>500
	print 'San Pham ' + convert(varchar(4),@maSP)+ ' co tren 500 don hang.'
else
	print 'San Pham ' + convert(varchar(4),@maSP)+ ' co it don hang.'
go

--2)	Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008),   nếu @n>0 thì 
--in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” ngược lại nếu @n=0 
--thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào trong năm 2008” 

select CustomerID from Sales.SalesOrderHeader
go 

declare @maKH int, @n int, @nam int

set @nam = 2008
set @maKH = 14650
set @n = (select  count(*)
			from Sales.SalesOrderHeader
			where CustomerID = @maKH and year(OrderDate) = @nam)

if @n>0
	print 'Khach hang '+convert(varchar(5),@maKH)+' co '+convert(varchar(4),@n)+' hoa don trong nam '+convert(char(4),@nam)
else
	print 'Khach hang '+convert(varchar(5),@maKH)+' khong co hoa don trong nam '+convert(char(4),@nam)
go

--3)	Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng tiền>100000, 
--thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), Discount (tiền giảm), với 
--Discount được tính như sau: 
--•	Những hóa đơn có SubTotal<100000 thì không giảm, 
--•	SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal 
--•	SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal 
--•	SubTotal từ 150000 trở lên thì giảm 15% của SubTotal 
--(Gợi ý: Dùng cấu trúc Case… When …Then …) 

--tim hieu du lieu
select SalesOrderID, SubTotal = Sum(LineTotal)
from Sales.SalesOrderDetail
group by SalesOrderID
having Sum(LineTotal)>100000
go -->co hoa don 43875

--viet batch
declare @salesOrderID int, @subTotal decimal, @discount decimal
set @salesOrderID = '43875'

select @subTotal=Sum(LineTotal)
from Sales.SalesOrderDetail
where SalesOrderID=@salesOrderID

select @discount = 
		case
			when @subTotal < 100000 then 0
			when @subTotal >= 100000 and @subTotal <120000 then 0.05*@subTotal
			when @subTotal between 120000 and 150000 then 0.1*@subTotal
			else 0.15*@subTotal
		end

select @salesOrderID AS SalesOrderID, @subTotal AS SubTotal, @discount as Discount
go

--4)	Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của các 
--field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho các 
--biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ gán  giá  trị  
--tương  ứng  của  field  [OnOrderQty]  cho  biến  @soluongcc,  nếu @soluongcc trả 
--về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung cấp sản phẩm 4”, 
--ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 cung cấp sản phẩm 4 
--với số lượng là 5” 
select BusinessEntityID,ProductID,OnOrderQty
from Purchasing.ProductVendor
go -->Nha cung cap 1688 cung cap san pham 2 voi so luong la 3


declare @mancc int, @masp int, @soluongcc int
set @mancc = 1688
set @masp = 2

set @soluongcc = (select OnOrderQty
					from Purchasing.ProductVendor
					where ProductID = @masp and BusinessEntityID = @mancc)

if @soluongcc is null
	print 'Nha cung cap '+convert(varchar(5),@mancc)+' khong cung cap san pham '+convert(varchar(5),@masp)
else
	print 'Nha cung cap '+convert(varchar(5),@mancc)+' cung cap san pham '+convert(varchar(5),@masp)+' voi so luong la '+convert(varchar(4),@soluongcc)
go

--5)	Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong [HumanResources].[EmployeePayHistory] 
--theo điều kiện sau: Khi tổng lương giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật 
--tăng lương giờ lên 10%, nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng. 
WHILE (SELECT SUM(rate) FROM [HumanResources].[EmployeePayHistory])<6000 
BEGIN 
	UPDATE [HumanResources].[EmployeePayHistory] 
		SET rate = rate*1.1 
	IF (SELECT MAX(rate)FROM [HumanResources].[EmployeePayHistory]) > 150 BREAK 
	ELSE 
		CONTINUE 
END 
GO
--KIEM TRA SUM(RATE)
SELECT SUM(rate) FROM [HumanResources].[EmployeePayHistory]
-----------------------------------------------------------------------------------------------------------------
--Tuan6: Scalar Function

--1)	Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, giá trị 
--truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng ban tương 
--ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng ban với số nhân 
--viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name, countOfEmp với 
--countOfEmp= CountOfEmployees([DepartmentID]). 
create function CountOfEmployees (@mapb smallint)
returns int
as
	begin
		declare @tongNV int
		select @tongNV = count(e.BusinessEntityID)
		from HumanResources.EmployeeDepartmentHistory e join HumanResources.Department d
				on e.DepartmentID=d.DepartmentID
		where e.DepartmentID=@mapb

		return @tongNV
	end
go
 --Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng ban với số nhân 
--viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name, countOfEmp với 
--countOfEmp= CountOfEmployees([DepartmentID])
select distinct e.DepartmentID, Name, dbo.CountOfEmployees(d.DepartmentID) as CountOfEmp
from HumanResources.EmployeeDepartmentHistory e join HumanResources.Department d
		on e.DepartmentID = d.DepartmentID
go

--2)	Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là 
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu vực tương ứng 
--với giá trị của tham số 
create function InventoryProd (@ProductID int, @LocationID smallint)
returns smallint
as
	begin
		return (select Quantity
				from Production.ProductInventory
				where ProductID = @ProductID and LocationID = @LocationID)
	end
go
drop function InventoryProd
--kiem tra 
select ProductID,LocationID,Quantity
from Production.ProductInventory
go --nho ProductID=1, LocationID=1 ==> Quantily=408

select dbo.InventoryProd(1,1) as Quantity
go

--3)	Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của một nhân viên trong một 
--tháng tùy ý trong một năm tùy ý, với tham số vào @EmplID, @MonthOrder, @YearOrder 
create function SubTotalOfEmp (@EmplID INT, @MonthOrder INT, @YearOrder INT)
returns MONEY
as
	begin
		return (select Sum(OrderQty*UnitPrice)
				from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d
							on h.SalesOrderID = d.SalesOrderID
				where SalesPersonID=@EmplID and Month(OrderDate)=@MonthOrder and Year(OrderDate)=@YearOrder )
	end
go

--kiem tra 
select SalesPersonID, year(OrderDate) as year, month(OrderDate) as month, Sum(OrderQty*UnitPrice)as sumofMoney
from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d
				on h.SalesOrderID = d.SalesOrderID
group by SalesPersonID, year(OrderDate), month(OrderDate)
go --nho SalesPersonID=280,YEAR=2006,MONTH=8 ==> SumOfMoney = 232871.1805

select dbo.SubTotalOfEmp(280,8,2006) as SumOfMoney
go