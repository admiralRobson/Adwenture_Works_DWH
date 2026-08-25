# Modern Data Platform: Orchestrating dbt & DuckDB with Apache Airflow

![Data Pipeline Architecture](https://img.shields.io/badge/Architecture-ELT-blue.svg)
![Airflow](https://img.shields.io/badge/Apache%20Airflow-3.x%20%2F%202.x-007A87.svg?logo=apacheairflow)
![dbt](https://img.shields.io/badge/dbt--core-1.8%2B-FF694B.svg?logo=dbt)
![DuckDB](https://img.shields.io/badge/DuckDB-OLAP-FFF000.svg?logo=duckdb)
![Cosmos](https://img.shields.io/badge/Astronomer-Cosmos-1C2126.svg)

An end-to-end, production-grade **Modern Data Stack** project demonstrating data pipeline orchestration, ELT transformation, in-process OLAP warehousing, and advanced resolution of concurrency/environment edge cases.

Built as a proof of concept and production template for **BI / Data Engineering** workflows using **dbt**, **DuckDB**, and **Apache Airflow** via **Astronomer Cosmos**.

---

## 📸 Pipeline Overview (Airflow Visualisation)

```
[start] ---> [dbt_transformations (DbtTaskGroup)] ---> [end]
                     ├── stg_product (View)
                     ├── stg_region (View)
                     ├── stg_reseller (View)
                     ├── stg_sales_person (View)
                     ├── stg_sales (View)
                     ├── stg_target (View)
                     ├── dim_product (Dimension)
                     ├── dim_region (Dimension)
                     ├── dim_reseller (Dimension)
                     ├── dim_sales_person (Dimension)
                     ├── dim_target (Dimension)
                     ├── fct_sales (Fact Table)
                     ├── fct_sales_incremental (Fact Table)
```

> **Key Feature:** Astronomer Cosmos automatically parses the native `dbt` project DAG structure (defined across `.sql` models and `sources.yml`) into granular, isolated Airflow Tasks with individual logging, lineage tracking, and retry policy.

---

## Architecture & Modern Data Stack

This project follows the **ELT (Extract, Load, Transform)** paradigm, decoupling data transformation logic from orchestration and compute.

```
+------------------+      +-------------------+      +-------------------------+
|   Raw Data Source|      |   DuckDB Engine   |      |   BI & Analytics Layer  |
|  (CSV / Parquet) | ---> |  (In-Process OLAP)| ---> | (Star Schema / Fact &   |
+------------------+      +-------------------+      |  Dimension Tables)      |
                                    ^                +-------------------------+
                                    |
                         +--------------------+
                         |   Apache Airflow   |
                         |  + Cosmos Engine   |
                         +--------------------+
```

* **Orchestration:** **Apache Airflow 3.x / 2.x** managing task schedules, dependencies, concurrency limits, and retry logic.
* **Transformation & Data Modeling:** **dbt-core** + **dbt-duckdb** enforcing modular SQL engineering, test coverage, and source definitions.
* **Storage / OLAP Warehouse:** **DuckDB** providing ultra-fast, zero-overhead analytical queries with columnar file storage.
* **Orchestration Integration:** **Astronomer Cosmos** for seamless dbt project parsing into native Airflow `TaskGroups` without requiring manual DAG code per model.
* **Environment:** Python 3.10+ running in **Linux / WSL2 (Ubuntu)** with custom C-extension build dependencies.

---

## Data Modeling & dbt Architecture

The transformation layer in `airflow_dbt_duckdb/` is structured into clean analytical layers:

```
/
├── dbt_project.yml          # Core dbt project settings & targets
├── profiles.yml             # Connection parameters for DuckDB
├── models/
│   ├── staging/             # Layer 1: Cleansing, cast types, standardize column n
│   │   ├── sources.yml     # Source declarations & raw data assertions
|	│   ├── stg_product.sql
|	│   ├── stg_region.sql
|	│   ├── stg_reseller.sql
|	│   ├── stg_sales_person.sql   
|	|	└── stg_target.sql
│   └── marts/               # Layer 2: Business Logic / Star Schema
│       ├── dim_product.sql
│       ├── dim_region.sql
│       ├── dim_reseller.sql
│       ├── dim_sales_person.sql
│       ├── dim_target.sql
│       ├── fct_sales_incremental.sql
│       ├── fct_sales.sql
│       └── marts.yml
└── airflow_dbt_duckdb.duckdb   # Single-file OLAP Database
```

---

## Key Technical Challenges Solved (Engineering Log)

This repository demonstrates deep troubleshooting experience across Python environments, Airflow internals, dbt parsing, and database concurrency:

### 1. Concurrency Control in DuckDB (`duckdb.IOException: Could not set lock on file`)
* **Problem:** DuckDB is an in-process single-writer OLAP database. When Airflow executed multiple dbt model tasks concurrently, parallel tasks crashed due to file-lock contention on `airflow_dbt_duckdb.duckdb`.
* **Solution:** Configured `max_active_tasks=1` at the Airflow DAG level and configured a single-slot Airflow Pool (`duckdb_pool`) inside `DbtTaskGroup(operator_args={"pool": "duckdb_pool"})` to guarantee sequential task execution while preserving full execution lineage in the UI.

### 2. Fast DAG Parsing via `LoadMode.DBT_MANIFEST`
* **Problem:** Dynamic file-pattern matching on `sources.yml` and models in Cosmos caused parsing latency (`No files found that match the pattern`) during Airflow scheduler heartbeats.
* **Solution:** Decoupled dbt parsing from DAG execution by configuring `LoadMode.DBT_MANIFEST` in `RenderConfig`, passing pre-compiled `target/manifest.json` directly into Airflow.

### 3. Airflow 3.x Migration & Compatibility
* **Problem:** Legacy commands like `airflow db init` and deprecated imports (`from airflow.operators import EmptyOperator`) caused failure in newer Airflow runtime environments.
* **Solution:** Refactored database initialization to `airflow db migrate`, user creation via `airflow fab create-user`, and operator imports to `from airflow.operators.empty import EmptyOperator`.

### 4. WSL & C-Extension Environment Build
* **Problem:** Virtualenv instantiation failed during `dbt-duckdb` compilation due to missing native C++ header files and SSL library bindings on WSL Linux.
* **Solution:** Established reproducible system bootstrap commands (`build-essential`, `python3-dev`, `libssl-dev`, `libffi-dev`) prior to `pip install` with constraint files.

---

## 🚀 Getting Started

### Prerequisites (Linux / WSL2)
```bash
sudo apt update
sudo apt install -y python3-dev python3-pip build-essential libssl-dev libffi-dev
```

### Installation
```bash
# Clone the repository via SSH
git clone https://github.com/admiralRobson/Adwenture_Works_DWH.git
cd airflow-dbt-duckdb-pipeline

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install exact dependencies
pip install -r requirements.txt
```

### Running dbt locally
```bash
cd aifrlow_duckdb_
dbt debug --profiles-dir .
dbt parse --profiles-dir .
dbt run --profiles-dir .
```

### Running Apache Airflow
```bash
# Initialize Airflow Database & Standalone Server
export AIRFLOW_HOME=~/airflow
airflow standalone
```
1. Open your browser at `http://localhost:8080`.
2. Retrieve the admin credentials generated in the terminal output.
3. Enable and trigger the `dbt_data_warehouse_pipeline` DAG.

---

## 👨‍💻 Author & Skills Demonstrated
**BI / Analytics Engineer**
* **Analytics Engineering:** Star Schema modeling, dbt transformation layers, SQL optimization.
* **Orchestration:** Airflow DAG design, Astronomer Cosmos integration, Task Group isolation, Pool configuration.
* **Data Infrastructure:** DuckDB OLAP administration, Linux/WSL environment configuration, Git SSH workflows, Python packaging.
