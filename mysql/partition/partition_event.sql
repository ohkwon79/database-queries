DELIMITER $$
CREATE EVENT ev_device_history
    ON SCHEDULE EVERY 1 DAY
        STARTS '2023-04-05 00:00:00.000'
    ON COMPLETION NOT PRESERVE
    ENABLE
DO BEGIN
	SET @tableName = 'tb_device_history';
	SET @today = CURRENT_DATE();
	SET @tomorrow = DATE_ADD(@today, INTERVAL 1 DAY);
	SET @ago = DATE_SUB(@today, INTERVAL 30 DAY);
	CALL ADD_PARTITIONS(@tableName, @tomorrow);
	CALL DROP_PARTITIONS(@tableName, @ago);
END $$
DELIMITER ;
