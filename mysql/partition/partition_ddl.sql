CREATE TABLE `my_table_history` (
  `content` varchar(200),
  `createdAt` datetime NOT NULL,
  `id` bigint (20) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`, `createdAt`) USING BTREE
) ENGINE = InnoDB PARTITION BY RANGE (to_days (`createdAt`)) (
  PARTITION `start` VALUES LESS THAN (0), -- 유효하지 않은 날자가 조회조건으로 들어오는 것을 방어함
  PARTITION `future` VALUES LESS THAN MAXVALUE
);