--Module 6: Role-Permission
--Xem tài khoản
exec sp_helplogins
exec sp_helplogins 'sa'

--2) Tạo hai login SQL server Authentication User2 và User3 
create login User2 with password='user2',
default_database=AdventureWorks2008R2

create login User3 with password='user3',
default_database=AdventureWorks2008R2
--3) Tạo một database user User2 ứng với login User2 và một database user  
--User3 ứng với login User3 trên CSDL AdventureWorks2008.
use AdventureWorks2008R2
create user User2 for login User2
create user User3 for login User3 
exec sp_helpuser 'dbo'
exec sp_helpuser
--4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện 
--các thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). 
--Có thực hiện được không? 


--5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select
--trên Employee cho User2. Ngắt 2 kết nối của User2 và User3
--grant select on HumanResources.Employee to User2
grant select on HumanResources.Employee to User2
-- qua query kia kiểm tra
revoke select on HumanResources.Employee from User2
--6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
--CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
--Employee_Role
create role Employee_Role

grant select,delete,update on HumanResources.Employee to Employee_Role
--7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông qua 
--login User2 và User3 thực hiện các thao tác sau: 
--a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng Employee 
--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân viên có BusinessEntityID=1 
--c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả. 
--d) Xóa role Employee_Role, (quá trình xóa role  ra sao?) 
exec sp_addrolemember Employee_Role,User2
exec sp_droprolemember Employee_Role,User2
drop role Employee_Role