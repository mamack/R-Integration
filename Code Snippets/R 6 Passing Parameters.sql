SET SCHEMA R;

-- app setup

DROP VIEW R_KM_DATA;
CREATE VIEW R_KM_DATA AS
 SELECT ID, LIFESPEND, NEWSPEND, INCOME, LOYALTY
  FROM CUSTOMERS
  ;

DROP TABLE R_KM_PARAMS;
CREATE COLUMN TABLE R_KM_PARAMS (PNAME VARCHAR(60), PVALUE INTEGER);
INSERT INTO R_KM_PARAMS VALUES ('CENTERS',3);

DROP TABLE R_KM_RESULTS;
CREATE COLUMN TABLE R_KM_RESULTS (ID BIGINT NOT NULL, CLUSTERNUMBER INTEGER);

-- R setup
DROP PROCEDURE R_KM;
CREATE PROCEDURE R_KM (IN data R_KM_DATA, IN params R_KM_PARAMS, OUT results R_KM_RESULTS)
LANGUAGE RLANG AS 
BEGIN
	library(cluster)
	clusters <- kmeans(data[c('LIFESPEND','NEWSPEND','INCOME','LOYALTY')], params[params$PNAME=='CENTERS',]$PVALUE)
	results <- cbind(data[c('ID')], CLUSTERNUMBER=clusters$cluster)
END;

-- app runtime

--UPDATE R_KM_PARAMS SET PVALUE=5 WHERE PNAME='CENTERS';

TRUNCATE TABLE R_KM_RESULTS;

CALL R_KM (R_KM_DATA, R_KM_PARAMS, R_KM_RESULTS) WITH OVERVIEW;

SELECT * FROM R_KM_DATA;
SELECT * FROM R_KM_PARAMS;
SELECT * FROM R_KM_RESULTS;