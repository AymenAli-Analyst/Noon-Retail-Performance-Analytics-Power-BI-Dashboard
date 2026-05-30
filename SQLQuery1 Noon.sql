
SELECT * FROM [dbo].[noon_customerss]

SELECT * FROM [dbo].[noon_order_itemss]

SELECT * FROM [dbo].[noon_orderss]

SELECT * FROM [dbo].[noon_orderss ae]

SELECT * FROM [dbo].[noon_reviewss]

SELECT 
    customer_segment,
    is_active,
    COUNT(customer_id) AS total_customers,
    SUM(loyalty_points) AS total_loyalty_points,
    AVG(loyalty_points) AS average_loyalty_points
FROM 
    dbo.noon_customerss
GROUP BY 
    customer_segment, 
    is_active
ORDER BY 
    total_customers DESC;

SELECT 
    city,
    COUNT(customer_id) AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(*) FROM dbo.noon_customerss), 2) AS percentage_of_total
FROM 
    dbo.noon_customerss
GROUP BY 
    city
ORDER BY 
    customer_count DESC;


    SELECT 
    YEAR(registration_date) AS registration_year,
    MONTH(registration_date) AS registration_month,
    COUNT(customer_id) AS new_customers_joined
FROM 
    dbo.noon_customerss
GROUP BY 
    YEAR(registration_date), 
    MONTH(registration_date)
ORDER BY 
    registration_year DESC, 
    registration_month DESC;



SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    city,
    loyalty_points,
    CASE 
        WHEN loyalty_points >= 5000 THEN 'VIP Customer'
        WHEN loyalty_points BETWEEN 2000 AND 4999 THEN 'Gold Customer'
        WHEN loyalty_points BETWEEN 500 AND 1999 THEN 'Silver Customer'
        ELSE 'Standard Customer'
    END AS customer_value_tier
FROM 
    dbo.noon_customerss
ORDER BY 
    loyalty_points DESC;



SELECT 
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS missing_emails,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_cities,
    SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS missing_registration_dates
FROM 
    dbo.noon_customerss;



SELECT 
    ROUND(SUM(total_price), 2) AS gross_revenue,
    ROUND(SUM(unit_price * CAST(quantity AS INT)) - SUM(total_price), 2) AS total_discounts_given,
    ROUND(SUM(total_price), 2) AS net_revenue,
    COUNT(DISTINCT order_id) AS total_orders_processed
FROM 
    dbo.noon_order_itemss;



    SELECT 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.total_price), 2) AS monthly_revenue
FROM 
    dbo.noon_orderss o
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
GROUP BY 
    YEAR(o.order_date), 
    MONTH(o.order_date)
ORDER BY 
    order_year DESC, 
    order_month DESC;


SELECT 
    o.shipping_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.total_price), 2) AS total_sales
FROM 
    dbo.noon_orderss o
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
GROUP BY 
    o.shipping_city
ORDER BY 
    total_sales DESC;


    SELECT 
    o.order_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.total_price), 2) AS revenue_impact,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM dbo.noon_orderss), 2) AS order_percentage
FROM 
    dbo.noon_orderss o
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_status
ORDER BY 
    order_count DESC;


    SELECT 
    o.payment_method,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.total_price), 2) AS total_revenue,
    ROUND(AVG(oi.total_price), 2) AS average_order_value
FROM 
    dbo.noon_orderss o
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
GROUP BY 
    o.payment_method
ORDER BY 
    total_revenue DESC;


SELECT 'Main Channel' AS sales_channel, order_id, customer_id, order_date, order_status, shipping_city 
FROM dbo.noon_orderss
UNION ALL
SELECT 'AE Channel' AS sales_channel, order_id, customer_id, order_date, order_status, shipping_city 
FROM dbo.noon_orderss ae;



SELECT 'Main Channel' AS sales_channel, order_id, customer_id, order_date, order_status, shipping_city 
FROM dbo.noon_orderss
UNION ALL
SELECT 'AE Channel' AS sales_channel, order_id, customer_id, order_date, order_status, shipping_city 
FROM dbo.noon_orderss ae;


