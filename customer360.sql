
-- Online Transactions External Table
CREATE OR ALTER VIEW ExternalOnline AS
SELECT *
FROM OPENROWSET(
    BULK 'raw/online_transactions.csv',
    DATA_SOURCE = 'LS_ADLS_RAW',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2
) WITH (
    CustomerID VARCHAR(10),
    TransactionID VARCHAR(10),
    Amount FLOAT,
    TransactionDate DATE
) AS rows;

-- In-Store Purchases External Table
CREATE OR ALTER VIEW ExternalInstore AS
SELECT *
FROM OPENROWSET(
    BULK 'raw/instore_purchases.csv',
    DATA_SOURCE = 'LS_ADLS_RAW',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2
) WITH (
    CustomerID VARCHAR(10),
    StoreID VARCHAR(10),
    Amount FLOAT,
    PurchaseDate DATE
) AS rows;

-- Customer Service External Table
CREATE OR ALTER VIEW ExternalCustomerService AS
SELECT *
FROM OPENROWSET(
    BULK 'raw/customer_service.csv',
    DATA_SOURCE = 'LS_ADLS_RAW',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2
) WITH (
    CustomerID VARCHAR(10),
    CaseID VARCHAR(10),
    Issue VARCHAR(100),
    Date DATE
) AS rows;

-- Loyalty Program External Table
CREATE OR ALTER VIEW ExternalLoyalty AS
SELECT *
FROM OPENROWSET(
    BULK 'raw/loyalty_program.csv',
    DATA_SOURCE = 'LS_ADLS_RAW',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2
) WITH (
    CustomerID VARCHAR(10),
    LoyaltyPoints INT,
    LastRedeemed DATE
) AS rows;

-- Customer 360 Master View
CREATE OR ALTER VIEW Customer360 AS
SELECT 
    COALESCE(o.CustomerID, i.CustomerID, cs.CustomerID, lp.CustomerID) as CustomerID,

    -- Online Transaction Metrics
    SUM(o.Amount) as TotalOnlineSpend,
    COUNT(DISTINCT o.TransactionID) as OnlineTransactionCount,
    MAX(o.TransactionDate) as LastOnlineTransaction,

    -- In-Store Transaction Metrics  
    SUM(i.Amount) as TotalInstoreSpend,
    COUNT(DISTINCT i.StoreID) as UniqueStoresVisited,
    MAX(i.PurchaseDate) as LastInstorePurchase,

    -- Customer Service Metrics
    COUNT(DISTINCT cs.CaseID) as TotalServiceCases,
    MAX(cs.Date) as LastServiceInteraction,
    STRING_AGG(cs.Issue, '; ') as ServiceIssues,

    -- Loyalty Metrics
    MAX(lp.LoyaltyPoints) as CurrentLoyaltyPoints,
    lp.LastRedeemed as LastLoyaltyRedemption,

    -- Calculated Fields
    (SUM(ISNULL(o.Amount,0)) + SUM(ISNULL(i.Amount,0))) as TotalCustomerValue,
    CASE 
        WHEN (SUM(ISNULL(o.Amount,0)) + SUM(ISNULL(i.Amount,0))) > 1000 THEN 'High Value'
        WHEN (SUM(ISNULL(o.Amount,0)) + SUM(ISNULL(i.Amount,0))) > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END as CustomerSegment

FROM ExternalOnline o
FULL OUTER JOIN ExternalInstore i ON o.CustomerID = i.CustomerID
FULL OUTER JOIN ExternalCustomerService cs ON COALESCE(o.CustomerID, i.CustomerID) = cs.CustomerID
FULL OUTER JOIN ExternalLoyalty lp ON COALESCE(o.CustomerID, i.CustomerID, cs.CustomerID) = lp.CustomerID
GROUP BY 
    COALESCE(o.CustomerID, i.CustomerID, cs.CustomerID, lp.CustomerID),
    lp.LoyaltyPoints, 
    lp.LastRedeemed;
