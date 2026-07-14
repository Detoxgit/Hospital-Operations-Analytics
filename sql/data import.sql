USE hospital_analysis;

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/patient.csv'
INTO TABLE patient
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    patient_id,
    gender,
    date_of_birth,
    blood_group,
    city,
    contact_number
);

SELECT COUNT(*) FROM patient;
describe admission;
ALTER TABLE admission
MODIFY admission_date VARCHAR(20),
MODIFY discharge_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/admission.csv'
INTO TABLE admission
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    admission_id,
    admission_date,
    discharge_date,
    admission_type,
    admission_status,
    patient_id,
    department_id,
    ward_id,
    bed_id,
    disease_id
);

SELECT count(*) from admission;

describe patient_insurance;

ALTER TABLE patient_insurance
MODIFY policy_start_date VARCHAR(20),
MODIFY policy_end_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/patient_insurance.csv'
INTO TABLE patient_insurance
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    patient_insurance_id,
    policy_number,
    coverage_percentage,
    policy_start_date,
    policy_end_date,
    patient_id,
    insurance_provider_id
);

SELECT count(*) from patient_insurance;

describe billing;

ALTER TABLE billing
MODIFY bill_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/billing.csv'
INTO TABLE billing
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    bill_id,
    bill_date,
    total_amount,
    insurance_covered_amount,
    patient_payable_amount,
    payment_status,
    payment_mode,
    admission_id
);

SELECT count(*) from billing;

describe billing_detail;

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/billing_detail.csv'
INTO TABLE billing_detail
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    billing_detail_id,
    charge_type,
    reference_id,
    amount,
    bill_id
);

SELECT count(*) from billing_detail;

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/prescription.csv'
INTO TABLE prescription
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    prescription_id,
    dosage,
    frequency,
    duration_days,
    admission_id,
    drug_id
);

SELECT count(*) from prescription;

ALTER TABLE patient_diagnostic
MODIFY test_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/patient_diagnostic.csv'
INTO TABLE patient_diagnostic
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    patient_diagnostic_id,
    test_date,
    result_status,
    admission_id,
    test_id,
    doctor_id
);

SELECT count(*) from patient_diagnostic;

ALTER TABLE drug_inventory
MODIFY last_restock_date VARCHAR(20);

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/drug_inventory.csv'
INTO TABLE drug_inventory
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    inventory_id,
    current_stock,
    reorder_level,
    inventory_status,
    last_restock_date,
    drug_id
);

SELECT count(*) from drug_inventory;
SELECT * from drug_inventory;

LOAD DATA LOCAL INFILE 'C:/Users/HP/Desktop/Data analyst projects/Hospital-Operations-Analytics/data/raw/staff_assignment.csv'
INTO TABLE staff_assignment
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    assignment_id,
    employee_id,
    ward_id,
    shift
);

SELECT count(*) from staff_assignment;