create DATABASE test_4;
GO

USE test_4;
GO

-- Create table DimIngredient
CREATE TABLE DimIngredient (
    [ID] INT NOT NULL PRIMARY KEY,
    [Item] VARCHAR(255) NULL,
    [VEG] VARCHAR(20) NULL,
    [Item Cnt] VARCHAR(255) NULL,
    [total_used] INT DEFAULT 0 NULL
) ON [PRIMARY];



-- Create table DimOrder

CREATE TABLE DimOrder (
    [order_id] INT NOT NULL PRIMARY KEY,
    [order_date] DATE NULL,
    [sales_qty] INT NULL,
    [sales_amount] float NULL,
    [currency] VARCHAR(3) NULL,
    [user_id] INT NOT NULL,
    [r_id] INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES DimUser(user_id),
    FOREIGN KEY (r_id) REFERENCES DimRestaurant(id)
) ON [PRIMARY];



-- Create table DimUser
CREATE TABLE DimUser (
    [user_id] INT NOT NULL PRIMARY KEY,
    [name] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [email] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [password] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [Age] INT NULL DEFAULT 0,
    [Gender] VARCHAR(10) DEFAULT 'Unknown' NULL,
    [Marital Status] VARCHAR(20) DEFAULT 'Unknown' NULL,
    [Occupation] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [Monthly Income] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [Educational Qualifications] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [Family size] INT NULL DEFAULT 0,
    [total_spent] DECIMAL(10,2) DEFAULT 0 NULL
) ON [PRIMARY];



-- Create table DimMenud

CREATE TABLE DimMenu (
    [menu_id] int NOT NULL PRIMARY KEY DEFAULT 'N/A',
    [r_id] INT NOT NULL DEFAULT 0,
    [f_id] INT NOT NULL DEFAULT 0,
    [cuisine] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [price] DECIMAL(10,2) DEFAULT 0 NULL,
    [total_sold] INT DEFAULT 0 NULL,
    FOREIGN KEY (r_id) REFERENCES DimRestaurant(id),
    FOREIGN KEY (f_id) REFERENCES DimIngredient(ID)
) ON [PRIMARY];



-- Create table DimRestaurant

CREATE TABLE DimRestaurant (
    [id] INT NOT NULL PRIMARY KEY DEFAULT 0,
    [name] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [city] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [rating] float DEFAULT 0 NULL,
    [rating_count] VARCHAR(255) DEFAULT 0 NULL,
    [cost] float DEFAULT 0 NULL,
    [cuisine] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [lic_no] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [link] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [address] VARCHAR(255) DEFAULT 'Unknown' NULL,
    [menu] VARCHAR(255) DEFAULT 'Unknown' NULL,
) ON [PRIMARY];



-- Create table FactSales
CREATE TABLE FactSales (
    [order_id] INT NOT NULL,
    [order_date] DATE NOT NULL,
    [user_id] INT NOT NULL,
    [r_id] INT NOT NULL,
    [menu_id] int NOT NULL,
    [f_id] INT NOT NULL,
    [sales_qty] INT NOT NULL,
    [sales_amount] float NOT NULL,
    [currency] VARCHAR(3) NOT NULL,
    [cost] float NOT NULL,
    [rating] float NOT NULL,
    [profit] float NOT NULL,
    CONSTRAINT PK_FactSales PRIMARY KEY NONCLUSTERED (order_id, menu_id),
    FOREIGN KEY (user_id) REFERENCES DimUser(user_id),
    FOREIGN KEY (r_id) REFERENCES DimRestaurant(id),
    FOREIGN KEY (menu_id) REFERENCES DimMenu(menu_id),
    FOREIGN KEY (f_id) REFERENCES DimIngredient(Id)
) ON [PRIMARY];

-- Insert data into FactSales from the dimension tables
INSERT INTO FactSales (
    order_id,
    order_date,
    user_id,
    r_id,
    menu_id,
    f_id,
    sales_qty,
    sales_amount,
    currency,
    cost,
    rating,
    profit
)
SELECT 
    do.order_id,
    do.order_date,
    do.user_id,
    do.r_id,
    dm.menu_id,
    dm.f_id,
    do.sales_qty,
    do.sales_amount,
    do.currency,
    dr.cost,
    dr.rating,
    (do.sales_amount - dr.cost) AS profit  
FROM 
    DimOrder do
JOIN 
    DimMenu dm ON dm.r_id = do.r_id  
JOIN 
    DimRestaurant dr ON dr.id = do.r_id
JOIN 
    DimIngredient di ON di.ID = dm.f_id
JOIN 
    DimUser du ON du.user_id = do.user_id;


