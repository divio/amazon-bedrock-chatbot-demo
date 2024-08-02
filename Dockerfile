FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt /app/

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

COPY . /app

EXPOSE 80

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=80"]
