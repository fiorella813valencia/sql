--Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

ANSWER: NO
SELECT * FROM dsv1069.final_assignments_qa;
--after run the query we need date column

Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type. 

SELECT * FROM dsv1069.final_assignments_qa;
SELECT * FROM dsv1069.final_assignments;
SELECT 
    item_id,
    test_a AS test_assignment,
    CASE 
        WHEN test_a IS NOT NULL THEN 'test_a'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_a IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa

UNION 

SELECT 
    item_id,
    test_b AS test_assignment,
    CASE 
        WHEN test_b IS NOT NULL THEN 'test_b'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_b IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa


UNION 
SELECT 
    item_id,
    test_c AS test_assignment,
    CASE 
        WHEN test_c IS NOT NULL THEN 'test_c'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
    item_id,
    test_c AS test_assignment,
    CASE 
        WHEN test_c IS NOT NULL THEN 'test_d'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
    item_id,
    test_c AS test_assignment,
    CASE 
        WHEN test_c IS NOT NULL THEN 'test_e'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT 
    item_id,
    test_c AS test_assignment,
    CASE 
        WHEN test_c IS NOT NULL THEN 'test_f'
        ELSE NULL
    END AS test_number,
    CASE 
        WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL
    END AS test_start_date
FROM dsv1069.final_assignments_qa


Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started)

SELECT 
    test_assignment,
    COUNT(DISTINCT item_id) AS number_of_items,
    SUM(order_binary) AS items_ordered_30d,
    MIN(test_start_date) AS test_start_date
FROM (
    SELECT 
        f.item_id,
        f.test_assignment,
        f.test_number,
        f.test_start_date,
        DATE(o.created_at) AS created_at,
        CASE 
            WHEN (o.created_at > f.test_start_date 
                  AND DATE_PART('day', o.created_at - f.test_start_date) <= 30) THEN 1
            ELSE 0
        END AS order_binary
    FROM dsv1069.final_assignments f
    LEFT JOIN dsv1069.orders o ON f.item_id = o.item_id
    WHERE f.test_number = 'item_test_2'
) AS order_binary_30d
GROUP BY test_assignment;

0	1130	402	2015-03-14 00:00:00
1	1068	384	2015-03-14 00:00:00



Use the final_assignments table to calculate the view binary, 
and average views for the 30 day window after the test assignment for 
item_test_2. (You may include the day the test started)

SELECT 
    item_test_2.item_id,
    item_test_2.test_assignment,
    item_test_2.test_number,
    item_test_2.test_start_date,
    MAX(CASE
        WHEN (item_test_2.view_date > item_test_2.test_start_date
              AND DATE_PART('day', item_test_2.view_date - item_test_2.test_start_date) <= 30) THEN 1
        ELSE 0
    END) AS view_binary
FROM (
    SELECT 
        final_assignments.*,
        DATE(events.event_time) AS view_date
    FROM dsv1069.final_assignments AS final_assignments
    LEFT JOIN (
        SELECT 
            event_time,
            CASE
                WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS NUMERIC)
                ELSE NULL
            END AS item_id
        FROM dsv1069.events
        WHERE event_name = 'view_item'
    ) AS events ON final_assignments.item_id = events.item_id
    WHERE test_number = 'item_test_2'
) AS item_test_2
GROUP BY 
    item_test_2.item_id,
    item_test_2.test_assignment,
    item_test_2.test_number,
    item_test_2.test_start_date
LIMIT 30;

Use the 
https://thumbtack.github.io/abba/demo/abba.html
 to compute the lifts in metrics and the p-values for the binary metrics 
 ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 
 
SELECT 
    test_assignment,
    test_number,
    COUNT(DISTINCT item_id) AS number_of_items,
    SUM(view_binary_30d) AS view_binary_30d
FROM (
    SELECT 
        fa.item_id AS item_id,
        fa.test_assignment AS test_assignment,
        fa.test_number AS test_number,
        COUNT(CASE 
            WHEN ve.event_time BETWEEN fa.test_start_date AND fa.test_start_date + INTERVAL '30 day' THEN 1
            ELSE NULL
        END) AS view_binary_30d
    FROM 
        dsv1069.final_assignments fa
    LEFT JOIN 
        dsv1069.view_item_events ve ON fa.item_id = ve.item_id
    WHERE 
        fa.test_number = 'item_test_2'
    GROUP BY 
        fa.item_id,
        fa.test_assignment,
        fa.test_number,
        fa.test_start_date
) AS view_binary
GROUP BY 
    test_assignment,
    test_number;

