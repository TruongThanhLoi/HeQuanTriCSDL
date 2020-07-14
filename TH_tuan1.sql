--Bai thuc hanh tuan 1

--Cau 2:
CREATE DATABASE SmallWorks
ON PRIMARY
(
	NAME = 'SmallWorksPrimary',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\SmallWorks.mdf',
	SIZE = 10MB, 
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData1
(
	NAME = 'SmallWorksData1',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\SmallWorksData1.ndf',
	SIZE = 10MB, 
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData2
(
	NAME = 'SmallWorksData2',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\SmallWorksData2.ndf',
	SIZE = 10MB, 
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
)
LOG ON
(
	NAME = 'SmallWorks_log',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\SmallWorks_log.ldf',
	SIZE = 10MB, 
	FILEGROWTH = 10%,
	MAXSIZE = 20MB
)
GO

--Cau 3:

--Cau 4: Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add thêm 2 file filedat1.ndf 
--và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1. 
--Dùng SSMS xem kết quả. 

--Tao filegroup Test1FG1
ALTER DATABASE SmallWorks
ADD FILEGROUP Test1FG1
GO

--add file
ALTER DATABASE SmallWorks
ADD FILE
( NAME = 'filedat1',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\filedat1.ndf',
	SIZE = 5MB
) TO FILEGROUP Test1FG1
GO
ALTER DATABASE SmallWorks
ADD FILE
( NAME = 'filedat2',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\filedat2.ndf',
	SIZE = 5MB
) TO FILEGROUP Test1FG1
GO

--Cau 5: Dùng T-SQL tạo thêm một một file thứ cấp filedat3.ndf 
--dung lượng 3MB trong filegroup Test1FG1. Sau đó sửa kích thước 
--tập tin này lên 5MB. Dùng SSMS xem kết quả. Dùng T-SQL xóa file thứ 
--cấp filedat3.ndf. Dùng SSMS xem kết quả 

--Tao file
ALTER DATABASE SmallWorks
ADD FILE
( NAME = 'filedat3',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\filedat3.ndf',
	SIZE = 3MB
) TO FILEGROUP Test1FG1
GO

--Sua kich thuoc
ALTER DATABASE SmallWorks
MODIFY FILE
( NAME = 'filedat3', SIZE = 5MB)
GO

--Xoa file
ALTER DATABASE SmallWorks
REMOVE FILE filedat3
GO

--Cau 6:	Xóa filegroup Test1FG1? Bạn có xóa được không?
--Nếu không giải thích? Muốn xóa được bạn phải làm gì? 
ALTER DATABASE SmallWorks
REMOVE FILEGROUP Test1FG1
GO -->Khong xoa duoc. Vi trong filegroup co chua file
---> De xoa dc, phai xoa het cac file co trong filegroup.
ALTER DATABASE SmallWorks
REMOVE FILE filedat1
GO
ALTER DATABASE SmallWorks
REMOVE FILE filedat1
GO
ALTER DATABASE SmallWorks
REMOVE FILEGROUP Test1FG1
GO

--Cau 7:Quan sát và cho biết các trang thể hiện thông tin gì?. 
sp_helpDb SmallWorks
go
-->Xem thong tin database va cac file co trong database

sp_spaceUsed
go
-->Xem kich thuot database

sp_helpFile
go
-->xem cac file primary va file log cua database

--Cau 8:
-->Thuoc tinh ReadOnly: chuyen mau CSDL sang mau xam
--Dat lai thuoc tinh
ALTER DATABASE SmallWorks
SET Read_Write
GO

--Cau 9:
USE SmallWorks
CREATE TABLE dbo.Person 
( 
PersonID int NOT NULL, 
FirstName varchar(50) NOT NULL, 
MiddleName varchar(50) NULL, 
LastName varchar(50) NOT NULL, 
EmailAddress nvarchar(50) NULL 
) ON SWUserData1 
GO
------------------------ 
CREATE TABLE dbo.Product 
( 
ProductID int NOT NULL, 
ProductName varchar(75) NOT NULL, 
ProductNumber nvarchar(25) NOT NULL, 
StandardCost money NOT NULL, 
ListPrice money NOT NULL 
) ON SWUserData2
GO 

--Cau 10:	Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng Person 
--và bảng Product trong AdventureWorks2008 
INSERT Person(PersonID,FirstName,MiddleName,LastName,EmailAddress)
SELECT p.BusinessEntityID,FirstName,MiddleName,LastName,EmailAddress
FROM AdventureWorks2008R2.Person.Person P 
	join AdventureWorks2008R2.Person.EmailAddress E
	ON P.BusinessEntityID = E.BusinessEntityID			
GO						

INSERT Product(ProductID,ProductName,ProductNumber,StandardCost,ListPrice)
SELECT ProductID,Name,ProductNumber,StandardCost,ListPrice
FROM AdventureWorks2008R2.Production.Product
GO