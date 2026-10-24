CREATE TABLE patients_name(
patient_id	varchar(20) primary key,
gender	varchar(20),
age	INT,
insurance_type	varchar(50)
);

create table admissions_date(
admission_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20) REFERENCES patients(patient_id),
    admission_date DATE,
    discharge_date DATE,
    admission_type VARCHAR(50),
    primary_diagnosis VARCHAR(100),
    department VARCHAR(50),
    discharge_disposition VARCHAR(50),
    total_cost NUMERIC(10, 2)
);

DROP TABLE IF EXISTS admissions_date CASCADE;
DROP TABLE IF EXISTS admissions CASCADE;

select * from admissions_date;
select * from patients;

/* QUESTION 1: IDENTIFYING 30-DAY READMISSIONS*/
with patient_encounters as (
select 
admission_id, patient_id, admission_date, discharge_date, department, total_cost,
lead(admission_date) over (
partition by patient_id
order by admission_date asc
) as next_admission_date
from admissions_date
)
select 
admission_id, patient_id, admission_date, discharge_date, department, next_admission_date,
(next_admission_date - discharge_date) as days_to_re_admit,
case 
when (next_admission_date - discharge_date) between 0 and 30 then 1 
else 0
end as Days30_re_admit,
total_cost
from patient_encounters;

/* QUESTION 2: HOSPITAL-LEVEL READMISSION RATE (SUMMARY KPI)
   Business Goal:
   Overall hospital performance measure karna:
   1. Total Admissions kitne huye?
   2. Unme se 30-Day Readmissions kitne huye?
   3. Readmission Rate (%) kya hai? */
with step_1 as (
select admission_id, patient_id, admission_date, discharge_date, lead(admission_date) over(
partition by patient_id order by admission_date asc) as next_admission_date 
from admissions_date
)
select count(*) as total_admissions,
sum(case when (next_admission_date - discharge_date) between 0 and 30 then 1 else 0 end)
as total_readmissions, 
round(sum(case when (next_admission_date - discharge_date) between 0 and 30 then 1 else 0 end)
* 100.0 / count(*),2 ) as total_readmissions_pct
from step_1;

/* QUESTION 3: Har department ka total admissions, readmissions,
               aur readmission rate (%) nikalo */
with step_1 as(
select admission_id, patient_id, department, admission_date, discharge_date,
lead(admission_date) over (partition by patient_id order by admission_date asc) as 
next_admission_date from admissions_date)
select department, count(*) as total_admissions,
sum (case when(next_admission_date - discharge_date) between 0 and 30 then 1 else 0 end) 
as total_readmissions,
round(sum(case when(next_admission_date - discharge_date)
between 0 and 30 then 1 else 0 end)*100.0/count(*),2) as readmission_date_pct
from step_1 group by department order by readmission_date_pct;

/* QUESTION 4: Find gender-wise total admissions, 30-day readmissions, 
               and readmission rate (%) */
with step_1 as (
select admission_id, patient_id, admission_date, discharge_date, lead(admission_date) over(
partition by patient_id order by admission_date asc) 
as next_admission_date from admissions_date)

select p.gender, count(*) as total_admissions, sum(case when(next_admission_date - discharge_date)
between 0 and 30 then 1 else 0 end) as total_readmissions,
round(sum(case when(next_admission_date - discharge_date)
between 0 and 30 then 1 else 0 end)*100.0/count(*),2) as total_readmissions_pct from step_1 s
join patients p on s.patient_id = p.patient_id group by p.gender order by 
total_readmissions_pct desc;

/* QUESTION 5: Find admission type-wise total admissions, 30-day readmissions, 
               and readmission rate (%) */
with step_1 as (select admission_id,patient_id,admission_date, discharge_date, 
admission_type, lead(admission_date) over(partition by patient_id order by
admission_date asc ) as next_admission_date from admissions_date)
select admission_type, count(*) total_admissions,
sum(case when(next_admission_date-discharge_date)between 0 and 30 then 1 else 0 end) as 
total_readmissions, round(sum(case when(next_admission_date-discharge_date)between
0 and 30 then 1 else 0 end)*100.0/count(*),2) as total_readis_pct from step_1
group by admission_type order by total_readis_pct desc;

