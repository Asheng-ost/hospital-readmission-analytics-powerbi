# 🏥 Hospital 30-Day Readmission & Patient Flow Analytics

## 📌 Executive Summary
This project evaluates hospital inpatient records (9,538 admissions) to identify drivers of 30-day readmissions, departmental operational burdens, and patient acuity trends. The goal is to provide healthcare administrators and clinical directors with actionable intelligence to minimize avoidable readmission penalties, optimize bed turnover, and improve post-discharge care protocols.

---

## 📸 Dashboard Overview
![Hospital Readmission Dashboard](Screenshot%202026-10-24%20190433.png)

---

## 📊 Key Operational Metrics (KPIs)
- **Total Admissions:** 9,538 patients
- **Overall 30-Day Readmission Rate:** 11.3% (1,080 readmitted patients)
- **Average Length of Stay (Avg LOS):** 5.1 Days
- **Emergency Case Volume:** 5,570 admissions (~58.4% of total inpatient volume)

---

## 🔍 Core Analytical Insights

### 1. High Volume vs. High Risk in Emergency Admissions
- Emergency cases form the bulk of hospital operations (**5,570 admissions**), carrying the highest 30-day readmission risk (~11.8%).
- Elective and Urgent admissions exhibit lower readmission trends, indicating that unplanned, acute cases drive post-discharge complications.

### 2. Departmental Workload & Readmission Burden
- High-volume departments (**Orthopedics, Pulmonology, and Cardiology**) exhibit elevated readmission counts alongside high patient inflows.
- Discharge planning protocols and follow-up clinics must prioritize high-throughput surgical and cardiac wards.

### 3. Patient Demographics & Payer Distribution
- Readmission trends remain consistently high across older adult cohorts, necessitating targeted post-acute care and home-health checkups.
- Insurance analysis reveals primary dependencies across Medicare, Medicaid, and Private health plans, highlighting financial exposure to readmission quality penalties.

---

## 🛠️ Tech Stack & Methodology
- **SQL (PostgreSQL / pgAdmin):** Data extraction, exploratory analysis, aggregations, window functions, and categorization of length of stay.
- **Power BI:** Data modeling, dynamic DAX KPI creation, interactive multi-axis visual construction, and executive UI formatting.
- **DAX Measures:**
  - `Total Admissions` = `COUNTROWS(hospital_readmission_master)`
  - `Readmission Rate` = `DIVIDE([Readmitted Patients], [Total Admissions], 0)`
  - `Emergency Admissions` = `CALCULATE(COUNTROWS(hospital_readmission_master), hospital_readmission_master[admission_type] = "Emergency")`
  - `Avg LOS` = `AVERAGE(hospital_readmission_master[los_days])`
