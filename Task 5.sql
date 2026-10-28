USE OrderManagementDB;

CREATE TABLE Payment (
    Payment_ID         INT PRIMARY KEY,
    Order_ID           INT NOT NULL UNIQUE,
    Payment_Date       DATE NOT NULL,
    Payment_Mode       VARCHAR(30) NOT NULL,
    Payment_Status     VARCHAR(20) NOT NULL DEFAULT 'Pending',
    Transaction_Amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_payment_order
        FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    CONSTRAINT chk_payment_mode
        CHECK (Payment_Mode IN ('UPI', 'Credit Card', 'Debit Card',
                                'Net Banking', 'Cash on Delivery')),
    CONSTRAINT chk_payment_status
        CHECK (Payment_Status IN ('Pending', 'Success', 'Failed')),
    CONSTRAINT chk_transaction_amount
        CHECK (Transaction_Amount > 0)
);

DESC Payment;
SHOW CREATE TABLE Payment;

INSERT INTO Payment
(Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES
(1, 1001, '2026-10-01', 'Credit Card',      'Success', 59000.00),
(2, 1002, '2026-10-03', 'UPI',              'Success', 27300.00),
(3, 1003, '2026-10-05', 'Debit Card',       'Success',  3800.00),
(4, 1004, '2026-10-08', 'Net Banking',      'Failed',  39500.00),
(5, 1005, '2026-10-10', 'Cash on Delivery', 'Success',  2300.00),
(6, 1006, '2026-10-12', 'UPI',              'Success',  5500.00),
(7, 1007, '2026-10-15', 'Credit Card',      'Failed',   3000.00),
(8, 1008, '2026-10-18', 'UPI',              'Success',  2050.00),
(9, 1009, '2026-10-20', 'Cash on Delivery', 'Pending',  8200.00);

SELECT * FROM Customer;
SELECT * FROM Orders;
SELECT * FROM Payment;

INSERT INTO Payment
(Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount)
VALUES
(10, 1010, '2026-10-22', 'Net Banking', 'Pending', 1500.00);

SELECT *
FROM Payment
WHERE Order_ID = 1005;

SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode, Transaction_Amount
FROM Payment
WHERE Payment_Status = 'Success'
ORDER BY Payment_Date;

SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode,
       Payment_Status, Transaction_Amount
FROM Payment
WHERE Payment_Status IN ('Failed', 'Pending')
ORDER BY Payment_Status, Payment_Date;

UPDATE Payment
SET Payment_Status = 'Success'
WHERE Order_ID = 1010
  AND Payment_Status = 'Pending';

UPDATE Payment
SET Payment_Mode   = 'UPI',
    Payment_Date   = '2026-10-17',
    Payment_Status = 'Success'
WHERE Order_ID = 1007
  AND Payment_Status = 'Failed';

SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status
FROM Payment
WHERE Order_ID IN (1007, 1010);

SELECT Payment_Status, COUNT(*) AS Number_Of_Payments
FROM Payment
WHERE Payment_Status IN ('Success', 'Failed')
GROUP BY Payment_Status;

SELECT
    SUM(Payment_Status = 'Success') AS Successful_Payments,
    SUM(Payment_Status = 'Failed')  AS Failed_Payments
FROM Payment;

SELECT
    p.Payment_ID,
    o.Order_ID,
    c.Customer_ID,
    c.Customer_Name,
    c.Email,
    c.City,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount       AS Order_Total,
    p.Payment_Date,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Payment p
JOIN Orders   o ON p.Order_ID    = o.Order_ID
JOIN Customer c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Payment_ID;

SELECT p.Payment_ID, p.Order_ID, p.Transaction_Amount, o.Total_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
WHERE p.Transaction_Amount <> o.Total_Amount;

SELECT Payment_Mode, COUNT(*) AS Number_Of_Transactions
FROM Payment
GROUP BY Payment_Mode
ORDER BY Number_Of_Transactions DESC;

SELECT Payment_Mode, COUNT(*) AS Number_Of_Transactions
FROM Payment
GROUP BY Payment_Mode
HAVING COUNT(*) = (
    SELECT MAX(Mode_Count)
    FROM (
        SELECT COUNT(*) AS Mode_Count
        FROM Payment
        GROUP BY Payment_Mode
    ) AS Counts
);

SELECT SUM(Transaction_Amount) AS Total_Successful_Revenue
FROM Payment
WHERE Payment_Status = 'Success';

SELECT
    Payment_Mode,
    COUNT(*) AS Total_Transactions,
    SUM(CASE WHEN Payment_Status = 'Success'
             THEN 1 ELSE 0 END) AS Successful_Transactions,
    SUM(CASE WHEN Payment_Status = 'Success'
             THEN Transaction_Amount ELSE 0 END) AS Successful_Revenue
FROM Payment
GROUP BY Payment_Mode
ORDER BY Successful_Revenue DESC;

SELECT
    ROUND(AVG(Transaction_Amount), 2) AS Average_Transaction_Amount,
    ROUND(AVG(CASE WHEN Payment_Status = 'Success'
                   THEN Transaction_Amount END), 2) AS Average_Successful_Amount
FROM Payment;

SELECT
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    p.Payment_Date,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Customer c
JOIN Orders  o ON c.Customer_ID = o.Customer_ID
JOIN Payment p ON o.Order_ID    = p.Order_ID
ORDER BY c.Customer_ID, p.Payment_Date;

SELECT
    Payment_Status,
    COUNT(*)                AS Number_Of_Transactions,
    SUM(Transaction_Amount) AS Total_Amount
FROM Payment
GROUP BY Payment_Status
ORDER BY Number_Of_Transactions DESC;

SELECT
    o.Order_ID,
    c.Customer_Name,
    c.Email,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount,
    p.Payment_Mode,
    p.Payment_Status
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Payment  p ON o.Order_ID    = p.Order_ID
WHERE p.Payment_Status IN ('Failed', 'Pending')
ORDER BY o.Order_ID;

SELECT o.Order_ID, o.Total_Amount, o.Order_Status
FROM Orders o
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
WHERE p.Payment_ID IS NULL;

SELECT * FROM Payment;
SHOW TABLES;
DESC Payment;

