use AdventureWorks2008R2
go

--Tuần 7: Module 5 TRIGGER
--Câu 1:1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau: 
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau: 
create table M_Department 
( 
	DepartmentID int not null primary key, 
	Name nvarchar(50), 
	GroupName nvarchar(50) 
) 

create table M_Employees 
( 
	EmployeeID int not null primary key, 
	Firstname nvarchar(50), 
	MiddleName nvarchar(50), 
	LastName nvarchar(50), 
	DepartmentID int foreign key references M_Department(DepartmentID) 
) 
go

-- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID, FirstName, 
--MiddleName, LastName, DepartmentID, Name, GroupName, dựa trên 2 bảng M_Employees 
--và M_Department.
Create view EmpDepart_View
as
select e.EmployeeID,e.Firstname,e.MiddleName,e.LastName, e.DepartmentID,Name,GroupName
from M_Department d inner join M_Employees e
	on d.DepartmentID = e.DepartmentID
go

-- Tạo một trigger tên InsteadOf_Trigger thực hiện trên view EmpDepart_View, dùng 
--để chèn dữ liệu vào các bảng M_Employees và M_Department khi chèn một record mới 
--thông qua view EmpDepart_View. 
create trigger InsteadOf_Trigger on EmpDepart_view
instead of insert
as
begin
	if exists (select * from inserted)
		begin
			raiserror(N'Chèn dữ liệu vào 2 bảng',11,1)
			insert M_Department
			select DepartmentID,Name,GroupName
			from inserted

			insert M_Employees
			select EmployeeID, Firstname,MiddleName,LastName,DepartmentID
			from inserted
		end
	else
		raiserror(N'Không có dữ liệu trong inserted',11,2)
end

--Kiểm tra trigger
insert EmpDepart_View values(1, 'Nguyen','Hoang','Huy',11,'Marketing','Sales')
insert EmpDepart_View values(2, 'Le','Hong','Huyen',12,'Finance','Sales')

select * from M_Department
select * from M_Employees
select * from EmpDepart_View
go

--2. Tạo một trigger thực hiện trên bảng MySalesOrders có chức năng thiết lập 
--độ ưu tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác 
--Insert, Update và Delete trên bảng MySalesOrders
 create table MCustomers 
 ( 
	 CustomerID int not null primary key, 
	 CustPriority int 
 )
 create table MSalesOrders 
 ( 
	 SalesOrderID int not null primary key, 
	 OrderDate date, 
	 SubTotal money, 
	 CustomerID int foreign key references MCustomers(CustomerID) 
 ) 

 -- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,nhưng 
 --chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho giá trị null
 insert MCustomers
	select CustomerID,null
	from Sales.Customer
	where CustomerID >30100 and CustomerID<30118

--Kiểm tra
select * from MCustomers

-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng Sales.SalesOrderHeader, 
--chỉ lấy những hóa đơn của khách hàng có trong bảng khách hàng. 
insert MSalesOrders
	select SalesOrderID,OrderDate,SubTotal,CustomerID
	from Sales.SalesOrderHeader
	where CustomerID in (select CustomerID from MCustomers)

--Kiểm tra
select * from MSalesOrders
go

--Viết Trigger:
-- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ 
--	thì độ ưu tiên của khách hàng (CustPriority) là 3 
-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $ 
--	thì độ ưu tiên của khách hàng (CustPriority) là 2 
-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên 
--	thì độ ưu tiên của khách hàng (CustPriority) là 1 
create trigger After_Trigger on MSalesOrders
after insert, update,delete
as
begin
	declare @maKH int, @tong money

	if exists (select * from inserted)
	begin
		-- 2 cách xuất thông báo: dùng print hay raiserror
		print (N'Đang chạy trigger')
		raiserror(N'Có Chèn/Cập nhật dữ liệu',11,3)

		--Dùng biến để giử lại giá trị trong bảng inserted
		select @maKH=CustomerID, @tong=Sum(SubTotal)
		from inserted
		group by CustomerID

		update MCustomers
		set CustPriority=
		case 
			when @tong<10000 then 3
			when @tong>=10000 and @tong<50000 then 2
			else 1
		end
		where CustomerID=@maKH
	end

	--trường hợp xóa dữ liệu
	if exists (select * from deleted) and not exists (select * from inserted)
		begin
			raiserror(N'Có Xóa dữ liệu',11,4)
			select @maKH=CustomerID-- giữ lại @maKH bị xóa
			from deleted

			update MCustomers
			set CustPriority = null
			where CustomerID=@maKH
		end
end
go

--Tìm hiểu phạm vi dữ liệu
select CustomerID, SalesOrderID,Sum(SubTotal) as SumOfSubTotal
from MSalesOrders
group by CustomerID, SalesOrderID
order by SumOfSubTotal desc

---Trước khi chạy trigger
select * from MSalesOrders --chưa có dòng SalesOrderID=1000
select * from MCustomers --để ý CustPriority = null

