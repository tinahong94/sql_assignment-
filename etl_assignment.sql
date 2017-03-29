--3. Create read query that
--Select all the products of that customer (pick 3 clients)
--The end result shall have the following columns
--Product ID
--Product Name
--Product Description
--Url
--Image_url
--Price
--Quantity Available
--Customer_name
--Customer_id
--Avoid products with no name (IS NOT NULL)

-------------------number 3 read query
SELECT p.id, p.name as product_name, p.description as product_description, p.url, p.image_url, p.price, p.qty_available, c.name as customer_name, c.id
FROM products AS p
JOIN customers AS c ON p.customer_id = c.id 
WHERE c.name in ('anntaylor', 'urbandecay', 'freepeople') AND p.name IS NOT NULL
ORDER BY p.name ASC; 

--Now create an aggregate query (only ONE query for all customers in aggregation) for selected customers that have the following columns
--Total number of products for the customer
--Total number of active products for the customer
--Total numbers of inactive products for the customer
--Percentage of inactive products for the customer
--Total numbers of products with no name
--Number of products with image_url for the customer
--Percentage of products with image_url for the customer
--Columns
--Num_products
--Num_active_products
--Num_inactive_products
--Perc_of_inactive_products
--Num_products_with_img
--Num_products_without_img
--Perc_of_products_with_img

---------------number 4 aggregation query
SELECT 
c.name as customer_name,

(SELECT COUNT(p1.id) FROM products AS p1 WHERE p1.customer_id = c.id) AS num_products, 

(SELECT COUNT(p1.id) 
	FROM products as p1
	WHERE active = true AND p1.customer_id = c.id) AS num_active_products, 
(SELECT COUNT(p1.id) 
	FROM products as p1
	WHERE active = false AND p1.customer_id = c.id) AS num_inactive_products,

round(100 * (SELECT COUNT(p1.id) 
	FROM products as p1
	WHERE active = false AND p1.customer_id = c.id) / (SELECT count(p1.id) FROM products AS p1 WHERE p1.customer_id = c.id), 1) AS perc_of_inactive_products,

(SELECT COUNT(p1.id) FROM products as p1 WHERE name IS NULL AND p1.customer_id = c.id) AS num_products_without_name,

(SELECT COUNT(p1.id) FROM products as p1 WHERE image_url IS NOT NULL AND p1.customer_id = c.id) AS num_products_with_img,
round(100 * (SELECT count(p1.id) FROM products as p1 WHERE image_url IS NOT NULL AND p1.customer_id = c.id) / (SELECT count(p1.id) FROM products AS p1 WHERE p1.customer_id = c.id), 1) AS perc_of_products_with_img

FROM customers AS c

WHERE c.name in ('journeys', 'anntaylor', 'freepeople', 'hsn', 'pier1', 'urbandecay', 'crateandbarrel', 'cb2', 'discountschoolsupply', 'menswearhouse')

GROUP BY c.id
ORDER BY c.name;


--With the query in step 3, add new column for categories (again with the same 3 customers)
--Hint: join through categories_products and categories
--Add column cateogry_names
--If product Yellow T-Shirt belongs to to Clothing and Shirt, it will be {“Clothing”, “Shirt”}
--Use array(subquery here) to put multiple values in the same field
-----https://www.tutorialspoint.com/postgresql/postgresql_array_functions.htm
--Add column cateogry_ids
--Do the same for category.id, if product is under 2 categories with id 2 and 4 it will be {2, 4}
--Add column total_categories (since above two points b and c has two categories, it will be 2)
-----New Columns
-----Cateogry_ids
-----Category_names
-----Num_categories

------------------number 5 along with query in number 3
SELECT 
	p.id, 
	p.name as product_name, 
	p.description as product_description, 
	p.url, 
	p.image_url, 
	p.price, 
	p.qty_available, 
	c.name as customer_name, 
	c.id,

	ARRAY(
		SELECT ca.id as category_ids
			FROM categories as ca
			JOIN categories_products as cp ON ca.id = cp.category_id
			WHERE cp.product_id = p.id),
	
	ARRAY(
		SELECT ca.name as category_names
			FROM categories as ca
			JOIN categories_products as cp ON ca.id = cp.category_id
			WHERE cp.product_id = p.id),
	
	(SELECT count(ca.id) as num_categories
		FROM categories as ca
		JOIN categories_products AS cp ON ca.id = cp.category_id
		WHERE cp.product_id = p.id)
	
