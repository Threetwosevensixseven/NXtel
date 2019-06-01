ALTER TABLE `nxtel`.`stats` 
ADD INDEX `ix_stats_PageNo` (`PageNo` ASC);

/*Total unique client count*/
SELECT COUNT(*) AS cnt from (
	SELECT ClientHash
	FROM stats
	GROUP BY ClientHash
) AS clients;

/*Total unique page count - WRONG*/
SELECT COUNT(*) AS cnt from (
	SELECT PageNo,COUNT(*) AS cnt
	FROM stats
	GROUP BY PageNo
) AS pages;

/*Total unique day count*/
SELECT COUNT(*) AS cnt from (
	SELECT DATE(`Timestamp`) AS dt,COUNT(*) AS cnt
	FROM stats
    GROUP BY dt
) AS days;

/*Unique client count per day*/
SELECT dt,COUNT(*) AS cnt from (
	SELECT DATE(`Timestamp`) AS dt,ClientHash,COUNT(*) AS cnt
	FROM stats
    GROUP BY dt,ClientHash
    ) AS clientdays
GROUP BY dt
ORDER BY dt DESC;

/*Unique page count per day*/
SELECT dt,COUNT(*) AS cnt from (
	SELECT DATE(`Timestamp`) AS dt,PageNo,COUNT(*) AS cnt
	FROM stats
    GROUP BY dt,PageNo
    ) AS clientpages
GROUP BY dt
ORDER BY dt DESC;

/*Most popular page per day - WRONG*/
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SELECT dt,MAX(ky) AS mx FROM (
	SELECT DATE(`Timestamp`) AS dt,PageNo,COUNT(*) AS cnt,
    CAST(CONCAT(DATE(`Timestamp`),'-',LPAD(CAST(COUNT(*) AS char),11,'0'),'-',LPAD(CAST(PageNo AS char),11,'0')) AS char) AS ky
	FROM stats
    WHERE PageNo NOT IN(0,1)
    GROUP BY dt,PageNo,ClientHash
    ) AS clientdayspages
GROUP BY dt
ORDER BY dt DESC;

/*Last seen date/time*/
SELECT MAX(`Timestamp`) AS ts
FROM stats
WHERE ClientHash='03c797814c031ad9c99748c5c999bc4b';

/*Most popular page per day*/
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SELECT dt,MAX(ky) AS mx FROM (
	SELECT dt,PageNo,
	CAST(CONCAT(dt,'-',LPAD(CAST(COUNT(*) AS char),11,'0'),'-',LPAD(CAST(PageNo AS char),11,'0')) AS char) AS ky
	 FROM (
		SELECT DATE(`Timestamp`) AS dt,PageNo
		FROM stats
		WHERE PageNo NOT IN(0,1)
		GROUP BY dt,PageNo,ClientHash
	) AS daysclientspages
	GROUP BY dt,PageNo
) AS dayspages
GROUP BY dt
ORDER BY dt DESC;

