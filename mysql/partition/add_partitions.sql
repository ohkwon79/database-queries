DELIMITER $$
CREATE PROCEDURE `ADD_PARTITIONS`(
	tableName VARCHAR(50), -- 테이블 이름
	tomorrow DATE -- 현재 날자 기준으로 
)
COMMENT 'Add new PARTITIONS'
BEGIN
	DECLARE fromDays INT;
	DECLARE to_sql VARCHAR(4000) DEFAULT '';

	SET @now = TO_DAYS(NOW());
	SELECT MAX(PARTITION_DESCRIPTION) INTO fromDays 
    	FROM INFORMATION_SCHEMA.PARTITIONS
    	WHERE TABLE_NAME = tableName AND PARTITION_NAME LIKE 'p%';
    IF fromDays IS NULL THEN
    	SELECT TO_DAYS(minDate) into fromDays FROM (SELECT MIN(time_created) AS minDate FROM tb_device_history) a;
    END IF;
   	IF fromDays IS NULL THEN
   		SET fromDays = @now;
   	END IF;
   
	add_loop: LOOP
		IF fromDays > TO_DAYS(tomorrow) THEN 
			LEAVE add_loop;
		END IF;
		SET @name = CONCAT('p', DATE_FORMAT(FROM_DAYS(fromDays), '%Y%m%d'));  
		SET to_sql = concat(to_sql, '    PARTITION `', @name, '` VALUES LESS THAN (', fromDays + 1, '),\n');
		SET fromDays = fromDays + 1;
	END LOOP;
	
	IF LENGTH(to_sql) > 0 THEN
		SET @alter_sql = CONCAT('ALTER TABLE tb_device_history REORGANIZE PARTITION\n'
			'    future\n',
			'INTO (\n',
			to_sql,
			'    PARTITION future VALUES LESS THAN MAXVALUE\n',
			');');
		PREPARE stmt FROM @alter_sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END IF;
END $$
DELIMITER ;