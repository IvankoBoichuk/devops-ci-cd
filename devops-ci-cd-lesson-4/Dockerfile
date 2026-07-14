# Використовуємо офіційний образ Python 3.11
FROM python:3.11-slim

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

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

# Запускаємо Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi:application"]
