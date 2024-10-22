create proc uspProductList
AS
BEGIN
select Product_name,list_price from production.products
order by product_name
END

exec uspProductList

sp_help uspProductList

alter proc uspProductList
AS
BEGIN
select product_name,model_year,list_price from
production.products order by list_price desc
END

exec sp_rename 'uspProductList','uspMyProductList'

create proc uspFindProducts(@modelyear as int)
AS
BEGIN
select * from production.products where model_year=@modelyear
END

exec uspFindProducts 2019

create proc uspFindProductsinRange(@minprice int,@maxprice int)
AS
BEGIN
select * from production.products where list_price>=@minprice and list_price<=@maxprice
END

exec uspFindProductsinRange 70,3000


create proc uspFindProductsbyName(@minPrice as decimal =200,@maxprice decimal, @name as varchar(max))
AS
BEGIN
select * from production.products where list_price>=@minPrice and list_price<=@maxprice
and product_name like '%'+@name+'%'
END

exec uspFindProductsbyName
@maxprice=1500,@name='Trek'

create procedure uspFindProductCountByModelYear(@modelyear int,@productCount int Output)
AS
BEGIN
select product_name,list_price
from production.products
where 
model_year=@modelyear

select @productCount=@@ROWCOUNT
END

declare @count int;
exec uspFindProductCountByModelYear @modelyear=2016,@productCount=@count OUT;;
select @count as 'Total Products found'

create proc usp_GetAllCustomers
AS
BEGIN
select * from sales.customers
END

usp_GetAllCustomers

create proc usp_GetCustomerOrders
@customerid int
AS
BEGIN
select * from sales.orders
where customer_id=@customerid
END

usp_GetCustomerOrders 1

create proc usp_GetCustomerData(@customerid int)
AS
BEGIN
exec usp_GetAllCustomers;
exec usp_GetCustomerOrders @customerid;
END

exec usp_GetCustomerData 1

--scalar valued  functions
create function GetAllProducts()
RETURNS INT
AS
BEGIN
RETURN (SELECT COUNT(*) from production.products)
END

print dbo.GetAllProducts()

--inline table valued functions
create function GetProductById(@productid int)
returns table
as
return (select * from production.products where product_id=@productid)

select * from GetProductById(4)


create function ILTVF_GetEmployees()
returns table
as
return (select EmpID,EmpName,Cast(DOB as Date) as DOB from Employee)

create function MSTVF_GetEmployees()
returns @Temptable table (EmpID int,EmpName varchar(50),DOB date)
as
begin
insert into @Temptable
 select EmpID,EmpName,Cast(DOB as Date) as DOB from Employee
 return 
 end

 select * from Employee
 select * from MSTVF_GetEmployees()
 select * from ILTVF_GetEmployees()

 update ILTVF_GetEmployees() set EmpName='Meena' where EmpID=1
  update MSTVF_GetEmployees() set EmpName='Asha' where EmpID=2 