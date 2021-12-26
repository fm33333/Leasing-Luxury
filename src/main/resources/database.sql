USE leasingluxury;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS handbags;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS rentals;
SET FOREIGN_KEY_CHECKS = 1;

/* 
 * 包包的信息
 * PS: 每种包包全球限量1个 ^^
*/
-- bagID, bagName, manufacturer, designer, bagType, color, pricePerDay, bagStatus
CREATE TABLE handbags (
    bagID		CHAR(3) NOT NULL,
    bagName		VARCHAR(30) NOT NULL UNIQUE,
    manufacturer	VARCHAR(20) NOT NULL,
    designer		VARCHAR(20) NOT NULL,
    bagType		VARCHAR(20) NOT NULL,
    color		VARCHAR(20) NOT NULL,
    pricePerDay		DECIMAL(4, 2) NOT NULL,
    -- 包的状态 0为“在库”; 1为“借出”
    bagStatus		SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (bagID)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/* 
 * 客户的信息 
 */
-- customerID, firstName, lastName, phone, address, emailAddr, creditCardID, totalLengthOfRental
CREATE TABLE customers (
    customerID		CHAR(5) NOT NULL,
    firstName		VARCHAR(20) NOT NULL,
    lastName		VARCHAR(20) NOT NULL,
    phone		VARCHAR(12) NOT NULL UNIQUE,
    address		TEXT NOT NULL,
    emailAddr		VARCHAR(20) NOT NULL UNIQUE,
    creditCardID	CHAR(12) NOT NULL UNIQUE,
    -- 总租期：此处为(dateReturned-dateRented)，而不是实际已租多少天
    totalLengthOfRental	INT DEFAULT 0,	
    PRIMARY KEY (customerID)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/* 
 * 交易表的信息
 */
-- rentalID, customerID, bagID, dateRented, dateReturned, insurance, returnStatus
CREATE TABLE rentals (
    rentalID		CHAR(4) NOT NULL,
    customerID		CHAR(5) NOT NULL,
    bagID		CHAR(3) NOT NULL,
    -- 租用时间：默认当前时间
    dateRented		TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    dateReturned	TIMESTAMP NOT NULL,
    -- 保险 0为没选保险; 1为选了保险
    insurance		SMALLINT NOT NULL DEFAULT 0,
    -- 归还状态 0为未归还; 1为已归还
    returnStatus	SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (rentalID),
    -- ON DELETE CASCADE 级联删除
    -- ON UPDATE CASCADE 级联更新
    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bagID) REFERENCES handbags(bagID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/* =============================================================================== */

/* 
 * 触发器：auto_set_bagID
 * 自动设置bagID 
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_bagID $$
CREATE TRIGGER auto_set_bagID
BEFORE INSERT ON handbags
FOR EACH ROW
BEGIN

    DECLARE n SMALLINT;
    DECLARE msg TEXT;

    IF NEW.bagID IS NULL OR NEW.bagID='' THEN
        IF (SELECT COUNT(*) FROM handbags) > 0 THEN
            -- handbags表中有数据则bagID为编号最大的+1
            SET NEW.bagID=(SELECT LPAD(bagID+1, 3, 0) FROM handbags 
                ORDER BY bagID DESC LIMIT 1);
        ELSE
            -- handbags表中无数据则bagID设为001
            SET NEW.bagID='001';
        END IF;
    END IF;
    
    -- 插入数据时，若表中已有，则抛出异常
    SELECT COUNT(*) INTO n 
        FROM handbags 
        WHERE bagName=NEW.bagName;     
    IF n <> 0 THEN
        SET msg = '已存在该包';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    
    
END $$
DELIMITER ;

/* 
 * 触发器：auto_set_handbags_SQLException
 * 自动设置异常信息
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_handbags_SQLException $$
CREATE TRIGGER auto_set_handbags_SQLException
BEFORE UPDATE ON handbags
FOR EACH ROW
BEGIN

    DECLARE n SMALLINT;
    DECLARE msg TEXT;
    
    -- 更新数据时，若表中已有，则抛出异常
    SELECT COUNT(*) INTO n 
        FROM handbags 
        WHERE bagName=NEW.bagName AND NEW.bagName!=OLD.bagName;     
    IF n <> 0 THEN
        SET msg = '已存在该包';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    
END $$
DELIMITER ;

/* 
 * 触发器：auto_set_customerID
 * 自动设置customerID 
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_customerID $$
CREATE TRIGGER auto_set_customerID
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN

    DECLARE n SMALLINT;
    DECLARE msg TEXT;

    IF NEW.customerID IS NULL OR NEW.customerID='' THEN
        IF (SELECT COUNT(*) FROM customers) > 0 THEN
            -- customers表中有数据则customerID为编号最大的+1
            SET NEW.customerID=(SELECT LPAD(customerID+1, 5, 0) FROM customers 
                ORDER BY customerID DESC LIMIT 1);
        ELSE
            -- customers表中无数据则customerID设为00001
            SET NEW.customerID='00001';
        END IF;
    END IF;
    
    -- 插入数据时，若表中已有，则抛出异常
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE firstName=NEW.firstName AND lastName=NEW.lastName;
    IF n <> 0 THEN
        SET msg = '已存在该客户';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE phone=NEW.phone;
    IF n <> 0 THEN
        SET msg = '已存在该电话号码，请重新输入电话号码';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE emailAddr=NEW.emailAddr;
    IF n <> 0 THEN
        SET msg = '已存在该邮箱，请重新输入邮箱';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE creditCardID=NEW.creditCardID;
    IF n <> 0 THEN
        SET msg = '已存在该信用卡号，请重新输入信用卡号';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;

END $$
DELIMITER ;

/* 
 * 触发器：auto_set_customers_SQLException
 * 自动设置异常信息
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_customers_SQLException $$
CREATE TRIGGER auto_set_customers_SQLException
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN

    DECLARE n SMALLINT;
    DECLARE msg TEXT;

    -- 更新数据时，若表中已有，则抛出异常
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE firstName=NEW.firstName AND lastName=NEW.lastName
            AND NEW.firstName!=OLD.firstName
            AND NEW.lastName!=OLD.lastName;
    IF n <> 0 THEN
        SET msg = '已存在该客户';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE phone=NEW.phone AND NEW.phone!=OLD.phone;
    IF n <> 0 THEN
        SET msg = '已存在该电话号码，请重新输入电话号码';
        SIGNAL SQLSTATE '23000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE emailAddr=NEW.emailAddr AND NEW.emailAddr!=OLD.emailAddr;
    IF n <> 0 THEN
        SET msg = '已存在该邮箱，请重新输入邮箱';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    END IF;
    -- 
    SELECT COUNT(*) INTO n 
        FROM customers 
        WHERE creditCardID=NEW.creditCardID AND NEW.creditCardID!=OLD.creditCardID;
    IF n <> 0 THEN
        SET msg = '已存在该信用卡号，请重新输入信用卡号';
        SIGNAL SQLSTATE '23000' SET MESSAGE_TEXT = msg;
    END IF;

END $$
DELIMITER ;

/* 
 * 触发器：auto_set_rentalID
 * 自动设置rentalID 
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_rentalID $$
CREATE TRIGGER auto_set_rentalID
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN

    IF NEW.rentalID IS NULL OR NEW.rentalID='' THEN
        IF (SELECT COUNT(*) FROM rentals) > 0 THEN
            -- rentals表中有数据则rentalID为编号最大的+1
            SET NEW.rentalID=(SELECT LPAD(rentalID+1, 4, 0) FROM rentals 
                ORDER BY rentalID DESC LIMIT 1);
        ELSE
            -- rentals表中无数据则rentalID设为0001
            SET NEW.rentalID='0001';
        END IF;
    END IF;
    
END $$
DELIMITER ;

/* 
 * 触发器：auto_set_totalLengthOfRental
 * 自动设置totalLengthOfRental 
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_totalLengthOfRental $$
CREATE TRIGGER auto_set_totalLengthOfRental
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    SET NEW.totalLengthOfRental = 0;
END $$
DELIMITER ;

/*
 * 触发器：auto_cul_totalLengthOfRental
 * 客户租用时，自动计算更新totalLengthOfRental的值
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_cul_totalLengthOfRental $$
CREATE TRIGGER auto_cul_totalLengthOfRental
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    DECLARE lengthOfRental INT;
    DECLARE _totalLengthOfRental INT;
    
    -- 时间差精确到天
    SET lengthOfRental = TIMESTAMPDIFF(DAY, NEW.dateRented, NEW.dateReturned);
    
    -- 归还日期大于租赁日期才进行计算更新
    IF lengthOfRental>0 THEN
        -- 获取原totalLengthOfRental
        SELECT customers.totalLengthOfRental INTO _totalLengthOfRental FROM customers
            WHERE NEW.customerID=customers.customerID;
        SET _totalLengthOfRental = _totalLengthOfRental + lengthOfRental;
    
        -- 更新customers表中该客户的totalLengthOfRental值
        UPDATE customers 
            SET totalLengthOfRental = _totalLengthOfRental
            WHERE customerID=NEW.customerID;
    END IF;
END $$
DELIMITER ;

/*
 * 触发器：auto_format_phone
 * 插入之后，将电话号码格式化成xxx-xxx-xxxx的形式
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_format_phone $$
CREATE TRIGGER auto_format_phone
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    DECLARE _phone1 VARCHAR(3);
    DECLARE _phone2 VARCHAR(3);
    DECLARE _phone3 VARCHAR(4);
    DECLARE _phone VARCHAR(12);
    
    -- 格式：xxx-xxx-xxxx
    SET _phone1 = SUBSTR(NEW.phone, 1, 3);
    SET _phone2 = SUBSTR(NEW.phone, 4, 3);
    SET _phone3 = SUBSTR(NEW.phone, 7, 4);
    SET _phone = CONCAT(_phone1, '-', _phone2, '-', _phone3);
    
    SET NEW.phone = _phone;
END $$
DELIMITER ;

/*
 * 触发器：auto_format_phone_update
 * 更新之前，将电话号码格式化成xxx-xxx-xxxx的形式
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_format_phone_update $$
CREATE TRIGGER auto_format_phone_update
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    DECLARE _phone1 VARCHAR(3);
    DECLARE _phone2 VARCHAR(3);
    DECLARE _phone3 VARCHAR(4);
    DECLARE _phone VARCHAR(12);
    
    -- 格式：xxx-xxx-xxxx
    /*此处if是防止在添加rentals元组时，对customers表的更新操作触发此触发器，
    导致电话号码不断被格式化*/
    IF LENGTH(NEW.phone)=10 THEN
        SET _phone1 = SUBSTR(NEW.phone, 1, 3);
        SET _phone2 = SUBSTR(NEW.phone, 4, 3);
        SET _phone3 = SUBSTR(NEW.phone, 7, 4);
        SET _phone = CONCAT(_phone1, '-', _phone2, '-', _phone3);
    
        SET NEW.phone = _phone;    
    END IF;
END $$
DELIMITER ;

/*
 * 触发器：auto_set_bagStatus_1
 * 增加租赁记录后，需要将该包的status置1，即“借出”状态
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_bagStatus_1 $$
CREATE TRIGGER auto_set_bagStatus_1
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    UPDATE handbags
        SET bagStatus = 1
        WHERE bagID=NEW.bagID;
END $$
DELIMITER ;

/*
 * 触发器：auto_set_bagStatus_0
 * 用户归还包，将rentals表的归还状态更新后，通过触发器将包的状态置0，即“在库”状态
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_bagStatus_0 $$
CREATE TRIGGER auto_set_bagStatus_0
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.returnStatus=1 AND OLD.returnStatus=0 THEN
        UPDATE handbags
	    SET bagStatus = 0
            WHERE bagID=NEW.bagID;
    END IF;
END $$
DELIMITER ;

/*
 * 触发器：auto_set_bagStatus_delete
 * 在删除交易后，自动将包的状态更新为“在库”
 */
DELIMITER $$
DROP TRIGGER IF EXISTS auto_set_bagStatus_delete $$
CREATE TRIGGER auto_set_bagStatus_delete
AFTER DELETE ON rentals
FOR EACH ROW
BEGIN
    UPDATE handbags
        SET bagStatus = 0
        WHERE bagID = OLD.bagID;
END $$
DELIMITER ;

/* =============================================================================== */

/*
 * 存储过程：bag_by_designer(designer)
 * 查询某设计师设计的所有包
 * 输入designer，列出bagName,color,manufacturer
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS bag_by_designer $$
CREATE PROCEDURE bag_by_designer(_designer VARCHAR(20))
BEGIN
    SELECT * 
        FROM handbags 
        WHERE designer=_designer;
END $$
DELIMITER ;

/*
 * 存储过程：best_customers()
 * 计算并添加每个客户所有包包的租赁时间
 * 列出lastName,firstName,address,phone,totalLengthOfRentals
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS best_customers $$
CREATE PROCEDURE best_customers()
BEGIN
    -- 这里直接获取了触发器计算的结果
    SELECT *
        FROM customers
        ORDER BY totalLengthOfRental DESC;
END $$
DELIMITER ;

/*
 * 存储过程：report_customer_amount(customerID)
 * 计算客户的消费金额，注意insurance
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS report_customer_amount $$
CREATE PROCEDURE report_customer_amount(_customerID CHAR(5))
BEGIN
    -- 客户姓名
    /*SELECT lastName, firstName
        FROM customers
        WHERE customerID=_customerID;*/
        
    
    
    -- 各个包所花费用
    SELECT h.manufacturer, h.bagName, 
    SUM(IF(r.insurance, h.pricePerDay+1, h.pricePerDay)*TIMESTAMPDIFF(DAY, 
    r.dateRented, r.dateReturned)) AS amount
        FROM handbags h, customers c, rentals r
        WHERE r.customerID=c.customerID 
            AND r.bagID=h.bagID 
            AND c.customerID=_customerID
        GROUP BY h.bagID;
        
    -- 总费用
    /*SELECT SUM(h.pricePerDay*TIMESTAMPDIFF(DAY, r.dateRented, r.dateReturned)) AS amount
        FROM handbags h, customers c, rentals r
        WHERE r.customerID=c.customerID 
            AND r.bagID=h.bagID 
            AND c.customerID=_customerID;*/
END $$
DELIMITER ;

/*
 * 存储过程：add_rentals(customerID, bagID, dateRented, dateReturned, insurance)
 * 向rentals表添加元组 其中dateRented为当前时间
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS add_rentals $$
CREATE PROCEDURE add_rentals(_customerID CHAR(5), _bagID CHAR(3), 
    _dateRented TIMESTAMP, _dateReturned TIMESTAMP, _insurance INT)
BEGIN

    DECLARE lengthOfRental INT;
    SET lengthOfRental = TIMESTAMPDIFF(DAY, _dateRented, _dateReturned);

    -- 归还日期大于租赁日期才插入数据
    IF lengthOfRental>0 THEN
        INSERT INTO rentals (customerID, bagID, dateRented, dateReturned, insurance) VALUES
            (_customerID, _bagID, _dateRented, _dateReturned, _insurance);
    END IF;
END $$
DELIMITER ;

/*
 * 存储过程：add_handbags(bagName, manufacturer, designer, bagType, color, pricePerDay)
 * 向handbags表添加元组
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS add_handbags $$
CREATE PROCEDURE add_handbags(_bagName VARCHAR(30), _manufacturer VARCHAR(20), _designer VARCHAR(20), 
    _bagType VARCHAR(20), _color VARCHAR(20), _pricePerDay DECIMAL(4, 2))
BEGIN
    INSERT INTO handbags (bagName, manufacturer, designer, bagType, color, pricePerDay) VALUES
        (_bagName, _manufacturer, _designer, _bagType, _color, _pricePerDay);
END $$
DELIMITER ;

/*
 * 存储过程：add_customers(firstName, lastName, phone, address, emailAddr, creditCardID)
 * 向customers表添加元组
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS add_customers $$
CREATE PROCEDURE add_customers(_firstName VARCHAR(20), _lastName VARCHAR(20), _phone VARCHAR(12), 
    _address TEXT, _emailAddr VARCHAR(20), _creditCardID CHAR(12))
BEGIN
    INSERT INTO customers(firstName, lastName, phone, address, emailAddr, creditCardID) VALUES
        (_firstName, _lastName, _phone, _address, _emailAddr, _creditCardID);
END $$
DELIMITER ;

/*
 * 存储过程：report_info_afterReturned(rentalID)
 * 包被归还（更新交易表的归还状态,触发器更新包的状态），打印信息表明租借的总长度
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS report_info_afterReturned $$
CREATE PROCEDURE report_info_afterReturned(_rentalID CHAR(4))
BEGIN
    -- 更新rentals表中该包的归还状态
    UPDATE rentals
        SET returnStatus = 1
        WHERE rentalID=_rentalID AND returnStatus = 0;
    
    -- 归还日期定为租赁时填写的日期，而非点击归还那一时刻
    -- 打印信息
    SELECT TIMESTAMPDIFF(DAY, dateRented, dateReturned) AS totalLengthOfRental
        FROM rentals
        WHERE rentalID=_rentalID;
END $$
DELIMITER ;

/*
 * 存储过程：report_info2_afterReturned(rentalID)
 * 包被归还（更新交易表的归还状态,触发器更新包的状态），打印信息表明租借的总金额
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS report_info2_afterReturned $$
CREATE PROCEDURE report_info2_afterReturned(_rentalID CHAR(4))
BEGIN
    DECLARE _insurance SMALLINT;
    
    -- 是否购买保险
    SELECT insurance INTO _insurance 
        FROM rentals 
        WHERE rentalID=_rentalID;
    
    -- 更新rentals表中该包的归还状态
    UPDATE rentals
        SET returnStatus = 1
        WHERE rentalID=_rentalID AND returnStatus = 0;
    
    -- 归还日期定为租赁时填写的日期
    -- 打印信息
    -- 没保险
    IF _insurance = 0 THEN
        SELECT (pricePerDay*TIMESTAMPDIFF(DAY, dateRented, dateReturned)) 
        AS totalPriceOfRental
            FROM rentals, handbags
            WHERE rentals.rentalID=_rentalID
                AND handbags.bagID = rentals.bagID;
    -- 有保险
    ELSEIF _insurance = 1 THEN
        SELECT ((pricePerDay+1)*TIMESTAMPDIFF(DAY, dateRented, dateReturned)) 
        AS totalPriceOfRental
            FROM rentals, handbags
            WHERE rentals.rentalID=_rentalID
                AND handbags.bagID = rentals.bagID;
    END IF;
END $$
DELIMITER ;

/*
 * 存储过程：get_customer_rentalInfo(customerID)
 * 查找某个客户的购买信息
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS get_customer_rentalInfo $$
CREATE PROCEDURE get_customer_rentalInfo(_customerID CHAR(5))
BEGIN
    DECLARE noOfCustomers SMALLINT;
    DECLARE msg TEXT;
    
    SELECT COUNT(*) INTO noOfCustomers 
        FROM customers
        WHERE customers.customerID=_customerID;
    -- 不存在此客户ID
    IF noOfCustomers = 0 THEN 
        SET msg = '查找的客户ID不存在';
        SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = msg;
    -- 显示该客户的购买信息
    ELSE
        SELECT bagName, dateRented, dateReturned, insurance
            FROM rentals, handbags
            WHERE rentals.customerID=_customerID AND rentals.bagID=handbags.bagID;
    END IF;   
END $$
DELIMITER ;

/*
 * 存储过程：searchHandbags(searchType, searchContent)
 * 根据前端传来的searchType来判断搜索哪一列内容
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS searchHandbags $$
CREATE PROCEDURE searchHandbags(searchType VARCHAR(20), searchContent VARCHAR(20))
BEGIN
    IF searchType = 'all' THEN
        SELECT * FROM handbags
            WHERE bagID LIKE CONCAT('%', searchContent, '%') OR
                  bagName LIKE CONCAT('%', searchContent, '%') OR
                  manufacturer LIKE CONCAT('%', searchContent, '%') OR
                  designer LIKE CONCAT('%', searchContent, '%') OR
                  bagType LIKE CONCAT('%', searchContent, '%') OR
                  color LIKE CONCAT('%', searchContent, '%') OR
                  pricePerDay LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'bagID' THEN
        SELECT * FROM handbags WHERE bagID LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'bagName' THEN
        SELECT * FROM handbags WHERE bagName LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'manufacturer' THEN
        SELECT * FROM handbags WHERE manufacturer LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'designer' THEN
        SELECT * FROM handbags WHERE designer LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'bagType' THEN
        SELECT * FROM handbags WHERE bagType LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'color' THEN
        SELECT * FROM handbags WHERE color LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'pricePerDay' THEN
        SELECT * FROM handbags WHERE pricePerDay LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'bagStatus' THEN
        SELECT * FROM handbags WHERE bagStatus=searchContent;
    END IF;
END $$
DELIMITER ;

/*
 * 存储过程：searchCustomers(searchType, searchContent)
 * 根据前端传来的searchType来判断搜索哪一列内容
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS searchCustomers $$
CREATE PROCEDURE searchCustomers(searchType VARCHAR(20), searchContent VARCHAR(20))
BEGIN
    IF searchType = 'all' THEN
        SELECT * FROM customers
            WHERE customerID LIKE CONCAT('%', searchContent, '%') OR
	          firstName LIKE CONCAT('%', searchContent, '%') OR
	          lastName LIKE CONCAT('%', searchContent, '%') OR
	          phone LIKE CONCAT('%', searchContent, '%') OR
	          address LIKE CONCAT('%', searchContent, '%') OR
	          emailAddr LIKE CONCAT('%', searchContent, '%') OR
	          creditCardID LIKE CONCAT('%', searchContent, '%') OR
	          totalLengthOfRental LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'customerID' THEN
        SELECT * FROM customers WHERE customerID LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'firstName' THEN
        SELECT * FROM customers WHERE firstName LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'lastName' THEN
        SELECT * FROM customers WHERE lastName LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'phone' THEN
        SELECT * FROM customers WHERE phone LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'address' THEN
        SELECT * FROM customers WHERE address LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'emailAddr' THEN
        SELECT * FROM customers WHERE emailAddr LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'creditCardID' THEN
        SELECT * FROM customers WHERE creditCardID LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'totalLengthOfRental' THEN
        SELECT * FROM customers WHERE totalLengthOfRental LIKE CONCAT('%', searchContent, '%');
    END IF;
END $$
DELIMITER ;

/*
 * 存储过程：searchRentals(searchType, searchContent)
 * 根据前端传来的searchType来判断搜索哪一列内容
 */
DELIMITER $$
DROP PROCEDURE IF EXISTS searchRentals $$
CREATE PROCEDURE searchRentals(searchType VARCHAR(20), searchContent VARCHAR(20))
BEGIN
    IF searchType = 'all' THEN
        SELECT * FROM rentals, customers, handbags
            WHERE rentals.customerID=customers.customerID
                AND rentals.bagID=handbags.bagID
                AND (firstName LIKE CONCAT('%', searchContent, '%') 
                OR lastName LIKE CONCAT('%', searchContent, '%')
                OR rentals.customerID = searchContent
                OR CONCAT(firstName, lastName) LIKE CONCAT('%', searchContent, '%')
                OR bagName LIKE CONCAT('%', searchContent, '%')
                OR rentals.bagID = searchContent);
    ELSEIF searchType = 'customer' THEN
        SELECT * FROM rentals, customers
            WHERE rentals.customerID=customers.customerID
                AND (firstName LIKE CONCAT('%', searchContent, '%') 
                OR lastName LIKE CONCAT('%', searchContent, '%')
                OR CONCAT(firstName, lastName) LIKE CONCAT('%', searchContent, '%'));
    ELSEIF searchType = 'customerID' THEN
        SELECT * FROM rentals
            WHERE customerID = searchContent;
    ELSEIF searchType = 'bag' THEN
        SELECT * FROM rentals, handbags
            WHERE rentals.bagID=handbags.bagID
                AND bagName LIKE CONCAT('%', searchContent, '%');
    ELSEIF searchType = 'bagID' THEN
        SELECT * FROM rentals
            WHERE bagID = searchContent;
    END IF;
END $$
DELIMITER ;

/* =============================================================================== */

/*INSERT INTO handbags (bagName, manufacturer, designer, bagType, color, pricePerDay) VALUES
('bag01', 'manuxxx01', 'desixxx01', 'typexxx01', 'blue', '10'),
('bag02', 'manuxxx02', 'desixxx02', 'typexxx02', 'red', '20'),
('bag03', 'manuxxx03', 'desixxx03', 'typexxx03', 'green', '30');*/

/*INSERT INTO customers (firstName, lastName, phone, address, emailAddr, creditCardID) VALUES
('firstxxx01', 'lastxxx', '0123456781', 'addressxxxx', '1487792164@qq.com1', '012345678911'),
('firstxxx02', 'lastxxx', '0123456782', 'addressxxxx', '1487792164@qq.com2', '012345678912'),
('firstxxx03', 'lastxxx', '0123456783', 'addressxxxx', '1487792164@qq.com3', '012345678913');*/


/*INSERT INTO rentals (customerID, bagID, dateRented, dateReturned, insurance) VALUES
('00002', '002', '2021/12/12', '2021-12-13', '0'),
('00002', '003', '2021/12/12', '2021-12-15', '1');*/

INSERT INTO customers (firstName, lastName, phone, address, emailAddr, creditCardID) VALUES
('Annabelle', 'Murray', '4049983928', '54 Oak Ave', 'email01@163.com', '443355463212'),
('Gina', 'Franco', '4048872342', '1012 Peachtree St', 'email02@163.com', '443398764532'),
('Sally', 'Quinn', '4049873427', '54 Oak Ave', 'email03@163.com', '443398765439'),
('Maria', 'Lopato', '4042348876', '5490 West 5th', 'email04@163.com', '443352635423'),
('Joan', 'Zern', '4046750091', '58 W. Central Ave', 'email05@163.com', '443357643254'),
('Anna', 'Berry', '4048874673', '9 Pleasant Way', 'email06@163.com', '443398762534'),
('Jill', 'Pao', '4048879238', '89 Orchard', 'email07@163.com', '443367256543'),
('Patricia', 'Smith', '4047653342', '1700 E. Lincoln Ave', 'email08@163.com', '443376562837'),
('名豪', '冯', '1812455261', '深圳市南山区深圳大学', '1487792164@qq.com', '112233445566');

INSERT INTO handbags (bagID, bagName, manufacturer, designer, bagType, color, pricePerDay) VALUES
('101', 'Claudia', 'Louis Vuitton', 'designer01', 'type01', 'white', '8.75'),
('107', 'Messenger', 'Prada', 'designer02', 'type02', 'Black', '9.50'),
('102', 'Cabas Piano', 'Louis Vuitton', 'designer03', 'type03', 'Multi', '8.75'),
('104', 'Satchel', 'Coach', 'designer04', 'type04', 'Camel', '9.00'),
('105', 'Hippie Flap', 'Coach', 'designer01', 'type02', 'Green', '9.00'),
('110', 'Haymarket Woven Warrier', 'Burberry', 'designer02', 'type03', 'Gold', '10.00'),
('106', 'Bleeker Bucket', 'Coach', 'designer03', 'type01', 'Blue', '9.00'),
('108', 'Fairy', 'Prada', 'designer04', 'type02', 'Multi', '9.50'),
('103', 'Monogram Pochette', 'Louis Vuitton', 'designer01', 'type01', 'Multi', '8.75'),
('109', 'Glove Soft Pebble', 'Prada', 'designer02', 'type04', 'Mauve', '9.50'),
('111', 'Knight', 'Burberry', 'designer04', 'type03', 'Plaid', '10.00');

INSERT INTO rentals (customerID, bagID, dateRented, dateReturned, insurance) VALUES
('00001', '101', '2011/4/12', '2011/4/30', '1'),
('00001', '107', '2011/1/19', '2011/2/1', '1'),
('00002', '102', '2011/2/11', '2011/2/19', '1'),
('00002', '104', '2011/3/9', '2011/3/11', '1'),
('00002', '105', '2011/5/21', '2011/5/25', '1'),
('00003', '110', '2011/3/16', '2011/3/17', '0'),
('00004', '106', '2011/5/18', '2011/5/25', '0'),
('00005', '108', '2011/1/1', '2011/2/1', '1');
-- 归还101包
UPDATE rentals SET returnStatus=1 WHERE bagID=101 AND returnStatus=0;
INSERT INTO rentals (customerID, bagID, dateRented, dateReturned, insurance) VALUES
('00005', '101', '2011/6/2', '2011/6/8', '1'),
('00005', '103', '2011/5/6', '2011/5/9', '1'),
('00006', '109', '2011/6/2', '2011/6/30', '0'),
('00007', '111', '2011/2/19', '2011/3/1', '1');
-- 归还111, 101, 103, 106包包
UPDATE rentals SET returnStatus=1 
    WHERE (bagID=111 OR bagID=101 OR bagID=103 OR bagID=106) AND returnStatus=0;
INSERT INTO rentals (customerID, bagID, dateRented, dateReturned, insurance) VALUES
('00007', '111', '2011/3/30', '2011/4/2', '1'),
('00008', '101', '2011/3/5', '2011/3/9', '0'),
('00008', '103', '2011/4/1', '2011/4/21', '0'),
('00008', '106', '2011/5/5', '2011/5/9', '0');

-- CALL bag_by_designer('desixxx01');
-- call best_customers();
-- CALL report_customer_amount('00005');
-- CALL add_handbags('bag04', 'manuxxx04', 'desixxx04', 'typexxx04', 'black', '40');
-- CALL add_handbags('bag05', 'manuxxx05', 'desixxx05', 'typexxx05', 'black', '-40');
-- CALL add_rentals('00001', '001', '2021/12/12', '2021-12-15', '1');
-- call report_info_afterReturned('00002', '003');
-- call report_info_afterReturned('00004', '012');
-- CALL report_info2_afterReturned('00004', '012');

-- 测试添加已有数据时是否能抛出错误
-- CALL add_handbags('bag04', 'manuxxx04', 'desixxx04', 'typexxx04', 'black', '40');
-- call add_customers('firstxxx03', 'lastxxx', '0123456783', 'addressxxxx', '1487792164@qq.com3', '012345678913');

-- 查找客户的购买信息，测试查询不存在的ID时是否能抛出错误
-- CALL get_customer_rentalInfo('00001');
-- call get_customer_rentalInfo('00005');

-- CALL searchHandbags('all', '01');
-- CALL searchCustomers('all', 'x01');

-- SELECT CONCAT(SUBSTR(phone, 1, 3), SUBSTR(phone, 5, 3), SUBSTR(phone, 9, 4)) AS phone FROM customers;

-- 测试级联删除
-- CALL add_rentals('00005', '005', '2021/12/12', '2021-12-18', '1');
-- delete from customers where customerID='00005';

-- update customers set creditCardID='012345678911' where customerID='00004';

-- CALL add_rentals('00001', '004', '20211212', '2021-12-15', '1');
