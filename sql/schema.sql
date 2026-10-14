-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- TABLE:
-- The database has 37 tables: Below are the sql schema:

-- TABLE: customers

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_code TEXT NOT NULL UNIQUE,
    customer_type TEXT NOT NULL
        CHECK (customer_type IN ('Individual', 'Business')),
    customer_special_date DATE,
    customer_special_date_type TEXT,
    customer_email TEXT,
    customer_phone_number TEXT,
    customer_address TEXT NOT NULL,
    gender TEXT CHECK (gender IN ('Male', 'Female')),
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT,
    credit_limit NUMERIC NOT NULL DEFAULT 0
        CHECK (credit_limit >= 0),
    customer_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (customer_status IN (
            'Active', 'Inactive', 'Suspended', 'Blocked'
        )),
    branch_id INTEGER NOT NULL,
    preferred_contact_method TEXT
        CHECK (preferred_contact_method IN ('Email', 'Phone', 'SMS')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- TABLE: employees

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    branch_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    employee_name TEXT NOT NULL,
    employee_code TEXT NOT NULL UNIQUE,
    gender TEXT CHECK (gender IN ('Male', 'Female')),
    employee_special_date DATE,
    employee_special_date_type TEXT,
    employee_mobile_phone_number TEXT,
    employee_home_address TEXT NOT NULL,
    job_title TEXT NOT NULL,
    employment_type TEXT NOT NULL
        CHECK (employment_type IN ('Full-Time', 'Part-Time', 'Contract', 'Temporary')),
    employment_status TEXT NOT NULL
        CHECK (employment_status IN ('Active', 'Inactive', 'Suspended', 'Terminated')),
    hire_date DATE NOT NULL,
    termination_date DATE,
    email_address TEXT UNIQUE,
    postal_code TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    salary NUMERIC NOT NULL CHECK (salary >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- TABLE: suppliers

CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY,
    company_name TEXT NOT NULL,
    supplier_code TEXT NOT NULL UNIQUE,
    supplier_type TEXT NOT NULL,
    supplier_email TEXT,
    supplier_phone_number TEXT,
    supplier_address TEXT NOT NULL,
    supplier_city TEXT NOT NULL,
    supplier_state TEXT NOT NULL,
    supplier_country TEXT NOT NULL,
    supplier_postal_code TEXT,
    supplier_rating NUMERIC CHECK (supplier_rating BETWEEN 0 AND 10),
    contract_start_date DATE,
    payment_terms TEXT,
    supplier_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (supplier_status IN ('Active', 'Inactive', 'Suspended', 'Terminated')),
    lead_time_days INTEGER CHECK (lead_time_days >= 0),
    quality_certification TEXT,
    minimum_order_quantity NUMERIC
        CHECK (minimum_order_quantity >= 0),
    supplier_risk_level_assessment TEXT
        CHECK (supplier_risk_level_assessment IN ('Low', 'Medium', 'High')),
    supplier_registration_number TEXT UNIQUE,
    supplier_tax_identification_number TEXT UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: shipment_requests

CREATE TABLE shipment_requests (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    shipment_request_code TEXT NOT NULL UNIQUE,
    request_date DATE NOT NULL,
    requested_pickup_date DATE,
    requested_delivery_date DATE,
    actual_pickup_date DATE,
    actual_delivery_date DATE,
    pickup_address TEXT,
    destination_address TEXT,
    destination_branch_id INTEGER,
    destination_hub_id INTEGER,
    shipment_receiving_mode TEXT NOT NULL
        CHECK (shipment_receiving_mode IN (
            'Customer Drop-off',
            'Branch Drop-off',
            'Hub Drop-off',
            'Company Pickup'
        )),
    shipment_service_level TEXT NOT NULL
        CHECK (shipment_service_level IN (
            'Standard',
            'Express',
            'Priority',
            'Same-Day'
        )),
    shipment_type TEXT NOT NULL,
    secondary_packaging_type TEXT,
    secondary_packaging_material TEXT,
    shipment_status TEXT NOT NULL DEFAULT 'Requested'
        CHECK (shipment_status IN (
            'Requested',
            'Pending',
            'Confirmed',
            'Picked Up',
            'In Transit',
            'Out for Delivery',
            'Delivered',
            'Returned',
            'Cancelled',
            'Closed'
        )),
    special_instructions TEXT,
    employee_id INTEGER NOT NULL,
    cancellation_reason TEXT,
    cancelled_at DATETIME,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        requested_delivery_date IS NULL
        OR requested_pickup_date IS NULL
        OR requested_delivery_date >= requested_pickup_date
    ),

    CHECK (
        actual_delivery_date IS NULL
        OR actual_pickup_date IS NULL
        OR actual_delivery_date >= actual_pickup_date
    ),

    CHECK (
        (destination_branch_id IS NOT NULL) +
        (destination_hub_id IS NOT NULL) +
        (destination_address IS NOT NULL) = 1
    ),

    CHECK (
        shipment_status != 'Cancelled'
        OR cancellation_reason IS NOT NULL
    ),

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (destination_branch_id) REFERENCES branches(id),
    FOREIGN KEY (destination_hub_id) REFERENCES hubs(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- TABLE: shipment_request_items

CREATE TABLE shipment_request_items (
    id INTEGER PRIMARY KEY,
    shipment_request_id INTEGER NOT NULL,
    item_description TEXT NOT NULL,
    item_category TEXT NOT NULL,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    declared_weight NUMERIC NOT NULL CHECK (declared_weight >= 0),
    verified_weight NUMERIC CHECK (verified_weight >= 0),
    length NUMERIC CHECK (length > 0),
    width NUMERIC CHECK (width > 0),
    height NUMERIC CHECK (height > 0),
    declared_value NUMERIC NOT NULL CHECK (declared_value >= 0),
    is_fragile TEXT NOT NULL DEFAULT 'No'
        CHECK (is_fragile IN ('Yes', 'No')),
    is_hazardous TEXT NOT NULL DEFAULT 'No'
        CHECK (is_hazardous IN ('Yes', 'No')),
    verification_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (verification_status IN (
            'Pending',
            'Verified',
            'Discrepancy',
            'Rejected'
        )),
    verified_by INTEGER,
    verified_at DATETIME,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (verified_by IS NULL AND verified_at IS NULL)
        OR
        (verified_by IS NOT NULL AND verified_at IS NOT NULL)
    ),

    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (verified_by) REFERENCES employees(id)
);

-- TABLE: branches

CREATE TABLE branches (
    id INTEGER PRIMARY KEY,
    branch_code TEXT NOT NULL UNIQUE,
    branch_name TEXT NOT NULL,
    branch_type TEXT NOT NULL
        CHECK (branch_type IN (
            'Headquarters',
            'Regional Branch',
            'Local Branch',
            'Distribution Branch'
        )),
    employee_id INTEGER,
    branch_phone_number TEXT,
    carbon_level NUMERIC CHECK (carbon_level >= 0),
    branch_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT,
    branch_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (branch_status IN (
            'Active',
            'Inactive',
            'Temporarily Closed',
            'Permanently Closed'
        )),
    branch_email TEXT,
    operating_days TEXT,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    warehouse_id INTEGER,
    latitude REAL CHECK (latitude BETWEEN -90 AND 90),
    longitude REAL CHECK (longitude BETWEEN -180 AND 180),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (closing_time > opening_time),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

-- TABLE: warehouses

CREATE TABLE warehouses (
    id INTEGER PRIMARY KEY,
    warehouse_code TEXT NOT NULL UNIQUE,
    warehouse_name TEXT NOT NULL UNIQUE,
    warehouse_address TEXT NOT NULL UNIQUE,
    warehouse_phone_number TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT,
    employee_id INTEGER,
    maximum_storage_capacity NUMERIC NOT NULL
        CHECK (maximum_storage_capacity > 0),
    current_storage_utilization NUMERIC NOT NULL DEFAULT 0
        CHECK (
            current_storage_utilization >= 0
            AND current_storage_utilization <= maximum_storage_capacity
        ),
    carbon_level NUMERIC CHECK (carbon_level >= 0),
    warehouse_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (warehouse_status IN (
            'Active',
            'Inactive',
            'Under Maintenance',
            'Closed'
        )),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- TABLE: hubs

CREATE TABLE hubs (
    id INTEGER PRIMARY KEY,
    hub_code TEXT NOT NULL UNIQUE,
    hub_name TEXT NOT NULL UNIQUE,
    hub_address TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL UNIQUE,
    employee_id INTEGER,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT,
    hub_type TEXT NOT NULL
        CHECK (hub_type IN (
            'Regional',
            'Distribution',
            'Consolidation',
            'Transit',
            'Sorting'
        )),
    hub_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (hub_status IN (
            'Active',
            'Inactive',
            'Under Maintenance',
            'Closed'
        )),
    carbon_level NUMERIC CHECK (carbon_level >= 0),
    maximum_storage_capacity NUMERIC NOT NULL
        CHECK (maximum_storage_capacity > 0),
    current_storage_utilization NUMERIC NOT NULL DEFAULT 0
        CHECK (
            current_storage_utilization >= 0
            AND current_storage_utilization <= maximum_storage_capacity
        ),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- TABLE: shipment_request_inventory

CREATE TABLE shipment_request_inventory (
    id INTEGER PRIMARY KEY,
    shipment_request_item_id INTEGER NOT NULL,
    barcode TEXT NOT NULL UNIQUE,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    storage_location TEXT,
    quantity_received NUMERIC NOT NULL
        CHECK (quantity_received > 0),
    current_quantity_level NUMERIC NOT NULL
        CHECK (current_quantity_level >= 0),
    inventory_status TEXT NOT NULL
        CHECK (inventory_status IN (
            'Received',
            'In Storage',
            'Processing',
            'Dispatched',
            'Damaged',
            'Missing',
            'Returned'
        )),
    item_condition TEXT NOT NULL
        CHECK (item_condition IN (
            'New',
            'Used',
            'Sealed',
            'Damaged',
            'Compromised'
        )),
    storage_start_date DATE NOT NULL,
    storage_end_date DATE,
    security_level TEXT NOT NULL
        CHECK (security_level IN (
            'Standard',
            'Secure',
            'High-Value',
            'Restricted'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        branch_id IS NOT NULL
        OR warehouse_id IS NOT NULL
        OR hub_id IS NOT NULL
    ),

    CHECK (
        current_quantity_level <= quantity_received
    ),

    CHECK (
        storage_end_date IS NULL
        OR storage_end_date >= storage_start_date
    ),

    FOREIGN KEY (shipment_request_item_id) REFERENCES shipment_request_items(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id)
);

-- TABLE: company_inventory

CREATE TABLE company_inventory (
    id INTEGER PRIMARY KEY,
    company_inventory_code TEXT NOT NULL UNIQUE,
    barcode TEXT NOT NULL UNIQUE,
    item_name TEXT NOT NULL,
    item_category TEXT NOT NULL,
    item_type TEXT NOT NULL,
    sku TEXT NOT NULL UNIQUE,
    unit_of_measure TEXT NOT NULL,
    quantity_received NUMERIC NOT NULL DEFAULT 0
        CHECK (quantity_received >= 0),
    reorder_level NUMERIC NOT NULL DEFAULT 0
        CHECK (reorder_level >= 0),
    reorder_quantity NUMERIC NOT NULL
        CHECK (reorder_quantity > 0),
    maximum_quantity_level NUMERIC NOT NULL
        CHECK (maximum_quantity_level > 0),
    unit_cost NUMERIC NOT NULL
        CHECK (unit_cost >= 0),
    inventory_status TEXT NOT NULL DEFAULT 'Available'
        CHECK (inventory_status IN (
            'Available',
            'Reserved',
            'Damaged',
            'Expired',
            'Discontinued'
        )),
    item_condition TEXT NOT NULL
        CHECK (item_condition IN (
            'New',
            'Used',
            'Damaged',
            'Sealed',
            'Compromised'
        )),
    storage_requirement TEXT NOT NULL,
    weight NUMERIC NOT NULL
        CHECK (weight >= 0),
    dimensions TEXT NOT NULL,
    expiry_date DATE NOT NULL,
    lot_number TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (reorder_level <= maximum_quantity_level),
    CHECK (reorder_quantity <= maximum_quantity_level)
);


-- TABLE: departments

CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    department_code TEXT NOT NULL UNIQUE,
    department_name TEXT NOT NULL UNIQUE,
    department_description TEXT NOT NULL,
    department_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (department_status IN ('Active', 'Inactive', 'Closed')),
    established_date DATE NOT NULL,
    cost_center_code TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- TABLE: tracking_events

CREATE TABLE tracking_events (
    id INTEGER PRIMARY KEY,
    shipment_request_id INTEGER NOT NULL,
    transport_asset_id INTEGER,
    employee_id INTEGER NOT NULL,
    event_code TEXT NOT NULL UNIQUE,
    event_type TEXT NOT NULL,
    event_status TEXT NOT NULL,
    estimated_date_time DATETIME,
    actual_date_time DATETIME,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    shipment_return_id INTEGER,
    location_description TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    latitude REAL CHECK (latitude BETWEEN -90 AND 90),
    longitude REAL CHECK (longitude BETWEEN -180 AND 180),
    event_sequence INTEGER NOT NULL CHECK (event_sequence > 0),
    proof_of_delivery_reference TEXT,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        actual_date_time IS NULL
        OR estimated_date_time IS NULL
        OR actual_date_time >= estimated_date_time
    ),

    CHECK (
        event_type != 'Delivered'
        OR proof_of_delivery_reference IS NOT NULL
    ),

    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (shipment_return_id) REFERENCES shipment_returns(id),

    UNIQUE (shipment_request_id, event_sequence)
);


-- TABLE: transport_assets

CREATE TABLE transport_assets (
    id INTEGER PRIMARY KEY,
    transport_asset_code TEXT NOT NULL UNIQUE,
    asset_name TEXT NOT NULL,
    asset_type TEXT NOT NULL,
    registration_number TEXT UNIQUE,
    vin_or_serial_number TEXT NOT NULL UNIQUE,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    manufacture_year INTEGER NOT NULL CHECK (manufacture_year BETWEEN 1900 AND 2100),
    acquisition_date DATE NOT NULL,
    acquisition_cost NUMERIC NOT NULL CHECK (acquisition_cost >= 0),
    ownership_type TEXT NOT NULL
        CHECK (ownership_type IN (
            'Company-Owned',
            'Leased',
            'Rented',
            'Third-Party/Contracted'
        )),
    cargo_capacity_weight NUMERIC NOT NULL CHECK (cargo_capacity_weight > 0),
    cargo_capacity_volume NUMERIC NOT NULL CHECK (cargo_capacity_volume > 0),
    fuel_type TEXT NOT NULL,
    fuel_consumption_rate NUMERIC NOT NULL CHECK (fuel_consumption_rate >= 0),
    odometer_or_usage_reading NUMERIC NOT NULL CHECK (odometer_or_usage_reading >= 0),
    asset_status TEXT NOT NULL DEFAULT 'Available'
        CHECK (asset_status IN (
            'Available',
            'Assigned',
            'In Transit',
            'Under Maintenance',
            'Out of Service',
            'Retired',
            'Decommissioned'
        )),
    last_maintenance_date DATE NOT NULL,
    next_maintenance_date DATE NOT NULL,
    insurance_expiry_date DATE NOT NULL,
    registration_expiry_date DATE NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        next_maintenance_date >= last_maintenance_date
    )
);


-- TABLE: purchase_orders

CREATE TABLE purchase_orders (
    id INTEGER PRIMARY KEY,
    purchase_order_code TEXT NOT NULL UNIQUE,
    supplier_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    purchase_order_date DATE NOT NULL,
    required_delivery_date DATE NOT NULL,
    delivery_address TEXT NOT NULL,
    warehouse_id INTEGER,
    hub_id INTEGER,
    purchase_order_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (purchase_order_status IN (
            'Draft',
            'Pending Approval',
            'Approved',
            'Sent',
            'Partially Received',
            'Fully Received',
            'Cancelled',
            'Closed'
        )),
    priority_level TEXT NOT NULL DEFAULT 'Normal'
        CHECK (priority_level IN (
            'Low',
            'Normal',
            'High',
            'Urgent'
        )),
    payment_terms TEXT NOT NULL,
    shipping_terms TEXT NOT NULL,
    shipping_cost NUMERIC NOT NULL DEFAULT 0
        CHECK (shipping_cost >= 0),
    approval_date DATE NOT NULL,
    approved_by_employee_id INTEGER NOT NULL,
    supplier_reference TEXT,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (warehouse_id IS NOT NULL) +
        (hub_id IS NOT NULL) = 1
    ),

    CHECK (
        required_delivery_date >= purchase_order_date
    ),

    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (approved_by_employee_id) REFERENCES employees(id)
);



-- TABLE: purchase_order_items

CREATE TABLE purchase_order_items (
    id INTEGER PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL,
    company_inventory_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    quantity_ordered NUMERIC NOT NULL CHECK (quantity_ordered > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
    discount_rate NUMERIC NOT NULL DEFAULT 0
        CHECK (discount_rate BETWEEN 0 AND 100),
    tax_rate NUMERIC NOT NULL DEFAULT 0
        CHECK (tax_rate BETWEEN 0 AND 100),
    requested_delivery_date DATE NOT NULL,
    item_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (item_status IN (
            'Pending',
            'Ordered',
            'Partially Received',
            'Fully Received',
            'Cancelled',
            'Closed'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (company_inventory_id) REFERENCES company_inventory(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),

    UNIQUE (purchase_order_id, company_inventory_id)
);



-- TABLE: goods_received

CREATE TABLE goods_received (
    id INTEGER PRIMARY KEY,
    purchase_order_item_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    goods_received_code TEXT NOT NULL UNIQUE,
    received_date DATE NOT NULL,
    warehouse_id INTEGER,
    hub_id INTEGER,
    quantity_received NUMERIC NOT NULL CHECK (quantity_received > 0),
    receiving_status TEXT NOT NULL
        CHECK (receiving_status IN (
            'Pending',
            'Partially Received',
            'Fully Received',
            'Rejected',
            'Discrepancy'
        )),
    item_condition TEXT NOT NULL
        CHECK (item_condition IN (
            'New',
            'Sealed',
            'Damaged',
            'Compromised',
            'Defective'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        warehouse_id IS NOT NULL
        OR hub_id IS NOT NULL
    ),

    FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id)
);


-- TABLE: inventory_transactions

CREATE TABLE inventory_transactions (
    id INTEGER PRIMARY KEY,
    transaction_code TEXT NOT NULL UNIQUE,
    company_inventory_id INTEGER NOT NULL,
    goods_received_id INTEGER,
    employee_id INTEGER NOT NULL,
    warehouse_id INTEGER,
    hub_id INTEGER,
    transaction_type TEXT NOT NULL
        CHECK (transaction_type IN (
            'Receipt',
            'Issue',
            'Transfer',
            'Return',
            'Adjustment',
            'Damage',
            'Loss',
            'Write-Off',
            'Stock Count Adjustment'
        )),
    transaction_date DATE NOT NULL,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    reason TEXT,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        warehouse_id IS NOT NULL
        OR hub_id IS NOT NULL
    ),

    FOREIGN KEY (company_inventory_id) REFERENCES company_inventory(id),
    FOREIGN KEY (goods_received_id) REFERENCES goods_received(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id)
);


-- TABLE: shipment_returns

CREATE TABLE shipment_returns (
    id INTEGER PRIMARY KEY,
    shipment_request_id INTEGER NOT NULL,
    return_code TEXT NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    return_date DATE NOT NULL,
    received_date DATE NOT NULL,
    return_address TEXT,
    warehouse_id INTEGER,
    return_status TEXT NOT NULL DEFAULT 'Initiated'
        CHECK (return_status IN (
            'Initiated',
            'In Transit',
            'Awaiting Customer',
            'Delivered',
            'Cancelled',
            'Closed'
        )),
    item_condition TEXT NOT NULL
        CHECK (item_condition IN (
            'Good',
            'Damaged',
            'Compromised',
            'Defective'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (received_date >= return_date),

    CHECK (
        (return_address IS NOT NULL)
        + (warehouse_id IS NOT NULL) = 1
    ),

    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);


-- TABLE: customer_feedbacks

CREATE TABLE customer_feedbacks (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    shipment_request_id INTEGER,
    feedback_code TEXT NOT NULL UNIQUE,
    feedback_date DATE NOT NULL,
    feedback_type TEXT NOT NULL
        CHECK (feedback_type IN (
            'Complaint',
            'Compliment',
            'Suggestion',
            'Service Review',
            'General Feedback'
        )),
    service_rating NUMERIC
        CHECK (service_rating BETWEEN 0 AND 10),
    delivery_rating NUMERIC
        CHECK (delivery_rating BETWEEN 0 AND 10),
    communication_rating NUMERIC
        CHECK (communication_rating BETWEEN 0 AND 10),
    feedback_text TEXT NOT NULL,
    response_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (response_status IN (
            'Pending',
            'Under Review',
            'Responded',
            'Resolved',
            'Closed'
        )),
    employee_id INTEGER,
    response_date DATE,
    resolution_date DATE,
    resolution_remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        response_date IS NULL
        OR response_date >= feedback_date
    ),

    CHECK (
        resolution_date IS NULL
        OR resolution_date >= feedback_date
    ),

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);


-- TABLE: payments

CREATE TABLE payments (
    id INTEGER PRIMARY KEY,
    payment_code TEXT NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    invoice_id INTEGER,
    supplier_id INTEGER,
    shipment_request_id INTEGER,
    shipment_return_id INTEGER,
    payment_date DATE NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL
        CHECK (payment_method IN (
            'Bank Transfer',
            'Card',
            'Cash',
            'Mobile Payment',
            'Electronic Payment'
        )),
    payment_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (payment_status IN (
            'Pending',
            'Successful',
            'Failed',
            'Reversed',
            'Refunded',
            'Cancelled'
        )),
    transaction_reference TEXT UNIQUE,
    employee_id INTEGER,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (shipment_return_id) REFERENCES shipment_returns(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);



-- TABLE: supplier_evaluations

CREATE TABLE supplier_evaluations (
    id INTEGER PRIMARY KEY,
    supplier_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    evaluation_code TEXT NOT NULL UNIQUE,
    evaluation_period_start DATE NOT NULL,
    evaluation_period_end DATE NOT NULL,
    delivery_performance_rating NUMERIC NOT NULL
        CHECK (delivery_performance_rating BETWEEN 0 AND 10),
    quality_rating NUMERIC NOT NULL
        CHECK (quality_rating BETWEEN 0 AND 10),
    order_accuracy_rating NUMERIC NOT NULL
        CHECK (order_accuracy_rating BETWEEN 0 AND 10),
    responsiveness_rating NUMERIC NOT NULL
        CHECK (responsiveness_rating BETWEEN 0 AND 10),
    pricing_rating NUMERIC NOT NULL
        CHECK (pricing_rating BETWEEN 0 AND 10),
    compliance_rating NUMERIC NOT NULL
        CHECK (compliance_rating BETWEEN 0 AND 10),
    insurance_compliance_rating NUMERIC NOT NULL
        CHECK (insurance_compliance_rating BETWEEN 0 AND 10),
    carbon_rating NUMERIC NOT NULL
        CHECK (carbon_rating BETWEEN 0 AND 10),
    environmental_impact_rating NUMERIC NOT NULL
        CHECK (environmental_impact_rating BETWEEN 0 AND 10),
    business_relationship_rating NUMERIC NOT NULL
        CHECK (business_relationship_rating BETWEEN 0 AND 10),
    evaluation_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (evaluation_status IN (
            'Draft',
            'Completed',
            'Reviewed',
            'Approved'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        evaluation_period_end >= evaluation_period_start
    ),

    UNIQUE (
        supplier_id,
        evaluation_period_start,
        evaluation_period_end
    ),

    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);


-- TABLE: budgets

CREATE TABLE budgets (
    id INTEGER PRIMARY KEY,
    budget_code TEXT NOT NULL UNIQUE,
    department_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    budget_period_start DATE NOT NULL,
    budget_period_end DATE NOT NULL,
    budget_category TEXT NOT NULL
        CHECK (budget_category IN (
            'Transportation',
            'Fuel',
            'Warehouse Operations',
            'Procurement',
            'Maintenance',
            'Packaging',
            'Technology',
            'Administration'
        )),
    budget_amount NUMERIC NOT NULL CHECK (budget_amount >= 0),
    budget_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (budget_status IN (
            'Draft',
            'Proposed',
            'Approved',
            'Active',
            'Suspended',
            'Closed'
        )),
    approval_date DATE NOT NULL,
    approved_by_employee_id INTEGER NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        budget_period_end >= budget_period_start
    ),

    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (approved_by_employee_id) REFERENCES employees(id)
);


-- TABLE: expenses

CREATE TABLE expenses (
    id INTEGER PRIMARY KEY,
    expense_code TEXT NOT NULL UNIQUE,
    department_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    expense_date DATE NOT NULL,
    expense_type TEXT NOT NULL
        CHECK (expense_type IN (
            'Fuel',
            'Maintenance',
            'Warehouse Operations',
            'Packaging',
            'Utilities',
            'Procurement',
            'Transportation',
            'Insurance',
            'Technology',
            'Administration'
        )),
    expense_description TEXT NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL
        CHECK (payment_method IN (
            'Bank Transfer',
            'Card',
            'Cash',
            'Electronic Payment'
        )),
    payment_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (payment_status IN (
            'Pending',
            'Paid',
            'Reimbursed',
            'Rejected',
            'Cancelled'
        )),
    budget_id INTEGER,
    purchase_order_id INTEGER,
    transport_asset_id INTEGER,
    receipt_reference TEXT NOT NULL,
    approval_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (approval_status IN (
            'Pending',
            'Approved',
            'Rejected',
            'Cancelled'
        )),
    approved_by_employee_id INTEGER NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (budget_id) REFERENCES budgets(id),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id),
    FOREIGN KEY (approved_by_employee_id) REFERENCES employees(id)
);


-- TABLE: environmental_impact_assessments

CREATE TABLE environmental_impact_assessments (
    id INTEGER PRIMARY KEY,
    assessment_code TEXT NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    assessment_scope TEXT NOT NULL
        CHECK (assessment_scope IN (
            'Supplier',
            'Department',
            'Branch',
            'Warehouse',
            'Hub',
            'Transport Asset',
            'Company Operations'
        )),
    supplier_id INTEGER,
    department_id INTEGER,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    transport_asset_id INTEGER,
    assessment_date DATE NOT NULL,
    assessment_period_start DATE NOT NULL,
    assessment_period_end DATE NOT NULL,
    carbon_impact_rating NUMERIC NOT NULL
        CHECK (carbon_impact_rating BETWEEN 0 AND 10),
    waste_management_rating NUMERIC NOT NULL
        CHECK (waste_management_rating BETWEEN 0 AND 10),
    resource_efficiency_rating NUMERIC NOT NULL
        CHECK (resource_efficiency_rating BETWEEN 0 AND 10),
    pollution_control_rating NUMERIC NOT NULL
        CHECK (pollution_control_rating BETWEEN 0 AND 10),
    environmental_compliance_rating NUMERIC NOT NULL
        CHECK (environmental_compliance_rating BETWEEN 0 AND 10),
    overall_impact_rating NUMERIC NOT NULL
        CHECK (overall_impact_rating BETWEEN 0 AND 10),
    assessment_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (assessment_status IN (
            'Draft',
            'In Progress',
            'Completed',
            'Reviewed',
            'Approved'
        )),
    recommendations TEXT NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (assessment_period_end >= assessment_period_start),

    CHECK (
        (assessment_scope = 'Supplier' AND supplier_id IS NOT NULL)
        OR
        (assessment_scope <> 'Supplier' AND supplier_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Department' AND department_id IS NOT NULL)
        OR
        (assessment_scope <> 'Department' AND department_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Branch' AND branch_id IS NOT NULL)
        OR
        (assessment_scope <> 'Branch' AND branch_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Warehouse' AND warehouse_id IS NOT NULL)
        OR
        (assessment_scope <> 'Warehouse' AND warehouse_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Hub' AND hub_id IS NOT NULL)
        OR
        (assessment_scope <> 'Hub' AND hub_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Transport Asset' AND transport_asset_id IS NOT NULL)
        OR
        (assessment_scope <> 'Transport Asset' AND transport_asset_id IS NULL)
    ),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id)
);


-- TABLE: compliance_assessments

CREATE TABLE compliance_assessments (
    id INTEGER PRIMARY KEY,
    assessment_code TEXT NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    assessment_scope TEXT NOT NULL
        CHECK (assessment_scope IN (
            'Supplier',
            'Department',
            'Branch',
            'Warehouse',
            'Hub',
            'Transport Asset',
            'Company Operations'
        )),
    supplier_id INTEGER,
    department_id INTEGER,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    transport_asset_id INTEGER,
    assessment_date DATE NOT NULL,
    assessment_period_start DATE NOT NULL,
    assessment_period_end DATE NOT NULL,
    compliance_type TEXT NOT NULL
        CHECK (compliance_type IN (
            'Regulatory',
            'Contractual',
            'Safety',
            'Environmental',
            'Operational',
            'Documentation',
            'Internal Policy'
        )),
    requirement_description TEXT NOT NULL,
    compliance_status TEXT NOT NULL
        CHECK (compliance_status IN (
            'Compliant',
            'Partially Compliant',
            'Non-Compliant',
            'Pending Review',
            'Not Applicable'
        )),
    severity_level TEXT NOT NULL
        CHECK (severity_level IN (
            'Low',
            'Medium',
            'High',
            'Critical'
        )),
    corrective_action_required TEXT NOT NULL
        CHECK (corrective_action_required IN ('Yes', 'No')),
    corrective_action_deadline DATE,
    assessment_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (assessment_status IN (
            'Draft',
            'In Progress',
            'Completed',
            'Reviewed',
            'Closed'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        assessment_period_end >= assessment_period_start
    ),

    CHECK (
        corrective_action_deadline IS NULL
        OR corrective_action_deadline >= assessment_date
    ),

    CHECK (
        (assessment_scope = 'Supplier' AND supplier_id IS NOT NULL)
        OR
        (assessment_scope <> 'Supplier' AND supplier_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Department' AND department_id IS NOT NULL)
        OR
        (assessment_scope <> 'Department' AND department_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Branch' AND branch_id IS NOT NULL)
        OR
        (assessment_scope <> 'Branch' AND branch_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Warehouse' AND warehouse_id IS NOT NULL)
        OR
        (assessment_scope <> 'Warehouse' AND warehouse_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Hub' AND hub_id IS NOT NULL)
        OR
        (assessment_scope <> 'Hub' AND hub_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Transport Asset' AND transport_asset_id IS NOT NULL)
        OR
        (assessment_scope <> 'Transport Asset' AND transport_asset_id IS NULL)
    ),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id)
);


-- TABLE: risk_assessments

CREATE TABLE risk_assessments (
    id INTEGER PRIMARY KEY,
    assessment_code TEXT NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    assessment_scope TEXT NOT NULL
        CHECK (assessment_scope IN (
            'Supplier',
            'Department',
            'Branch',
            'Warehouse',
            'Hub',
            'Transport Asset',
            'Company Operations'
        )),
    supplier_id INTEGER,
    department_id INTEGER,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    transport_asset_id INTEGER,
    assessment_date DATE NOT NULL,
    risk_type TEXT NOT NULL
        CHECK (risk_type IN (
            'Operational',
            'Transportation',
            'Warehouse',
            'Supplier',
            'Financial',
            'Safety',
            'Security',
            'Environmental',
            'Compliance'
        )),
    risk_description TEXT NOT NULL,
    likelihood_rating NUMERIC NOT NULL
        CHECK (likelihood_rating BETWEEN 0 AND 10),
    impact_rating NUMERIC NOT NULL
        CHECK (impact_rating BETWEEN 0 AND 10),
    risk_level TEXT NOT NULL
        CHECK (risk_level IN (
            'Low',
            'Medium',
            'High',
            'Critical'
        )),
    mitigation_action TEXT NOT NULL,
    responsible_employee_id INTEGER NOT NULL,
    target_resolution_date DATE NOT NULL,
    risk_status TEXT NOT NULL
        CHECK (risk_status IN (
            'Open',
            'Under Review',
            'Mitigated',
            'Accepted',
            'Transferred',
            'Closed'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (assessment_scope = 'Supplier' AND supplier_id IS NOT NULL)
        OR
        (assessment_scope <> 'Supplier' AND supplier_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Department' AND department_id IS NOT NULL)
        OR
        (assessment_scope <> 'Department' AND department_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Branch' AND branch_id IS NOT NULL)
        OR
        (assessment_scope <> 'Branch' AND branch_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Warehouse' AND warehouse_id IS NOT NULL)
        OR
        (assessment_scope <> 'Warehouse' AND warehouse_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Hub' AND hub_id IS NOT NULL)
        OR
        (assessment_scope <> 'Hub' AND hub_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Transport Asset' AND transport_asset_id IS NOT NULL)
        OR
        (assessment_scope <> 'Transport Asset' AND transport_asset_id IS NULL)
    ),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (responsible_employee_id) REFERENCES employees(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id)
);


-- TABLE: insurance_policies

CREATE TABLE insurance_policies (
    id INTEGER PRIMARY KEY,
    policy_code TEXT NOT NULL UNIQUE,
    policy_holder_type TEXT NOT NULL
        CHECK (policy_holder_type IN (
            'Supplier',
            'Company',
            'Branch',
            'Warehouse',
            'Hub',
            'Transport Asset'
        )),
    supplier_id INTEGER,
    branch_id INTEGER,
    warehouse_id INTEGER,
    hub_id INTEGER,
    transport_asset_id INTEGER,
    policy_type TEXT NOT NULL
        CHECK (policy_type IN (
            'Cargo',
            'Vehicle',
            'Liability',
            'Property',
            'Workers'' Compensation',
            'Business Insurance'
        )),
    insurance_provider TEXT NOT NULL,
    policy_number TEXT NOT NULL UNIQUE,
    coverage_description TEXT NOT NULL,
    coverage_amount NUMERIC NOT NULL
        CHECK (coverage_amount > 0),
    policy_start_date DATE NOT NULL,
    policy_expiry_date DATE NOT NULL,
    policy_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (policy_status IN (
            'Active',
            'Expired',
            'Pending Renewal',
            'Cancelled',
            'Suspended'
        )),
    verification_date DATE NOT NULL,
    verified_by_employee_id INTEGER NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (policy_expiry_date >= policy_start_date),

    CHECK (
        (policy_holder_type = 'Supplier' AND supplier_id IS NOT NULL)
        OR
        (policy_holder_type <> 'Supplier' AND supplier_id IS NULL)
    ),

    CHECK (
        (policy_holder_type = 'Branch' AND branch_id IS NOT NULL)
        OR
        (policy_holder_type <> 'Branch' AND branch_id IS NULL)
    ),

    CHECK (
        (policy_holder_type = 'Warehouse' AND warehouse_id IS NOT NULL)
        OR
        (policy_holder_type <> 'Warehouse' AND warehouse_id IS NULL)
    ),

    CHECK (
        (policy_holder_type = 'Hub' AND hub_id IS NOT NULL)
        OR
        (policy_holder_type <> 'Hub' AND hub_id IS NULL)
    ),

    CHECK (
        (policy_holder_type = 'Transport Asset' AND transport_asset_id IS NOT NULL)
        OR
        (policy_holder_type <> 'Transport Asset' AND transport_asset_id IS NULL)
    ),

    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),
    FOREIGN KEY (transport_asset_id) REFERENCES transport_assets(id),
    FOREIGN KEY (verified_by_employee_id) REFERENCES employees(id)
);


-- TABLE: service_level_assessments

CREATE TABLE service_level_assessments (
    id INTEGER PRIMARY KEY,
    assessment_code TEXT NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    assessment_scope TEXT NOT NULL
        CHECK (assessment_scope IN (
            'Shipment',
            'Customer',
            'Branch',
            'Hub',
            'Company Operations'
        )),
    customer_id INTEGER,
    shipment_request_id INTEGER,
    branch_id INTEGER,
    hub_id INTEGER,
    assessment_date DATE NOT NULL,
    assessment_period_start DATE NOT NULL,
    assessment_period_end DATE NOT NULL,
    pickup_performance_rating NUMERIC NOT NULL
        CHECK (pickup_performance_rating BETWEEN 0 AND 10),
    delivery_performance_rating NUMERIC NOT NULL
        CHECK (delivery_performance_rating BETWEEN 0 AND 10),
    timeliness_rating NUMERIC NOT NULL
        CHECK (timeliness_rating BETWEEN 0 AND 10),
    service_reliability_rating NUMERIC NOT NULL
        CHECK (service_reliability_rating BETWEEN 0 AND 10),
    service_compliance_rating NUMERIC NOT NULL
        CHECK (service_compliance_rating BETWEEN 0 AND 10),
    assessment_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (assessment_status IN (
            'Draft',
            'In Progress',
            'Completed',
            'Reviewed',
            'Approved'
        )),
    performance_result TEXT NOT NULL
        CHECK (performance_result IN (
            'Met',
            'Partially Met',
            'Not Met'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        assessment_period_end >= assessment_period_start
    ),

    CHECK (
        (assessment_scope = 'Customer' AND customer_id IS NOT NULL)
        OR
        (assessment_scope <> 'Customer' AND customer_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Shipment' AND shipment_request_id IS NOT NULL)
        OR
        (assessment_scope <> 'Shipment' AND shipment_request_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Branch' AND branch_id IS NOT NULL)
        OR
        (assessment_scope <> 'Branch' AND branch_id IS NULL)
    ),

    CHECK (
        (assessment_scope = 'Hub' AND hub_id IS NOT NULL)
        OR
        (assessment_scope <> 'Hub' AND hub_id IS NULL)
    ),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id)
);


-- TABLE: invoices

CREATE TABLE invoices (
    id INTEGER PRIMARY KEY,
    invoice_code TEXT NOT NULL UNIQUE,
    invoice_number TEXT NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    shipment_request_id INTEGER,
    shipment_return_id INTEGER,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_status TEXT NOT NULL DEFAULT 'Draft'
        CHECK (invoice_status IN (
            'Draft',
            'Issued',
            'Partially Paid',
            'Paid',
            'Overdue',
            'Cancelled',
            'Disputed'
        )),
    subtotal_amount NUMERIC NOT NULL
        CHECK (subtotal_amount >= 0),
    discount_amount NUMERIC NOT NULL DEFAULT 0
        CHECK (discount_amount >= 0),
    tax_amount NUMERIC NOT NULL DEFAULT 0
        CHECK (tax_amount >= 0),
    shipping_cost NUMERIC NOT NULL DEFAULT 0
        CHECK (shipping_cost >= 0),
    total_amount NUMERIC NOT NULL
        CHECK (total_amount >= 0),
    payment_status TEXT NOT NULL DEFAULT 'Unpaid'
        CHECK (payment_status IN (
            'Unpaid',
            'Partially Paid',
            'Paid',
            'Overdue',
            'Refunded',
            'Cancelled'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (due_date >= invoice_date),

    CHECK (
        total_amount =
        subtotal_amount
        - discount_amount
        + tax_amount
        + shipping_cost
    ),

    CHECK (
        shipment_request_id IS NOT NULL
        OR shipment_return_id IS NOT NULL
    ),

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (shipment_request_id) REFERENCES shipment_requests(id),
    FOREIGN KEY (shipment_return_id) REFERENCES shipment_returns(id)
);


-- TABLE: audit_logs

CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER,
    event_code TEXT NOT NULL UNIQUE,
    action_type TEXT NOT NULL
        CHECK (action_type IN (
            'Create',
            'Update',
            'Delete',
            'Approve',
            'Cancel',
            'Restore',
            'Status Change'
        )),
    table_name TEXT NOT NULL,
    record_id INTEGER NOT NULL CHECK (record_id > 0),
    event_date_time DATETIME NOT NULL,
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_id) REFERENCES employees(id)
);


-- TABLE: containers

CREATE TABLE containers (
    id INTEGER PRIMARY KEY,
    container_code TEXT NOT NULL UNIQUE,
    container_type TEXT NOT NULL,
    container_owner_type TEXT NOT NULL
        CHECK (container_owner_type IN (
            'Company',
            'Supplier',
            'Customer',
            'Other Authorized Party'
        )),
    supplier_id INTEGER,
    customer_id INTEGER,
    dimensions TEXT NOT NULL,
    maximum_weight_capacity NUMERIC NOT NULL
        CHECK (maximum_weight_capacity > 0),
    internal_volume NUMERIC NOT NULL
        CHECK (internal_volume > 0),
    container_status TEXT NOT NULL DEFAULT 'Available'
        CHECK (container_status IN (
            'Available',
            'In Use',
            'In Transit',
            'Under Maintenance',
            'Damaged',
            'Lost',
            'Retired'
        )),
    container_condition TEXT NOT NULL
        CHECK (container_condition IN (
            'Good',
            'Fair',
            'Damaged',
            'Unserviceable'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        (container_owner_type = 'Supplier' AND supplier_id IS NOT NULL)
        OR
        (container_owner_type <> 'Supplier' AND supplier_id IS NULL)
    ),

    CHECK (
        (container_owner_type = 'Customer' AND customer_id IS NOT NULL)
        OR
        (container_owner_type <> 'Customer' AND customer_id IS NULL)
    ),

    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);


-- TABLE: employee_leave_history

CREATE TABLE employee_leave_history (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    leave_code TEXT NOT NULL UNIQUE,
    leave_type TEXT NOT NULL
        CHECK (leave_type IN (
            'Annual',
            'Sick',
            'Maternity',
            'Paternity',
            'Bereavement',
            'Study',
            'Emergency',
            'Unpaid Leave'
        )),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    leave_status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (leave_status IN (
            'Pending',
            'Approved',
            'Rejected',
            'Cancelled',
            'Completed'
        )),
    approved_by_employee_id INTEGER NOT NULL,
    approval_date DATE NOT NULL,
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (end_date >= start_date),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (approved_by_employee_id) REFERENCES employees(id)
);


-- TABLE: employee_department_history

CREATE TABLE employee_department_history (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    assignment_start_date DATE NOT NULL,
    assignment_end_date DATE,
    assignment_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (assignment_status IN (
            'Active',
            'Transferred',
            'Ended'
        )),
    remarks TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        assignment_end_date IS NULL
        OR assignment_end_date >= assignment_start_date
    ),

    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE shipment_item_classifications (
    id INTEGER PRIMARY KEY,
    classification_code TEXT NOT NULL UNIQUE,
    classification_name TEXT NOT NULL UNIQUE,
    remarks TEXT,
    handling_requirement TEXT NOT NULL,
    storage_requirement TEXT,
    transport_restriction TEXT,
    classification_status TEXT NOT NULL DEFAULT 'Active'
        CHECK (classification_status IN (
            'Active',
            'Inactive',
            'Retired'
        )),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- TABLE: shipment_item_classification_assignment

CREATE TABLE shipment_item_classification_assignment (
    id INTEGER PRIMARY KEY,
    shipment_request_item_id INTEGER NOT NULL,
    classification_id INTEGER NOT NULL,

    FOREIGN KEY (shipment_request_item_id)
        REFERENCES shipment_request_items(id),

    FOREIGN KEY (classification_id)
        REFERENCES shipment_item_classifications(id),

    UNIQUE (
        shipment_request_item_id,
        classification_id
    )
);


-- TABLE: shipment_item_containers

CREATE TABLE shipment_item_containers (
    id INTEGER PRIMARY KEY,
    shipment_request_item_id INTEGER NOT NULL,
    container_id INTEGER NOT NULL,

    FOREIGN KEY (shipment_request_item_id)
        REFERENCES shipment_request_items(id),

    FOREIGN KEY (container_id)
        REFERENCES containers(id),

    UNIQUE (
        shipment_request_item_id,
        container_id
    )
);


-- TABLE: company_inventory_locations

CREATE TABLE company_inventory_locations (
    id INTEGER PRIMARY KEY,
    company_inventory_id INTEGER NOT NULL,
    warehouse_id INTEGER,
    hub_id INTEGER,
    storage_location TEXT,
    quantity NUMERIC NOT NULL CHECK (quantity >= 0),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        warehouse_id IS NOT NULL
        OR hub_id IS NOT NULL
    ),

    FOREIGN KEY (company_inventory_id) REFERENCES company_inventory(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (hub_id) REFERENCES hubs(id),

    UNIQUE (
        company_inventory_id,
        warehouse_id,
        hub_id,
        storage_location
    )
);



-- INDEXES
-- LSCMIS was designed with 10 indexes to improve query performance and make the retrieval of frequently accessed records more efficient.
-- Below is the schema for each index, together with its purpose.


-- INDEX: idx_shipment_request_inventory_item_id — Speeds up retrieval of inventory records associated with a specific shipment request item.

CREATE INDEX idx_shipment_request_inventory_item_id
ON Shipment_Request_Inventory(shipment_request_item_id);


-- INDEX: idx_shipment_item_classification_assignment_item_id — Improves retrieval of classifications assigned to a specific shipment request item.

CREATE INDEX idx_shipment_item_classification_assignment_item_id
ON Shipment_Item_Classification_Assignment(shipment_request_item_id);


-- INDEX: idx_shipment_item_containers_item_id — Speeds up retrieval of containers associated with a specific shipment request item.

CREATE INDEX idx_shipment_item_containers_item_id
ON Shipment_Item_Containers(shipment_request_item_id);


-- INDEX: idx_payments_invoice_id — Improves retrieval of payments associated with a specific invoice.

CREATE INDEX idx_payments_invoice_id
ON Payments(invoice_id);


-- INDEX: idx_shipment_requests_status — Speeds up filtering of shipment requests based on their current shipment status.

CREATE INDEX idx_shipment_requests_status
ON Shipment_Requests(shipment_status);


-- INDEX: idx_tracking_events_shipment_datetime — Improves retrieval of tracking events for a specific shipment and date/time analysis.

CREATE INDEX idx_tracking_events_shipment_datetime
ON Tracking_Events(shipment_request_id, actual_date_time);


-- INDEX: idx_inventory_transactions_inventory_date — Improves retrieval of inventory transactions for a specific inventory item and date-based analysis.

CREATE INDEX idx_inventory_transactions_inventory_date
ON Inventory_Transactions(company_inventory_id, transaction_date);


-- INDEX: idx_purchase_orders_supplier_status — Improves retrieval of purchase orders for a specific supplier and filtering by purchase order status.

CREATE INDEX idx_purchase_orders_supplier_status
ON Purchase_Orders(supplier_id, purchase_order_status);


-- INDEX: idx_customers_customer_type — Improves filtering and grouping of customers based on customer type.

CREATE INDEX idx_customers_customer_type
ON Customers(customer_type);


-- INDEX: idx_customers_customer_name — Improves searches and retrieval of customer records based on customer name.

CREATE INDEX idx_customers_customer_name
ON Customers(customer_name);



-- VIEWS

-- LSCMIS was designed with 9 views to help optimize recurring business operational needs.
-- Below is the schema for each view, together with its purpose.

-- VIEW: warehouse_utilization — Monitors warehouse capacity, current utilization, available capacity, and utilization status.

CREATE VIEW warehouse_utilization AS
SELECT
    id AS warehouse_id,
    warehouse_code,
    warehouse_name,
    city,
    state,
    country,
    warehouse_status,
    maximum_storage_capacity,
    current_storage_utilization,

    ROUND(
        current_storage_utilization * 100.0 /
        maximum_storage_capacity,
        2
    ) AS utilization_percentage,

    maximum_storage_capacity -
    current_storage_utilization AS available_capacity,

    CASE
        WHEN current_storage_utilization >= maximum_storage_capacity
            THEN 'At Capacity'
        WHEN current_storage_utilization >= maximum_storage_capacity * 0.90
            THEN 'Critical'
        WHEN current_storage_utilization >= maximum_storage_capacity * 0.75
            THEN 'High'
        WHEN current_storage_utilization >= maximum_storage_capacity * 0.50
            THEN 'Moderate'
        ELSE 'Available'
    END AS utilization_status

FROM warehouses
WHERE maximum_storage_capacity > 0;


-- VIEW: inventory_risk — Identifies inventory risks based on stock levels, reorder levels, damage, expiry, and item condition.


CREATE VIEW inventory_risk AS

WITH damage_summary AS (
    SELECT
        company_inventory_id,

        COALESCE(
            SUM(
                CASE
                    WHEN transaction_type = 'Damage'
                    THEN quantity
                    ELSE 0
                END
            ),
            0
        ) AS damaged_quantity

    FROM inventory_transactions

    GROUP BY company_inventory_id
),

current_stock AS (
    SELECT
        company_inventory_id,
        COALESCE(SUM(quantity), 0) AS current_quantity_level

    FROM company_inventory_locations

    GROUP BY company_inventory_id
),

inventory_metrics AS (
    SELECT
        ci.id AS inventory_id,
        ci.company_inventory_code,
        ci.item_name,
        ci.item_category,
        ci.quantity_received,

        COALESCE(
            cs.current_quantity_level,
            0
        ) AS current_quantity_level,

        ci.reorder_level,
        ci.maximum_quantity_level,
        ci.inventory_status,
        ci.item_condition,
        ci.expiry_date,
        ci.lot_number,

        COALESCE(
            ds.damaged_quantity,
            0
        ) AS damaged_quantity,

        -- Damage percentage based on quantity received
        CASE
            WHEN ci.quantity_received > 0
            THEN ROUND(
                COALESCE(ds.damaged_quantity, 0) * 100.0 /
                ci.quantity_received,
                2
            )
            ELSE 0
        END AS damaged_percentage,

        -- Expired stock for the specific inventory batch
        CASE
            WHEN ci.expiry_date IS NOT NULL
                 AND DATE(ci.expiry_date) <= DATE('now')
            THEN COALESCE(cs.current_quantity_level, 0)
            ELSE 0
        END AS expired_quantity

    FROM company_inventory ci

    LEFT JOIN damage_summary ds
        ON ds.company_inventory_id = ci.id

    LEFT JOIN current_stock cs
        ON cs.company_inventory_id = ci.id
),

risk_metrics AS (
    SELECT
        *,

        -- Expired percentage based on current stock
        CASE
            WHEN current_quantity_level > 0
            THEN ROUND(
                expired_quantity * 100.0 /
                current_quantity_level,
                2
            )
            ELSE 0
        END AS expired_percentage

    FROM inventory_metrics
),

classified_inventory AS (
    SELECT
        *,

        -- Independent stock-level classification
        CASE
            WHEN current_quantity_level <= reorder_level
                THEN 'Low Stock'

            WHEN current_quantity_level >= maximum_quantity_level
                THEN 'Overstocked'

            ELSE 'Within Range'
        END AS stock_level_status,

        -- Independent expiry risk classification
        CASE
            WHEN expired_percentage >= 10
                THEN 'Critical'

            WHEN expired_percentage > 0
                THEN 'Attention Required'

            ELSE 'No Expiry Risk'
        END AS expiry_risk_status,

        -- Independent damage risk classification
        CASE
            WHEN damaged_percentage >= 10
                THEN 'Critical'

            WHEN damaged_percentage > 0
                THEN 'Attention Required'

            ELSE 'No Recorded Damage'
        END AS damage_risk_status

    FROM risk_metrics
)

SELECT
    inventory_id,
    company_inventory_code,
    item_name,
    item_category,
    quantity_received,
    current_quantity_level,
    reorder_level,
    maximum_quantity_level,

    -- Stock-level classification
    stock_level_status,

    inventory_status,
    item_condition,
    expiry_date,
    lot_number,

    -- Damage metrics
    damaged_quantity,
    damaged_percentage,

    -- Expiry metrics
    expired_quantity,
    expired_percentage,
    expiry_risk_status,

    -- Damage risk classification
    damage_risk_status,

    -- Combined summary of inventory risk
    CASE
        WHEN damage_risk_status = 'Critical'
             OR expiry_risk_status = 'Critical'
            THEN 'Critical'

        WHEN damage_risk_status = 'Attention Required'
             OR expiry_risk_status = 'Attention Required'
            THEN 'Attention Required'

        WHEN stock_level_status = 'Low Stock'
            THEN 'Low Stock'

        WHEN stock_level_status = 'Overstocked'
            THEN 'Overstocked'

        ELSE 'Normal'
    END AS inventory_risk_status

FROM classified_inventory;


-- VIEW: cash_flow_monitoring — Monitors cash inflows and outflows to provide an overview of the company’s cash-flow position.

CREATE VIEW cash_flow_monitoring AS
WITH inflows AS (
    SELECT
        payment_date AS flow_date,
        COALESCE(SUM(amount), 0) AS cash_inflow

    FROM payments

    WHERE payment_status = 'Successful'

    GROUP BY payment_date
),

outflows AS (
    SELECT
        expense_date AS flow_date,
        COALESCE(SUM(amount), 0) AS cash_outflow

    FROM expenses

    WHERE payment_status = 'Paid'

    GROUP BY expense_date
),

flow_dates AS (
    SELECT flow_date
    FROM inflows

    UNION

    SELECT flow_date
    FROM outflows
)

SELECT
    fd.flow_date,

    COALESCE(i.cash_inflow, 0)
        AS cash_inflow,

    COALESCE(o.cash_outflow, 0)
        AS cash_outflow,

    ROUND(
        COALESCE(i.cash_inflow, 0) -
        COALESCE(o.cash_outflow, 0),
        2
    ) AS net_cash_flow,

    CASE
        WHEN COALESCE(i.cash_inflow, 0) >
             COALESCE(o.cash_outflow, 0)
            THEN 'Positive'

        WHEN COALESCE(i.cash_inflow, 0) <
             COALESCE(o.cash_outflow, 0)
            THEN 'Negative'

        ELSE 'Balanced'
    END AS cash_flow_status

FROM flow_dates fd

LEFT JOIN inflows i
    ON i.flow_date = fd.flow_date

LEFT JOIN outflows o
    ON o.flow_date = fd.flow_date;


-- VIEW: transport_asset_liability — Monitors transport assets and their related liabilities, including maintenance, insurance, and registration.

CREATE VIEW transport_asset_liability AS
SELECT
    ta.id AS transport_asset_id,
    ta.transport_asset_code,
    ta.asset_name,
    ta.asset_type,
    ta.asset_status,
    ta.acquisition_cost,

    COALESCE(
        e.total_transport_expenses,
        0
    ) AS total_transport_expenses,

    COALESCE(
        i.total_insurance_coverage,
        0
    ) AS total_insurance_coverage,

    ROUND(
        ta.acquisition_cost +
        COALESCE(e.total_transport_expenses, 0),
        2
    ) AS total_asset_financial_exposure,

    ROUND(
        MAX(
            (
                ta.acquisition_cost +
                COALESCE(e.total_transport_expenses, 0)
            ) -
            COALESCE(i.total_insurance_coverage, 0),
            0
        ),
        2
    ) AS estimated_uninsured_exposure,

    CASE
        WHEN COALESCE(i.total_insurance_coverage, 0) = 0
            THEN 'Uninsured'

        WHEN COALESCE(i.total_insurance_coverage, 0) <
             (
                 ta.acquisition_cost +
                 COALESCE(e.total_transport_expenses, 0)
             )
            THEN 'Partially Insured'

        ELSE 'Fully Insured'
    END AS insurance_coverage_status

FROM transport_assets ta

LEFT JOIN (
    SELECT
        transport_asset_id,
        COALESCE(SUM(amount), 0)
            AS total_transport_expenses

    FROM expenses

    WHERE transport_asset_id IS NOT NULL
      AND payment_status = 'Paid'

    GROUP BY transport_asset_id
) e
    ON e.transport_asset_id = ta.id

LEFT JOIN (
    SELECT
        transport_asset_id,
        COALESCE(SUM(coverage_amount), 0)
            AS total_insurance_coverage

    FROM insurance_policies

    WHERE transport_asset_id IS NOT NULL
      AND policy_holder_type = 'Transport Asset'
      AND policy_type = 'Vehicle'
      AND policy_status = 'Active'
      AND DATE(policy_start_date) <= DATE('now')
      AND DATE(policy_expiry_date) >= DATE('now')

    GROUP BY transport_asset_id
) i
    ON i.transport_asset_id = ta.id;


-- VIEW: supplier_performance — Evaluates supplier performance based on procurement, delivery, and receiving information.

CREATE VIEW supplier_performance AS
WITH evaluations AS (
    SELECT
        supplier_id,
        COUNT(*) AS evaluation_count,

        ROUND(
            AVG(delivery_performance_rating),
            2
        ) AS avg_delivery_rating,

        ROUND(
            AVG(quality_rating),
            2
        ) AS avg_quality_rating,

        ROUND(
            AVG(order_accuracy_rating),
            2
        ) AS avg_order_accuracy_rating,

        ROUND(
            AVG(responsiveness_rating),
            2
        ) AS avg_responsiveness_rating,

        ROUND(
            AVG(pricing_rating),
            2
        ) AS avg_pricing_rating,

        ROUND(
            AVG(compliance_rating),
            2
        ) AS avg_compliance_rating,

        ROUND(
            AVG(business_relationship_rating),
            2
        ) AS avg_business_relationship_rating

    FROM supplier_evaluations

    WHERE evaluation_status IN (
        'Completed',
        'Reviewed',
        'Approved'
    )

    GROUP BY supplier_id
),

orders AS (
    SELECT
        po.supplier_id,

        COUNT(*) AS purchase_order_count,

        COALESCE(SUM(
            (
                SELECT COALESCE(SUM(
                    poi.quantity_ordered * poi.unit_price
                ), 0)

                FROM purchase_order_items poi

                WHERE poi.purchase_order_id = po.id
            )
        ), 0) AS purchase_value,

        COUNT(
            CASE
                WHEN po.purchase_order_status IN (
                    'Fully Received',
                    'Closed'
                )
                THEN 1
            END
        ) AS completed_orders

    FROM purchase_orders po

    GROUP BY po.supplier_id
),

receiving AS (
    SELECT
        po.supplier_id,

        COALESCE(
            SUM(gr.quantity_received),
            0
        ) AS quantity_received,

        COUNT(gr.id)
            AS receiving_records,

        COUNT(
            CASE
                WHEN gr.item_condition IN (
                    'Damaged',
                    'Defective'
                )
                OR gr.receiving_status = 'Rejected'
                THEN 1
            END
        ) AS damaged_or_rejected_receipts

    FROM purchase_orders po

    JOIN purchase_order_items poi
        ON poi.purchase_order_id = po.id

    JOIN goods_received gr
        ON gr.purchase_order_item_id = poi.id

    GROUP BY po.supplier_id
)

SELECT
    s.id AS supplier_id,
    s.supplier_code,
    s.company_name,
    s.supplier_type,
    s.supplier_status,
    s.supplier_rating,
    s.lead_time_days,
    s.supplier_risk_level_assessment,

    COALESCE(
        e.evaluation_count,
        0
    ) AS evaluation_count,

    e.avg_delivery_rating,
    e.avg_quality_rating,
    e.avg_order_accuracy_rating,
    e.avg_responsiveness_rating,
    e.avg_pricing_rating,
    e.avg_compliance_rating,
    e.avg_business_relationship_rating,

    COALESCE(
        o.purchase_order_count,
        0
    ) AS purchase_order_count,

    COALESCE(
        o.purchase_value,
        0
    ) AS purchase_value,

    COALESCE(
        o.completed_orders,
        0
    ) AS completed_orders,

    COALESCE(
        r.quantity_received,
        0
    ) AS quantity_received,

    COALESCE(
        r.receiving_records,
        0
    ) AS receiving_records,

    COALESCE(
        r.damaged_or_rejected_receipts,
        0
    ) AS damaged_or_rejected_receipts,

    CASE
        WHEN COALESCE(r.receiving_records, 0) > 0
        THEN ROUND(
            r.damaged_or_rejected_receipts * 100.0 /
            r.receiving_records,
            2
        )
        ELSE 0
    END AS damaged_rejection_rate

FROM suppliers s

LEFT JOIN evaluations e
    ON e.supplier_id = s.id

LEFT JOIN orders o
    ON o.supplier_id = s.id

LEFT JOIN receiving r
    ON r.supplier_id = s.id;


-- VIEW: customer_satisfaction — Provides information for monitoring customer satisfaction based on customer feedback and related service information.

CREATE VIEW customer_satisfaction AS
WITH feedback_summary AS (
    SELECT
        cf.customer_id,

        COUNT(cf.id) AS feedback_count,

        ROUND(
            AVG(cf.service_rating),
            2
        ) AS average_service_rating,

        ROUND(
            AVG(cf.delivery_rating),
            2
        ) AS average_delivery_rating,

        ROUND(
            AVG(cf.communication_rating),
            2
        ) AS average_communication_rating,

        ROUND(
            AVG(
                CASE
                    WHEN cf.service_rating IS NOT NULL
                      OR cf.delivery_rating IS NOT NULL
                      OR cf.communication_rating IS NOT NULL
                    THEN (
                        COALESCE(cf.service_rating, 0) +
                        COALESCE(cf.delivery_rating, 0) +
                        COALESCE(cf.communication_rating, 0)
                    ) * 1.0 /
                    (
                        CASE
                            WHEN cf.service_rating IS NOT NULL
                            THEN 1
                            ELSE 0
                        END +
                        CASE
                            WHEN cf.delivery_rating IS NOT NULL
                            THEN 1
                            ELSE 0
                        END +
                        CASE
                            WHEN cf.communication_rating IS NOT NULL
                            THEN 1
                            ELSE 0
                        END
                    )
                END
            ),
            2
        ) AS overall_average_rating,

        COUNT(
            CASE
                WHEN cf.feedback_type = 'Complaint'
                THEN 1
            END
        ) AS complaint_count,

        COUNT(
            CASE
                WHEN cf.response_status IN (
                    'Pending',
                    'Under Review'
                )
                THEN 1
            END
        ) AS unresolved_feedback_count

    FROM customer_feedbacks cf

    GROUP BY cf.customer_id
)

SELECT
    c.id AS customer_id,
    c.customer_code,
    c.customer_name,

    COALESCE(
        fs.feedback_count,
        0
    ) AS feedback_count,

    fs.average_service_rating,
    fs.average_delivery_rating,
    fs.average_communication_rating,
    fs.overall_average_rating,

    COALESCE(
        fs.complaint_count,
        0
    ) AS complaint_count,

    COALESCE(
        fs.unresolved_feedback_count,
        0
    ) AS unresolved_feedback_count,

    CASE
        WHEN COALESCE(fs.feedback_count, 0) = 0
            THEN 'No Feedback'

        WHEN fs.overall_average_rating >= 4
            THEN 'Satisfied'

        WHEN fs.overall_average_rating >= 3
            THEN 'Neutral'

        ELSE 'Dissatisfied'
    END AS satisfaction_status

FROM customers c

LEFT JOIN feedback_summary fs
    ON fs.customer_id = c.id;


-- VIEW: inventory_movement — Tracks inventory movements, including receipts, returns, issues, damage, losses, and write-offs.

CREATE VIEW inventory_movement AS
SELECT
    ci.id AS inventory_id,
    ci.company_inventory_code,
    ci.item_name,
    ci.item_category,

    COUNT(it.id) AS transaction_count,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type IN (
                'Receipt',
                'Return'
            )
            THEN it.quantity
            ELSE 0
        END
    ), 0) AS quantity_received_or_returned,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'Issue'
            THEN it.quantity
            ELSE 0
        END
    ), 0) AS quantity_issued,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'Damage'
            THEN it.quantity
            ELSE 0
        END
    ), 0) AS quantity_damaged,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'Loss'
            THEN it.quantity
            ELSE 0
        END
    ), 0) AS quantity_lost,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type = 'Write-Off'
            THEN it.quantity
            ELSE 0
        END
    ), 0) AS quantity_written_off,

    COALESCE(SUM(
        CASE
            WHEN it.transaction_type IN (
                'Receipt',
                'Return'
            )
            THEN it.quantity

            WHEN it.transaction_type IN (
                'Issue',
                'Damage',
                'Loss',
                'Write-Off'
            )
            THEN -it.quantity

            ELSE 0
        END
    ), 0) AS net_inventory_movement,

    MIN(it.transaction_date)
        AS first_transaction_date,

    MAX(it.transaction_date)
        AS latest_transaction_date

FROM company_inventory ci

LEFT JOIN inventory_transactions it
    ON it.company_inventory_id = ci.id

GROUP BY
    ci.id,
    ci.company_inventory_code,
    ci.item_name,
    ci.item_category;


-- VIEW: department_budget_expenses_performance — Compares departmental budgets with actual expenses to monitor budget utilization and spending performance.

CREATE VIEW department_budget_expenses_performance AS
WITH budget_summary AS (
    SELECT
        department_id,
        COALESCE(
            SUM(budget_amount),
            0
        ) AS total_budget
    FROM budgets
    GROUP BY department_id
),

expense_summary AS (
    SELECT
        department_id,

        COALESCE(SUM(
            CASE
                WHEN approval_status = 'Approved'
                THEN amount
                ELSE 0
            END
        ), 0) AS approved_expenses,

        COALESCE(SUM(
            CASE
                WHEN approval_status = 'Approved'
                AND payment_status IN ('Paid', 'Reimbursed')
                THEN amount
                ELSE 0
            END
        ), 0) AS paid_approved_expenses,

        COALESCE(SUM(
            CASE
                WHEN approval_status = 'Approved'
                AND payment_status = 'Pending'
                THEN amount
                ELSE 0
            END
        ), 0) AS unpaid_approved_expenses

    FROM expenses
    GROUP BY department_id
)

SELECT
    d.id AS department_id,
    d.department_code,
    d.department_name,

    COALESCE(
        b.total_budget,
        0
    ) AS total_budget,

    COALESCE(
        e.approved_expenses,
        0
    ) AS approved_expenses,

    COALESCE(
        e.paid_approved_expenses,
        0
    ) AS paid_approved_expenses,

    COALESCE(
        e.unpaid_approved_expenses,
        0
    ) AS unpaid_approved_expenses,

    ROUND(
        COALESCE(b.total_budget, 0)
        - COALESCE(e.approved_expenses, 0),
        2
    ) AS remaining_budget,

    ROUND(
        CASE
            WHEN COALESCE(b.total_budget, 0) > 0
            THEN (
                COALESCE(e.approved_expenses, 0) * 100.0
            ) / b.total_budget
            ELSE 0
        END,
        2
    ) AS budget_utilization_percentage,

    CASE
        WHEN COALESCE(b.total_budget, 0) = 0
            THEN 'No Budget'

        WHEN COALESCE(e.approved_expenses, 0)
            > b.total_budget
            THEN 'Over Budget'

        WHEN COALESCE(e.approved_expenses, 0)
            >= b.total_budget * 0.90
            THEN 'Critical'

        WHEN COALESCE(e.approved_expenses, 0)
            >= b.total_budget * 0.75
            THEN 'High'

        ELSE 'Within Budget'
    END AS budget_status

FROM departments d

LEFT JOIN budget_summary b
    ON b.department_id = d.id

LEFT JOIN expense_summary e
    ON e.department_id = d.id;


-- VIEW: shipment_performance — Analyses shipment performance by monitoring delivery activities, delays, and service-level performance.

CREATE VIEW shipment_performance AS
WITH item_summary AS (
    SELECT
        shipment_request_id,
        COUNT(*) AS item_count,
        COALESCE(
            SUM(quantity),
            0
        ) AS total_item_quantity,

        COALESCE(
            SUM(declared_value),
            0
        ) AS total_declared_value,

        COALESCE(
            SUM(declared_weight),
            0
        ) AS total_declared_weight

    FROM shipment_request_items

    GROUP BY shipment_request_id
),

tracking_summary AS (
    SELECT
        shipment_request_id,
        COUNT(*) AS tracking_event_count,
        COUNT(
            DISTINCT transport_asset_id
        ) AS transport_asset_count

    FROM tracking_events

    GROUP BY shipment_request_id
)

SELECT
    sr.id AS shipment_id,
    sr.shipment_request_code,
    sr.customer_id,
    c.customer_name,

    sr.branch_id AS processing_branch_id,
    b.branch_name AS processing_branch,

    sr.destination_branch_id,
    db.branch_name AS destination_branch,

    sr.destination_hub_id,
    h.hub_name AS destination_hub,

    sr.request_date,
    sr.requested_pickup_date,
    sr.actual_pickup_date,
    sr.requested_delivery_date,
    sr.actual_delivery_date,

    sr.shipment_service_level,
    sr.shipment_type,
    sr.shipment_status,

    COALESCE(
        i.item_count,
        0
    ) AS item_count,

    COALESCE(
        i.total_item_quantity,
        0
    ) AS total_item_quantity,

    COALESCE(
        i.total_declared_value,
        0
    ) AS total_declared_value,

    COALESCE(
        i.total_declared_weight,
        0
    ) AS total_declared_weight,

    COALESCE(
        t.tracking_event_count,
        0
    ) AS tracking_event_count,

    COALESCE(
        t.transport_asset_count,
        0
    ) AS transport_asset_count,

    CASE
        WHEN sr.actual_delivery_date IS NOT NULL
             AND sr.requested_delivery_date IS NOT NULL
             AND DATE(sr.actual_delivery_date) >
                 DATE(sr.requested_delivery_date)
        THEN ROUND(
            julianday(sr.actual_delivery_date) -
            julianday(sr.requested_delivery_date),
            2
        )

        WHEN sr.actual_delivery_date IS NULL
             AND sr.requested_delivery_date IS NOT NULL
             AND sr.shipment_status NOT IN (
                 'Delivered',
                 'Cancelled'
             )
             AND DATE('now') >
                 DATE(sr.requested_delivery_date)
        THEN ROUND(
            julianday('now') -
            julianday(sr.requested_delivery_date),
            2
        )

        ELSE 0
    END AS delivery_delay_days,

    CASE
        WHEN sr.actual_delivery_date IS NOT NULL
             AND sr.requested_delivery_date IS NOT NULL
             AND DATE(sr.actual_delivery_date) <=
                 DATE(sr.requested_delivery_date)
        THEN 'On Time'

        WHEN sr.actual_delivery_date IS NOT NULL
             AND sr.requested_delivery_date IS NOT NULL
             AND DATE(sr.actual_delivery_date) >
                 DATE(sr.requested_delivery_date)
        THEN 'Delayed'

        WHEN sr.actual_delivery_date IS NULL
             AND sr.requested_delivery_date IS NOT NULL
             AND sr.shipment_status NOT IN (
                 'Delivered',
                 'Cancelled'
             )
             AND DATE('now') >
                 DATE(sr.requested_delivery_date)
        THEN 'Currently Delayed'

        ELSE 'Pending'
    END AS delivery_performance

FROM shipment_requests sr

JOIN customers c
    ON c.id = sr.customer_id

JOIN branches b
    ON b.id = sr.branch_id

LEFT JOIN branches db
    ON db.id = sr.destination_branch_id

LEFT JOIN hubs h
    ON h.id = sr.destination_hub_id

LEFT JOIN item_summary i
    ON i.shipment_request_id = sr.id

LEFT JOIN tracking_summary t
    ON t.shipment_request_id = sr.id;



-- TRIGGERS
-- LSCMIS was designed with 14 triggers to help automation of key business operations.
-- Below is the schema for each trigger, together with its purpose.

-- TRIGGER: trg_risk_assessment_immediate_action — Automatically records high or critical risk assessments that require management attention.

CREATE TRIGGER trg_risk_assessment_immediate_action
AFTER INSERT ON risk_assessments
WHEN NEW.risk_level IN ('High', 'Critical')
     AND NEW.risk_status IN ('Open', 'Under Review')
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.responsible_employee_id,
        'RISK-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Create',
        'risk_assessments',
        NEW.id,
        CURRENT_TIMESTAMP,
        NULL,
        NEW.risk_level || ' / ' || NEW.risk_status,
        'Management attention required for high or critical risk'
    );
END;


-- TRIGGER: trg_compliance_assessment_immediate_action — Automatically records significant non-compliance cases that require corrective action.

CREATE TRIGGER trg_compliance_assessment_immediate_action
AFTER INSERT ON compliance_assessments
WHEN NEW.compliance_status = 'Non-Compliant'
     AND NEW.severity_level IN ('High', 'Critical')
     AND NEW.corrective_action_required = 'Yes'
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.employee_id,
        'COMPLIANCE-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Create',
        'compliance_assessments',
        NEW.id,
        CURRENT_TIMESTAMP,
        NULL,
        NEW.compliance_status || ' / ' || NEW.severity_level,
        'Immediate management attention required for significant non-compliance'
    );
END;


-- TRIGGER: trg_insurance_policy_immediate_action — Automatically monitors insurance policies for expiry and pending renewal conditions.

CREATE TRIGGER trg_insurance_policy_immediate_action
AFTER UPDATE OF policy_status, policy_expiry_date
ON insurance_policies
WHEN (
        OLD.policy_status <> NEW.policy_status
        AND NEW.policy_status IN ('Expired', 'Pending Renewal')
    )
    OR (
        OLD.policy_expiry_date >= DATE('now')
        AND NEW.policy_expiry_date < DATE('now')
    )
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.verified_by_employee_id,
        'INSURANCE-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Update',
        'insurance_policies',
        NEW.id,
        CURRENT_TIMESTAMP,
        OLD.policy_status || ' / ' || OLD.policy_expiry_date,
        NEW.policy_status || ' / ' || NEW.policy_expiry_date,
        'Management attention required for insurance policy expiry or renewal'
    );
END;


-- TRIGGER:trg_environmental_impact_immediate_action — Automatically records environmental assessments that require management attention.

CREATE TRIGGER trg_environmental_impact_immediate_action
AFTER INSERT ON environmental_impact_assessments
WHEN NEW.overall_impact_rating < 5
     AND NEW.assessment_status IN ('Completed', 'Reviewed')
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.employee_id,
        'ENVIRONMENT-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Create',
        'environmental_impact_assessments',
        NEW.id,
        CURRENT_TIMESTAMP,
        NULL,
        'Overall Impact Rating: ' || NEW.overall_impact_rating,
        'Management attention required for poor environmental performance'
    );
END;


-- TRIGGER: trg_transport_asset_critical_condition — Automatically monitors critical transport asset conditions, expired insurance or registration, and overdue maintenance.

CREATE TRIGGER trg_transport_asset_critical_condition
AFTER UPDATE OF
    next_maintenance_date,
    insurance_expiry_date,
    registration_expiry_date,
    asset_status
ON transport_assets
WHEN (
        NEW.asset_status IN (
            'Under Maintenance',
            'Out of Service',
            'Retired',
            'Decommissioned'
        )
        AND OLD.asset_status NOT IN (
            'Under Maintenance',
            'Out of Service',
            'Retired',
            'Decommissioned'
        )
    )
    OR (
        NEW.insurance_expiry_date < DATE('now')
        AND OLD.insurance_expiry_date >= DATE('now')
    )
    OR (
        NEW.registration_expiry_date < DATE('now')
        AND OLD.registration_expiry_date >= DATE('now')
    )
    OR (
        NEW.next_maintenance_date < DATE('now')
        AND OLD.next_maintenance_date >= DATE('now')
    )
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NULL,
        'ASSET-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Update',
        'transport_assets',
        NEW.id,
        CURRENT_TIMESTAMP,
        OLD.asset_status,
        NEW.asset_status,
        'Management attention required for transport asset condition'
    );
END;


-- TRIGGER: trg_expiring_inventory_status — Automatically changes company inventory_status to expired when its expiry date is reached or passed.

CREATE TRIGGER trg_expiring_inventory_status
AFTER UPDATE OF expiry_date
ON company_inventory
WHEN NEW.expiry_date <= DATE('now')
     AND NEW.inventory_status = 'Available'
BEGIN
    UPDATE company_inventory
    SET inventory_status = 'Expired',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
END;


-- TRIGGER: trg_employee_department_history — Automatically updates employee department history when an employee is transferred to another department.

CREATE TRIGGER trg_employee_department_history
AFTER UPDATE OF department_id
ON employees
WHEN OLD.department_id <> NEW.department_id
BEGIN
    UPDATE employee_department_history
    SET assignment_end_date = DATE('now'),
        assignment_status = 'Transferred',
        updated_at = CURRENT_TIMESTAMP
    WHERE employee_id = NEW.id
      AND assignment_status = 'Active';

    INSERT INTO employee_department_history (
        employee_id,
        department_id,
        assignment_start_date,
        assignment_status,
        remarks,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.department_id,
        DATE('now'),
        'Active',
        'Department assignment automatically created following employee transfer',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
END;


-- TRIGGER: trg_critical_payment_change_audit — Automatically records significant changes in payment status for audit purposes.

CREATE TRIGGER trg_critical_payment_change_audit
AFTER UPDATE OF payment_status
ON payments
WHEN OLD.payment_status <> NEW.payment_status
     AND NEW.payment_status IN (
         'Successful',
         'Reversed',
         'Refunded',
         'Cancelled'
     )
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.employee_id,
        'PAYMENT-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Status Change',
        'payments',
        NEW.id,
        CURRENT_TIMESTAMP,
        OLD.payment_status,
        NEW.payment_status,
        'Critical payment status change automatically recorded'
    );
END;


-- TRIGGER: trg_inventory_transaction_synchronization — Automatically updates inventory-location quantities when qualifying inventory transactions occur.

CREATE TRIGGER trg_inventory_transaction_synchronization
AFTER INSERT ON inventory_transactions
WHEN NEW.transaction_type IN (
    'Receipt',
    'Return',
    'Issue',
    'Damage',
    'Loss',
    'Write-Off'
)
BEGIN
    SELECT CASE
        WHEN (
            NEW.warehouse_id IS NOT NULL
            AND NEW.hub_id IS NOT NULL
        )
        OR (
            NEW.warehouse_id IS NULL
            AND NEW.hub_id IS NULL
        )
        THEN RAISE(
            ABORT,
            'Inventory transaction must identify exactly one warehouse or hub'
        )
    END;

    UPDATE company_inventory_locations
    SET quantity = CASE
        WHEN NEW.transaction_type IN ('Receipt', 'Return')
            THEN quantity + NEW.quantity
        WHEN NEW.transaction_type IN (
            'Issue',
            'Damage',
            'Loss',
            'Write-Off'
        )
            THEN quantity - NEW.quantity
    END,
    updated_at = CURRENT_TIMESTAMP
    WHERE company_inventory_id = NEW.company_inventory_id
      AND (
          (
              NEW.warehouse_id IS NOT NULL
              AND warehouse_id = NEW.warehouse_id
              AND hub_id IS NULL
          )
          OR (
              NEW.hub_id IS NOT NULL
              AND hub_id = NEW.hub_id
              AND warehouse_id IS NULL
          )
      );

    SELECT CASE
        WHEN changes() = 0
        AND NEW.transaction_type IN (
            'Issue',
            'Damage',
            'Loss',
            'Write-Off'
        )
        THEN RAISE(
            ABORT,
            'Inventory location not found for stock reduction'
        )
    END;

    INSERT INTO company_inventory_locations (
        company_inventory_id,
        warehouse_id,
        hub_id,
        quantity,
        created_at,
        updated_at
    )
    SELECT
        NEW.company_inventory_id,
        NEW.warehouse_id,
        NEW.hub_id,
        NEW.quantity,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    WHERE changes() = 0
      AND NEW.transaction_type IN ('Receipt', 'Return');
END;


-- TRIGGER: trg_purchase_order_receiving_status — Automatically updates purchase order receiving status based on the goods received.

CREATE TRIGGER trg_purchase_order_receiving_status
AFTER INSERT ON goods_received
WHEN NEW.receiving_status IN (
    'Partially Received',
    'Fully Received'
)
BEGIN
    UPDATE purchase_order_items
    SET item_status = CASE
        WHEN (
            SELECT COALESCE(
                SUM(gr.quantity_received),
                0
            )
            FROM goods_received gr
            WHERE gr.purchase_order_item_id =
                NEW.purchase_order_item_id
              AND gr.receiving_status IN (
                  'Partially Received',
                  'Fully Received'
              )
        ) >= quantity_ordered
        THEN 'Fully Received'
        ELSE 'Partially Received'
    END,
    updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.purchase_order_item_id;

    UPDATE purchase_orders
    SET purchase_order_status = CASE
        WHEN (
            SELECT COUNT(*)
            FROM purchase_order_items poi
            WHERE poi.purchase_order_id = purchase_orders.id
              AND poi.item_status NOT IN (
                  'Fully Received',
                  'Cancelled'
              )
        ) = 0
        AND (
            SELECT COUNT(*)
            FROM purchase_order_items poi
            WHERE poi.purchase_order_id = purchase_orders.id
              AND poi.item_status = 'Fully Received'
        ) > 0
        THEN 'Fully Received'

        WHEN EXISTS (
            SELECT 1
            FROM purchase_order_items poi
            WHERE poi.purchase_order_id = purchase_orders.id
              AND poi.item_status IN (
                  'Partially Received',
                  'Fully Received'
              )
        )
        THEN 'Partially Received'

        ELSE purchase_order_status
    END,
    updated_at = CURRENT_TIMESTAMP
    WHERE id = (
        SELECT purchase_order_id
        FROM purchase_order_items
        WHERE id = NEW.purchase_order_item_id
    );
END;


-- TRIGGER: trg_shipment_status_change_audit — Automatically records significant shipment status changes for audit purposes.

CREATE TRIGGER trg_shipment_status_change_audit
AFTER UPDATE OF shipment_status
ON shipment_requests
WHEN OLD.shipment_status <> NEW.shipment_status
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.employee_id,
        'SHIPMENT-' || NEW.id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Status Change',
        'shipment_requests',
        NEW.id,
        CURRENT_TIMESTAMP,
        OLD.shipment_status,
        NEW.shipment_status,
        'Shipment status transition automatically recorded'
    );
END;


-- TRIGGER: trg_customer_credit_exposure_invoice — Automatically monitors customer credit exposure when invoices affect outstanding balances.

CREATE TRIGGER trg_customer_credit_exposure_invoice
AFTER INSERT ON invoices
WHEN NEW.payment_status IN (
    'Unpaid',
    'Partially Paid',
    'Overdue'
)
AND (
    SELECT COALESCE(SUM(
        CASE
            WHEN i.total_amount > COALESCE((
                SELECT SUM(p.amount)
                FROM payments p
                WHERE p.invoice_id = i.id
                  AND p.payment_status = 'Successful'
            ), 0)
            THEN i.total_amount - COALESCE((
                SELECT SUM(p.amount)
                FROM payments p
                WHERE p.invoice_id = i.id
                  AND p.payment_status = 'Successful'
            ), 0)
            ELSE 0
        END
    ), 0)
    FROM invoices i
    WHERE i.customer_id = NEW.customer_id
      AND i.payment_status IN (
          'Unpaid',
          'Partially Paid',
          'Overdue'
      )
) > (
    SELECT credit_limit
    FROM customers
    WHERE id = NEW.customer_id
)
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NULL,
        'CREDIT-INVOICE-' || NEW.customer_id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Status Change',
        'customers',
        NEW.customer_id,
        CURRENT_TIMESTAMP,
        NULL,
        CAST((
            SELECT COALESCE(SUM(
                CASE
                    WHEN i.total_amount > COALESCE((
                        SELECT SUM(p.amount)
                        FROM payments p
                        WHERE p.invoice_id = i.id
                          AND p.payment_status = 'Successful'
                    ), 0)
                    THEN i.total_amount - COALESCE((
                        SELECT SUM(p.amount)
                        FROM payments p
                        WHERE p.invoice_id = i.id
                          AND p.payment_status = 'Successful'
                    ), 0)
                    ELSE 0
                END
            ), 0)
            FROM invoices i
            WHERE i.customer_id = NEW.customer_id
              AND i.payment_status IN (
                  'Unpaid',
                  'Partially Paid',
                  'Overdue'
              )
        ) AS TEXT),
        'Customer outstanding credit exposure exceeds approved credit limit after invoice creation'
    );
END;


-- TRIGGER: trg_customer_credit_exposure_payment — Automatically monitors customer credit exposure when relevant payment status changes occur.

CREATE TRIGGER trg_customer_credit_exposure_payment
AFTER UPDATE OF payment_status ON payments
WHEN OLD.payment_status <> NEW.payment_status
AND NEW.payment_status IN (
    'Successful',
    'Reversed',
    'Refunded',
    'Cancelled'
)
AND NEW.invoice_id IS NOT NULL
AND (
    SELECT COALESCE(SUM(
        CASE
            WHEN i.total_amount > COALESCE((
                SELECT SUM(p.amount)
                FROM payments p
                WHERE p.invoice_id = i.id
                  AND p.payment_status = 'Successful'
            ), 0)
            THEN i.total_amount - COALESCE((
                SELECT SUM(p.amount)
                FROM payments p
                WHERE p.invoice_id = i.id
                  AND p.payment_status = 'Successful'
            ), 0)
            ELSE 0
        END
    ), 0)
    FROM invoices i
    WHERE i.customer_id = (
        SELECT customer_id
        FROM invoices
        WHERE id = NEW.invoice_id
    )
    AND i.payment_status IN (
        'Unpaid',
        'Partially Paid',
        'Overdue'
    )
) > (
    SELECT credit_limit
    FROM customers
    WHERE id = (
        SELECT customer_id
        FROM invoices
        WHERE id = NEW.invoice_id
    )
)
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NEW.employee_id,
        'CREDIT-PAYMENT-' ||
            (SELECT customer_id
             FROM invoices
             WHERE id = NEW.invoice_id) ||
            '-' || strftime('%Y%m%d%H%M%f', 'now'),
        'Status Change',
        'customers',
        (
            SELECT customer_id
            FROM invoices
            WHERE id = NEW.invoice_id
        ),
        CURRENT_TIMESTAMP,
        OLD.payment_status,
        NEW.payment_status,
        'Customer credit exposure remains above approved credit limit following payment status change'
    );
END;


-- TRIGGER: trg_inventory_replenishment_monitoring — Automatically records an audit event when inventory reaches or falls below its reorder level.

CREATE TRIGGER trg_inventory_replenishment_monitoring
AFTER UPDATE OF quantity
ON company_inventory_locations
WHEN OLD.quantity > (
    SELECT ci.reorder_level
    FROM company_inventory ci
    WHERE ci.id = NEW.company_inventory_id
)
AND NEW.quantity <= (
    SELECT ci.reorder_level
    FROM company_inventory ci
    WHERE ci.id = NEW.company_inventory_id
)
BEGIN
    INSERT INTO audit_logs (
        employee_id,
        event_code,
        action_type,
        table_name,
        record_id,
        event_date_time,
        old_value,
        new_value,
        reason
    )
    VALUES (
        NULL,
        'REORDER-' || NEW.company_inventory_id || '-' ||
            strftime('%Y%m%d%H%M%f', 'now'),
        'Update',
        'company_inventory',
        NEW.company_inventory_id,
        CURRENT_TIMESTAMP,
        CAST(OLD.quantity AS TEXT),
        CAST(NEW.quantity AS TEXT),
        'Inventory has reached or fallen below its reorder level'
    );
END;
