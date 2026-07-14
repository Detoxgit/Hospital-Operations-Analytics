USE hospital_analysis;
-- Convert date column back to date as we used varchar
-- Patient
UPDATE patient
SET date_of_birth =
STR_TO_DATE(date_of_birth,'%d-%m-%Y');

ALTER TABLE patient
MODIFY date_of_birth DATE;

-- Admission
UPDATE admission
SET
admission_date =
STR_TO_DATE(admission_date,'%d-%m-%Y'),
discharge_date =
STR_TO_DATE(discharge_date,'%d-%m-%Y');

ALTER TABLE admission
MODIFY admission_date DATE,
MODIFY discharge_date DATE;

-- Pateint Insurance
UPDATE patient_insurance
SET
policy_start_date =
STR_TO_DATE(policy_start_date,'%d-%m-%Y'),

policy_end_date =
STR_TO_DATE(policy_end_date,'%d-%m-%Y');

ALTER TABLE patient_insurance
MODIFY policy_start_date DATE,
MODIFY policy_end_date DATE;

-- Billing
UPDATE billing
SET bill_date =
STR_TO_DATE(bill_date,'%d-%m-%Y');

ALTER TABLE billing
MODIFY bill_date DATE;

-- Pateint Diagnostic

UPDATE patient_diagnostic
SET test_date =
STR_TO_DATE(test_date,'%d-%m-%Y');

ALTER TABLE patient_diagnostic
MODIFY test_date DATE;

-- Drug Inventory
UPDATE drug_inventory
SET last_restock_date =
STR_TO_DATE(last_restock_date,'%d-%m-%Y');

ALTER TABLE drug_inventory
MODIFY last_restock_date DATE;

-- Standardization
SELECT gender, COUNT(*) AS total
FROM patient
GROUP BY gender; -- no need to change as already correct

-- we wont get much difference as most of it is checked in the data entry process

-- ============================================================
-- Contact Number Cleaning
-- ============================================================
UPDATE patient
SET contact_number = REPLACE(contact_number,' ','');
UPDATE patient
SET contact_number = REPLACE(contact_number,'-','');

-- Billing Validation
SELECT *
FROM billing
WHERE insurance_covered_amount > total_amount;

-- admission verification
SELECT *
FROM admission
WHERE discharge_date < admission_date;

-- Drug Inventory no neg stock we will remove that data
SELECT *
FROM drug_inventory
WHERE current_stock < 0;

-- Insurance coverage percentage
SELECT *
FROM patient_insurance
WHERE coverage_percentage NOT BETWEEN 0 AND 100;

-- ==================================================
-- FEATURE ENGINEERING(CREATION OF NEW ANALYTICAL FEATURES)
-- ==================================================
-- Patient Age
ALTER TABLE patient
ADD COLUMN age INT;
UPDATE patient
SET age = TIMESTAMPDIFF(
    YEAR,
    date_of_birth,
    CURDATE()
);

-- Age Group
ALTER TABLE patient
ADD COLUMN age_group VARCHAR(20);

UPDATE patient
SET age_group =
CASE
    WHEN age < 18 THEN 'Child'
    WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN age BETWEEN 36 AND 60 THEN 'Adult'
    ELSE 'Senior'
END;

-- Length Of Stay
ALTER TABLE admission
ADD COLUMN stay_length INT;

UPDATE admission
SET stay_length = DATEDIFF(discharge_date, admission_date);

-- Bill Category

ALTER TABLE billing
ADD COLUMN bill_category VARCHAR(20);

UPDATE billing
SET bill_category =
CASE
    WHEN total_amount < 10000 THEN 'Low'
    WHEN total_amount < 50000 THEN 'Medium'
    ELSE 'High'
END;


-- ===============================================
-- Analytical Views
-- ===============================================

-- Patient Summary
CREATE VIEW vw_patient_summary AS
SELECT
    p.patient_id,
    p.gender,
    p.age,
    p.age_group,
    a.admission_id,
    a.stay_length,
    d.disease_name,
    b.total_amount
FROM patient p
JOIN admission a
    ON p.patient_id = a.patient_id
JOIN disease d
    ON a.disease_id = d.disease_id
JOIN billing b
    ON a.admission_id = b.admission_id;
    
SELECT *
FROM vw_patient_summary;

-- Department Performance
CREATE VIEW vw_department_performance AS
SELECT
    d.department_id,
    d.department_name,

    a.admission_id,

    dis.disease_name,

    b.total_amount,
    b.patient_payable_amount,
    b.insurance_covered_amount

FROM department d
JOIN admission a
    ON d.department_id = a.department_id
JOIN disease dis
    ON a.disease_id = dis.disease_id
JOIN billing b
    ON a.admission_id = b.admission_id;

SELECT * FROM vw_department_performance;

-- Doctor Performance
CREATE VIEW vw_doctor_performance AS
SELECT
    doc.doctor_id,
    doc.specialization,

    pd.patient_diagnostic_id,
    pd.test_date,
    pd.result_status,

    a.admission_id,

    p.patient_id,
    p.age_group

FROM doctor doc
JOIN patient_diagnostic pd
    ON doc.doctor_id = pd.doctor_id
JOIN admission a
    ON pd.admission_id = a.admission_id
JOIN patient p
    ON a.patient_id = p.patient_id;
    
SELECT * FROM vw_doctor_performance;

-- Ward Occupance View
CREATE VIEW vw_ward_summary AS
SELECT
    w.ward_id,
    w.ward_name,

    b.bed_id,

    a.admission_id,
    a.patient_id

FROM ward w
JOIN bed b
    ON w.ward_id = b.ward_id
LEFT JOIN admission a
    ON b.bed_id = a.bed_id;
    
-- Prescription View

CREATE VIEW vw_prescription_summary AS
SELECT
    p.prescription_id,

    d.drug_name,

    p.dosage,
    p.frequency,
    p.duration_days,

    a.patient_id

FROM prescription p
JOIN drug d
    ON p.drug_id = d.drug_id
JOIN admission a
    ON p.admission_id = a.admission_id;