SELECT TOP 10
    product_id,
    product_name,
    category,
    base_price,
    cost_price,
    ROUND((base_price - cost_price), 2) AS profit_per_unit,
    ROUND(((base_price - cost_price) / NULLIF(base_price, 0)) * 100, 2) AS profit_margin_percentage
FROM 
    dbo.noon_reviewss
ORDER BY 
    profit_per_unit DESC;


SELECT 
    category,
    subcategory,
    COUNT(product_id) AS total_products,
    ROUND(AVG(rating), 2) AS average_rating,
    SUM(CAST(num_reviews AS INT)) AS total_reviews_received
FROM 
    dbo.noon_reviewss
GROUP BY 
    category, 
    subcategory
ORDER BY 
    average_rating DESC, 
    total_reviews_received DESC;


    SELECT 
    product_id,
    product_name,
    brand,
    stock_quantity,
    CASE 
        WHEN stock_quantity = 0 AND is_active = 1 THEN 'Out of Stock Alert'
        WHEN stock_quantity BETWEEN 1 AND 10 THEN 'Low Stock Warning'
        ELSE 'Healthy Stock'
    END AS inventory_status
FROM 
    dbo.noon_reviewss
WHERE 
    stock_quantity <= 10 OR is_active = 0
ORDER BY 
    stock_quantity ASC;



    SELECT TOP 20
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.customer_segment,
    c.loyalty_points,
    COUNT(DISTINCT o.order_id) AS total_orders_placed,
    ROUND(SUM(oi.total_price), 2) AS total_money_spent,
    ROUND(AVG(oi.total_price), 2) AS average_spend_per_order
FROM 
    dbo.noon_customerss c
JOIN 
    dbo.noon_orderss o ON c.customer_id = o.customer_id
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
WHERE 
    o.order_status = 'Delivered' --
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.customer_segment, c.loyalty_points
ORDER BY 
    total_money_spent DESC;


SELECT 
    c.customer_segment,
    p.category,
    SUM(CAST(oi.quantity AS INT)) AS total_quantity_sold,
    ROUND(SUM(oi.total_price), 2) AS total_sales_revenue
FROM 
    dbo.noon_customerss c
JOIN 
    dbo.noon_orderss o ON c.customer_id = o.customer_id
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
JOIN 
    dbo.noon_reviewss p ON oi.product_id = p.product_id
GROUP BY 
    c.customer_segment, 
    p.category
ORDER BY 
    c.customer_segment, 
    total_sales_revenue DESC;


SELECT TOP 15
    p.product_id,
    p.product_name,
    p.brand,
    COUNT(DISTINCT o.order_id) AS total_orders_ordered,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS total_returned_orders,
    ROUND(
        (SUM(CASE WHEN o.order_status = 'Returned' THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT o.order_id)) * 100, 2
    ) AS return_rate_percentage
FROM 
    dbo.noon_reviewss p
JOIN 
    dbo.noon_order_itemss oi ON p.product_id = oi.product_id
JOIN 
    dbo.noon_orderss o ON oi.order_id = o.order_id
GROUP BY 
    p.product_id, p.product_name, p.brand
HAVING 
    COUNT(DISTINCT o.order_id) >= 5 -- 
ORDER BY 
    return_rate_percentage DESC;



SELECT 
    CASE 
        WHEN p.rating >= 4.5 THEN 'Excellent (4.5+)'
        WHEN p.rating BETWEEN 3.5 AND 4.49 THEN 'Good (3.5 - 4.4)'
        WHEN p.rating BETWEEN 2.5 AND 3.49 THEN 'Average (2.5 - 3.4)'
        ELSE 'Poor (Below 2.5)'
    END AS rating_range,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(CAST(oi.quantity AS INT)) AS total_units_sold,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM 
    dbo.noon_reviewss p
JOIN 
    dbo.noon_order_itemss oi ON p.product_id = oi.product_id
GROUP BY 
    CASE 
        WHEN p.rating >= 4.5 THEN 'Excellent (4.5+)'
        WHEN p.rating BETWEEN 3.5 AND 4.49 THEN 'Good (3.5 - 4.4)'
        WHEN p.rating BETWEEN 2.5 AND 3.49 THEN 'Average (2.5 - 3.4)'
        ELSE 'Poor (Below 2.5)'
    END
