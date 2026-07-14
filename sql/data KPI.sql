USE hospital_analysis;
-- HOSPITAL KPI
SELECT COUNT(*) AS total_patients
FROM patient;

SELECT COUNT(*) AS total_admissions
FROM admission;

SELECT
ROUND(SUM(total_amount),2) AS total_revenue
FROM billing;

SELECT
ROUND(AVG(total_amount),2) AS average_bill
FROM billing;

SELECT
ROUND(SUM(insurance_covered_amount),2) AS insurance_paid
FROM billing;

SELECT
ROUND(SUM(patient_payable_amount),2) AS patient_paid
FROM billing;

SELECT
ROUND(
SUM(insurance_covered_amount)/
SUM(total_amount)*100,
2
) AS insurance_percentage,

ROUND(
SUM(patient_payable_amount)/
SUM(total_amount)*100,
2
) AS patient_percentage

FROM billing;

SELECT
ROUND(AVG(stay_length),2)
AS average_stay
FROM admission;

describe bed;
SELECT
bed_status,
COUNT(*) AS total_beds
FROM bed
GROUP BY bed_status;

SELECT
DATE_FORMAT(
admission_date,
'%Y-%m'
) month,
COUNT(*) admissions
FROM admission
GROUP BY month
ORDER BY month;

-- Patient KPI

-- Gender Distribution
SELECT
    gender,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patient), 2) AS percentage
FROM patient
GROUP BY gender;

-- Age Group Distribution
SELECT
    age_group,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patient), 2) AS percentage
FROM patient
GROUP BY age_group
ORDER BY total_patients DESC;

-- Pateints By City
SELECT
    city,
    COUNT(*) AS total_patients
FROM patient
GROUP BY city
ORDER BY total_patients DESC
LIMIT 10;

-- Youngest and Oldest Pateint
SELECT
    MIN(age) AS youngest_patient,
    MAX(age) AS oldest_patient
FROM patient;

-- Average Age by Gender

SELECT
    gender,
    ROUND(AVG(age),2) AS average_age
FROM patient
GROUP BY gender;

-- Repeated Patients

SELECT
    p.patient_id,
    p.gender,
    p.age,
    COUNT(a.admission_id) AS total_admissions
FROM patient p
JOIN admission a
ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.gender,
    p.age
HAVING COUNT(a.admission_id) > 1
ORDER BY total_admissions DESC;


-- Number of One time vs repeat patients
SELECT
    CASE
        WHEN total_admissions = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS patient_type,
    COUNT(*) AS patients
FROM (
    SELECT
        patient_id,
        COUNT(*) AS total_admissions
    FROM admission
    GROUP BY patient_id
) t
GROUP BY patient_type;

-- Average Length os stay by age group
SELECT
    p.age_group,
    ROUND(AVG(a.stay_length),2) AS average_stay
FROM patient p
JOIN admission a
ON p.patient_id = a.patient_id
GROUP BY p.age_group
ORDER BY average_stay DESC;

-- Average Hospital Bill by age group
SELECT
    p.age_group,
    ROUND(AVG(b.total_amount),2) AS average_bill
FROM patient p
JOIN admission a
ON p.patient_id = a.patient_id
JOIN billing b
ON a.admission_id = b.admission_id
GROUP BY p.age_group
ORDER BY average_bill DESC;

-- Top 10 Highest Spending Pateint
SELECT
    p.patient_id,
    p.gender,
    p.age,
    ROUND(SUM(b.total_amount),2) AS total_spent
FROM patient p
JOIN admission a
ON p.patient_id = a.patient_id
JOIN billing b
ON a.admission_id = b.admission_id
GROUP BY
    p.patient_id,
    p.gender,
    p.age
ORDER BY total_spent DESC
LIMIT 10;

-- Financial Analytics

-- Revenue by Department
SELECT
    d.department_name,
    ROUND(SUM(b.total_amount),2) revenue
FROM department d
JOIN admission a
ON d.department_id=a.department_id
JOIN billing b
ON a.admission_id=b.admission_id
GROUP BY d.department_name
ORDER BY revenue DESC;

-- Monthly Revenue Trend
SELECT
DATE_FORMAT(bill_date,'%Y-%m') month,
ROUND(SUM(total_amount),2) revenue
FROM billing
GROUP BY month
ORDER BY month;

-- Revenue by payment Mode
SELECT
payment_mode,
ROUND(SUM(total_amount),2) revenue
FROM billing
GROUP BY payment_mode
ORDER BY revenue DESC;

-- Insurance Vs Patient Payment
SELECT
ROUND(SUM(insurance_covered_amount),2) insurance_paid,
ROUND(SUM(patient_payable_amount),2) patient_paid
FROM billing;

-- Department analysis
-- Most common disease per department
WITH disease_count AS
(
SELECT
d.department_name,
di.disease_name,
COUNT(*) cases,

ROW_NUMBER() OVER(
PARTITION BY d.department_name
ORDER BY COUNT(*) DESC
) rn

FROM department d

JOIN admission a
ON d.department_id=a.department_id

JOIN disease di
ON a.disease_id=di.disease_id

GROUP BY
d.department_name,
di.disease_name
)

SELECT *
FROM disease_count
WHERE rn=1;

-- Doctor analysis

-- Doctor Handling most patients
SELECT
doctor_id,
COUNT(*) total_patients
FROM patient_diagnostic
GROUP BY doctor_id
ORDER BY total_patients DESC;

-- Doctor ordering most diagnostic test
SELECT
doctor_id,
COUNT(*) total_tests
FROM patient_diagnostic
GROUP BY doctor_id
ORDER BY total_tests DESC;

-- Patients per specilialization
SELECT
d.specialization,
COUNT(DISTINCT a.patient_id) patients
FROM doctor d
JOIN patient_diagnostic pd
ON d.doctor_id=pd.doctor_id
JOIN admission a
ON pd.admission_id=a.admission_id
GROUP BY d.specialization;

-- Doctor Workload Ranking
SELECT
doctor_id,
COUNT(*) patients_seen,
RANK() OVER(
ORDER BY COUNT(*) DESC
) workload_rank

FROM patient_diagnostic

GROUP BY doctor_id;

-- Some more queries

-- Rank Department by revenue
SELECT
department_name,
SUM(total_amount) revenue,

RANK() OVER(
ORDER BY SUM(total_amount) DESC
) revenue_rank

FROM vw_department_performance

GROUP BY department_name;

-- Revenue Contribution &
SELECT
department_name,

SUM(total_amount) revenue,

ROUND(
SUM(total_amount)*100/
SUM(SUM(total_amount)) OVER(),
2
) contribution

FROM vw_department_performance

GROUP BY department_name;

-- Running Monthly Revenue
SELECT
DATE_FORMAT(bill_date,'%Y-%m') month,

SUM(total_amount) revenue,

SUM(SUM(total_amount))
OVER(
ORDER BY DATE_FORMAT(bill_date,'%Y-%m')
) running_total

FROM billing

GROUP BY month;