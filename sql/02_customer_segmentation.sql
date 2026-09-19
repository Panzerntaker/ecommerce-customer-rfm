WITH customer_summary AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(total_amount) AS total_spend,
        CAST(JULIANDAY('2011-12-10') - JULIANDAY(MAX(invoice_date)) AS INTEGER) AS recency_days
    FROM transactions
    GROUP BY customer_id
),
segmented AS (
    SELECT 
        customer_id,
        total_orders,
        total_spend,
        recency_days,
        CASE 
            WHEN total_spend >= 2000 AND total_orders >= 3 THEN 'VIP High-Spender'
            WHEN recency_days <= 90 THEN 'Active Regular'
            ELSE 'At-Risk / Dormant'
        END AS segment
    FROM customer_summary
)
SELECT 
    segment,
    COUNT(customer_id) AS customer_count,
    ROUND(100.0 * COUNT(customer_id) / (SELECT COUNT(*) FROM segmented), 2) AS pct_customers,
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(100.0 * SUM(total_spend) / (SELECT SUM(total_spend) FROM segmented), 2) AS pct_revenue,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
