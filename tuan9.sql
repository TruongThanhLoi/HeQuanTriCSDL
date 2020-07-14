----II. 	CONCURRENT TRANSACTIONS (Các giao tác đồng thời) 
 
----1) Tạo bảng Accounts 
create table Accounts (acctID int NOT NULL PRIMARY KEY, balance int NOT NULL, 
CONSTRAINT unloanable_account CHECK (balance >= 0))
go 

INSERT INTO Accounts (acctID,balance) VALUES (101,1000) 
INSERT INTO Accounts (acctID,balance) VALUES (202,2000) 

--Kiểm tra
select * from Accounts
go

----2) SET TRANSACTION ISOLATION LEVEL 
----SET TRANSACTION ISOLATION LEVEL 
----{ READ UNCOMMITTED 
----| READ COMMITTED 
----| REPEATABLE READ 
----| SNAPSHOT 
----| SERIALIZABLE 
----}[ ; ] 
----	READ UNCOMMITTED: có thể đọc những dòng đang được hiệu chỉnh bởi các transaction khác nhưng chưa commit 
----	READ COMMITTED: không thể đọc những dòng đang hiệu chỉnh bởi những transaction khác mà chưa commit 
-------------------------------------
----3) Mở 2 cửa sổ Query của SQL server, thiết lập SET TRANSACTION ISOLATION LEVEL READ COMMITTED ở cả 2 cửa sổ (tạm gọi là client A bên trái, và client B bên phải) 
--Client A: chính cửa sổ này
set transaction isolation level read committed
--Kiểm tra
DBCC useroptions

begin transaction
---- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101 
 select * from Accounts where acctID=101
----	B2: Client A cập nhật account trên AccountID  =101, balance =1000-200 
 update Accounts
 set balance=1000-200
 where acctID=101
 waitfor delay '00:00:15'

----	B3: Client B cập nhật account trên AccountID  =101, balance =1000-500 
 
----	B4: Client A: SELECT trên Accounts với AccountID  =101; COMMIT; 
 select * from Accounts
 where acctID=101
 commit transaction
----	B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT;  
----Quan sát kết quả hiển thị và giải thích. 

------------------------------------------
--Client B: copy đoạn sau qua cửa sổ query khác
set transaction isolation level read committed
--Kiểm tra
DBCC useroptions

begin transaction
---- B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101 
 select * from Accounts where acctID=101
----	B2: Client A cập nhật account trên AccountID  =101, balance =1000-200 


----	B3: Client B cập nhật account trên AccountID  =101, balance =1000-500 
  update Accounts
 set balance=1000-500
 where acctID=101
 waitfor delay '00:00:15'
----	B4: Client A: SELECT trên Accounts với AccountID  =101; COMMIT; 
----	B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT;  
 select * from Accounts
 where acctID=101
 commit transaction
----Quan sát kết quả hiển thị và giải thích. 

--Câu 4
--Trả acctID=101 về trị ban đầu ở câu 1
update Accounts
set balance=1000
where acctID=101

select * from Accounts

--Client A: chính cửa sổ này
set transaction isolation level repeatable read
--Kiểm tra
DBCC useroptions

begin transaction
--	B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với  AccountID =101 
 select * from Accounts
 where acctID=101
--	B2: Client A cập nhật accounts trên AccountID  =101, balance =1000-200 
 update Accounts
 set balance = 1000-200 --800
 where acctID=101
 waitfor delay '00:00:15'
--	B3: Client B cập nhật accounts trên AccountID  =101, balance =1000-500. 
 
--	B4: Client A: SELECT trên Accounts với AccountID  =101; COMMIT; 
 select * from Accounts
 where acctID=101
 commit transaction
--Quan sát kết quả hiển thị và giải thích. 
------------------------------------------------------------
--Client B: copy đoạn này sang một query khác
set transaction isolation level repeatable read
--Kiểm tra
DBCC useroptions

begin transaction
--	B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với  AccountID =101 
 select * from Accounts
 where acctID=101
--	B2: Client A cập nhật accounts trên AccountID  =101, balance =1000-200 

--	B3: Client B cập nhật accounts trên AccountID  =101, balance =1000-500. 
  update Accounts
 set balance = 1000-500 
 where acctID=101
 waitfor delay '00:00:15'
--	B4: Client A: SELECT trên Accounts với AccountID  =101; COMMIT; 
 
 commit transaction
--Quan sát kết quả hiển thị và giải thích. 
go

-----------------------------------------------------
--Module 8. Bảo trì cơ sở dữ liệu 
--T:\backup\adv2008back.bak
EXEC sp_addumpdevice 'disk','adv2008back','G:\backup\adv2008back.bak'
--Kiểm tra  : \Server Object\Backup Devices

--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là 
--full, rồi thực hiện full backup vào thiết bị backup vừa tạo 
alter database AdventureWorks2008
set recovery full