ORDER BY 
    total_revenue DESC;





WITH Customer_RFM AS (
    SELECT 
        c.customer_id,
        c.first_name + ' ' + c.last_name AS customer_name,
        DATEDIFF(day, MAX(o.order_date), GETDATE()) AS recency_days, -- 
        COUNT(DISTINCT o.order_id) AS frequency,                    -- 
        ROUND(SUM(oi.total_price), 2) AS monetary_value             -- 
    FROM 
        dbo.noon_customerss c
    JOIN 
        dbo.noon_orderss o ON c.customer_id = o.customer_id
    JOIN 
        dbo.noon_order_itemss oi ON o.order_id = oi.order_id
    WHERE 
        o.order_status = 'Delivered'
    GROUP BY 
        c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    customer_name,
    recency_days,
    frequency,
    monetary_value,
    CASE 
        WHEN recency_days <= 30 AND frequency >= 5 THEN 'Champions (Core Loyal)'
        WHEN recency_days BETWEEN 31 AND 90 AND frequency >= 3 THEN 'Loyal Customers'
        WHEN recency_days <= 30 AND frequency = 1 THEN 'Recent New Customers'
        WHEN recency_days > 180 THEN 'At Risk / Churned Customers'
        ELSE 'Regular Customers'
    END AS rfm_customer_segment
FROM 
    Customer_RFM
ORDER BY 
    monetary_value DESC;


    WITH Product_Sales_Rank AS (
    SELECT 
        p.category,
        p.product_id,
        p.product_name,
        p.brand,
        SUM(CAST(oi.quantity AS INT)) AS total_units_sold,
        DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(CAST(oi.quantity AS INT)) DESC) AS product_rank
    FROM 
        dbo.noon_reviewss p
    JOIN 
        dbo.noon_order_itemss oi ON p.product_id = oi.product_id
    GROUP BY 
        p.category, p.product_id, p.product_name, p.brand
)
SELECT 
    category,
    product_rank,
    product_id,
    product_name,
    brand,
    total_units_sold
FROM 
    Product_Sales_Rank
WHERE 
    product_rank <= 3
ORDER BY 
    category ASC, 
    product_rank ASC;


SELECT 
    o.order_id,
    COUNT(oi.item_id) AS total_items_in_order,
    SUM(CAST(oi.quantity AS INT)) AS total_units_in_order,
    ROUND(SUM(oi.total_price), 2) AS total_order_value,
    CASE 
        WHEN SUM(oi.total_price) >= 5000 THEN 'Bulk / Corporate Order'
        WHEN SUM(oi.total_price) BETWEEN 1500 AND 4999 THEN 'High-Value Retail'
        WHEN SUM(oi.total_price) BETWEEN 500 AND 1499 THEN 'Average Retail'
        ELSE 'Low-Value Order'
    END AS order_value_segment
FROM 
    dbo.noon_orderss o
JOIN 
    dbo.noon_order_itemss oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id
ORDER BY 
    total_order_value DESC;


    WITH Monthly_Sales AS (
    SELECT 
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        ROUND(SUM(oi.total_price), 2) AS current_month_revenue
    FROM 
        dbo.noon_orderss o
    JOIN 
        dbo.noon_order_itemss oi ON o.order_id = oi.order_id
    WHERE 
        o.order_status = 'Delivered'
    GROUP BY 
        YEAR(o.order_date), 
        MONTH(o.order_date)
),
Revenue_Comparison AS (
    SELECT 
        sales_year,
        sales_month,
        current_month_revenue,
        LAG(current_month_revenue, 1) OVER (ORDER BY sales_year, sales_month) AS previous_month_revenue
    FROM 
        Monthly_Sales
)
SELECT 
    sales_year,
    sales_month,
    current_month_revenue,
    previous_month_revenue,
    ROUND(((current_month_revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0)) * 100, 2) AS monthly_growth_percentage
FROM 
    Revenue_Comparison
ORDER BY 
    sales_year DESC, 
    sales_month DESC;


















































































































































































































































































