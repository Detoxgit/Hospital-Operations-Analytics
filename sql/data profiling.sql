USE hospital_analysis;
SHOW TABLES;

DESC patient;

SELECT
    table_name,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'hospital_analysis';

-- Missing Value 
SELECT
SUM(patient_id IS NULL) AS patient_id_null,

SUM(TRIM(gender)='') AS gender_blank,
SUM(gender IS NULL) AS gender_null,

SUM(TRIM(date_of_birth)='') AS dob_blank,
SUM(date_of_birth IS NULL) AS dob_null,

SUM(TRIM(blood_group)='') AS blood_group_blank,
SUM(blood_group IS NULL) AS blood_group_null,

SUM(TRIM(city)='') AS city_blank,
SUM(city IS NULL) AS city_null,

SUM(TRIM(contact_number)='') AS contact_blank,
SUM(contact_number IS NULL) AS contact_null

FROM patient;

-- Primary Key Duplicates
SELECT patient_id,
       COUNT(*) AS duplicate_count
FROM patient
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Business Duplicates
SELECT
    gender,
    date_of_birth,
    city,
    contact_number,
    COUNT(*) AS duplicate_count
FROM patient
GROUP BY
    gender,
    date_of_birth,
    city,
    contact_number
HAVING COUNT(*) > 1;

-- Checking Phone number
SELECT *
FROM patient
WHERE LENGTH(contact_number) <> 10;

SELECT *
FROM patient
WHERE contact_number NOT REGEXP '^[0-9]{10}$';

-- Age Validation
SELECT
    patient_id,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(date_of_birth,'%d-%m-%Y'),
        CURDATE()
    ) AS age
FROM patient;



