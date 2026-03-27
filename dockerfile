# ---------- Stage 1: Builder ----------
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies (if needed)
RUN apt-get update && apt-get install -y build-essential

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install dependencies into a separate folder
RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt


# ---------- Stage 2: Final Image ----------
FROM python:3.11-slim

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY app.py .

# Create non-root user
RUN useradd -m appuser
USER appuser

# Expose port
EXPOSE 5000

# Run with gunicorn (production ready)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
