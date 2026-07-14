from django.http import HttpResponse
from django.db import connection


def home(request):
    """Домашня сторінка"""
    
    # Перевірка підключення до бази даних
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            db_version = cursor.fetchone()[0]
        db_status = f"Підключено ({db_version.split()[0]} {db_version.split()[1]})"
    except Exception as e:
        db_status = f"Помилка підключення: {str(e)}"
    
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Django + PostgreSQL + Nginx</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background-color: #f5f5f5;
            }}
            .container {{
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }}
            h1 {{
                color: #0c4b33;
            }}
            .status {{
                padding: 10px;
                margin: 10px 0;
                border-radius: 5px;
                background-color: #d4edda;
                border: 1px solid #c3e6cb;
                color: #155724;
            }}
            .info {{
                margin: 10px 0;
                padding: 10px;
                background-color: #e7f3ff;
                border-left: 4px solid #2196F3;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🎉 Вітаємо в Django проєкті!</h1>
            <div class="status">
                <strong>✅ Статус:</strong> Проєкт успішно запущено
            </div>
            <div class="info">
                <h2>Налаштування проєкту:</h2>
                <ul>
                    <li><strong>Django:</strong> Працює</li>
                    <li><strong>PostgreSQL:</strong> {db_status}</li>
                    <li><strong>Nginx:</strong> Проксирує запити</li>
                    <li><strong>Docker:</strong> Всі сервіси в контейнерах</li>
                </ul>
            </div>
            <div class="info">
                <h2>Доступні endpoint'и:</h2>
                <ul>
                    <li><a href="/">/ - Домашня сторінка</a></li>
                    <li><a href="/admin/">/admin/ - Адмін панель Django</a></li>
                </ul>
            </div>
        </div>
    </body>
    </html>
    """
    
    return HttpResponse(html)
