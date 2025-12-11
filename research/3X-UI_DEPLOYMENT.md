# Развертывание 3X-UI с VLESS+Reality и IP Limit

**Дата:** 11 декабря 2025
**Назначение:** Пошаговая инструкция для развертывания VPN панели 3X-UI
**Время установки:** 1-2 часа
**Требования:** Docker, Linux сервер (Hetzner финляндия)

---

## Предварительные требования

### Сервер
- Linux (Ubuntu 20.04+)
- 1+ vCPU
- 1-2 GB RAM
- 10 GB свободного места
- Docker установлен
- Публичный IP адрес (статический)

### Домен (опционально)
- HTTPS требует валидного домена
- Сертификат Let's Encrypt (бесплатный)

---

## Шаг 1: Подготовка сервера

### 1.1 Подключиться к серверу
```bash
# SSH подключение
ssh root@SERVER_IP

# Обновить систему
apt update && apt upgrade -y

# Установить необходимые пакеты
apt install -y curl wget git
```

### 1.2 Убедиться, что Docker установлен
```bash
# Проверить Docker
docker --version

# Если Docker не установлен:
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

---

## Шаг 2: Создание директорий и конфигурации

### 2.1 Создать директории для хранения данных
```bash
# Создать основную директорию
mkdir -p /root/3x-ui/{db,cert}

# Установить права доступа
chmod -R 755 /root/3x-ui
```

### 2.2 Создать docker-compose файл

**Сохранить как `/root/3x-ui/docker-compose.yml`:**

```yaml
version: '3.8'

services:
  3x-ui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3x-ui
    restart: unless-stopped
    ports:
      - "54321:54321"      # Web UI
      - "443:443/tcp"      # VLESS (маскировка под HTTPS)
      - "443:443/udp"      # QUIC
      - "80:80/tcp"        # HTTP fallback (не используется)
    volumes:
      - /root/3x-ui/db:/etc/x-ui/
      - /root/3x-ui/cert:/root/cert/
    environment:
      - XRAY_VMESS_AEAD_FORCED=false
    network_mode: "host"
```

### 2.3 Альтернативный вариант (без docker-compose)

Если предпочитаете использовать `docker run`:

```bash
docker run -itd \
  --name 3x-ui \
  -e XRAY_VMESS_AEAD_FORCED=false \
  -v /root/3x-ui/db:/etc/x-ui/ \
  -v /root/3x-ui/cert:/root/cert/ \
  -p 54321:54321 \
  -p 443:443 \
  --restart unless-stopped \
  --network=host \
  ghcr.io/mhsanaei/3x-ui:latest
```

---

## Шаг 3: Запуск 3X-UI

### 3.1 Запуск контейнера через docker-compose
```bash
cd /root/3x-ui
docker-compose up -d
```

### 3.2 Проверка статуса
```bash
# Просмотреть логи
docker logs 3x-ui

# Проверить работающие контейнеры
docker ps | grep 3x-ui
```

### 3.3 Проверка открытых портов
```bash
# Проверить слушающие порты
netstat -tlnp | grep -E '(54321|443|80)'
```

**Ожидаемый вывод:**
```
tcp        0      0 0.0.0.0:54321          0.0.0.0:*               LISTEN      XXXXX/docker-proxy
tcp        0      0 0.0.0.0:443            0.0.0.0:*               LISTEN      XXXXX/docker-proxy
```

---

## Шаг 4: Первый вход в панель

### 4.1 Открыть веб-интерфейс
```
URL: http://SERVER_IP:54321
```

### 4.2 Авторизация по умолчанию
```
Логин: admin
Пароль: admin
```

### 4.3 ⚠️ КРИТИЧЕСКИ: Смена пароля
1. Нажать на иконку профиля (правый верхний угол)
2. Settings → Change Password
3. Сменить пароль на надежный (минимум 12 символов)

---

## Шаг 5: Установка fail2ban для IP Limit

### 5.1 Установить fail2ban на хост
```bash
# Установить fail2ban
apt install -y fail2ban

# Запустить сервис
systemctl start fail2ban
systemctl enable fail2ban

