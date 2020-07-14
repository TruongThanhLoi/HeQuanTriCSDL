CREATE DATABASE Sales
ON PRIMARY
(
	NAME = 'SalesPrimary',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\Sales.mdf',
	SIZE = 10MB, 
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
)
LOG ON
(
	NAME = 'Sales_log',
	FILENAME = 'F:\HKI-Năm 4\Hệ quản trị CSDL\Sales_log.mdf',
	SIZE = 10MB, 
	FILEGROWTH = 10%,
	MAXSIZE = 20MB
)
GO

--1. Tao cac kieu du lieu
EXEC SP_ADDTYPE Mot, 'nvarchar(40)', NULL
GO
SP_HELP Mota
go

EXEC SP_ADDTYPE IDKH, 'char(10)', 'NOT NULL'
GO
SP_HELP IDKH
go

EXEC SP_ADDTYPE DT, 'char(12)', NULL
GO
SP_HELP DT
go

--2.Tao bang:
CREATE TABLE SanPham 
(
	MaSP char(6) not null,
	TenSP varchar(20),
	NgayNhap date,
	DVT char(10),
	SoLuongTon int,
	DonGiaNhap money
)
GO
CREATE TABLE HoaDon 
(
	MaHD char(10) not null,
	NgayLap date,
	NgayGiao date,
	MaKH IDKH,
	DienGiai Mota
)
GO
CREATE TABLE KhachHang
(
	MaKH IDKH not null,
	TenKH Nvarchar(30),
	Diachi Nvarchar(40),
	DienThoai DT
)
GO
CREATE TABLE ChiTietHD
(
	MaHD char(10) NOT NULL,
	MaSP char(6) NOT NULL,
	Soluong int
)
GO

--3: Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100). 
ALTER TABLE HoaDon 
ALTER COLUMN DienGiai nvarchar(100)
GO

--4.	Thêm vào bảng SanPham cột TyLeHoaHong float 
ALTER TABLE SanPham
ADD TyLeHoaHong float
GO

--5.	Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
DROP COLUMN NgayNhap
GO

ALTER TABLE SanPham
ADD NgayNhap date
GO

--6.	Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
ALTER TABLE  SanPham
ADD CONSTRAINT PK_SP PRIMARY KEY (MaSP)
GO

ALTER TABLE HoaDon
ADD CONSTRAINT PK_HD PRIMARY KEY (MaHD),
	CONSTRAINT FK_HD FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
GO

ALTER TABLE  KhachHang
ADD CONSTRAINT PK_KH PRIMARY KEY (MaKH)
GO

ALTER TABLE ChiTietHD
ADD CONSTRAINT PK_CTHD1 PRIMARY KEY (MaHD,MaSP),
	CONSTRAINT FK_CTHD1 FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
	CONSTRAINT FK_CTHD2 FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
GO	 

--7.	Thêm vào bảng HoaDon các ràng buộc sau: 
ALTER TABLE HoaDon
ADD CONSTRAINT Check1 CHECK (NgayGiao >= NgayLap)
GO


--ALTER TABLE HoaDon
--ADD CONSTRAINT Check2 CHECK (MaHD CHAR(6))
--GO


ALTER TABLE HoaDon
ADD CONSTRAINT default1 DEFAULT getdate() FOR NgayLap
GO

--8.	Thêm vào bảng Sản phẩm các ràng buộc sau: 
ALTER TABLE SanPham
ADD CONSTRAINT check8a CHECK (SoLuongTon between 0 and 500)
GO

ALTER TABLE SanPham
ADD CONSTRAINT check8b CHECK (DonGiaNhap >0)
GO

ALTER TABLE SanPham
ADD CONSTRAINT default8c DEFAULT GETDATE() FOR NgayNhap
GO

ALTER TABLE SanPham
ADD CONSTRAINT check8D CHECK (DVT = 'KQ' OR DVT = 'Thùng' OR DVT = 'Hộp' OR DVT = 'Cái' )
GO

--9.	Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng buộc của mỗi Table 
INSERT INTO SanPham VALUES
('SP01',N'Máy tính',N'KQ',20,10000,5.0,'2019-08-01'),
('SP02',N'Điện thoại',N'Hộp',15,5000,3.0,'2019-08-02'),
('SP03',N'Tai nghe',N'Cái',14,200,8.4,'2019-08-03'),
('SP04',N'Bao da',N'Thùng',3,1000,4.0,'2019-08-04')
GO
DELETE FROM SanPham
go
SELECT*FROM SanPham
GO

INSERT INTO KhachHang VALUES
('KH01',N'Nguyễn Văn A',N'134 Tây Thạnh, p. Tây Thạnh, q. Tân Phú',0362589654),
('KH02',N'Nguyễn Thị B',N'12 Nguyễn Văn Bảo, p.4, q. Gò Vấp',0789654852),
('KH03',N'Nguyễn Thị B',N'46 Trường Sơn, p.2, q. Tân Bình',0937895624)
GO
SELECT*FROM KhachHang
GO

INSERT INTO HoaDon VALUES
('HD0001','2019-08-03','2019-08-13','KH01',NULL),
('HD0002','2019-08-02','2019-08-17','KH02',NULL),
('HD0003','2019-08-06','2019-08-12','KH03',NULL)
GO
SELECT*FROM HoaDon
GO

INSERT INTO ChiTietHD VALUES
('HD0001','SP01',54),
('HD0002','SP02',42),
('HD0003','SP01',45),
('HD0002','SP04',34),
('HD0001','SP03',14),
('HD0003','SP04',65)
GO
SELECT*FROM ChiTietHD
GO

--10.	Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? 
--Tại sao? Nếu vẫn muốn xóa thì phải dùng cách nào? 

DELETE FROM HoaDon
WHERE MaHD = 'HD0003'
GO -->Không xóa được.
	-->Vì bảng hóa đơn có liên kết với bảng ChiTietHD.
	-->Nếu muốn xóa phải:
		--c1: Xóa foreign của bảng ChiTietHD
		--c2: Xóa hóa đơn có mã muốn xóa trong bảng ChiTietHD

DELETE FROM ChiTietHD
WHERE MaHD = 'HD0003'
GO

DELETE FROM HoaDon
WHERE MaHD = 'HD0003'
GO

--11.	Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và MaHD=’1234567890’. 
--Có nhập được không? Tại sao? 
INSERT INTO HoaDon VALUES
('HD999999999','2019-08-03','2019-08-13','KH01',NULL),
('HD1234567890','2019-08-06','2019-08-12','KH03',NULL)
GO -->Không được. vì sai MaHD sai kiểu dử liệu.

--12.	Đổi tên CSDL Sales thành BanHang 
 Sp_ReNameDB Sales, BanHang
 GO

 --13.	Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao chép được không? Tại sao?
 --Muốn sao chép được bạn phải làm gì? Sau khi sao chép, bạn thực hiện Attach CSDL vào lại SQL. 

 --14.	Tạo bản BackUp cho CSDL BanHang
 BACKUP DATABASE BanHang TO DISK = 'F:\HKI-Năm 4\Hệ quản trị CSDL\BanHang.bak'
 GO
 
 --15.	Xóa CSDL BanHang 
 DROP DATABASE BanHang
 GO

 --16.	Phục hồi lại CSDL BanHang. 
 RESTORE DATABASE BanHang FROM DISK = 'F:\HKI-Năm 4\Hệ quản trị CSDL\BanHang.bak'
 GO
