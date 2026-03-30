import os
import io
import uuid
import random
import boto3
import pandas as pd
from faker import Faker

fake = Faker()

MINIO_URL = os.getenv("MINIO_URL", "http://localhost:9000")
MINIO_USER = os.getenv("MINIO_USER", "minioadmin")
MINIO_PASS = os.getenv("MINIO_PASS", "minioadmin")
BUCKET = "landing"

def generate_data(num_records=1000):
    data = []
    statuses = ['success', 'failed', 'pending']
    for _ in range(num_records):
        data.append({
            "user_id": str(uuid.uuid4()),
            "user_name": fake.name(),
            "transaction_amount": round(random.uniform(10.0, 5000.0), 2),
            "transaction_date": fake.date_time_this_year().isoformat(),
            "status": random.choice(statuses)
        })
    return pd.DataFrame(data)

from botocore.client import Config

def upload_to_minio(df):
    s3 = boto3.client(
        's3',
        endpoint_url=MINIO_URL,
        aws_access_key_id=MINIO_USER,
        aws_secret_access_key=MINIO_PASS,
        region_name="us-east-1",
        config=Config(s3={'addressing_style': 'path'})
    )
    
    # Ensure buckets exist
    for b in ["landing", "processing", "curated"]:
        try:
            s3.head_bucket(Bucket=b)
        except Exception:
            print(f"Bucket '{b}' not found. Creating it...")
            s3.create_bucket(Bucket=b)
    
    # Needs to buffer parquet to upload via boto3
    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, index=False)
    parquet_buffer.seek(0)
    
    file_name = f"raw_transactions_{uuid.uuid4().hex[:8]}.parquet"
    print(f"Uploading {file_name} to MinIO bucket '{BUCKET}'...")
    s3.upload_fileobj(parquet_buffer, BUCKET, file_name)
    print("Upload complete!")

if __name__ == "__main__":
    print("Generating synthetic data...")
    df = generate_data()
    print(f"Generated {len(df)} records.")
    
    print("\n--- AMOSTRA DOS DADOS OBTIDOS (LANDING) ---")
    print(df.head())
    print("-------------------------------------------\n")
    
    print("Uploading to MinIO...")
    upload_to_minio(df)
