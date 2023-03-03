-- CASE STUDY: Pizza Runner
-- DATA CLEANING WITH SQL
-- Danny is the owner of a pizza business. He knew that just selling pizza was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!. Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters he paid for the building of a mobile app to accept orders from customers.
-- Danny has collected data for his business but he requires further assistance to clean his data.
-- There are six tables in total: runners, customer_orders, runner_orders, pizza_names, pizza_recipes, pizza_toppings.

-- Pre-Cleaning Process
-- First, all tables were accessed to identify tables that needed data cleaning. Three tables needed data cleaning

-- Issues Identified:
-- Customer_orders: blanks and null values, faulty data type, double information in exclusions and extras column, split datetime column to date and time only. Also, no primary key was observed.
-- Runner_orders: blanks and null values, split pickup_time datetime column, normalize distance and duration column, remove km and mins from both, then convert to numbers from string.
-- Pizza_recipe: split topping column. One row and column must hold just and distinct data information. Convert table to long 

--DATA CLEANING
--Create new table which holds a copy of the customer_orders table. This is to ensure preservation of the original dataset.

DROP TABLE IF EXISTS clean_customer_orders;
SELECT *
INTO clean_customer_orders
FROM pizza_runner.customer_orders
--confirm correct creation of table copy
SELECT *
FROM clean_customer_orders

-- Create new column "date_ordered" and fill same with values from the split order_time column
ALTER TABLE clean_customer_orders
ADD date_ordered Date

UPDATE clean_customer_orders
SET date_ordered = cast(order_time as Date)

-- Create new column "time_ordered" and fill same with values from the split order_time column
ALTER TABLE clean_customer_orders
ADD time_ordered Time

UPDATE clean_customer_orders
SET time_ordered = cast(order_time as time)

--Confirm successful addition of both columns
SELECT *
FROM clean_customer_orders

--Update nulls and blanks to NULL in exclusions column of the clean_customer_orders table
UPDATE clean_customer_orders
SET exclusions = CASE when exclusions = '' 
					OR exclusions = 'null' THEN NULL
					ELSE exclusions
					END::varchar(23);

--Update nulls and blanks to NULL in extras column in the clean_customer_orders table
UPDATE clean_customer_orders
SET extras = CASE when extras = '' 
					OR extras = 'null' THEN NULL
					ELSE extras
					END::varchar(23);


-- Create new column "exclusions_count " and fill same with values that count the number of exclusions per order in the clean_customer_orders table.
ALTER TABLE clean_customer_orders
ADD exclusions_count integer

--  Fill new columns with the exclusion count
UPDATE clean_customer_orders
SET exclusions_count = CAST(LENGTH(REPLACE((REPLACE(exclusions, ' ', '')),',','')) as integer)

-- Create new column "extras_count " and fill same with values that count the number of extras per order in the clean_customer_orders table.
ALTER TABLE clean_customer_orders
ADD extras_count integer

-- Fill new columns with the extras count
UPDATE clean_customer_orders
SET extras_count = CAST(LENGTH(REPLACE((REPLACE(extras, ' ', '')),',','')) as integer)

--Create table “multiple_exclusions_extras”, holding orders with exclusions or extras greater than 1 to address the denormalization in the clean_customer_orders table and unnest cells that hold multiple comma separated values.
DROP TABLE IF EXISTS multiple_exclusions_extras;

SELECT order_id, 
		UNNEST(STRING_TO_ARRAY(exclusions, ',')) AS exclusions,
		UNNEST(STRING_TO_ARRAY(extras, ',')) AS extras
INTO multiple_exclusions_extras
FROM clean_customer_orders
WHERE exclusions_count > 1 or extras_count > 1;

--Confirm successful creation of table
SELECT *
FROM multiple_exclusions_extras

--Create new table which holds a copy of the pizza_recipes table. This is to ensure preservation of the original dataset.

DROP TABLE IF EXISTS clean_ pizza_recipes;
SELECT *
INTO clean_ pizza_recipes
FROM pizza_runner.pizza_recipes

--confirm correct creation of table copy
SELECT *
FROM clean_ pizza_recipes

--unnest pizza_id and toppings column in clean_ pizza_recipes table
SELECT pizza_id,
		UNNEST(STRING_TO_ARRAY(TOPPINGS, ',')) AS TOPPINGS
FROM clean_ pizza_recipes
--Create new table which holds a copy of the runner_orders table. This is to ensure preservation of the original dataset.

DROP TABLE IF EXISTS clean_runner_orders
SELECT *
INTO clean_runner_orders
FROM pizza_runner.runner_orders

--confirm correct creation of table copy
SELECT *
FROM clean_runner_orders

--Update nulls and blanks to NULL in pickup_time column of the clean_runner_orders table
UPDATE clean_runner_orders
SET pickup_time = case when pickup_time = '' 
					or pickup_time = 'null' then NULL
					else pickup_time
					END::timestamp ;

--Update nulls and blanks to NULL in distance column and strip off km in the clean_runner_orders table
UPDATE clean_runner_orders
SET distance = CASE WHEN distance = '' OR distance = 'null' THEN NULL
					WHEN distance LIKE '%km' THEN TRIM('km' from distance)
					ELSE distance
					END :: float

--Update nulls and blanks to NULL in cancellation column of the clean_runner_orders table
UPDATE clean_runner_orders
SET cancellation = CASE WHEN cancellation = '' OR cancellation = 'null' THEN NULL
					ELSE cancellation
					END :: varchar(23)

--Update nulls and blanks to NULL in duration column of the clean_runner_orders table
UPDATE clean_runner_orders
SET duration = CASE WHEN duration = '' OR duration = 'null' THEN NULL
					ELSE duration
					END :: varchar(23)
--strip duration column of non numeric characters in the clean_runner_orders table
UPDATE clean_runner_orders
SET duration = CASE WHEN duration <> '' THEN LEFT(duration, 2)
				ELSE duration
				END :: integer;

--Alter the data types of pickup_time, distance and duration columns of the clean_runner_orders table
ALTER TABLE clean_runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time:: timestamp,
ALTER COLUMN distance TYPE FLOAT USING distance:: double precision,
ALTER COLUMN duration TYPE INT USING duration:: integer;

-- Create new column "date_pickup" and fill same with values from the split pickup_time column
ALTER TABLE clean_runner_orders
ADD date_pickup Date

UPDATE clean_runner_orders
SET date_pickup = cast(pickup_time as Date)

-- Create new column "time_pickup" and fill same with values from the split pickup_time column
ALTER TABLE clean_runner_orders
ADD time_pickup Time

UPDATE clean_runner_orders
SET time_pickup = CAST(pickup_time as time)

--Confirm successful addition of both columns
SELECT *
FROM clean_runner_orders

-- CONCLUSION
-- After following laid down processes for data cleaning using sql, the datasets are now good enough to be used to generate insights and drive data-driven decision making.
-- These datasets were gotten from the Danny Ma’s 8 weeks SQL challenge.
-- The Schema SQL code for the creation of permanent tables used for this project is attached below




CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

