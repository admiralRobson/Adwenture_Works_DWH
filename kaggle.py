import kagglehub
import os
import pandas as pd
from datetime import datetime

DATASET_HANDLE = "algorismus/adventure-works-in-excel-tables"
TARGET_DATA_DIR = "./data_raw"

# Download latest version
path = kagglehub.dataset_download("algorismus/adventure-works-in-excel-tables")

print("Path to dataset files:", path)
def download_kaggle_adventure_works():
    print("Krok 1: Pobieranie najnowszych danych z Kaggle za pomocą kagglehub...")
    try:
        # kagglehub pobiera pliki do wewnętrznej pamięci podręcznej (cache) i zwraca ścieżkę do nich
        download_path = kagglehub.dataset_download(DATASET_HANDLE)
        print(f"Dane pobrane pomyślnie do pamięci cache: {download_path}")
    except Exception as e:
        print(f"Błąd podczas pobierania z Kaggle: {e}")
        return
    # Znajdujemy plik CSV w pobranym folderze (zazwyczaj nazywa się apartments_pl.csv)
    csv_files = [f for f in os.listdir(download_path) if f.endswith('.csv')]
    if not csv_files:
        print("W pobranej paczce nie znaleziono żadnego pliku CSV!")
        return
    print(csv_files)
    source_csv_path = os.path.join(download_path, csv_files[0])


    print("Krok 2: Przetwarzanie danych w Pandas i konwersja do formatu Parquet...")
    try:
        # Wczytujemy pobrany plik CSV
        for csv_file in csv_files:
            source_csv_path = os.path.join(download_path, csv_file)
            table_name = csv_file.split(".")[0]
            
            df = pd.read_csv(source_csv_path, sep='\t')
            print(f"Pomyślnie wczytano {len(df)} wierszy danych.")
            # Dodajemy metadane biznesowe (Partitioning/Snapshot Date)
            current_date = datetime.now().strftime("%Y-%m-%d")
            df['ingested_at'] = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
            df['snapshot_date'] = current_date
            # Upewniamy się, że folder docelowy dla DuckDB istnieje
            os.makedirs(TARGET_DATA_DIR, exist_ok=True)

            # Zapisujemy do ultra-wydajnego formatu Parquet w folderze danych
            target_parquet_path = os.path.join(TARGET_DATA_DIR, f"{table_name}_{current_date}.parquet")
            print(target_parquet_path)
            df.to_parquet(target_parquet_path, index=False)
            print(f"Sukces! Plik gotowy dla dbt pod ścieżką: {target_parquet_path}")

    except Exception as e:
        print(f"Błąd podczas przetwarzania danych: {e}")

if __name__ == "__main__":
    download_kaggle_adventure_works()