# Проверить статус
systemctl status fail2ban
```

### 5.2 Настроить fail2ban в 3X-UI
```bash
# Войти в контейнер 3X-UI
docker exec -it 3x-ui bash

# Установить IP Limit (в контейнере)
x-ui install-fail2ban

# Выход из контейнера
exit
```

### 5.3 Перезагрузить контейнер
```bash
docker restart 3x-ui
```

---

## Шаг 6: Конфигурация VLESS+Reality

### 6.1 Создание нового inbound

1. Перейти в **Inbound List**
2. Нажать на **+ New Inbound**
3. Заполнить форму:

```
Protocol: VLESS
Port: 443

VLESS Settings:
  └─ Add ID (нажать "+" и скопировать автогенерированный UUID)

Stream Settings:
  Transport: TCP
  Security: Reality

Reality Settings:
  □ Show advanced (включить галку)

  Private Key: [Сгенерировать кнопкой "Gen Key"]
  Public Key: [Автоматически генерируется]
  Server Name (SNI): www.google.com
              (или cloudflare.com, microsoft.com - популярные сайты)

  Short IDs:
    [] (оставить пусто или сгенерировать)

uTLS:
  Chrome (или оставить по умолчанию)

XTLS Flow: (оставить пусто)
```

4. Нажать **Create**

### 6.2 Проверка конфигурации

1. В списке инбаундов нажать на только что созданный
2. Проверить:
   - ✅ Port: 443
   - ✅ Protocol: VLESS
   - ✅ Security: Reality
   - ✅ Private Key и Public Key заполнены

---

## Шаг 7: Добавление пользователей с IP Limit

### 7.1 Создание пользователя

1. Перейти в **Clients**
2. Нажать на **+ New Client**
3. Заполнить форму:

```
Email: user1@example.com
(или любой идентификатор)

Settings:
  ├─ Total Upload Traffic Limit: unlimited
  ├─ Total Download Traffic Limit: [выбрать, например 10 GB]
  ├─ Expiry Time: [выбрать дату окончания доступа]
  └─ IP Limit: 1  ⭐ ВАЖНО: Установить 1 для лимита 1 устройства

  ├─ Enable: ✅
  └─ Reset Time: (не менять)
```

4. Нажать **Create**

### 7.2 Получение конфигурации клиента

1. Клик на иконку **Share** (поделиться)
2. Выбрать созданный VLESS+Reality inbound
3. Получить:
   - **Link**: скопировать строку подключения
   - **QR Code**: сканировать на мобильном устройстве

---

## Шаг 8: Тестирование подключения

### 8.1 Установка клиента на мобильный (Android)

1. Скачать приложение **v2rayNG** из Google Play
2. Нажать **+** → **Import from QR Code**
3. Отсканировать QR код с панели 3X-UI
4. Выбрать профиль и нажать **Start**
5. Проверить иконку VPN в статус-баре (должна быть)

### 8.2 Установка клиента на ПК (Windows)

1. Скачать **v2rayN** с GitHub (github.com/2dust/v2rayN/releases)
2. Запустить исполняемый файл
3. Меню → Subscribe → **Paste link** (вставить ссылку из панели)
4. Выбрать сервер и нажать **Start**

### 8.3 Установка клиента на macOS

1. Скачать **FoXray** или **Hiddify**
2. Импортировать конфигурацию через ссылку или QR
3. Подключиться

### 8.4 Проверка подключения

```bash
# На клиентской машине
curl https://api.ipify.org

# Должен вывести IP сервера (не ваш реальный IP)
```

---

## Шаг 9: Дополнительная конфигурация (опционально)

### 9.1 Включение HTTPS для панели (рекомендуется)

**Важно!** По умолчанию панель работает по HTTP. Для безопасности рекомендуется включить HTTPS.

#### Вариант A: Самоподписанный сертификат (быстро)

```bash
# Сгенерировать самоподписанный сертификат
docker exec 3x-ui openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /root/cert/server.key \
  -out /root/cert/server.crt \
  -subj "/C=US/ST=State/L=City/O=Org/CN=SERVER_IP"

