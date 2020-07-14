--Bài tập về nhà tuần 3
--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau: 
create table MyDepartment ( 
DepID smallint not null primary key, DepName nvarchar(50), GrpName nvarchar(50) 
) 
create table MyEmployee ( EmpID int not null primary key, FrstName nvarchar(50), 
MidName nvarchar(50), LstName nvarchar(50), 
DepID smallint not null foreign key references MyDepartment(DepID) 
) 

--2) Dùng 	lệnh 	insert 	<TableName1> 	select 	<fieldList> 	from 
--<TableName2>  chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ bảng [HumanResources].[Department]. 

Insert MyDepartment
select DepartmentID,Name, GroupName
from HumanResources.Department
go

--kiểm tra
select * from MyDepartment
go

--3)	Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu từ 2 bảng 
--[Person].[Person] và [HumanResources].[EmployeeDepartmentHistory] 

Insert MyEmployee
select top 5 P.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from Person.Person p join HumanResources.EmployeeDepartmentHistory h
			on p.BusinessEntityID = h.BusinessEntityID
where DepartmentID=1
go
Insert MyEmployee
select top 5 P.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from Person.Person p join HumanResources.EmployeeDepartmentHistory h
			on p.BusinessEntityID = h.BusinessEntityID
where DepartmentID=3
go
Insert MyEmployee
select top 5 P.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from Person.Person p join HumanResources.EmployeeDepartmentHistory h
			on p.BusinessEntityID = h.BusinessEntityID
where DepartmentID=7
go
Insert MyEmployee
select top 5 P.BusinessEntityID, FirstName, MiddleName, LastName, DepartmentID
from Person.Person p join HumanResources.EmployeeDepartmentHistory h
			on p.BusinessEntityID = h.BusinessEntityID
where DepartmentID=5
go
--kiểm tra
select * from MyEmployee
go

--4)	Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1, có thực hiện được không? Vì sao? 

delete from MyDepartment
where DepID=1
go -- Không xóa được vì vi phạm ràng buộc khóa ngoại với bảng MyEmployee.
	--bảng MyEmployee có dữ liệu

--5)	Thêm một default constraint vào field DepID trong bảng MyEmployee, với giá trị mặc định là 1. 

alter table MyEmployee
add constraint DepID_DF default 1 for DepID
GO
--Kiểm tra
sp_help DepID_DF
GO

--Xem lại số liệu bảng MyEmployee
select * from MyEmployee
go 

--6)	Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau: insert into MyEmployee (EmpID, FrstName, MidName, 
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị trong field depID của record mới thêm. 

insert into MyEmployee (EmpID, FrstName, MidName, 
LstName) values(1, 'Nguyen','Nhat','Nam')
go
-- Kiểm tra
select * from MyEmployee
go --- DepID được thêm mặc định là 1

--7)	Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại 
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on delete set default. 

--Xem tên khóa ngoại
sp_helpconstraint MyEmployee
go -- có khóa ngoại là FK__MyEmploye__DepID__3B95D2F1

--Xóa foreign key constraint trong bảng MyEmployee
alter table MyEmployee
drop constraint FK__MyEmploye__DepID__3B95D2F1
go

--thiết lập lại khóa ngoại ... on delete set default
alter table MyEmployee
add constraint FK_MyEmployee foreign key (DepID) references MyDepartment(DepID)
on delete set default
go

--Ý nghĩa: Dữ liệu trong bảng MyEmployee sẽ trở về mặc định nếu dữ liệu trong bảng MyDepartment 
--         bị xóa hoặc cập nhật.

--8)	Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả trong hai bảng MyEmployee và MyDepartment 

--Dữ liệu có DepID=7 ở hai bảng
select * from MyDepartment where DepID=7
select * from MyEmployee where DepID=7 -- EmpID= 33, 34, 35, 36,37

delete
from MyDepartment
where DepID=7
go

--Kiểm tra
select * from MyDepartment where DepID=7
select * from MyEmployee where EmpID in (33,34,35,36,37)

---On delete set default Các giá trị DepID trong bảng MyEmployee được gán mặc định là 1

--9)	Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa ngoại DepID trong bảng MyEmployee, thiết lập thuộc 
--tính on delete cascade và on update cascade 

--Xóa foreign key constraint trong bảng MyEmployee
alter table MyEmployee
drop constraint FK_MyEmployee
go

--thiết lập lại khóa ngoại ... on delete cascade và on update cascade
alter table MyEmployee
add constraint FK_MyEmployee foreign key (DepID) references MyDepartment(DepID)
on delete cascade
on update cascade
go

--10)	Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có thực hiện được không? 
delete 
from MyDepartment
WHERE DepID=3
go

--Kiểm tra
select * from MyDepartment where DepID=3
select * from MyEmployee where DepID=3

-->on delete cascade: dữ liệu ở bảng con sẽ bị xóa khi dữ liệu ở bảng cha bị xóa

--11)	Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho phép nhận thêm những Department thuộc group Manufacturing
alter table MyDepartment
add constraint ck_MyDept check (GrpName = 'Manufacturing')
go ---> Không được

select * from MyDepartment
go --> Vì trong bảng đã có dử liệu không thuộc group Manufacturing

alter table MyDepartment
with nocheck 
add constraint ck_MyDept check (GrpName = 'Manufacturing')
go -->để nocheck trước add constraint

insert MyDepartment values(17,N'Phòng mới','Quality Assurance')
go --> không được. vì vi phạm ràng buộc check

insert MyDepartment values(17,N'Phòng mới','Manufacturing')
go -->chèn được

select * from MyDepartment
go -->kiểm tra sau khi chèn

--12)	Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột 
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60 

alter table HumanResources.Employee
with nocheck 
add constraint ck_Emp check(((year(getdate()))-(year(BirthDate)))>=18 and 
						((year(getdate()))-(year(BirthDate)))<=60)
go

