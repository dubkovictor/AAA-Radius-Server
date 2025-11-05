FROM python:3.11-slim

WORKDIR /app

# Копируем файл зависимостей
COPY requirements.txt .

COPY radius.dict .

# ✅ Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем сам код приложения
COPY app.py .

EXPOSE 8080

CMD ["python", "app.py"]