# Перезагрузить контейнер
docker restart 3x-ui
```

Затем панель будет доступна по `https://SERVER_IP:54321` (браузер покажет предупреждение о сертификате - это нормально).

#### Вариант B: Let's Encrypt (если есть домен)

1. Установить certbot:
```bash
apt install -y certbot python3-certbot-dns-cloudflare
```

2. Получить сертификат:
```bash
certbot certonly --standalone -d yourdomain.com
```

3. Скопировать сертификат:
```bash
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /root/3x-ui/cert/
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /root/3x-ui/cert/
```

4. Перезагрузить:
```bash
docker restart 3x-ui
```

### 9.2 Резервное копирование конфигурации

```bash
# Создать архив БД
tar -czf 3x-ui-backup-$(date +%Y%m%d).tar.gz /root/3x-ui/

# Скачать на локальный ПК (из локального терминала)
scp root@SERVER_IP:/root/3x-ui-backup-*.tar.gz ./
```

### 9.3 Мониторинг использования трафика

1. Перейти в **Clients**
2. Видны колонки:
   - **Upload**: загруженный трафик
   - **Download**: скачанный трафик
   - **Exp Time**: дата окончания доступа
3. Нажать на клиента для детальной информации

---

## Шаг 10: Решение проблем

### Проблема: IP Limit не работает

**Решение:**
```bash
# 1. Убедиться, что fail2ban установлен
systemctl status fail2ban

# 2. Переустановить IP Limit в 3X-UI
docker exec -it 3x-ui bash
x-ui install-fail2ban
exit

# 3. Перезагрузить контейнер
docker restart 3x-ui
```

### Проблема: QR код не сканируется

**Решение:**
```bash
# 1. Обновить 3X-UI до последней версии
docker pull ghcr.io/mhsanaei/3x-ui:latest
docker stop 3x-ui
docker rm 3x-ui
docker-compose up -d  # (если используете docker-compose)

# 2. Попробовать перегенерировать QR код
# В панели: Clients → Share → перегенерировать
```

### Проблема: Подключение медленное

**Возможные причины:**
- Неправильный Server Name (SNI) в Reality
- Перегруженный сервер
- Плохое интернет соединение клиента

**Решение:**
```bash
# Менять Server Name на другие популярные сайты:
- google.com
- cloudflare.com
- facebook.com
- microsoft.com
- netflix.com

# Выбрать тот, с наименьшим пингом
# Команда для проверки пинга:
ping -c 5 google.com
ping -c 5 cloudflare.com
```

### Проблема: Клиент не может подключиться

**Проверка:**
```bash
# 1. Проверить, что контейнер работает
docker ps | grep 3x-ui

# 2. Проверить логи
docker logs 3x-ui

# 3. Проверить открытые порты
netstat -tlnp | grep -E '(443|54321)'

# 4. Проверить firewall (если используется)
# Убедиться, что порты 443 и 54321 открыты
ufw allow 443/tcp
ufw allow 54321/tcp
```

---

## Чек-лист развертывания

- [ ] Сервер подготовлен (Docker установлен)
- [ ] Директории созданы `/root/3x-ui/{db,cert}`
- [ ] Контейнер запущен (`docker ps` показывает 3x-ui)
- [ ] Панель доступна по `http://SERVER_IP:54321`
- [ ] Пароль администратора изменен
- [ ] fail2ban установлен и запущен
- [ ] VLESS+Reality inbound создан
- [ ] Минимум один пользователь добавлен с IP Limit = 1
- [ ] Получена конфигурация/QR код
- [ ] Тестирование на мобильном устройстве выполнено
- [ ] Резервная копия конфигурации создана
- [ ] (Опционально) HTTPS сертификат установлен

---

## Команды для управления

### Основные команды Docker

```bash
# Просмотр логов в реальном времени
docker logs -f 3x-ui

# Перезагрузка контейнера
docker restart 3x-ui

# Остановка контейнера
docker stop 3x-ui

# Удаление контейнера (БД остаётся)
docker rm 3x-ui

# Обновление образа
docker pull ghcr.io/mhsanaei/3x-ui:latest
docker-compose down
docker-compose up -d
```

### Резервное копирование

