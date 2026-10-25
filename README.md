LOGISTICS & SUPPLY CHAIN MANAGEMENT INFORMATION SYSTEM (LSCMIS)

A relational database system designed to support the core operational, management, reporting, and business intelligence needs of a logistics and supply chain organization using SQLite.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Business Requirements and Business Intelligence](#business-requirements-and-business-intelligence)
3. [Database Structure](#database-structure)
4. [Main Business Areas](#main-business-areas)
5. [Database Design Features](#database-design-features)
6. [Business Intelligence Examples](#business-intelligence-examples)
7. [Technology](#technology)
8. [Project Files](#project-files)
9. [Entity Relationship Diagram](#entity-relationship-diagram)
10. [Data Integrity and Validation](#data-integrity-and-validation)
11. [Optimization and Effective Database Management](#optimization-and-effective-database-management)
12. [Limitations](#limitations)
13. [Future Development](#future-development)
14. [Conclusion](#conclusion)


## PROJECT OVERVIEW

The Logistics & Supply Chain Management Information System (LSCMIS) is a relational database designed to centralize and manage important logistics and supply chain operations within a structured database environment.

The system brings together operational areas including customer and employee management, shipment processing and tracking, warehouse and hub operations, inventory management, procurement and supplier management, transport asset administration, customer service, financial records, budgeting and expenses, compliance, risk management, environmental assessment, insurance, service-level management, and operational auditing.

The database was designed not only to store operational data, but also to support management reporting, business analysis, monitoring, and evidence-based decision-making.

By bringing related business information into one relational system, LSCMIS helps reduce data redundancy, improve data consistency, maintain data integrity, strengthen operational visibility, and provide a reliable foundation for business intelligence and future analytical solutions.



## BUSINESS REQUIREMENTS AND BUSINESS INTELLIGENCE

The design of LSCMIS was informed by a broad set of logistics and supply chain business requirements and management questions.

More than 250 business intelligence questions and requirements were considered across the different operational areas of the organization. These requirements helped guide the database structure, relationships, attributes, constraints, analytical views, triggers, indexes, and SQL queries.

The questions cover areas such as:

- Customer management
- Shipment processing and delivery performance
- Shipment tracking
- Warehouse and hub operations
- Inventory management and inventory risk
- Procurement and purchasing
- Supplier performance
- Transport assets and fleet-related liabilities
- Customer satisfaction
- Finance and cash flow
- Invoicing and payments
- Departmental budgets and expenses
- Employee and department management
- Compliance
- Risk assessment
- Environmental impact
- Insurance
- Service-level performance
- Operational monitoring and auditing

The following are five examples of high-impact business intelligence questions** selected from the wider set of business questions and requirements identified for LSCMIS:

1. Which processing branches and service levels have the highest shipment delays?
2. Which inventory items currently represent the greatest operational risk?
3. Which suppliers have the greatest procurement and receiving risk?
4. Which departments are approaching or exceeding their budgets?
5. On which dates is LSCMIS experiencing negative cash flow?

These five questions are examples of the analytical capability of the database and are not intended to represent the complete set of business intelligence requirements**.


## DATABASE STRUCTURE

The LSCMIS database contains 37 relational tables/entities designed to represent the major business operations of a logistics and supply chain organization.

The database uses primary keys and foreign keys to establish relationships between entities and maintain referential integrity.

The design primarily uses one-to-many (1:M) relationships, with two explicit many-to-many (M:N) relationships resolved through associative tables:

- Shipment_Request_Items ↔ Shipment_Item_Classifications
 - resolved through Shipment_Item_Classification_Assignment

- Shipment_Request_Items ↔ Containers
  - resolved through `Shipment_Item_Containers

The complete entity structure, attributes, relationships, constraints, and design decisions are documented in "DESIGN.md".



## MAIN BUSINESS AREAS

The database covers the following major areas:

Customer Management:
Manages customer records, customer types, contact information, credit information, and customer status.

Employee and Department Management:
Manages employees, departments, leave history, and employee department history.

Shipment Management:
Supports shipment requests, shipment items, shipment inventory, shipment classifications, containers, branches, hubs, tracking events, and delivery performance.

Warehouse and Inventory Management:
Supports warehouses, company inventory, inventory locations, inventory transactions, inventory movement, inventory risk, stock levels, damage, expiry, and replenishment monitoring.

Procurement and Supplier Management:
Supports suppliers, purchase orders, purchase order items, goods received, supplier evaluations, and supplier performance monitoring.

Transport Asset Management:
Maintains information relating to transport assets and supports monitoring of maintenance, registration, insurance, and operational conditions.

Customer Service:
Supports customer feedback and customer satisfaction analysis.

Financial Management:
Supports invoices, payments, budgets, expenses, and cash-flow monitoring.

Risk, Compliance and Environmental Management:
Supports risk assessments, compliance assessments, environmental impact assessments, and related monitoring.

Insurance and Service-Level Management:
Supports insurance policies and service-level assessments.

Operational Governance and Auditing:
Supports audit logging and automated monitoring of significant operational events.



## DATABASE DESIGN FEATURES

The database uses several relational database techniques to improve data integrity, maintainability, performance, monitoring, and analytical capability.

Constraints

The database uses constraints such as:

- PRIMARY KEY
- FOREIGN KEY
- NOT NULL
- UNIQUE
- CHECK
- DEFAULT

These constraints help prevent invalid, incomplete, duplicated, or inconsistent data from being stored.

Views

The database contains 9 business-focused views designed to simplify recurring analysis and reporting.

The views include:

1. warehouse_utilization
2. inventory_risk
3. `ash_flow_monitoring
4. transport_asset_liability
5. supplier_performance
6. customer_satisfactio
7. inventory_movement
8. department_budget_expenses_performance
9. `hipment_performance

These views contain reusable joins, calculations, aggregations, and business logic that can support recurring management analysis.

Triggers

The database contains 14 triggers designed to support automation, monitoring, synchronization, and auditing.

The triggers cover areas including:

- Risk assessment monitoring
- Compliance monitoring
- Insurance expiry and renewal monitoring
- Environmental impact monitoring
- Transport asset critical conditions
- Inventory expiry
- Employee department history
- Payment change auditing
- Inventory transaction synchronization
- Purchase order receiving status
- Shipment status auditing
- Customer credit exposure
- Inventory replenishment monitoring

Indexes

The database contains 10 indexes designed primarily to improve query performance.

The indexes focus on columns frequently used for:

- Filtering
- Searching
- Joining
- Retrieving related records
- Working with shipment tracking dates
- Working with inventory transactions
- Filtering purchase orders and customers

Common Table Expressions (CTEs)

CTEs are used in complex queries to break data processing into meaningful stages.

They improve the organization, readability, and maintainability of queries involving multiple calculations, aggregations, and intermediate results.


## BUSINESS INTELLIGENCE EXAMPLES

The project includes SQL queries demonstrating how the database can answer management questions.

For example, the shipment performance analysis can identify branches and service levels with high delivery delays.

The inventory risk analysis can identify inventory items requiring attention because of low stock, damage, expiry, or other risk conditions.

Supplier performance analysis can combine purchasing activity, delivery performance, quality ratings, order accuracy, business relationship ratings, and damaged or rejected receipts.

Budget analysis can identify departments approaching or exceeding their allocated budgets.

Cash-flow analysis can identify dates where cash outflows exceed cash inflows.

These examples demonstrate how the relational database can move beyond data storage and provide information that can support operational and management decisions.


## TECHNOLOGY

The project was implemented using:

1. SQLite
2. SQL
3. Github
4. Github Codespaces

SQLite was selected as the database management system for this project because it provides a lightweight relational database environment suitable for designing, implementing, testing, and demonstrating the LSCMIS database.



## PROJECT FILES

The repository contains the following main project files:

schema.sql - Contains the SQL schema used to create the database tables and related database structures.

queries.sql - Contains analytical and business intelligence SQL queries used to answer selected management questions

DESIGN.md - Provides detailed documentation of the database design, entities, attributes, relationships, constraints, views, triggers, indexes, CTEs, BI questions, and design decisions.

LSCMIS_ERD.png - Entity Relationship Diagram showing the structure and relationships between the database entities.

LSCMIS.db → the actual SQLite database containing the sample data for practical analysis and demonstration.


## ENTITY RELATIONSHIP DIAGRAM

The complete Entity Relationship Diagram for LSCMIS is provided below.

![LSCMIS Entity Relationship Diagram](LSCMIS_ERD.png)


## DATA INTEGIRTY AND VALIDATION

The database was designed with data integrity as an important consideration.

Business rules are enforced through relational constraints and validation logic. Examples include preventing negative quantities where inappropriate, restricting fields to valid business statuses, enforcing valid geographical ranges for latitude and longitude, maintaining relationships between related entities, and preventing duplicate business identifiers.

The database also uses triggers to automatically respond to selected operational events, helping maintain synchronized records and create audit information where required.



## OPTIMIZATION AND EFFECTIVE DATABASE MANAGEMENT

The project includes **10 indexes, 9 views, and 14 triggers** to improve the effectiveness and management of the database.

The indexes were primarily designed to improve query performance, while the views and triggers support reusable analysis, automation, monitoring, synchronization, and auditing.

CTEs were also used to make complex SQL queries clearer, more organized, and easier to maintain.


## LIMITATION

Although LSCMIS covers a broad range of logistics and supply chain operations, some capabilities are outside the current scope of the project.

The current implementation does not include:

- Automated quotation management
- External payment gateway integration
- Automated payment processing
- Payroll management
- Government customs brokerage
- Trade union brokerage
- Government policy management
- GPS navigation
- Route optimization
- Real-time telematics
- Predictive demand forecasting
- Integration with external enterprise systems

These areas can be considered potential future enhancements.

Another limitation is the use of SQLite. While SQLite is appropriate for this project, it may not be the best choice for a very large organization requiring many simultaneous users and concurrent database updates.


## FUTURE DEVELOPMENT

Potential future development could include:

- Integration with external enterprise systems
- Real-time GPS and vehicle tracking
- Route optimization
- Predictive demand forecasting
- Automated quotation management
- Automated payment processing
- Advanced business intelligence dashboards
- Integration with larger client-server database systems
- Expanded predictive analytics and machine learning capabilities



## CONCLUSION

LSCMIS was designed as a structured relational database solution for managing and analysing important logistics and supply chain operations.

The project combines **37 relational tables, 9 business-focused views, 14 triggers, 10 indexes, constraints, CTEs, an ERD, and analytical SQL queries** to provide a database that supports both operational data management and management-level analysis.

The system was developed around a broad set of logistics and supply chain business requirements, including more than **250 identified business intelligence questions and requirements**. The selected analytical queries demonstrate only a portion of the questions that the database can be used to investigate.

The overall objective of LSCMIS is therefore not simply to store logistics data, but to provide a structured and reliable relational foundation for **operational management, business intelligence, monitoring, reporting, auditing, and future analytical development**.
