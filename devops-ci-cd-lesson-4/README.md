# Django + PostgreSQL + Nginx в Docker

Цей проєкт демонструє розгортання веб-застосунку Django з базою даних PostgreSQL та веб-сервером Nginx в Docker контейнерах.

## 📋 Структура проєкту

```
.
├── myproject/              # Django проєкт
│   ├── __init__.py
│   ├── settings.py        # Налаштування Django (з PostgreSQL)
│   ├── urls.py            # URL маршрути
│   ├── views.py           # Views (домашня сторінка)
│   └── wsgi.py
├── nginx/
│   └── nginx.conf         # Конфігурація Nginx
├── Dockerfile             # Docker образ для Django
├── docker-compose.yml     # Оркестрація всіх сервісів
├── requirements.txt       # Python залежності
├── manage.py              # Django management скрипт
└── README.md              # Цей файл
```

## 🚀 Технології

- **Django 4.2** - Python веб-фреймворк
- **PostgreSQL 15** - Реляційна база даних
- **Nginx** - Веб-сервер і reverse proxy
- **Gunicorn** - WSGI HTTP сервер для Python
- **Docker & Docker Compose** - Контейнеризація

## 📦 Компоненти

### 1. Django (web)
- Python веб-застосунок
- Порт: 8000 (внутрішній)
- Використовує Gunicorn як WSGI сервер

### 2. PostgreSQL (db)
- База даних для збереження інформації
- Порт: 5432
- Креденшали (змініть у продакшені!):
  - Database: `djangodb`
  - User: `djangouser`
  - Password: `djangopass`

### 3. Nginx (nginx)
- Reverse proxy сервер
- Порт: 80 (зовнішній)
- Проксирує запити до Django

## 🛠️ Швидкий старт

### Передумови

Встановлені на вашому комп'ютері:
- Docker
- Docker Compose

### Запуск проєкту

1. **Клонуйте репозиторій:**
```bash
git clone <your-repo-url>
cd devops-ci-cd
```

2. **Створіть файл .env (опціонально):**
```bash
cp .env.example .env
```

3. **Запустіть всі сервіси:**
```bash
docker-compose up -d
```

4. **Перевірте статус контейнерів:**
```bash
docker-compose ps
```

5. **Відкрийте браузер:**
   - Домашня сторінка: http://localhost
   - Адмін панель: http://localhost/admin/

### Корисні команди

**Переглянути логи:**
```bash
docker-compose logs -f          # Всі сервіси
docker-compose logs -f web      # Тільки Django
docker-compose logs -f db       # Тільки PostgreSQL
docker-compose logs -f nginx    # Тільки Nginx
```

**Зупинити проєкт:**
```bash
docker-compose down
```

**Зупинити і видалити volumes:**
```bash
docker-compose down -v
```

**Створити суперкористувача Django:**
```bash
docker-compose exec web python manage.py createsuperuser
```

**Виконати міграції:**
```bash
docker-compose exec web python manage.py migrate
```

**Зайти в контейнер:**
```bash
docker-compose exec web bash       # Django
docker-compose exec db psql -U djangouser -d djangodb  # PostgreSQL
```

**Перезапустити сервіси:**
```bash
docker-compose restart
```

**Перебудувати образи:**
```bash
docker-compose up -d --build
```

## 🔧 Налаштування

### Django settings.py

Основні налаштування в `myproject/settings.py`:

- **База даних**: PostgreSQL з креденшалами з environment variables
- **Static files**: Збираються в `/app/staticfiles/`
- **Allowed hosts**: `['*']` (змініть у продакшені!)
- **Debug**: Керується через `DEBUG` env var

### Nginx конфігурація

В `nginx/nginx.conf`:
- Слухає на порті 80
- Проксирує всі запити до Django (web:8000)
- Віддає статичні файли з `/app/staticfiles/`

### Docker Compose

Три сервіси в `docker-compose.yml`:
1. **db**: PostgreSQL з persistent volume
2. **web**: Django з залежністю від db
3. **nginx**: Reverse proxy з залежністю від web

## 📊 Перевірка роботи

1. **Перевірте доступність:**
```bash
curl http://localhost
```

2. **Перевірте підключення до бази даних:**
   - Відкрийте http://localhost - статус PostgreSQL має бути "Підключено"

3. **Перевірте логи:**
```bash
docker-compose logs
```

## 🐛 Troubleshooting

**Проблема: "Port is already allocated"**
```bash
# Перевірте, що порти 80, 8000, 5432 вільні
sudo lsof -i :80
sudo lsof -i :8000
sudo lsof -i :5432
```

**Проблема: "Database connection failed"**
```bash
# Перевірте, що PostgreSQL запущений
docker-compose ps
# Подивіться логи
docker-compose logs db
```

**Проблема: "Static files not found"**
```bash
# Зберіть static files
docker-compose exec web python manage.py collectstatic --noinput
```

## 📝 Завдання виконано

✅ Створено Django проєкт  
✅ Налаштовано PostgreSQL як базу даних  
✅ Додано Nginx для проксирування трафіку  
✅ Створено Dockerfile для Django  
✅ Створено docker-compose.yml з трьома сервісами  
✅ Налаштовано nginx.conf  
✅ Протестовано локально  

## 🤝 Автор

Проєкт створено для курсу DevOps CI/CD

## 📄 Ліцензія

MIT