backup database AdventureWorks2008R2
--to adv2008back
to disk = 'G:\backup\adv2008back.bak'
with description = 'AdventureWorks2008R2 FULL Backup'
go

--3. Mở CSDL AdventureWorks2008, 
use AdventureWorks2008R2

--Tìm hiểu csdl
select * from Production.ProductCategory
where Name='Bikes'

--có mấy loại xe đạp
select * from Production.ProductSubcategory
where ProductCategoryID=1 --3 loại

--lọc các mặt hàng là xe đạp
select ProductID,Name,ListPrice
from Production.Product
where ProductSubcategoryID in(select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1)
								--prpductID=749,ListPrice =3578,27
 
  --tạo một transaction giảm giá tất cả mặt hàng xe đạp trong bảng Product 
  -- xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp hơn 60%. 
begin tran
declare @TongXeDap money,@Tong money
set @TongXeDap=(select Sum(ListPrice) from Production.Product
where ProductSubcategoryID in(select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1))
set @Tong=(select Sum(ListPrice) from Production.Product)

if @TongXeDap/@Tong>0.6
	begin 
		update Production.Product
		set ListPrice=ListPrice-15
		where ProductSubcategoryID in (select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1)
		commit tran
	end
else
	rollback tran
go

---Xem lại
select ProductID,Name,ListPrice
from Production.Product
where ProductSubcategoryID in(select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1)
								--prpductID=749,ListPrice =3563,27, đã giảm 15 

--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu 
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup  
backup database AdventureWorks2008R2
to adv2008back --tên thiết bị backup
--to disk='G:\backup\adv2008back.bak
with differential, description='AdventureWorks2008R2 Differential Backup Lan 1'
go
--b. Tạo 1 transaction log backup 
backup log AdventureWorks2008R2 
TO adv2008back
--to disk='G:\backup\adv2008back.bak
with description='AdventureWorks2008R2 Transaction log Backup lan 1'
go

--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
select * from Person.EmailAddress --19972 dòng
--Xóa mọi bản ghi trong bảng Person.EmailAddress,
delete
from Person.EmailAddress

 --tạo 1 transaction log backup
backup log AdventureWorks2008R2
to adv2008back
--to disk='G:\backup\adv2008back.bak
with description = 'AdventureWorks2008R2 Transaction log Backup lan 2'
go

--6. Thực hiện lệnh: a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business 
--là 10000 như sau: INSERT  INTO Person.PersonPhone VALUES (10000,'123-4567890',1,GETDATE())
select * from Person.PersonPhone where BusinessEntityID>9999

insert into Person.PersonPhone values (10000,'123-456-7890',1,getdate())

--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị backup vừa tạo. 
backup database AdventureWorks2008R2
to adv2008back --tên thiết bị backup
--to disk='G:\backup\adv2008back.bak
with differential, description='AdventureWorks2008R2 Differential Backup Lan 2'
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
from disk='G:\backup\adv2008back.bak'

--backup type=1: database
--backup type=2"transaction log
--backup type=5: differential database

--a. Như lúc ban đầu (trước câu 3) thì phải restore thế  nào? 
restore database AdventureWorks2008R2
from adv2008back -- tên thiết bị
--from disk='G:\backup\adv2008back.bak'
with file=1,recovery
go

--Kiểm tra ListPrice của xe đạp
use AdventureWorks2008R2
select ProductID,Name,ListPrice
from Production.Product
where ProductSubcategoryID in(select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1)
								--prpductID=749,ListPrice =3578,27 --y như cũ


--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn 
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào? 

use master
drop database AdventureWorks2008R2
 
restore database AdventureWorks2008R2
from adv2008back -- tên thiết bị
--from disk='G:\backup\adv2008back.bak'
with file=2,norecovery
go

restore database AdventureWorks2008R2
from adv2008back
with file=3,norecovery
go

restore log AdventureWorks2008R2
from adv2008back
with file=4,recovery
go

--có khôi phục đạt yêu cầu
use AdventureWorks2008R2
--Kiểm tra giá xe đạp sau khi giảm
use AdventureWorks2008R2
select ProductID,Name,ListPrice
from Production.Product
where ProductSubcategoryID in(select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID=1)
								--prpductID=749,ListPrice =3563,27--Đúng
--bảng person.EmailAddress chưa bị xóa
select * from Person.EmailAddress --19972 dòng

--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc 
--restore lại CSDL AdventureWorks2008  ra sao? 
use master
drop database AdventureWorks2008R2
 
restore database AdventureWorks2008R2
from adv2008back -- tên thiết bị
--from disk='G:\backup\adv2008back.bak'
with file=2,norecovery
go

restore database AdventureWorks2008R2
from adv2008back
with file=6,recovery
go


--có khôi phục đạt yêu cầu
use AdventureWorks2008R2
--Gía trị dòng 10000?
select * from Person.PersonPhone
where BusinessEntityID=10000
--Bảng ShoppingCartItem chưa bị xóa
select * from Sales.ShoppingCartItem