--Chạy trigger bằng Insert
insert MSalesOrders values(10000,getdate(),60000,30101) ---ưu tiên 1
insert MSalesOrders values(10001,getdate()+1,5000,30102) ---ưu tiên 3

select * from MCustomers --Kiểm tra độ ưu tiên
select * from MSalesOrders

--Chạy trigger bằng update
update MSalesOrders
set SubTotal=40000 --ưu tiên 2
where SalesOrderID=10000 --CustomerID=30101

select * from MCustomers
select * from MSalesOrders

----Chạy trigger bằng Delete
delete from MSalesOrders
where SalesOrderID=10001 

select * from MCustomers
select * from MSalesOrders

--3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực hiện 
--chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập nhật số nhân 
--viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng số nhân viên của phòng 
--tương ứng <=200 thì cho phép chèn thêm, ngược lại thì hiển thị thông báo “Bộ phận đã 
--đủ nhân viên” và hủy giao tác. Các bước thực hiện: 
-- Tạo mới 2 bảng MEmployees và MDepartment 

create table MDepartment 
( 
	DepartmentID int not null primary key, 
	Name nvarchar(50), 
	NumOfEmployee int 
) 
create table MEmployees 
( 
	EmployeeID int not null, 
	FirstName nvarchar(50), 
	MiddleName nvarchar(50), 
	LastName nvarchar(50), 
	DepartmentID int not null foreign key references MDepartment(DepartmentID), 
	constraint pk_emp_depart primary key(EmployeeID, DepartmentID) 
) 

-- Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, 
--cột NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng EmployeeDepartmentHistory 
insert MDepartment 
select DepartmentID,Name,null
from HumanResources.Department
--drop table MDepartment
--Kiểm tra
select * from MDepartment
 
insert MEmployees
select e.BusinessEntityID,FirstName,MiddleName,LastName,DepartmentID
from HumanResources.EmployeeDepartmentHistory  e join Person.Person p
	on e.BusinessEntityID=p.BusinessEntityID
--Kiểm tra
select * from MEmployees

-- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger 
create trigger AddEmp_trigger on MEmployees  --drop trigger AddEmp_trigger
after insert
as
begin
	declare @departmentID int,@numOfEmployee int

	if exists (select * from inserted)
	begin
		-- 2 cách xuất thông báo: dùng print 
		print (N'Đang chạy trigger')
		--Dùng biến để giử lại giá trị trong bảng inserted
		select @departmentID=DepartmentID from inserted
		select @numOfEmployee=NumOfEmployee from MDepartment where DepartmentID=@departmentID
		
		if(@numOfEmployee>200 )
			begin
				print N'Bộ phận đã đủ nhân viên'
				RollBack Tran
			end
		else 
			begin
				if(@numOfEmployee is null)
					begin
						update MDepartment
						set NumOfEmployee=1
						where DepartmentID=@departmentID
					end
				else 
					begin
						update MDepartment
						set NumOfEmployee=NumOfEmployee+1
						where DepartmentID=@departmentID
					end
			end
	end
end
go
		
--trước khi chạy trigger
select * from MDepartment --DepartmentID=1 --> NumOfEmployee = null
select * from MEmployees where DepartmentID=1 --Không có EmployeeID=1, 7
--update cho DepartmentID=1 có NumOfEmployee = 200
update MDepartment
set NumOfEmployee=200
where DepartmentID=1
--Chạy trigger
insert MEmployees values
(1,N'Trương',N'Thành',N'Lội',1) --- Thêm thành công
insert MEmployees values
(7,N'Trương',N'Thành',N'Lội',1)-- Kh6ng thêm được.. Bộ phận đã đủ nhân viên

select * from MDepartment 
select * from MEmployees where DepartmentID=1

--delete from MEmployees where EmployeeID=7 and DepartmentID=1

--Câu 4:Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng 
--[Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị 
--thông báo không cho phép chèn và đồng thời hủy giao tác. 

create trigger add_PurchaseOrderHeader on Purchasing.PurchaseOrderHeader
after insert
as
begin
	declare @vendorID int, @creditRating tinyint

	if exists (select * from inserted)
	begin
		select @vendorID = VendorID from inserted
		select @creditRating = CreditRating
		from Purchasing.Vendor
		where BusinessEntityID=@vendorID

		if(@creditRating=5)
			begin 
				print N'Không cho phép chèn!'
				RollBack Tran
			end
	end
end
go

--Kiểm tra dữ liệu
select CreditRating from Purchasing.Vendor where BusinessEntityID=1652 --Có CreditRating =5
select CreditRating from Purchasing.Vendor where BusinessEntityID=1650 --Có CreditRating =1
select * from Purchasing.PurchaseOrderHeader
--Chạy trigger
INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status, EmployeeID, VendorID, 
ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight) 
VALUES  
( 2  ,3,  261,  1652,  4  ,GETDATE()  ,GETDATE()  ,    44594.55 ,3567.564,1114.8638 )
	---- Không chèn được

INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status, EmployeeID, VendorID, ShipMethodID, 
OrderDate, ShipDate, SubTotal, TaxAmt, Freight) 
VALUES  
( 2  ,3,  261,  1650,  4  ,GETDATE()  ,GETDATE()  ,    44594.55 ,3567.564,1114.8638 )
	--Chèn được
--Kiểm tra
select * from Purchasing.PurchaseOrderHeader

--Câu 5:5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng sản 
--phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với số   lượng   
--xác   định   trong  field OrderQty, nếu số lượng trong kho Quantity> OrderQty thì cập nhật 
--lại số  lượng  trong  kho Quantity= Quantity- OrderQty, ngược lại nếu Quantity=0 thì xuất 
--thông báo “Kho hết hàng” và đồng thời hủy giao tác. 

--Viết trigger với LocationID =1
create trigger add_SalesOrder ON Sales.SalesOrderDetail
after insert
as
begin
	declare @orderQty smallint,@quantity smallint

	if exists (select * from inserted)
	select @orderQty=OrderQty from inserted
	select @quantity=Quantity 
	from Production.ProductInventory p join inserted i 
		on p.ProductID=i.ProductID
	where LocationID=1

	if(@quantity=0)
		begin
			print N'Kho hết hàng'
			RollBack Tran
		end
	else if (@quantity-@orderQty<=0)
		begin
			print N'Kho Không đủ hàng'
			RollBack Tran
		end
	else
		begin
			update Production.ProductInventory
			set Quantity =	Quantity-@orderQty
			from Production.ProductInventory p join inserted i 
				on p.ProductID=i.ProductID
			where LocationID=1
		end
end
go
--drop trigger add_SalesOrder
--Xem dữ liệu
select *
from Production.ProductInventory 
where LocationID=1 and productID=807
 --- productID=807 --> Quantity=291
 select * from Sales.SalesOrderDetail
 where productID!=807 -->SalesOrderID=43659
 --Kiểm tra trigger
 insert into Sales.SalesOrderDetail (SalesOrderID,OrderQty,ProductID,SpecialOfferID,UnitPrice,
 UnitPriceDiscount,rowguid,ModifiedDate)
 values 
 (43659,1,807,1,2024.994,0,'B307C96D-D9E6-402B-8470-2CC176C42283','2005-07-01')
	 --Thành Công
	 --Kiểm tra:
	 select *
		from Production.ProductInventory 
		where LocationID=1 and productID=807
		-->Quantity=290

insert into Sales.SalesOrderDetail (SalesOrderID,OrderQty,ProductID,SpecialOfferID,UnitPrice,
UnitPriceDiscount,rowguid,ModifiedDate)
 values 
 (43660,290,807,1,2024.994,0,'B407C96D-D9E6-402B-8470-2CC176C42283','2005-07-01')
 --Không thành công: Kho Không đủ hàng

--Câu 6:6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, 
--khi người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định như sau:
-- Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng SalesOrderHeader có giá 
-- trị >10000000 thì tăng tiền thưởng lên 10% của mức thưởng hiện tại. Cách thực hiện: 
--  Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader 
create table M_SalesPerson 
( 
	SalePSID int not null primary key, 
	TerritoryID int, 
	BonusPS money 
) 
create table M_SalesOrderHeader 
( 
	SalesOrdID int not null primary key, 
	OrderDate date, 
	SubTotalOrd money, 
	SalePSID int foreign key references M_SalesPerson(SalePSID) 
) 

-- Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn những field 
--tương ứng với 2 bảng mới tạo. 
insert M_SalesPerson 
select BusinessEntityID,TerritoryID,Bonus
from Sales.SalesPerson
--Kiểm tra
select * from M_SalesPerson
--
insert M_SalesOrderHeader
select SalesOrderID,OrderDate,SubTotal,SalesPersonID
from Sales.SalesOrderHeader
--Kiểm tra
select * from M_SalesOrderHeader

-- Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger thực thi 
--thì dữ liệu trong bảng M_SalesPerson được cập nhật. 
create trigger add_SalesOrderHeader on M_SalesOrderHeader
after insert
as
begin
	declare @subTotal money,@salePSID int

	if exists (select * from inserted)
	begin 
		select @subTotal = SubTotalOrd from inserted
		select @salePSID = SalePSID from inserted

		if(@subTotal>10000000)
			begin 
				update M_SalesPerson
				set BonusPS = BonusPS*1.1
				where SalePSID =@salePSID
			end
	end
end
go

--Xem dữ liệu
select * from M_SalesPerson -->SalePSID =275, BonusPS= 4100
select * from M_SalesOrderHeader
-- Chạy trigger
insert M_SalesOrderHeader values
(80000,'2005-07-01',10000000,275)
--delete from M_SalesOrderHeader where SalesOrdID =80000
--Kiểm tra

select * from M_SalesPerson where SalePSID=275 -- Bonus không đổi
select * from M_SalesOrderHeader

-- Chạy trigger
insert M_SalesOrderHeader values
(80001,'2005-07-01',10000001,275)
--Kiểm tra

select * from M_SalesPerson where SalePSID=275 -- Bonus đổi: 4100+410=4510
select * from M_SalesOrderHeader