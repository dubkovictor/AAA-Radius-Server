FROM python:3.11-slim

WORKDIR /app

# Copy the dependency file
COPY requirements.txt .

COPY radius.dict .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app.py .

EXPOSE 8080

CMD ["python", "app.py"]
