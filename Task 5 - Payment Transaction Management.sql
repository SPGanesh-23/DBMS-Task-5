USE flipkart_db;
 
-- ============ 1. PAYMENT TABLE ============

DESCRIBE payment;
 
SHOW COLUMNS FROM payment LIKE 'payment_mode';
SHOW COLUMNS FROM payment LIKE 'payment_status';
 
-- ============ 2. CONSTRAINTS & RELATIONSHIPS ============

ALTER TABLE payment
    ADD CONSTRAINT chk_payment_success_date
    CHECK (payment_status <> 'Success' OR payment_date IS NOT NULL);
 
-- ============ 3. MANAGE PAYMENT TRANSACTIONS ============
 
-- 3.1 Payments already stored (created in Task 1 for orders 1 to 10)
SELECT * FROM payment;
 
-- 3.2 Orders that do not have a payment record yet (the five new orders from Week 4)
SELECT o.order_id, o.customer_id, o.order_date, o.total_amount, o.order_status
FROM orders o
LEFT JOIN payment p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;
 
-- 3.3 Insert payment records for those orders, using different payment modes.
INSERT INTO payment (order_id, payment_date, payment_mode, payment_status, transaction_amount) VALUES
(11, '2026-10-11', 'Net Banking',      'Success', (SELECT total_amount FROM orders WHERE order_id = 11)),
(12, '2026-10-12', 'UPI',              'Success', (SELECT total_amount FROM orders WHERE order_id = 12)),
(13, '2026-10-13', 'Credit Card',      'Failed',  (SELECT total_amount FROM orders WHERE order_id = 13)),
(14, '2026-10-16', 'Cash on Delivery', 'Success', (SELECT total_amount FROM orders WHERE order_id = 14));
 
INSERT INTO payment (order_id, payment_date, payment_mode, payment_status, transaction_amount)
SELECT order_id, NULL, 'Debit Card', 'Pending', total_amount
FROM orders
WHERE customer_id = 6 AND order_date = '2026-10-16';
 
-- 3.4 Retrieve the payment details for a specific order
SELECT * FROM payment WHERE order_id = 13;
 
-- 3.5 Check that the payment records are linked correctly to the Order Management System
SELECT o.order_id
FROM orders o
LEFT JOIN payment p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;
 
SELECT p.payment_id, p.order_id, p.transaction_amount, o.total_amount
FROM payment p
JOIN orders o ON p.order_id = o.order_id
WHERE p.transaction_amount <> o.total_amount;
 
-- ============ 4. PAYMENT TRANSACTION OPERATIONS ============
 
-- 4.1 Insert new payment transactions
-- The inserts in 3.3 add five new transactions. One more can be added the same way:
-- INSERT INTO payment (order_id, payment_date, payment_mode, payment_status, transaction_amount)
-- VALUES (<order_id>, '<date>', '<mode>', '<status>', (SELECT total_amount FROM orders WHERE order_id = <order_id>));
 
-- 4.2 Display all successful payments
SELECT payment_id, order_id, payment_date, payment_mode, transaction_amount
FROM payment
WHERE payment_status = 'Success'
ORDER BY payment_id;
 
-- 4.3 Find failed and pending transactions
SELECT payment_id, order_id, payment_mode, payment_status, transaction_amount
FROM payment
WHERE payment_status IN ('Failed', 'Pending')
ORDER BY payment_status, payment_id;
 
-- 4.4 Update payment status after a transaction retry
UPDATE payment
SET payment_mode   = 'UPI',
    payment_status = 'Success',
    payment_date   = '2026-10-14'
WHERE order_id = 13;
 
SELECT * FROM payment WHERE order_id = 13;
 
-- 4.5 Count successful and failed payments
SELECT SUM(payment_status = 'Success') AS successful_payments,
       SUM(payment_status = 'Failed')  AS failed_payments
FROM payment;
 
-- 4.6 Display complete payment information with customer and order details
SELECT p.payment_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_id, o.order_date, o.order_status, o.total_amount,
       p.payment_mode, p.payment_status, p.payment_date, p.transaction_amount
FROM payment p
JOIN orders   o ON p.order_id    = o.order_id
JOIN customer c ON o.customer_id = c.customer_id
ORDER BY p.payment_id;
 
-- ============ 5. PAYMENT ANALYSIS REPORTS ============
 
-- 5.1 Number of transactions by payment mode
SELECT payment_mode, COUNT(*) AS total_transactions
FROM payment
GROUP BY payment_mode
ORDER BY total_transactions DESC, CAST(payment_mode AS CHAR);
 
-- 5.2 Most preferred payment method (the mode with the most transactions)
SELECT payment_mode, COUNT(*) AS total_transactions
FROM payment
GROUP BY payment_mode
HAVING COUNT(*) = (SELECT MAX(mode_count)
                   FROM (SELECT COUNT(*) AS mode_count
                         FROM payment
                         GROUP BY payment_mode) AS counts);
 
-- 5.3 Total successful payment revenue
SELECT SUM(transaction_amount) AS total_successful_revenue
FROM payment
WHERE payment_status = 'Success';
 
-- 5.4 Revenue by payment method (successful payments only)
SELECT payment_mode,
       COUNT(*)                AS successful_payments,
       SUM(transaction_amount) AS revenue
FROM payment
WHERE payment_status = 'Success'
GROUP BY payment_mode
ORDER BY revenue DESC;
 
-- 5.5 Average transaction amount
SELECT ROUND(AVG(transaction_amount), 2) AS average_all_transactions
FROM payment;
 
SELECT ROUND(AVG(transaction_amount), 2) AS average_successful_transactions
FROM payment
WHERE payment_status = 'Success';
 
-- 5.6 Customer payment history
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_id, p.payment_id, p.payment_mode, p.payment_status,
       p.transaction_amount, p.payment_date
FROM customer c
JOIN orders  o ON c.customer_id = o.customer_id
JOIN payment p ON o.order_id    = p.order_id
ORDER BY c.customer_id, o.order_id;
 
-- 5.7 Total successful, failed and pending transactions
SELECT payment_status,
       COUNT(*)                AS total_transactions,
       SUM(transaction_amount) AS total_amount
FROM payment
GROUP BY payment_status
ORDER BY FIELD(payment_status, 'Success', 'Pending', 'Failed');
 
-- 5.8 Orders with failed or pending payments
SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_status, p.payment_mode, p.payment_status, p.transaction_amount
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN payment  p ON o.order_id    = p.order_id
WHERE p.payment_status IN ('Failed', 'Pending')
ORDER BY o.order_id;
 