--Module 6 - ROLE - PERMISSION
--Xem tài khoản
EXEC sp_helplogins
EXEC sp_helplogins 'sa'
--1) Đăng nhập vào SQL bằng SQL Server authentication, tài khoản sa. Sử dụng TSQL

--2) Tạo hai login SQL server Authentication User2 và User3
create login User2 with password='user2',
default_database= AdventureWorks2008R2

create login User3 with password='user3',
default_database=AdventureWorks2008R2

--3) Tạo một database user User2 ứng với login User2 và một database user User3
--ứng với login User3 trên CSDL AdventureWorks2008
--use AdventureWorks2008R2 --Phải vào CSDL, tạo User trên CSDL này
--create user User2 for login User2 --tên Login trùng tên User
--create user User3 for login User3

use AdventureWorks2008R2
create user User2 for login User2
create user User3 for login User3
Exec sp_helpuser 'dbo'
Exec sp_helpuser

--4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các
--thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực
--hiện được không?
-- mở 1 new SQLQuery trong kết nối của User2, tạo dòng lệnh:
select * from HumanResources.Employee
--lỗi 
--The SELECT permission was denied on the object 'Employee', 
--			database 'AdventureWorks2008R2', schema 'HumanResources'.

--5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select
--trên Employee cho User2. Ngắt 2 kết nối của User2 và User3
--grant select on HumanResources.Employee to User2

grant select on HumanResources.Employee to User2
--Kiểm tra kết quả trên cửa sổ query của user
--Qua user2 chạy được dòng lệnh select

--Xóa quyền select trên Employee cho User2
--revoke select on HumanResources.Employee from User2
revoke select on HumanResources.Employee from User2
--Kiểm tra kết quả trên cửa sổ query của user
--Qua user2 chạy dòng lệnh select bị lỗi

--6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
--CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
--Employee_Role
create role Employee_Role

--Sau đó gán các quyền cho role
grant select, update, delete on HumanResources.Employee to Employee_Role

--7) Thêm các User2 và User3 vào Employee_Role. 

--EXEC sp_addrolemember 'RoleName','UserName'
--EXEC sp_addrolemember Employee_role,User2
--EXEC sp_addrolemember Employee_role,User3
exec sp_addrolemember Employee_Role,User2
exec sp_addrolemember Employee_Role,User3
--Tạo lại 2 kết nối đến server thông qua login User2 và User3 thực hiện các thao tác sau:
--a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng Employee
select * from HumanResources.Employee

--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
--viên có BusinessEntityID=1
--Xem thông tin trước khi cập nhật
select * from HumanResources.Employee
where BusinessEntityID=1

update HumanResources.Employee
set JobTitle='*** Sale Manager'
where BusinessEntityID=1

--c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
select * from HumanResources.Employee

--d) Xóa role Employee_Role, (quá trình xóa role ra sao?)
drop role Employee_Role

--EXEC sp_droprolemember 'RoleName','UserName'
EXEC sp_droprolemember Employee_Role,User2
--Kiểm tra

EXEC sp_droprolemember Employee_Role,User3
--Kiểm tra

drop role Employee_Role
--Kiểm tra
---------------------------------------------------------------------------------------------


--Module 7: SINGLE TRANSACTION
--1) Thêm vào bảng Department một dòng dữ liệu tùy ý bằng câu lệnh INSERT..VALUES…
select * from HumanResources.Department --16 phòng ban

insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate) --phải có danh sách thuộc tính
values (20,'Customer Care',N'Chăm sóc khách hàng',getdate())
-- Lỗi: Cannot insert explicit value for identity column in table 'Department' when IDENTITY_INSERT is set to OFF.

set identity_insert HumanResources.Department on

insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)
values (20,'Customer Care',N'Chăm sóc khách hàng',getdate())
--Thành công
--a) Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng
--cách thực hiện lệnh Begin tran và Rollback, dùng câu lệnh Select * From
--Department xem kết quả
begin tran T1
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)
values (20,'Customer Care',N'Chăm sóc khách hàng',getdate())
rollback tran T1

--Xem kết quả
select * from HumanResources.Department
go
--> hiểu lệnh rollback --> trở lại trạng thái trước khi thực hiện giao tác

--b) Thực hiện câu lệnh trên với lệnh Commit và kiểm tra kết quả.
begin tran T2
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)
values (20,'Customer Care',N'Chăm sóc khách hàng',getdate())
commit tran T2

--Xem kết quả
select * from HumanResources.Department
go
-- có dòng 20

--2) Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS ON).
set implicit_transactions on

--Tạo đoạn batch gồm các thao tác:
Begin tran
--Thêm một dòng vào bảng Department
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)
values (17,'Investment & Development',N'Đầu tư và phát triển', getdate())
--Tạo một bảng Test (id int, name nvarchar(10))
create table Test (id int primary key,name nvarchar(10))
--Thêm một dòng vào Test
insert into Test values(1,'Test')
rollback
go

--Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết quả.
select * from HumanResources.Department
select * from Test --không có bảng Test

set implicit_transactions off -- trả về autocommit mode (default)
go 
--3) Viết đoạn batch thực hiện các thao tác sau (lưu ý thực hiện lệnh 
--SET XACT_ABORT ON: nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn 
--bộ giao dịch được chấm dứt và Rollback) 
set XACT_ABORT ON --Giao tác gặp lỗi sẽ quay lui
--BATCH
begin tran
--Câu lệnh select với phép chia 0:
select 1/0 as Dummy
--Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này không tồn tại)
UPDATE HumanResources.Department
set Name='New Department'
where DepartmentID =17

-- Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
delete
from HumanResources.Department
where DepartmentID=66
--  Thêm một dòng bất kỳ vào bảng Department 
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--Phải có danh sách thuộc tính
values(18,'Investment &Development',N'Đầu tư và phát triển',getdate())
COMMIT --Divide by zero error encountered.
go
--Kiểm tra 
select * from HumanResources.Department --Không có dòng 18
--4) Thực hiện lệnh SET XACT_ABORT OFF (những câu lệnh lỗi sẽ rollback, transaction vẫn tiếp tục) 
--sau đó thực thi lại các thao tác của đoạn batch ở câu 3. 
set XACT_ABORT OFF --Giao tác gặp lỗi tiếp tục làm các câu lệnh ở phía sau
--BATCH
begin tran
--Câu lệnh select với phép chia 0:
select 1/0 as Dummy
--Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này không tồn tại)
UPDATE HumanResources.Department
set Name='New Department'
where DepartmentID =17

-- Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
delete
from HumanResources.Department
where DepartmentID=66
--  Thêm một dòng bất kỳ vào bảng Department 
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--Phải có danh sách thuộc tính
values(18,'Investment & Development',N'Đầu tư và phát triển',getdate())
COMMIT --Divide by zero error encountered.
go

--Quan sát kết quả và giải thích kết quả? 
select * from HumanResources.Department --Không có dòng 18