```bash
# Создать резервную копию
tar -czf /root/3x-ui-backup-$(date +%Y%m%d-%H%M%S).tar.gz /root/3x-ui/

# Восстановить из резервной копии
tar -xzf 3x-ui-backup-ДАТА.tar.gz -C /
docker restart 3x-ui
```

### Сброс пароля администратора

```bash
# Войти в контейнер
docker exec -it 3x-ui bash

# Внутри контейнера - сбросить пароль
x-ui reset-password admin your_new_password

# Выход
exit

# Перезагрузить контейнер
docker restart 3x-ui
```

---

## Рекомендации по безопасности

### 1. Закрыть порт 54321 от внешнего доступа (опционально)

```bash
# Используя firewall
ufw allow from 127.0.0.1 to any port 54321

# Или через iptables
iptables -A INPUT -p tcp --dport 54321 -j DROP
iptables -A INPUT -p tcp --dport 54321 -s 127.0.0.1 -j ACCEPT
```

### 2. Использовать VPN/SSH туннель для доступа к панели

```bash
# Локально
ssh -L 54321:localhost:54321 root@SERVER_IP

# Затем открыть http://localhost:54321
```

### 3. Регулярно обновлять 3X-UI

```bash
# Раз в месяц
docker pull ghcr.io/mhsanaei/3x-ui:latest
docker-compose restart
```

### 4. Мониторить логи на предмет атак

```bash
# Просмотреть логи за последние 10 строк
docker logs 3x-ui | tail -10

# Поискать ошибки
docker logs 3x-ui | grep error
```

### 5. Регулярно архивировать БД

```bash
# Добавить в crontab для ежедневного архивирования (в 3:00 AM)
(crontab -l 2>/dev/null; echo "0 3 * * * tar -czf /root/3x-ui-backup-\$(date +\%Y\%m\%d).tar.gz /root/3x-ui/") | crontab -
```

---

## Итоговая архитектура

```
┌─────────────────────────────────────────────────────┐
│           Hetzner VPS (Финляндия)                   │
│  Ubuntu 20.04+ | 1 vCPU | 1-2 GB RAM | 10 GB HDD  │
├─────────────────────────────────────────────────────┤
│                                                      │
│   ┌──────────────────────────────────────────┐    │
│   │  Docker Container: 3X-UI                 │    │
│   │  ├─ Port 54321: Web Panel (HTTP/HTTPS)  │    │
│   │  ├─ Port 443: VLESS+Reality (TCP/UDP)   │    │
│   │  ├─ DB: SQLite (/root/3x-ui/db/)        │    │
│   │  └─ Cert: /root/3x-ui/cert/             │    │
│   │                                          │    │
│   └──────────────────────────────────────────┘    │
│                                                      │
│   fail2ban (для IP Limit)                         │
│                                                      │
└─────────────────────────────────────────────────────┘
         ↓↓↓ Трафик пользователей через порт 443 ↓↓↓
┌─────────────────────────────────────────────────────┐
│      Клиенты (v2rayNG, v2rayN, FoXray и т.д.)     │
│      VLESS+Reality подключение маскируется         │
│      под обычный HTTPS трафик                      │
└─────────────────────────────────────────────────────┘
```

---

## Дополнительные ресурсы

- [3X-UI GitHub](https://github.com/MHSanaei/3x-ui)
- [3X-UI Wiki](https://github.com/MHSanaei/3x-ui/wiki)
- [VLESS+Reality](https://github.com/XTLS/Xray-core)
- [v2rayNG для Android](https://github.com/2dust/v2rayNG)
- [v2rayN для Windows](https://github.com/2dust/v2rayN)
- [FoXray для macOS](https://foxray.app/)

---

## Заключение

3X-UI - это мощное и простое решение для развертывания VLESS+Reality VPN сервера. Встроенный IP Limit позволяет эффективно контролировать количество подключенных устройств на пользователя, а простой веб-интерфейс делает управление доступным даже без особых технических знаний.

Время развертывания: 1-2 часа
Стоимость (Hetzner): €3.79/мес
Сложность: Средняя
Рекомендация: ✅ Отличное решение для малых и средних инфраструктур
