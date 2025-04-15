# Use official Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy dependency file and install
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY . .

# Command to run the app
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
