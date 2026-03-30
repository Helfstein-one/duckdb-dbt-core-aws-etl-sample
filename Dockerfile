FROM python:3.10-slim

# Evita criação de arquivos .pyc e logs extensos do python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instala as dependências dentro do container
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    dbt-duckdb \
    faker \
    pandas \
    pyarrow \
    boto3

# Copia os arquivos do projeto para o container
COPY . /app/
