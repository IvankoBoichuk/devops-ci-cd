# Використовуємо офіційний образ Python 3.11
FROM python:3.11-slim

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV GUNICORN_CMD_ARGS="--bind 0.0.0.0:8000 --workers 2 --threads 4 --worker-class gthread --timeout 120 --graceful-timeout 30 --keep-alive 5 --access-logfile - --error-logfile -"

# Встановлюємо робочу директорію
WORKDIR /app

# Встановлюємо системні залежності
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Копіюємо файл залежностей
COPY requirements.txt /app/

# Встановлюємо залежності Python
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Копіюємо проєкт
COPY . /app/

# Виконуємо міграції та збираємо статичні файли
RUN python manage.py collectstatic --noinput || true

# Відкриваємо порт 8000
EXPOSE 8000

# Запускаємо Gunicorn з кількома воркерами, щоб одиничні завислі з'єднання не блокували весь pod
CMD ["gunicorn", "app.wsgi:application"]
