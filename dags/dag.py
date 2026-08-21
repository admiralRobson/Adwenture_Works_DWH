import os
from pathlib import Path
from datetime import datetime

from airflow import DAG
from airflow.providers.standard.operators.empty import EmptyOperator 

from cosmos import DbtTaskGroup
from cosmos import ProjectConfig
from cosmos import ProfileConfig
from cosmos import ExecutionConfig
from cosmos import RenderConfig
from cosmos.profiles import DuckDBUserPasswordProfileMapping
from cosmos import ExecutionMode

# 1. Definiowanie ścieżek w systemie 
HOME_DIR = Path(os.path.expanduser("~"))
DBT_PROJECT_DIR = HOME_DIR / "airflow_dbt_duckdb_project" / "airflow_dbt_duckdb"
DBT_EXECUTABLE_PATH = HOME_DIR / "airflow_dbt_duckdb_project" / "venv" / "bin" / "dbt"
DBT_DATABASE_PATH = DBT_PROJECT_DIR /  "airflow_dbt_duckdb.duckdb"

# 2. Konfiguracja profilu dbt dla DuckDB
profile_config = ProfileConfig(
    profile_name="airflow_dbt_duckdb",
    target_name="dev",
    profile_mapping=DuckDBUserPasswordProfileMapping(
        conn_id="duckdb_default",
        profile_args={"path": str(DBT_DATABASE_PATH)},
    ),
)

# 3. Definicja DAG-a w Airflow
with DAG(
    dag_id="dbt_data_warehouse_pipeline",
    start_date=datetime(2026, 8, 21),
    schedule= "@daily",  # Uruchamiaj codziennie
    catchup=False,
    max_active_tasks=1,
    tags=["dbt", "duckdb", "analytics"],
) as dag:
    
    start_task = EmptyOperator(task_id="start")
    end_task = EmptyOperator(task_id="end")

    # 4. Tworzenie grupy zadań z projektu dbt
    dbt_models = DbtTaskGroup(
        group_id="dbt_transformations",
        project_config=ProjectConfig(
            dbt_project_path=str(DBT_PROJECT_DIR),
        ),
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path=str(DBT_EXECUTABLE_PATH),
            execution_mode=ExecutionMode.LOCAL
        ),
        render_config=RenderConfig(
            # Opcjonalnie: możesz przefiltrować uruchamiane modele
            # select=["tag:daily"],
        ),
    )

    # 5. Kolejność wykonywania zadań
    start_task >> dbt_models >> end_task

