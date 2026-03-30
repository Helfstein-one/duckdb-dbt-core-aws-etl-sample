#!/bin/bash
# run_pipeline.sh - Executa o processo E2E 100% conteinerizado e finaliza com teardown
set -e

echo "🚀 [1/4] Iniciando MinIO via podman-compose..."
podman-compose up -d

echo "⏳ Aguardando MinIO estar pronto para configurar os buckets..."
sleep 5
./setup_buckets.sh

echo "📦 [2/4] Realizando o build do Container ETL pelas dependências (dbt, faker, etc)..."
podman build -t antigravity-etl .

echo "🏃 [3/4] Inicializando pipeline completo no container (Faker -> dbt run -> dbt test)..."
# Usamos --network host para acessar o localhost:9000 (MinIO exposto pelo host)
podman run --rm --network host antigravity-etl bash -c "python scripts/generate_faker_data.py && dbt run --profiles-dir . && echo -e '\n--- AMOSTRA DOS DADOS (STAGING) ---' && dbt show --select stg_raw_data --profiles-dir . --limit 5 && echo -e '\n--- AMOSTRA DOS DADOS (CURATED) ---' && dbt show --select fct_analytics --profiles-dir . --limit 5 && dbt test --profiles-dir ."

echo "🛑 [4/4] Processo finalizado com sucesso! Executando End/Teardown..."
podman-compose down

echo "✅ Limpeza concluída e pipeline E2E encerrado."
