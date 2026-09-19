WITH customer_spend AS (
    SELECT 
        customer_id,
        ROUND(SUM(total_amount), 2) AS total_spend,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM transactions
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT 
        customer_id,
        total_spend,
        total_orders,
        ROW_NUMBER() OVER (ORDER BY total_spend DESC) AS cust_rank,
        COUNT(*) OVER () AS total_cust_count,
        SUM(total_spend) OVER (ORDER BY total_spend DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_spend,
        SUM(total_spend) OVER () AS grand_total_spend
    FROM customer_spend
)
SELECT 
    cust_rank,
    customer_id,
    total_spend,
    ROUND(100.0 * cust_rank / total_cust_count, 2) AS pct_customers,
    ROUND(100.0 * cum_spend / grand_total_spend, 2) AS pct_cumulative_revenue
FROM ranked_customers
WHERE cust_rank IN (
    CAST(total_cust_count * 0.05 AS INT),
    CAST(total_cust_count * 0.10 AS INT),
    CAST(total_cust_count * 0.20 AS INT),
    CAST(total_cust_count * 0.50 AS INT),
    total_cust_count
);