-- Create table FactRestaurantPerformance
drop table FactRestaurantPerformance
CREATE TABLE FactRestaurantPerformance (
    [r_id] INT NOT NULL PRIMARY KEY,
    [name] VARCHAR(255)  NULL,
    [city] VARCHAR(255)  NULL,
    [total_orders] INT  NULL,
    [total_sales_amount] FLOAT  NULL,
    [total_profit] FLOAT  NULL,
    [average_rating] FLOAT  NULL,
    [number_of_customers] INT  NULL,
    FOREIGN KEY (r_id) REFERENCES DimRestaurant(id)
) ON [PRIMARY];

INSERT INTO FactRestaurantPerformance (r_id, name, city, total_orders, total_sales_amount, total_profit, average_rating, number_of_customers)
SELECT
    r.id,
    r.name,
    r.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.sales_amount) AS total_sales_amount,
    SUM(o.sales_qty * m.price) AS total_profit,
    AVG(r.rating) AS average_rating,
    COUNT(DISTINCT o.user_id) AS number_of_customers
FROM
    DimRestaurant r
    LEFT JOIN DimOrder o ON r.id = o.r_id
    LEFT JOIN DimMenu m ON o.r_id = m.r_id
GROUP BY
    r.id,
    r.name,
    r.city;



BULK INSERT DimRestaurant
FROM 'D:\hoc\nam_3\datawarehouse\ck\restaurant.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Use this if your CSV has a header row
);

BULK INSERT DimMenu
FROM 'D:\hoc\nam_3\datawarehouse\ck\menu.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Use this if your CSV has a header row
);



BULK INSERT DimUser
FROM 'D:\hoc\nam_3\datawarehouse\ck\users.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Use this if your CSV has a header row
);

BULK INSERT DimIngredient
FROM 'D:\hoc\nam_3\datawarehouse\ck\DIM_FOODS_VEG.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Use this if your CSV has a header row
);

BULK INSERT DimOrder
FROM 'D:\hoc\nam_3\datawarehouse\ck\orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Use this if your CSV has a header row
);

-- Tính toán và cập nhật các fact
-- Doanh thu trung bình theo thành phố (DimRestaurant)


-- Tổng chi tiêu của người dùng (DimUser)
UPDATE DimUser
SET total_spent = (
    SELECT SUM(fs.sales_amount)
    FROM FactSales fs
    WHERE fs.user_id = DimUser.user_id
);
select * from FactSales
-- Tổng số lượng món ăn đã bán (DimMenu)
UPDATE DimMenu
SET total_sold = (
    SELECT SUM(fs.sales_qty)
    FROM FactSales fs
    WHERE fs.menu_id = DimMenu.menu_id
);

-- Tổng số lượng nguyên liệu đã sử dụng (DimIngredient)
UPDATE DimIngredient
SET total_used = (
    SELECT SUM(fs.sales_qty)
    FROM FactSales fs
    JOIN DimMenu dm ON fs.menu_id = dm.menu_id
    WHERE dm.f_id = DimIngredient.ID
);


ALTER TABLE stgMenu ADD CONSTRAINT LK_Menu_Restaurant FOREIGN KEY (r_id) REFERENCES stgRestaurant(id);
ALTER TABLE stgMenu WITH NOCHECK ADD CONSTRAINT LK_Menu_Ingredient FOREIGN KEY (f_id) REFERENCES stgIngredient(ID);

ALTER TABLE stgOrder ADD CONSTRAINT LK_order_User FOREIGN KEY (user_id) REFERENCES stgUser(user_id);
ALTER TABLE stgOrder ADD CONSTRAINT LK_order_Restaurant FOREIGN KEY (r_id)  REFERENCES stgRestaurant(id);



ALTER TABLE stgFactSales ADD CONSTRAINT LK_stgFactSales_User FOREIGN KEY (user_id) REFERENCES stgUser(user_id);
ALTER TABLE stgFactSales ADD CONSTRAINT LK_stgFactSales_Restaurant FOREIGN KEY (r_id) REFERENCES stgRestaurant(id);
ALTER TABLE stgFactSales ADD CONSTRAINT LK_stgFactSales_Menu FOREIGN KEY (menu_id) REFERENCES stgMenu(menu_id);
ALTER TABLE stgFactSales ADD CONSTRAINT LK_stgFactSales_Ingredient FOREIGN KEY (f_id) REFERENCES stgIngredient(Id);


ALTER TABLE stgFactRestaurantPerformance ADD CONSTRAINT LK_FactRestaurantPerformance_Restaurant FOREIGN KEY (r_id) REFERENCES stgRestaurant(id);



select * from stgOrder