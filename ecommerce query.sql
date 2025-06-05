CREATE TABLE ecommerce_dataset (
    invoice_no VARCHAR(20),
    invoice_date TIMESTAMP,
    customer_id INTEGER,
    stock_code VARCHAR(20),
    description TEXT,
    quantity INTEGER,
    unit_price NUMERIC(10, 2),
    country VARCHAR(50)
) ;

SELECT *
FROM ecommerce_dataset ;

--REMOVE DUPLICATES
SELECT DISTINCT *
FROM ecommerce_dataset ;

--SEPARATE MONTH AND YEAR FROM THE INVOICE DATE
ALTER TABLE ecommerce_dataset
ADD invoice_year INT;
UPDATE ecommerce_dataset
SET invoice_year = EXTRACT( YEAR FROM invoice_date)
WHERE invoice_date is not NULL;

ALTER TABLE ecommerce_dataset
ADD invoice_month INT ;
UPDATE ecommerce_dataset
SET invoice_month = EXTRACT(MONTH FROM invoice_date)
WHERE invoice_date IS NOT NULL;

--INSERT NEW COLUMN (TOTAL SALES = QUANTITY * UNIT PRICE)

ALTER TABLE ecommerce_dataset
ADD total_sales INT;
UPDATE ecommerce_dataset
SET total_sales = quantity * unit_price;

-- COUNTRY WITH HIGHEST SALES

SELECT country,
    description,
    SUM(total_sales) AS total_sales 
FROM ecommerce_dataset
GROUP BY country, description
ORDER BY total_sales DESC
LIMIT 10;

-- ADD RANKING TO THE TOP SELLING PRODUCTS BY COUNTRY

WITH ranked_sales AS (
    SELECT 
        country,
        description,
        SUM(total_sales) AS total_sales,
        RANK() OVER (PARTITION BY country ORDER BY SUM(total_sales) DESC) AS total_sales_rank
    FROM ecommerce_dataset
    GROUP BY country, description
)

SELECT *
FROM ranked_sales
WHERE total_sales_rank <= 10
ORDER BY country, total_sales_rank
;


--TOP SELLING PRODUCTS 

SELECT
    description,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_sales) AS total_sales
FROM ecommerce_dataset
GROUP BY description
ORDER BY total_sales DESC
LIMIT 10;


--PRICE RANGE (GROUP UNIT PRICE)

ALTER TABLE ecommerce_dataset
ADD COLUMN price_range VARCHAR(20);

UPDATE ecommerce_dataset
SET price_range = CASE
    WHEN unit_price < 10 THEN 'less than 10'
    WHEN unit_price BETWEEN 10 AND 50 THEN '10 to 50'
    WHEN unit_price BETWEEN 51 AND 100 THEN '51 to 100'
    ELSE 'above 100'
END;


