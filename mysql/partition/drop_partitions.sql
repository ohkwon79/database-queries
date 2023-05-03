DELIMITER $$
CREATE PROCEDURE `DROP_PARTITIONS`(
	tableName VARCHAR(50), -- 테이블 이름
	ago DATE -- 현재 날자 기준으로 
)
COMMENT 'DROP old PARTITIONS'
BEGIN
	DECLARE partitionCount INT;
	DECLARE toDays INT;
	DECLARE partitionName VARCHAR(50);
	drop_loop: LOOP
		SELECT COUNT(*) INTO partitionCount FROM INFORMATION_SCHEMA.PARTITIONS
			WHERE TABLE_NAME = tableName AND PARTITION_NAME LIKE 'p%';
		IF partitionCount < 2 THEN	-- start와 future를 제외한 PARTITION 이 2개 이상 있을 때만 DROP 한다.
			LEAVE drop_loop;
		END IF;
		SELECT PARTITION_NAME, PARTITION_DESCRIPTION INTO partitionName, toDays 
			FROM INFORMATION_SCHEMA.PARTITIONS
			WHERE TABLE_NAME = tableName AND PARTITION_NAME LIKE 'p%'
			ORDER BY PARTITION_DESCRIPTION ASC
			LIMIT 1;
		IF TO_DAYS(ago) < toDays THEN	-- 지정한 날자보다 작을 때만 DROP 한다.
			LEAVE drop_loop;
		END IF;
		SET @alter_sql = CONCAT('ALTER TABLE `', tableName, '` DROP PARTITION `', partitionName, '`;');
        PREPARE stmt FROM @alter_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
	END LOOP;
END $$
DELIMITER ;