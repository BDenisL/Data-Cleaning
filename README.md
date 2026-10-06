# HR Data Cleaning & Engineering Pipeline (SQL & Python)

This repository contains an end-to-end data engineering project focused on **Data Quality, Schema Standardization, and Feature Engineering**. The pipeline ingests a highly unformatted HR dataset, performs automated data auditing via Python, and executes a sequential cleaning process using MySQL to deliver clean, business-ready relational tables.

---

## 📌 Project Overview & Problem Statement
Data coming from production systems often lacks clean data types, uniform structures, or standardized nomenclature. In this project, the raw source file (`Limpieza.csv`) contained multiple inconsistencies critical for business analytics:
* **Inconsistent Date Formats:** Dates were recorded in mixed formats (`MM/DD/YYYY` and `MM-DD-YYYY`) alongside timestamp rows containing text zones (`YYYY-MM-DD HH:MM:SS UTC`).
* **Text Anomalies:** Fields included trailing/leading whitespaces and non-standardized categorical fields (e.g., mixed languages for gender attributes).
* **Incorrect Data Types:** Financial features (salaries) were stored as string objects containing symbols (`$`) and formatting commas (`,`), preventing any arithmetic operations.
* **Data Duplication:** Redundant corporate records compromised entity integrity constraints.

---

## 🛠️ Tech Stack & Architecture
* **Language:** Python 3.x, SQL (MySQL Dialect)
* **Libraries:** Pandas, NumPy
* **Database Management System:** MySQL Server

```text
  [ Raw CSV File ] ──> [ Python Auditing Script ] ──> [ MySQL Staging Table ]
                                                               │
                                                               ▼
  [ Clean Relational Schema ] <── [ Feature Engineering ] <── [ Sequential Pipeline ]
```

---

## 📂 Repository Structure
```text
├── data/
│   └── Limpieza.csv            # Raw dataset with structural anomalies
├── scripts/
│   └── csv_types.py        # Automated schema and data type checking script
├── sql/
│   └── script_definitivo.sql   # Main production SQL script with sequential execution
|   └── script_01.sql
|   └── creacion_importe_crudo.sql
└── README.md                   # Project documentation
```

---

## ⚙️ Data Engineering Steps

### 1. Automated Profiling & Auditing (Python)
Before building the SQL infrastructure, an automated Python data-profiling script (`csv_types.py`) was deployed leveraging `pandas` to infer underlying structures, discover schema requirements, and detect anomaly frequencies across features.

### 2. Sequential Ingestion & Cleaning Pipeline (MySQL)
The production pipeline (`script_definitivo.sql`) is architected sequentially to prevent type coercion conflicts. It follows these distinct stages:

* **Staging Table Setup:** Ingests raw inputs into loose `VARCHAR` columns to ensure complete data capture without dropping malformed string errors.
* **Entity Integrity Enforcement:** Deduplicates corporate records dynamically by mirroring distinct transactions through a temporary staging index layer.
* **String Estandardization:** Normalizes alphabetical entries by stripping white spaces (`TRIM`) and mapping multi-language string indicators into unified English parameters (`male`, `female`).
* **Sanitizing Financial Attributes:** Applies sequential string manipulation to eliminate corporate formatting indicators (`$`, `,`) before executing a `CAST` operation into an exact numeric `DECIMAL(15,2)` constraints for monetary precision.
* **Complex Temporal Parsing:** Parses multi-pattern calendar indicators using contextual `CASE` flows and MySQL regex validation (`STR_TO_DATE`), enforcing safe conversion constraints into native `DATE` and `DATETIME` formats.

### 3. Attribute Engineering (Data Enrichment)
To unlock business analytics value from the operational schema, two enriched dimensions were engineered directly into the data lake model:
* **Metric Generation (`age`):** Computes active age intervals dynamically using temporal differentials (`TIMESTAMPDIFF`) between historical birth dates and operational execution parameters.
* **String Combination Metrics (`email`):** Generates unified corporate emails dynamically by extracting substring components (`CONCAT`) from existing personal attributes and strictly casting them into system lowercase guidelines.

---

*Developed as a capstone project demonstrating production-grade SQL data workflows for Lovelytics Data School evaluation.*


