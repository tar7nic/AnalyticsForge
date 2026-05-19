# ============================================================
# Model:       load_olist.py
# Description: Loads all Olist CSV files from the data/ folder
#              into Snowflake RAW.OLIST schema as raw tables.
#              Uses snowflake-connector-python and pandas.
# Author:      Tarun Nichwani
# Last Modified: 2026-05-19
# ============================================================

import os
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from dotenv import load_dotenv

# ── Load credentials from .env ────────────────────────────────
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

# ── Snowflake connection config ───────────────────────────────
SNOWFLAKE_CONFIG = {
    "account":   os.getenv("SNOWFLAKE_ACCOUNT"),
    "user":      os.getenv("SNOWFLAKE_USER"),
    "password":  os.getenv("SNOWFLAKE_PASSWORD"),
    "role":      os.getenv("SNOWFLAKE_ROLE"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
    "database":  os.getenv("SNOWFLAKE_DATABASE"),
    "schema":    os.getenv("SNOWFLAKE_SCHEMA"),
}

# ── CSV files to load ─────────────────────────────────────────
# Maps: Snowflake table name → CSV filename
CSV_TABLE_MAP = {
    "orders":               "olist_orders_dataset.csv",
    "order_items":          "olist_order_items_dataset.csv",
    "order_payments":       "olist_order_payments_dataset.csv",
    "order_reviews":        "olist_order_reviews_dataset.csv",
    "customers":            "olist_customers_dataset.csv",
    "sellers":              "olist_sellers_dataset.csv",
    "products":             "olist_products_dataset.csv",
    "geolocation":          "olist_geolocation_dataset.csv",
    "product_category_name_translation": "product_category_name_translation.csv",
}

# ── Data folder path ──────────────────────────────────────────
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'data')


def get_connection():
    """Create and return a Snowflake connection."""
    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    print(f"Connected as {SNOWFLAKE_CONFIG['user']} "
          f"to {SNOWFLAKE_CONFIG['database']}.{SNOWFLAKE_CONFIG['schema']}")
    return conn


def load_csv_to_snowflake(conn, table_name: str, csv_filename: str) -> int:
    """
    Load a single CSV file into a Snowflake table.
    - Reads CSV with pandas
    - Uppercases all column names (Snowflake default is uppercase)
    - Drops and recreates the table on each run (idempotent)
    - Returns row count loaded
    """
    csv_path = os.path.join(DATA_DIR, csv_filename)

    # ── Read CSV ──────────────────────────────────────────────
    print(f"\n  Reading {csv_filename}...")
    df = pd.read_csv(csv_path, dtype=str)  # load everything as string — types handled in dbt staging
    df.columns = [col.upper() for col in df.columns]  # Snowflake expects uppercase column names

    row_count = len(df)
    print(f"  Rows read: {row_count:,}")

    # ── Drop table if exists (idempotent reload) ───────────────
    cursor = conn.cursor()
    cursor.execute(f"DROP TABLE IF EXISTS {table_name.upper()}")

    # ── Write to Snowflake ────────────────────────────────────
    print(f"  Loading into RAW.OLIST.{table_name.upper()}...")
    success, num_chunks, num_rows, output = write_pandas(
        conn=conn,
        df=df,
        table_name=table_name.upper(),
        auto_create_table=True,      # creates table based on df schema
        overwrite=True,
    )

    if success:
        print(f"  ✓ Loaded {num_rows:,} rows into {table_name.upper()}")
    else:
        print(f"  ✗ Failed to load {table_name.upper()}")

    cursor.close()
    return num_rows


def verify_row_counts(conn):
    """
    Run SELECT COUNT(*) on every table and print a summary.
    This is our Phase 1 deliverable verification.
    """
    print("\n" + "="*55)
    print("  ROW COUNT VERIFICATION — RAW.OLIST")
    print("="*55)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT table_name, row_count
        FROM information_schema.tables
        WHERE table_schema = 'OLIST'
          AND table_type = 'BASE TABLE'
        ORDER BY table_name
    """)

    rows = cursor.fetchall()
    total = 0
    for table_name, row_count in rows:
        print(f"  {table_name:<45} {row_count:>10,} rows")
        total += row_count

    print("-"*55)
    print(f"  {'TOTAL':<45} {total:>10,} rows")
    print("="*55)
    cursor.close()


def main():
    print("="*55)
    print("  AnalyticsForge — Phase 1 Raw Ingestion")
    print("="*55)

    conn = get_connection()

    # ── Load each CSV ─────────────────────────────────────────
    results = {}
    for table_name, csv_filename in CSV_TABLE_MAP.items():
        try:
            rows = load_csv_to_snowflake(conn, table_name, csv_filename)
            results[table_name] = rows
        except Exception as e:
            print(f"  ✗ ERROR loading {table_name}: {e}")
            results[table_name] = None

    # ── Verify in Snowflake ───────────────────────────────────
    verify_row_counts(conn)

    conn.close()
    print("\nConnection closed. Phase 1 ingestion complete.")


if __name__ == "__main__":
    main()