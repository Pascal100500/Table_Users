--DECLARE @login nvarchar (50) ='thebroenblow';
--DECLARE @password nvarchar(100) ='qwerty';
--DECLARE @first_name nvarchar(100) = 'Артем';
--DECLARE @last_name nvarchar(100) = 'Красов';
--declare @midle_name nvarchar(100) = 'Александрович';
--declare @email nvarchar(255) = 'dsdf@mail.com';
--declare @phone nvarchar(20) = '79999992255';


--INSERT INTO users(login, password, first_name, last_name, middle_name, email, phone, registration_date)
--VALUES (@login, @password, @first_name, @last_name, @middle_name, @email, @phone, GETUTCDATE());

CREATE PROCEDURE add_user
    @login NVARCHAR(50),
    @password NVARCHAR(100),
    @first_name NVARCHAR(100),
    @last_name NVARCHAR(100),
    @middle_name NVARCHAR(100) = NULL,
    @email NVARCHAR(255),
    @phone NVARCHAR(20) = NULL
AS
BEGIN
    INSERT INTO Users (login, password, firstName, lastName, middleName, email, phoneNumber, registration_date)
    VALUES (@login, @password, @first_name, @last_name, @middle_name, @email, @phone, GETUTCDATE());
END;

--*************************
--Добавление категории

CREATE PROCEDURE add_category
    @name NVARCHAR(100),
    @description NVARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO categories (name, description)
    VALUES (@name, @description);
END

--Присвоение категории товару
CREATE PROCEDURE assign_product_to_category
    @product_id INT,
    @category_id INT
AS
BEGIN
    INSERT INTO products_categories (product_id, category_id)
    VALUES (@product_id, @category_id);
END

--*************************
--2. Вывод всех пользователей с количеством их заказов

CREATE PROCEDURE get_users_with_orders
AS
BEGIN
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        COUNT(o.order_id) AS total_orders
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.first_name, u.last_name;
END;

--*************************
--3. Топ 5 пользователей, которые совершили больше всего заказов

CREATE PROCEDURE get_top_5_users_by_orders
AS
BEGIN
    SELECT TOP 5 
        u.user_id,
        u.first_name,
        u.last_name,
        COUNT(o.order_id) AS total_orders
    FROM users u
    INNER JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.first_name, u.last_name
    ORDER BY total_orders DESC;
END;

--*************************
--4. Получение продукта по категории

CREATE PROCEDURE get_products_by_category
    @category_name NVARCHAR(100)
AS
BEGIN
    SELECT 
        p.product_id, 
        p.name, 
        p.price, 
        p.quantity, 
        c.name AS category_name
    FROM products p
    JOIN products_categories pc ON p.product_id = pc.product_id
    JOIN categories c ON c.category_id = pc.category_id
    WHERE c.name = @category_name;
END;

--*************************
--5. Поиск продуктов по названию и по диапазону цены
--Поиск через переменную для названия

CREATE PROCEDURE search_products
    @name_part NVARCHAR(200),
    @min_price DECIMAL(10, 2),
    @max_price DECIMAL(10, 2)
AS
BEGIN
    SELECT product_id, name, price, quantity, add_date
    FROM products
    WHERE name LIKE '%' + @name_part + '%'
      AND price BETWEEN @min_price AND @max_price;
END;

--*************************
--6. Вывод всех заказов пользователя в определённый диапазоне дат

CREATE PROCEDURE get_user_orders_by_date
    @user_id INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT o.order_id, o.order_date, o.total_amount, o.status_id, o.delivery_adress
    FROM orders o
    WHERE o.user_id = @user_id
      AND o.order_date BETWEEN @start_date AND @end_date;
END;

--*************************
--7. Получение списка всех товаров постранично

CREATE PROCEDURE get_products_page
    @page_number INT,
    @page_size INT
AS
BEGIN
    DECLARE @offset INT = (@page_number - 1) * @page_size;

    SELECT product_id, name, price, quantity, add_date
    FROM products
    ORDER BY product_id
    OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;
END;

--*************************
--8. самые популярные товары - TOP 10 
--Суммарно по всем складам

CREATE PROCEDURE GetTopPopularProducts
AS
BEGIN
    SELECT TOP 10 
        p.product_id,
        p.name,
        SUM(op.quantity) AS total_sold
    FROM orders_products op
    JOIN products p ON p.product_id = op.product_id
    GROUP BY p.product_id, p.name
    ORDER BY total_sold DESC;
END;

--*************************
--9. Представление для информации о пользователях (без паролей)

CREATE VIEW UsersPublicInfo AS
SELECT 
    user_id,
    login,
    first_name,
    last_name,
    middle_name,
    email,
    phone,
    registration_date
FROM users;

--*************************
--10. Получение кол-ва продуктов по каждой категории.

CREATE VIEW CategoryProductCount AS
SELECT 
    c.category_id,
    c.name AS category_name,
    COUNT(pc.product_id) AS product_count
FROM categories AS c
LEFT JOIN products_categories AS pc ON c.category_id = pc.category_id
GROUP BY c.category_id, c.name;

--*************************
--11. Получение кол-ва продуктов для любых двух категорий.

CREATE PROCEDURE GetProductCountForCategories
    @Category1 NVARCHAR(100),
    @Category2 NVARCHAR(100)
AS
BEGIN
    SELECT 
        c.name AS category_name,
        COUNT(pc.product_id) AS product_count
    FROM categories AS c
    LEFT JOIN products_categories AS pc ON c.category_id = pc.category_id
    WHERE c.name IN (@Category1, @Category2)
    GROUP BY c.name;
END;