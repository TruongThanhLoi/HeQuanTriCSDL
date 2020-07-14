--1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong 
--thư mục T:\backup\adv2008back.bak
exec sp_addumpdevice 'disk','adv2008back','G:\backup\adv2008back.bak'
--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, 
--rồi thực hiện full backup vào thiết bị backup vừa tạo
alter database AdventureWorks2008R2
set recovery full

backup database AdventureWorks2008R2
to disk='G:\backup\adv2008back.bak'
with description='AdventureWorks2008R2 FULL backup'
go

--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất 
--cả mặt hàng xe đạp trong bảng Product  xuống $15 nếu tổng trị giá 
--các mặt hàng xe đạp không thấp hơn 60%.
use AdventureWorks2008R2

select * from Production.ProductCategory
where Name='Bikes'

select * from Production.ProductSubCategory
where ProductCategoryID=1

select ProductID,Name,ListPrice
from Production.Product
where ProductSubCategoryID in (select ProductSubCategoryID
								from Production.ProductSubCategory
								where ProductCategoryID=1)
								--749 --> 3578.27

begin tran
declare @tongXeDap money, @tong money
set @tong=(select Sum(ListPrice) from Production.Product)
set @tongXeDap=(select Sum(ListPrice)
				from Production.Product
				where ProductSubcategoryID in (select ProductSubcategoryID
												from Production.ProductSubcategory
												where ProductCategoryID=1))
if @tongXeDap/@tong >0.6
	begin
		update Production.Product
		set ListPrice=ListPrice-15
		where ProductSubCategoryID in (select ProductSubCategoryID
									from Production.ProductSubCategory
									where ProductCategoryID=1)
		commit tran
	end
else
	rollback tran
go

--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup 
--đều lưu vào thiết bị backup vừa tạo 
--a. Tạo 1 differential backup  
backup database AdventureWorks2008R2
to disk = 'G:\backup\adv2008back.bak'
with differential,description='AdventureWorks2008R2 DIFFERENTIAL backup lan 1'
go
--b. Tạo 1 transaction log backup
backup log AdventureWorks2008R2
to disk='G:\backup\adv2008back.bak'
with description='AdventureWorks2008R2 LOG backup lan 1'
go
--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
-- Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
select * from Person.EmailAddress -- 19972 dòng

delete from Person.EmailAddress

backup log AdventureWorks2008R2
to disk='G:\backup\adv2008back.bak'
with description='AdventureWorks2008R2 LOG backup lan 2'
go
--6. Thực hiện lệnh: a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business 
--là 10000 như sau: INSERT  INTO Person.PersonPhone VALUES (10000,'123-4567890',1,GETDATE())
select * from Person.PersonPhone where BusinessEntityID>9999

insert into Person.PersonPhone values (10000,'123-456-7890',1,getdate())

--- --b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị backup vừa tạo. 
backup database AdventureWorks2008R2
to disk = 'G:\backup\adv2008back.bak'
with differential, description='AdventureWorks2008R2 Differential backup lan 2'
go
--c. Chú ý giờ hệ thống của máy.  Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem 
drop table Sales.ShoppingCartItem

select * from Sales.ShoppingCartItem
--7. Xóa CSDL AdventureWorks2008 
use master
drop database AdventureWorks2008R2

--8. Để khôi phục lại CSDL: 
--Kiểm tra File=x , để biết restore từ file nào
restore headeronly
from disk = 'G:\backup\adv2008back.bak'
--a. restore ve truoc cau 3
restore database AdventureWorks2008R2
from disk='G:\backup\adv2008back.bak'
with file=1,recovery
go
--Kiem tra:
use AdventureWorks2008R2
select ProductID,Name,ListPrice
from Production.Product
where ProductSubCategoryID in (select ProductSubCategoryID
								from Production.ProductSubCategory
								where ProductCategoryID=1)

--b restore ve truoc cau 5
use master
drop database AdventureWorks2008R2

restore database AdventureWorks2008R2
from disk='G:\backup\adv2008back.bak'
with file=1,norecovery
go

restore database AdventureWorks2008R2
from disk='G:\backup\adv2008back.bak'
with file=2,norecovery
go

restore log AdventureWorks2008R2
from disk='G:\backup\adv2008back.bak'
with file=3,recovery
go
--Kiem tra
use AdventureWorks2008R2
select ProductID,Name,ListPrice
from Production.Product
where ProductSubCategoryID in (select ProductSubCategoryID
								from Production.ProductSubCategory
								where ProductCategoryID=1)

select * from Person.EmailAddress

--c.. backup toan bo
use master
drop database AdventureWorks2008R2
go

restore database AdventureWorks2008R2
from disk ='G:\backup\adv2008back.bak'
with file=1, norecovery
go
restore database AdventureWorks2008R2
from disk ='G:\backup\adv2008back.bak'
with file=5, recovery
go

--Kiem tra
use AdventureWorks2008R2
select * from Sales.ShoppingCartItem

