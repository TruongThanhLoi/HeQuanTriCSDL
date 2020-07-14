-- --Tuan 5
--II) Stored Procedure: 
--1)	Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một tháng 
--bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, thông tin gồm: 
--CustomerID, SumOfTotalDue =Sum(TotalDue) 

create proc Cau1_TT @thang int, @nam int
as
	begin
		select c.CustomerID,SumOfTotalDue=Sum(TotalDue) 
		from Sales.Customer c join Sales.SalesOrderHeader h
								on c.CustomerID=h.CustomerID
		where month(OrderDate)=@thang and year(OrderDate)=@nam
		group by c.CustomerID
	end
go

--Tìm hiểu dử liệu
select c.CustomerID,OrderDate,SumOfTotalDue=Sum(TotalDue) 
from Sales.Customer c join Sales.SalesOrderHeader h
					on c.CustomerID=h.CustomerID
group by c.CustomerID,OrderDate
	--Nhớ tháng 2 năm 2006
	--		tháng 7 năm 2007

-- Thực thi
exec Cau1_TT 7,2007
go
exec Cau1_TT 2,2006
go


--2)	Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của một nhân 
--viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số  
--     @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.   
Create proc Cau2_TT @salesPerson int,@salesYTD money out -- hay output
as
	select @salesYTD=SalesYTD
	from Sales.SalesPerson
	where BusinessEntityID=@salesPerson
go

--tìm số liệu
select *
from Sales.SalesPerson --Nhớ BusinessEntityID=275 (SalesPersonID)

--Gọi thủ tục bằng Batch
declare @doanhThuNam money
exec Cau2_TT 276,@doanhThuNam out
select @doanhThuNam as [Doanh thu nam]
go

--3)	Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có giá bán 
--không vượt quá một giá trị chỉ định (tham số input @MaxPrice).  

--ListPrice=Selling price
Create proc Cau3_TT @MaxPrice money
as
	select ProductID,ListPrice
	from Production.Product
	where ListPrice<=@MaxPrice
go

--Thực thi
exec Cau3_TT 700
go

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới bằng mức thưởng 
--hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm  
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:  
--SumOfSubTotal =sum(SubTotal)  
--NewBonus = Bonus+ sum(SubTotal)*0.01  
create proc NewBonus @maNV int
as
	select s.BusinessEntityID,NewBonus= Bonus+Sum(SubTotal),SumOfSubTotal=Sum(SubTotal)
	from Sales.SalesPerson s join Sales.SalesOrderHeader h
						on s.BusinessEntityID=h.SalesPersonID
	where s.BusinessEntityID=@maNV
	group by s.BusinessEntityID,Bonus
go
 --Tìm hiểu dữ liệu
select s.BusinessEntityID,Bonus,SumOfSubTotal=Sum(SubTotal)
from Sales.SalesPerson s join Sales.SalesOrderHeader h
						on s.BusinessEntityID=h.SalesPersonID
group by s.BusinessEntityID,Bonus
		--	Nhớ nv:284, bonus:3900

---Chạy thủ tục
exec NewBonus 284
go

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) có tổng số 
--lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số input), thông tin gồm: 
--ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng  
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail. 
--(Lưu ý: dùng Sub Query)  
create proc View_Category @nam int
as
	select c.ProductCategoryID,c.Name,SumOfQty=Sum(OrderQty)
	from Production.ProductCategory c join Production.ProductSubcategory s on c.ProductCategoryID=s.ProductCategoryID
										join Production.Product p on s.ProductSubcategoryID=p.ProductSubcategoryID
										join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
										join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
	where year(OrderDate)=@nam
	group by c.ProductCategoryID,c.Name
	having Sum(OrderQty)>=all(select Sum(OrderQty)
							from Production.ProductCategory c join Production.ProductSubcategory s on c.ProductCategoryID=s.ProductCategoryID
																join Production.Product p on s.ProductSubcategoryID=p.ProductSubcategoryID
																join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
																join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
							where year(OrderDate)=@nam
							group by c.ProductCategoryID,c.Name
							)
go 
--Tìm hiểu dừ liệu
select nam=year(OrderDate)
from Sales.SalesOrderHeader
		--Nhớ ProductCategoryID=4,nam=2005
select c.ProductCategoryID,c.Name,SumOfQty=Sum(OrderQty)
	from Production.ProductCategory c join Production.ProductSubcategory s on c.ProductCategoryID=s.ProductCategoryID
										join Production.Product p on s.ProductSubcategoryID=p.ProductSubcategoryID
										join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
										join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
	where year(OrderDate)=2005
	group by c.ProductCategoryID,c.Name
	having Sum(OrderQty)>=all(select Sum(OrderQty)
							from Production.ProductCategory c join Production.ProductSubcategory s on c.ProductCategoryID=s.ProductCategoryID
																join Production.Product p on s.ProductSubcategoryID=p.ProductSubcategoryID
																join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
																join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
							where year(OrderDate)=2005
							group by c.ProductCategoryID,c.Name
							)
			--Nhớ ProductCategoryID=1, sum=7139

--Chạy thủ tục
exec View_Category 2005
go


--6)	Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra là 
--tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả về trạng thái 
--thành công hay thất bại của thủ tục. 
create proc TongThu @maNV int,@TongTG money out
as
	begin
		set @TongTG=
			(select Sum(TotalDue)
			from Sales.SalesPerson s join Sales.SalesOrderHeader h
									on s.BusinessEntityID=h.SalesPersonID
			where BusinessEntityID=@maNV
			group by BusinessEntityID
			)
		if @TongTG = 0 return 0
		else return 1
	end
go

--Tìm hiểu dử liệu
select BusinessEntityID,Sum(TotalDue) as SumOfTotalDue
from Sales.SalesPerson s join Sales.SalesOrderHeader h
						on s.BusinessEntityID=h.SalesPersonID
group by BusinessEntityID
order by BusinessEntityID

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo năm đã cho
create proc Proc_Cau7 @nam int
as
	select s.Name, SumOfMoney=Sum(UnitPrice*OrderQty),SumOfOrderQty=Sum(OrderQty)
	from Sales.Store s join Sales.SalesPerson p on s.SalesPersonID=p.BusinessEntityID
						join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
						join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
	where year(OrderDate)=@nam
	group by s.Name
	having Sum(OrderQty) >=all (select Sum(OrderQty)
								from Sales.Store s join Sales.SalesPerson p on s.SalesPersonID=p.BusinessEntityID
													join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
													join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
								where year(OrderDate)=@nam
								group by s.Name
								)
go
--Tìm hiểu dữ liệu
select Sum(OrderQty) as tonghang
from Sales.Store s join Sales.SalesPerson p on s.SalesPersonID=p.BusinessEntityID
					join Sales.SalesOrderHeader h on p.BusinessEntityID=h.SalesPersonID
					join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
where year(OrderDate)=2005
group by s.Name


-- chạy thủ tục
exec Proc_Cau7 2005
go