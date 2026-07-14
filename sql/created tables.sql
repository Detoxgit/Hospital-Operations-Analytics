USE hospital_analysis;
CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_type VARCHAR(50) NOT NULL,
    floor_number INT,
    status VARCHAR(20) NOT NULL
);
CREATE TABLE ward (
    ward_id INT PRIMARY KEY,
    ward_name VARCHAR(100) NOT NULL,
    ward_type VARCHAR(30) NOT NULL,
    total_beds INT NOT NULL CHECK (total_beds > 0),
    department_id INT NOT NULL,
    CONSTRAINT fk_ward_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
);
CREATE TABLE bed (
    bed_id INT PRIMARY KEY,
    bed_number VARCHAR(20) NOT NULL,
    bed_status VARCHAR(20) NOT NULL,
    ward_id INT NOT NULL,
    CONSTRAINT chk_bed_status
        CHECK (
            bed_status IN (
                'Occupied',
                'Available',
                'Maintenance'
            )
        ),
    CONSTRAINT fk_bed_ward
        FOREIGN KEY (ward_id)
        REFERENCES ward(ward_id),
    INDEX idx_bed_ward (ward_id)
);
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    role VARCHAR(30) NOT NULL,
    employment_type VARCHAR(20) NOT NULL,
    date_of_joining DATE NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT chk_employee_gender
        CHECK (gender IN ('Male', 'Female')),
    CONSTRAINT chk_employment_type
        CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract')),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id),

    INDEX idx_employee_department (department_id)
);
CREATE TABLE doctor (
    doctor_id INT PRIMARY KEY,
    employee_id INT NOT NULL UNIQUE,
    specialization VARCHAR(50) NOT NULL,
    qualification VARCHAR(20) NOT NULL,
    experience_years INT NOT NULL,
    CONSTRAINT chk_experience
        CHECK (experience_years >= 0),
    CONSTRAINT fk_doctor_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id),

    INDEX idx_doctor_employee (employee_id)
);
CREATE TABLE disease (
    disease_id INT PRIMARY KEY,
    disease_name VARCHAR(150) NOT NULL UNIQUE,
    disease_category VARCHAR(50) NOT NULL
);
CREATE TABLE drug_manufacturer (
    manufacturer_id INT PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50) NOT NULL,
    reliability_rating DECIMAL(2,1) NOT NULL,
    contract_status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_reliability_rating
        CHECK (reliability_rating BETWEEN 0 AND 5),
    CONSTRAINT chk_contract_status
        CHECK (contract_status IN ('Active', 'Inactive'))
);
CREATE TABLE drug (
    drug_id INT PRIMARY KEY,
    drug_name VARCHAR(100) NOT NULL,
    brand_name VARCHAR(100) NOT NULL,
    drug_category VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    manufacturer_id INT NOT NULL,
    CONSTRAINT chk_unit_cost
        CHECK (unit_cost >= 0),
    CONSTRAINT fk_drug_manufacturer
        FOREIGN KEY (manufacturer_id)
        REFERENCES drug_manufacturer(manufacturer_id),

    INDEX idx_drug_manufacturer (manufacturer_id)
);
CREATE TABLE diagnostic_test (
    test_id INT PRIMARY KEY,
    test_name VARCHAR(100) NOT NULL UNIQUE,
    test_category VARCHAR(50) NOT NULL,
    standard_cost DECIMAL(10,2) NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT chk_standard_cost
        CHECK (standard_cost >= 0),
    CONSTRAINT fk_test_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id),

    INDEX idx_test_department (department_id)
);
CREATE TABLE insurance_provider (
    insurance_provider_id INT PRIMARY KEY,
    provider_name VARCHAR(150) NOT NULL UNIQUE,
    provider_type VARCHAR(20) NOT NULL,
    contact_details VARCHAR(20) NOT NULL,
    coverage_limit DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_provider_type
        CHECK (provider_type IN ('Private', 'Govt')),
    CONSTRAINT chk_coverage_limit
        CHECK (coverage_limit >= 0)
);
CREATE TABLE patient (
    patient_id INT PRIMARY KEY,
    gender VARCHAR(10) NOT NULL,
    date_of_birth varchar(10) NOT NULL,
    blood_group VARCHAR(5) NOT NULL,
    city VARCHAR(100) NOT NULL,
    contact_number VARCHAR(30) NOT NULL,
    CONSTRAINT chk_gender
        CHECK (gender IN ('Male', 'Female')),
    CONSTRAINT chk_blood_group
        CHECK (
            blood_group IN (
                'A+', 'A-',
                'B+', 'B-',
                'AB+', 'AB-',
                'O+', 'O-'
            )
        )
);
CREATE TABLE admission (
    admission_id INT PRIMARY KEY,
    admission_date DATE NOT NULL,
    discharge_date DATE NOT NULL,
    admission_type VARCHAR(20) NOT NULL,
    admission_status VARCHAR(20) NOT NULL,
    patient_id INT NOT NULL,
    department_id INT NOT NULL,
    ward_id INT NOT NULL,
    bed_id INT NOT NULL,
    disease_id INT NOT NULL,
    CONSTRAINT chk_admission_type
        CHECK (admission_type IN ('Emergency', 'Elective')),
    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),
    CONSTRAINT fk_admission_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id),
    CONSTRAINT fk_admission_ward
        FOREIGN KEY (ward_id)
        REFERENCES ward(ward_id),
    CONSTRAINT fk_admission_bed
        FOREIGN KEY (bed_id)
        REFERENCES bed(bed_id),
    CONSTRAINT fk_admission_disease
        FOREIGN KEY (disease_id)
        REFERENCES disease(disease_id),

    INDEX idx_admission_patient (patient_id),
    INDEX idx_admission_department (department_id),
    INDEX idx_admission_disease (disease_id),
    INDEX idx_admission_date (admission_date),
    INDEX idx_admission_ward (ward_id),
    INDEX idx_admission_bed (bed_id)
);
CREATE TABLE patient_insurance (
    patient_insurance_id INT PRIMARY KEY,
    policy_number VARCHAR(20) NOT NULL UNIQUE,
    coverage_percentage DECIMAL(5,2) NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    patient_id INT NOT NULL,
    insurance_provider_id INT NOT NULL,
    CONSTRAINT chk_coverage_percentage
        CHECK (coverage_percentage BETWEEN 0 AND 100),
    CONSTRAINT fk_patientinsurance_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),
    CONSTRAINT fk_patientinsurance_provider
        FOREIGN KEY (insurance_provider_id)
        REFERENCES insurance_provider(insurance_provider_id),
        
    INDEX idx_patient_insurance_patient (patient_id),
    INDEX idx_patient_insurance_provider (insurance_provider_id)
);
CREATE TABLE billing (
    bill_id INT PRIMARY KEY,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    insurance_covered_amount DECIMAL(12,2) NOT NULL,
    patient_payable_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_mode VARCHAR(20) NOT NULL,
    admission_id INT NOT NULL UNIQUE,
    CONSTRAINT chk_total_amount
        CHECK (total_amount >= 0),
    CONSTRAINT chk_insurance_amount
        CHECK (insurance_covered_amount >= 0),
    CONSTRAINT chk_patient_amount
        CHECK (patient_payable_amount >= 0),
    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('Paid', 'Pending')),
    CONSTRAINT chk_payment_mode
        CHECK (payment_mode IN ('Cash', 'Card', 'Insurance','UPI')),
    CONSTRAINT fk_billing_admission
        FOREIGN KEY (admission_id)
        REFERENCES admission(admission_id),

    INDEX idx_billing_date (bill_date)
);
CREATE TABLE billing_detail (
    billing_detail_id INT PRIMARY KEY,
    charge_type VARCHAR(30) NOT NULL,
    reference_id INT,
    amount DECIMAL(12,2) NOT NULL,
    bill_id INT NOT NULL,
    CONSTRAINT chk_charge_type
        CHECK (
            charge_type IN (
                'Room',
                'Drug',
                'Test',
                'Procedure'
            )
        ),
    CONSTRAINT chk_amount
        CHECK (amount >= 0),
    CONSTRAINT fk_billingdetail_bill
        FOREIGN KEY (bill_id)
        REFERENCES billing(bill_id),

    INDEX idx_billingdetail_bill (bill_id)
);
CREATE TABLE prescription (
    prescription_id INT PRIMARY KEY,
    dosage VARCHAR(30) NOT NULL,
    frequency VARCHAR(30) NOT NULL,
    duration_days INT NOT NULL,
    admission_id INT NOT NULL,
    drug_id INT NOT NULL,
    CONSTRAINT chk_frequency
        CHECK (
            frequency IN (
                'Once a day',
                'Twice a day',
                'Thrice a day'
            )
        ),
    CONSTRAINT chk_duration
        CHECK (duration_days > 0),
    CONSTRAINT fk_prescription_admission
        FOREIGN KEY (admission_id)
        REFERENCES admission(admission_id),
    CONSTRAINT fk_prescription_drug
        FOREIGN KEY (drug_id)
        REFERENCES drug(drug_id),

    INDEX idx_prescription_admission (admission_id),
    INDEX idx_prescription_drug (drug_id)
);
CREATE TABLE patient_diagnostic (
    patient_diagnostic_id INT PRIMARY KEY,
    test_date DATE NOT NULL,
    result_status VARCHAR(20) NOT NULL,
    admission_id INT NOT NULL,
    test_id INT NOT NULL,
    doctor_id INT NOT NULL,
    CONSTRAINT chk_result_status
        CHECK (
            result_status IN (
                'Normal',
                'Abnormal'
            )
        ),
    CONSTRAINT fk_patientdiagnostic_admission
        FOREIGN KEY (admission_id)
        REFERENCES admission(admission_id),
    CONSTRAINT fk_patientdiagnostic_test
        FOREIGN KEY (test_id)
        REFERENCES diagnostic_test(test_id),
    CONSTRAINT fk_patientdiagnostic_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id),

    INDEX idx_patientdiagnostic_admission (admission_id),
    INDEX idx_patientdiagnostic_test (test_id),
    INDEX idx_patientdiagnostic_doctor (doctor_id)
);
CREATE TABLE drug_inventory (
    inventory_id INT PRIMARY KEY,
    current_stock INT NOT NULL,
    reorder_level INT NOT NULL,
    inventory_status VARCHAR(20) NOT NULL,
    last_restock_date DATE NOT NULL,
    drug_id INT NOT NULL,
    CONSTRAINT chk_current_stock
        CHECK (current_stock >= 0),
    CONSTRAINT chk_reorder_level
        CHECK (reorder_level >= 0),
    CONSTRAINT chk_inventory_status
        CHECK (inventory_status IN ('Normal', 'Low')),
    CONSTRAINT fk_inventory_drug
        FOREIGN KEY (drug_id)
        REFERENCES drug(drug_id),

    INDEX idx_inventory_drug (drug_id)
);
CREATE TABLE staff_assignment (
    assignment_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    ward_id INT NOT NULL,
    shift VARCHAR(20) NOT NULL,
    CONSTRAINT chk_shift
        CHECK (
            shift IN (
                'Morning',
                'Evening',
                'Night'
            )
        ),
    CONSTRAINT fk_staff_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id),
    CONSTRAINT fk_staff_ward
        FOREIGN KEY (ward_id)
        REFERENCES ward(ward_id),

    INDEX idx_staff_employee (employee_id),
    INDEX idx_staff_ward (ward_id)
);