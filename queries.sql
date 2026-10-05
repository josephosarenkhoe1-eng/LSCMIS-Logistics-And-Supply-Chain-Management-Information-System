-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

While designing this database, I developed over 250 business intelligence questions. The LSCMIS database not only satisfies these questions but can also meet other relevant business intelligence requirements. To assess the effectiveness of the database, below are 5 high-impact BI questions and their corresponding SQL queries.

1. Which processing branches and service levels have the highest shipment delays?
Description: Identifies the branches and service levels with the highest number and percentage of delayed shipments.

SELECT
    processing_branch,
    shipment_service_level,

    COUNT(*) AS total_shipments,

    SUM(
        CASE
            WHEN delivery_performance IN (
                'Delayed',
                'Currently Delayed'
            )
            THEN 1
            ELSE 0
        END
    ) AS delayed_shipments,

    SUM(
        CASE
            WHEN delivery_performance = 'On Time'
            THEN 1
            ELSE 0
        END
    ) AS on_time_shipments,

    ROUND(
        SUM(
            CASE
                WHEN delivery_performance IN (
                    'Delayed',
                    'Currently Delayed'
                )
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delay_percentage

FROM shipment_performance

GROUP BY
    processing_branch,
    shipment_service_level

HAVING delayed_shipments > 0

ORDER BY
    delay_percentage DESC,
    delayed_shipments DESC;


2. Which inventory items currently represent the greatest operational risk?
Description: Identifies inventory items requiring attention because of critical or high risk, overstocking, damage, or expiry.

SELECT
    company_inventory_code,
    item_name,
    item_category,

    current_quantity_level,
    reorder_level,
    maximum_quantity_level,

    damaged_quantity,
    damaged_percentage,

    expired_quantity,
    expired_percentage,

    inventory_risk_status

FROM inventory_risk

WHERE inventory_risk_status IN (
    'Critical',
    'High',
    'Overstocked'
)

ORDER BY
    CASE inventory_risk_status
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Overstocked' THEN 3
    END,
    damaged_percentage DESC,
    expired_percentage DESC;


3. Which suppliers have the greatest procurement and receiving risk?
Description: Identifies suppliers with higher damaged or rejected receipts, weaker relationship ratings, and significant purchasing activity.

SELECT
    supplier_code,
    company_name,
    supplier_status,

    purchase_order_count,
    purchase_value,
    completed_orders,

    avg_delivery_rating,
    avg_quality_rating,
    avg_order_accuracy_rating,
    avg_business_relationship_rating,

    receiving_records,
    damaged_or_rejected_receipts,
    damaged_rejection_rate

FROM supplier_performance

WHERE purchase_order_count > 0

ORDER BY
    damaged_rejection_rate DESC,
    avg_business_relationship_rating ASC,
    purchase_value DESC;


4. Which departments are approaching or exceeding their budgets?
Description: Identifies departments with critical budget utilization or expenses that have exceeded their budgets.

SELECT
    department_code,
    department_name,

    total_budget,
    approved_expenses,
    paid_approved_expenses,
    unpaid_approved_expenses,

    remaining_budget,
    budget_utilization_percentage,

    budget_status

FROM department_budget_expenses_performance

WHERE budget_status IN (
    'Critical',
    'Over Budget'
)

ORDER BY
    CASE budget_status
        WHEN 'Over Budget' THEN 1
        WHEN 'Critical' THEN 2
    END,
    budget_utilization_percentage DESC;


5. On which dates is LSCMIS experiencing negative cash flow?
Description: Identifies dates when cash outflow is greater than cash inflow.

SELECT
    flow_date,

    cash_inflow,
    cash_outflow,
    net_cash_flow,

    cash_flow_status

FROM cash_flow_monitoring

WHERE cash_flow_status = 'Negative'

ORDER BY
    net_cash_flow ASC;
