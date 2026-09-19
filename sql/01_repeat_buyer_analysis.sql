WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(total_amount) AS total_spend,
        MIN(invoice_date) AS first_order_date,
        MAX(invoice_date) AS last_order_date
    FROM transactions
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(customer_id) AS customer_count,
    ROUND(100.0 * COUNT(customer_id) / (SELECT COUNT(*) FROM customer_orders), 2) AS pct_customers,
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM customer_orders), 2) AS pct_revenue,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_customer,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM customer_orders
GROUP BY 1
ORDER BY customer_count DESC;