FROM products AS p
JOIN customers AS c ON p.customer_id = c.id 
WHERE c.name in ('urbandecay', 'anntaylor', 'freepeople') AND p.name IS NOT NULL
ORDER BY p.name ASC;



--Lastly add aggregation query (with the help of step 4) to include the following columns for each customers in ONE aggregation query
-----Total number of products without categories
-----Total number of products with categories
-----The product with maximum number of categories for the customer (for example if a customer has a product with 7 categories while all other products has <7, then it’s 7)
-------New columns
-------Num_products_with_categories
-------Num_products_without_categories
-------Max_categoires_in_one_product


--number 6 along with query number 4
SELECT 
c.id, c.name as customer_name,

(SELECT count(distinct p.id) FROM products as p
JOIN categories_products as cp ON p.id = cp.product_id WHERE p.customer_id = c.id) as num_products_with_categories,

(SELECT count(p.id) FROM products as p LEFT JOIN categories_products as cp ON p.id = cp.product_id WHERE p.customer_id = c.id AND cp.category_id IS NULL) as num_products_without_categories,

----max(category_id.count) here using alias from ''(select count(cp.category_id)'' which we name it 'category_id' as an alias 
(select max(category_id.count) from (select count(cp.category_id) from products p join categories_products cp on p.id=cp.product_id where p.customer_id=c.id group by p.id) category_id) as max_categories_in_one_product

FROM customers AS c

WHERE c.name IN ('journeys', 'anntaylor', 'freepeople', 'hsn', 'pier1', 'urbandecay', 'crateandbarrel', 'cb2', 'discountschoolsupply', 'menswearhouse')

GROUP BY c.id
ORDER BY 1;

---Create views for the following
-----Create 3 views for the 3 customers from step 5
------Name the view %customer_name%_products (%customer_name% to be replaced by the actual customer name)
------Create 1 view for step 6
-------Name the view all_customer_agg_info


-------view for number 5
CREATE VIEW urbandecay_products AS

SELECT 
p.id, 
p.name as product_name, 
p.description as product_description, 
p.url, 
p.image_url, 
p.price, 
p.qty_available, 
c.name as customer_name, 

	ARRAY(
		SELECT ca.id as category_ids
			FROM categories as ca
			JOIN categories_products as cp ON ca.id = cp.category_id
			WHERE cp.product_id = p.id) as category_ids,
	
	ARRAY(
		SELECT ca.name as category_names
			FROM categories as ca
			JOIN categories_products as cp ON ca.id = cp.category_id
			WHERE cp.product_id = p.id) as category_names,
	
	(SELECT count(ca.id) as num_categories
		FROM categories as ca
		JOIN categories_products AS cp ON ca.id = cp.category_id
		WHERE cp.product_id = p.id)
	
FROM products AS p
JOIN customers AS c ON p.customer_id = c.id 
WHERE c.name = 'urbandecay' AND p.name IS NOT NULL
ORDER BY p.name ASC;


------example
create materialized view all_customer_agg_info as
select c.id, 
  c.name, 
  (select count(p.id) from products p where p.customer_id=c.id) as num_products,
  (select count(distinct p.id) from products p join categories_products cp on p.id=cp.product_id where p.customer_id=c.id) as num_products_with_categories,
  (select max(c.count) from (select count(cp.category_id) from products p join categories_products cp on p.id=cp.product_id where p.customer_id=c.id group by p.id) c) as max_categories_in_one_product
from customers c where c.id in (11, 36, 45); 


------view for number 6
create view all_customer_agg_info as
SELECT 
c.id, c.name as customer_name,

(SELECT count(distinct p.id) FROM products as p
JOIN categories_products as cp ON p.id = cp.product_id WHERE p.customer_id = c.id) as num_products_with_categories,

(SELECT count(p.id) FROM products as p LEFT JOIN categories_products as cp ON p.id = cp.product_id WHERE p.customer_id = c.id AND cp.category_id IS NULL) as num_products_without_categories,

----max(category_id.count) here using alias from ''(select count(cp.category_id)'' which we name it 'category_id' as an alias 
(select max(category_id.count) from (select count(cp.category_id) from products p join categories_products cp on p.id=cp.product_id where p.customer_id=c.id group by p.id) category_id) as max_categories_in_one_product

FROM customers AS c

WHERE c.name IN ('journeys', 'anntaylor', 'freepeople', 'hsn', 'pier1', 'urbandecay', 'crateandbarrel', 'cb2', 'discountschoolsupply', 'menswearhouse')

GROUP BY c.id
ORDER BY 1; 
