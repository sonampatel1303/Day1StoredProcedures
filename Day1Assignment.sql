

  CREATE PROCEDURE GetCustomersByProductID
   (@ProductID INT)
AS
BEGIN
    SELECT DISTINCT C.customer_id, C.first_name, C.last_name, C.email
    FROM sales.customers C
    INNER JOIN sales.orders O ON C.customer_id = O.customer_id
    INNER JOIN sales.order_items OI ON O.order_id = OI.order_id
    WHERE OI.product_id = @ProductID;
END;

exec GetCustomersByProductID 12

  --3 ) Create a user Defined function to calculate the TotalPrice based on productid and Quantity Products Table
 
  CREATE FUNCTION dbo.CalculateTotalPrice( @ProductID INT, @Quantity INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalPrice DECIMAL(10, 2);

    SELECT @TotalPrice = list_price * @Quantity
    FROM production.products
    WHERE product_id = @ProductID;

    RETURN @TotalPrice;
END;

SELECT dbo.CalculateTotalPrice(12, 3) AS TotalPrice;

--4) create a function that returns all orders for a specific customer, including details such as OrderID, OrderDate, and the total amount of each order.

CREATE FUNCTION dbo.GetCustomerOrders( @CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        O.order_id,
        O.order_date,
        SUM(OI.quantity * OI.list_price * (1 - OI.discount)) AS TotalAmount
    FROM sales.orders O
    INNER JOIN sales.order_items OI ON O.order_id = OI.order_id
    WHERE O.customer_id = @CustomerID
    GROUP BY O.order_id, O.order_date
);

SELECT * FROM dbo.GetCustomerOrders(1);

--create a Multistatement table valued function that calculates the total sales for each product, considering quantity and price.
CREATE FUNCTION CalculateTotalSalesPerProduct()
RETURNS @ProductSales TABLE
(
    ProductID INT,
    ProductName VARCHAR(255),
    TotalSales DECIMAL(18, 2)
)
AS
BEGIN
   
    INSERT INTO @ProductSales (ProductID, ProductName, TotalSales)
    SELECT 
        P.product_id,
        P.product_name,
        SUM(OI.quantity * OI.list_price * (1 - OI.discount)) AS TotalSales
    FROM production.products P
    INNER JOIN sales.order_items OI ON P.product_id = OI.product_id
    GROUP BY P.product_id, P.product_name;

    RETURN;
END;

SELECT * FROM CalculateTotalSalesPerProduct();

--6)create a  multi-statement table-valued function that lists all customers along with the total amount they have spent on orders.
CREATE FUNCTION GetCustomerTotalSpending()
RETURNS @CustomerSpending TABLE
(
    CustomerID INT,
    FullName VARCHAR(255),
    TotalSpent DECIMAL(18, 2)
)
AS
BEGIN
    -- Insert data into the return table
    INSERT INTO @CustomerSpending (CustomerID, FullName, TotalSpent)
    SELECT 
        C.customer_id,
        CONCAT(C.first_name, ' ', C.last_name) AS FullName,
        SUM(OI.quantity * OI.list_price * (1 - OI.discount)) AS TotalSpent
    FROM sales.customers C
    INNER JOIN sales.orders O ON C.customer_id = O.customer_id
    INNER JOIN sales.order_items OI ON O.order_id = OI.order_id
    GROUP BY C.customer_id, C.first_name, C.last_name;

    RETURN;
END;

SELECT * FROM GetCustomerTotalSpending();