/* QUESTION 6: Find age group-wise total admissions, 30-day readmissions,
               and readmission rate (%) */
with step_1 as (
select admission_id,patient_id,admission_date,discharge_date, lead(admission_date) over
(partition by patient_id order by admission_date) as next_admission_date from admissions_date)
select case when p.age >= 60 then 'Senior(60+)' when p.age between 35 and 59 then 
'Adult(35-59)' else 'Young(<35)' end as age_group, count(*) as total_admissions, sum(case when
(next_admission_date-discharge_date)between 0 and 30 then 1 else 0 end) as total_readmissions,
round(sum(case when(next_admission_date-discharge_date)between 0 and 30 then 1 else 0 end)
*100.0/count(*),2) as total_readmis_prct from step_1 s join patients p
on s.patient_id=p.patient_id group by case when p.age>=60 then 'Senior(60+)' when p.age 
between 35 and 59 then 'Adult(35-59)' else 'Young(<35)' end order by total_readmis_prct desc;

/* QUESTION 7: Find Length of Stay (LOS) bucket-wise total admissions, 30-day readmissions,
               and readmission rate (%) */
with step_1 as(
select admission_id,patient_id,admission_date,discharge_date,(discharge_date-admission_date)
as los_days,lead(admission_date)over(partition by patient_id order by admission_date) as 
next_admission_date from admissions_date)
select case when los_days between 1 and 3 then 'Short Stay(1-3)' when los_days between 4 and 7
then 'Medium Stay(4-7)' else 'Long Stays(8+)' end as stays_category, count(*) as 
total_admissions, sum(case when(next_admission_date-discharge_date)between 0 and 30 then 1
else 0 end) as total_readmissions, round(sum(case when(next_admission_date-
discharge_date)between 0 and 30 then 1 else 0 end )*100.0/count(*),2) as total_readmis_pct 
from step_1 group by stays_category order by total_readmis_pct desc;
			   
SELECT * FROM admissions_date LIMIT 1;
SELECT * FROM patients LIMIT 1;

/* QUESTION 8: Find primary diagnosis-wise total admissions, 30-day readmissions,
               and readmission rate (%) */
with step_1 as(select admission_id,patient_id,admission_date,discharge_date,primary_diagnosis,
lead(admission_date)over(partition by patient_id order by admission_date asc) as
next_admission_date from admissions_date)
select primary_diagnosis, count(*) as total_admissions, sum(case when(next_admission_date-
discharge_date)between 0 and 30 then 1  else 0 end) as total_readmissions, round(sum(case when
(next_admission_date-discharge_date)between 0 and 30 then 1 else 0 end)*100.0/count(*),2) as
total_readmis_pct from step_1 group by primary_diagnosis order by total_readmis_pct desc;

/* MASTER DATASET FOR POWER BI DASHBOARD */

with step_1 as (
    select 
        a.admission_id,
        a.patient_id,
        p.gender,
        p.age,
        case 
            when p.age >= 60 then 'Senior (60+)'
            when p.age between 35 and 59 then 'Adult (35-59)'
            else 'Young (<35)'
        end as age_group,
        p.insurance_type,
        a.admission_date,
        a.discharge_date,
        (a.discharge_date - a.admission_date) as los_days,
        case 
            when (a.discharge_date - a.admission_date) between 1 and 3 then 'Short Stay (1-3)'
            when (a.discharge_date - a.admission_date) between 4 and 7 then 'Medium Stay (4-7)'
            else 'Long Stay (8+)'
        end as stays_category,
        a.admission_type,
        a.primary_diagnosis,
        a.department,
        lead(a.admission_date) over (
            partition by a.patient_id 
            order by a.admission_date asc
        ) as next_admission_date
    from admissions_date a
    join patients p 
        on a.patient_id = p.patient_id
)
select 
    *,
    (next_admission_date - discharge_date) as days_to_readmission,
    case 
        when (next_admission_date - discharge_date) between 0 and 30 then 1 
        else 0 
    end as is_readmitted_30d
from step_1;