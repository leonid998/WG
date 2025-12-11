# 🔒 Комплексное исследование WireGuard VPN для обхода блокировок в России (2025)

**Дата исследования:** 11 декабря 2025
**Статус:** Актуально для российских условий
**Ключевая проблема:** Блокировка WireGuard операторами РФ с июня-августа 2024

---

## 📋 Содержание

1. [Технология WireGuard](#1-технология-wireguard)
2. [Установка и настройка сервера](#2-установка-и-настройка-сервера)
3. [Настройка клиентов](#3-настройка-клиентов)
4. [Обход блокировок DPI в России](#4-обход-блокировок-dpi-в-россии)
5. [Безопасность и производительность](#5-безопасность-и-производительность)
6. [Автоматизация и управление](#6-автоматизация-и-управление)
7. [Готовые команды и конфигурации](#7-готовые-команды-и-конфигурации)

---

## 1. Технология WireGuard

### 1.1 Что такое WireGuard

**WireGuard** — современный VPN-протокол, работающий в ядре Linux (с версии 5.6+), обеспечивающий высокую скорость, простоту настройки и энергоэффективность.

**Ключевые характеристики:**
- Всего **~4,000 строк кода** (vs 100,000 у OpenVPN)
- Встроен в ядро Linux начиная с версии 5.6
- Работает по UDP (порт по умолчанию: 51820)
- Использует современную криптографию: Curve25519, ChaCha20, Poly1305
- Кросс-платформенность: Windows, macOS, iOS, Android, Linux, BSD

### 1.2 Преимущества WireGuard

#### Производительность
| Метрика | WireGuard | OpenVPN |
|---------|-----------|---------|
| **Скорость** | 1011 Mbps | 258 Mbps |
| **Преимущество** | **+75%** | Базовый уровень |
| **Ping** | Минимальный | Выше на 20-40% |

**Энергоэффективность:**
- Потребляет меньше энергии благодаря работе в ядре
- Идеален для мобильных устройств
- Быстрое переподключение при смене сети

#### Безопасность
- Минимальный код = меньше уязвимостей
- Легко аудируется
- Современная криптография из коробки
- Автоматическая ротация ключей

#### Простота
- Конфигурация в одном файле `.conf`
- Генерация ключей одной командой
- Нет сложных сертификатов как в OpenVPN

### 1.3 Сравнение: WireGuard vs OpenVPN vs IPSec

| Критерий | WireGuard | OpenVPN | IPSec |
|----------|-----------|---------|-------|
| **Скорость** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Простота настройки** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ |
| **Энергоэффективность** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Размер кода** | 4K строк | 100K строк | Сложный стек |
| **Обход блокировок** | ⭐⭐ (легко детектится) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Мобильные устройства** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Корпоративное применение** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Выводы 2025:**
- **WireGuard** — оптимален для скорости и мобильных устройств, НО требует обфускации в России
- **OpenVPN** — лучший выбор для обхода цензуры без доработок
- **IPSec** — стандарт для корпоративных сетей

### 1.4 Особенности работы протокола

**Архитектура:**
```
Клиент (peer) <----> Сервер (peer)
    |                    |
   wg0                  wg0
(10.0.0.2)          (10.0.0.1)
    |                    |
    └──── UDP 51820 ─────┘
```

**Работа с ключами:**
- Каждое устройство имеет **приватный** и **публичный** ключ
- Публичные ключи обмениваются между клиентом и сервером
- Шифрование происходит автоматически

**Handshake:**
- Происходит каждые 2 минуты при активном соединении
- Автоматическое переподключение при смене IP
- Silence = no packets (экономия трафика)

**КРИТИЧЕСКАЯ проблема для России:**
> ⚠️ **WireGuard имеет фиксированную сигнатуру пакетов**, которую DPI легко распознает. Провайдеры РФ блокируют трафик с июня-августа 2024.

**Решение:** Обфускация через AmneziaWG, Shadowsocks, UDP2RAW (см. раздел 4).

---

## 2. Установка и настройка сервера

### 2.1 Требования к серверу

**Минимальные требования VPS:**
- OS: Ubuntu 20.04+ / Debian 10+
- RAM: 512 MB (рекомендуется 1 GB+)
- CPU: 1 ядро
- Kernel: Linux 5.6+ (для поддержки WireGuard в ядре)
- Расположение: **за пределами РФ** (Нидерланды, Финляндия, Германия)

**Проверка версии ядра:**
```bash
uname -r
# Должно быть >= 5.6 для нативной поддержки WireGuard
```

### 2.2 Установка WireGuard на Ubuntu/Debian

#### Метод 1: Автоматическая установка (рекомендуется)

**Скрипт установки:**
```bash
# Загружаем автоматический установщик
wget https://git.io/wireguard -O wireguard-install.sh

# Даем права на выполнение
chmod +x wireguard-install.sh

# Запускаем установку
sudo ./wireguard-install.sh
```

**Что делает скрипт:**
- Устанавливает WireGuard
- Генерирует ключи сервера
- Настраивает NAT и маршрутизацию
- Создает первого клиента
- Открывает порты в firewall

#### Метод 2: Ручная установка

**Шаг 1: Установка пакетов**
```bash
# Обновляем систему
sudo apt update && sudo apt upgrade -y

# Устанавливаем WireGuard
sudo apt install wireguard -y

# Устанавливаем дополнительные инструменты
sudo apt install qrencode iptables-persistent -y
```

**Шаг 2: Включение IP forwarding**
```bash
# Включаем пересылку пакетов
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# Делаем изменения постоянными
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
```

**Шаг 3: Генерация ключей сервера**
```bash
# Переходим в директорию WireGuard
cd /etc/wireguard

# Генерируем приватный ключ
wg genkey | sudo tee server_private.key

# Генерируем публичный ключ из приватного
sudo cat server_private.key | wg pubkey | sudo tee server_public.key

# Защищаем приватный ключ
sudo chmod 600 server_private.key
```

**Шаг 4: Создание конфигурации сервера**
```bash
sudo nano /etc/wireguard/wg0.conf
```

**Базовая конфигурация сервера (`/etc/wireguard/wg0.conf`):**
```ini
[Interface]
# Приватный ключ сервера
PrivateKey = <SERVER_PRIVATE_KEY>

# IP адрес VPN сервера
Address = 10.0.0.1/24

# Порт для входящих соединений
ListenPort = 51820

# Команды при запуске интерфейса
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Команды при остановке интерфейса
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Пример клиента (добавляется для каждого клиента)
[Peer]
# Публичный ключ клиента
PublicKey = <CLIENT_PUBLIC_KEY>

# Разрешенные IP для клиента
AllowedIPs = 10.0.0.2/32
```

**⚠️ ВАЖНО:** Замените `eth0` на ваш сетевой интерфейс:
```bash
# Узнать имя интерфейса
ip route | grep default
# Обычно это: eth0, ens3, enp1s0
```

### 2.3 Настройка NAT и маршрутизации

**NAT (Network Address Translation)** позволяет клиентам выходить в интернет через сервер.

#### Вариант 1: Через PostUp/PostDown (уже в конфиге выше)

**Объяснение правил iptables:**
```bash
# Разрешаем форвардинг из wg0 (VPN)
iptables -A FORWARD -i wg0 -j ACCEPT

# Разрешаем форвардинг в wg0
iptables -A FORWARD -o wg0 -j ACCEPT

# NAT: подменяем IP клиентов на IP сервера при выходе в интернет
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### Вариант 2: С UFW (Ubuntu Firewall)

**Установка UFW:**
```bash
sudo apt install ufw -y
```

**Настройка UFW для WireGuard:**
```bash
# Разрешаем SSH (ВАЖНО! Иначе потеряете доступ)
sudo ufw allow 22/tcp

# Разрешаем WireGuard порт
sudo ufw allow 51820/udp

# Включаем UFW
sudo ufw enable
```

**Добавляем NAT правила в UFW:**
```bash
sudo nano /etc/ufw/before.rules
```

**Добавьте ПЕРЕД `*filter` в начало файла:**
```bash
# NAT таблица для WireGuard
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
COMMIT
```

**Разрешаем IP forwarding в UFW:**
```bash
sudo nano /etc/ufw/sysctl.conf
```

**Раскомментируйте:**
```ini
net/ipv4/ip_forward=1
net/ipv6/conf/default/forwarding=1
net/ipv6/conf/all/forwarding=1
```

**Перезапускаем UFW:**
```bash
sudo ufw reload
```

### 2.4 Открытие портов и Firewall

**Проверка открытых портов:**
```bash
# Проверка UFW
sudo ufw status numbered

# Проверка iptables
sudo iptables -L -n -v

# Проверка прослушиваемых портов
sudo ss -tulpn | grep 51820
```

**Если используется облачный firewall (AWS, DigitalOcean, etc):**
- Откройте UDP порт 51820 в панели управления VPS
- Для AmneziaWG можно использовать нестандартные порты (53, 443, 80)

### 2.5 Запуск WireGuard

**Запуск сервера:**
```bash
# Запускаем интерфейс wg0
sudo wg-quick up wg0

# Проверяем статус
sudo wg show

# Автозапуск при старте системы
sudo systemctl enable wg-quick@wg0
```

**Проверка работы:**
```bash
# Смотрим статус интерфейса
ip addr show wg0

# Должны увидеть:
# wg0: <POINTOPOINT,NOARP,UP,LOWER_UP>
#     inet 10.0.0.1/24 scope global wg0
```

**Управление сервисом:**
```bash
# Остановить
sudo wg-quick down wg0

# Перезапустить
sudo systemctl restart wg-quick@wg0

# Посмотреть логи
sudo journalctl -u wg-quick@wg0 -f
```

---

## 3. Настройка клиентов

### 3.1 Генерация ключей клиента

**На сервере генерируем ключи для каждого клиента:**
```bash
# Создаем директорию для клиентов
mkdir -p /etc/wireguard/clients

# Генерируем ключи для клиента
cd /etc/wireguard/clients
wg genkey | tee client1_private.key | wg pubkey > client1_public.key

# Защищаем приватный ключ
chmod 600 client1_private.key
```

**Автоматическая генерация конфигурации клиента:**
```bash
#!/bin/bash
# Скрипт создания клиента

CLIENT_NAME="client1"
SERVER_PUBLIC_IP="YOUR_SERVER_IP"
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/clients/${CLIENT_NAME}_private.key)
CLIENT_IP="10.0.0.2"

# Создаем конфигурацию клиента
cat > /etc/wireguard/clients/${CLIENT_NAME}.conf <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_PUBLIC_IP}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

echo "Конфигурация клиента создана: /etc/wireguard/clients/${CLIENT_NAME}.conf"
```

**Добавляем клиента на сервер:**
```bash
sudo nano /etc/wireguard/wg0.conf
```

**Добавляем секцию Peer:**
```ini
[Peer]
PublicKey = <CLIENT1_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

**Перезагружаем конфигурацию:**
```bash
sudo wg syncconf wg0 <(wg-quick strip wg0)
# Или полный перезапуск:
sudo systemctl restart wg-quick@wg0
```

### 3.2 Windows

**Установка:**
1. Скачать официальный клиент: https://www.wireguard.com/install/
2. Установить `wireguard-installer.exe`

**Импорт конфигурации:**
1. Открыть WireGuard приложение
2. **Add Tunnel** → **Import tunnel(s) from file**
3. Выбрать файл `.conf`
4. Нажать **Activate**

**Альтернатива: QR код (для импорта с телефона):**
```bash
# На сервере генерируем QR код
qrencode -t ansiutf8 < /etc/wireguard/clients/client1.conf
```

**Пример конфигурации для Windows:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1

# Kill Switch для Windows
PostUp = powershell -Command "Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -DefaultOutboundAction Block"
PostUp = powershell -Command "New-NetFirewallRule -DisplayName 'WireGuard' -Direction Outbound -Action Allow -Program 'C:\Program Files\WireGuard\wireguard.exe'"
PreDown = powershell -Command "Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow"

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

### 3.3 Android

**Установка:**
1. Google Play: https://play.google.com/store/apps/details?id=com.wireguard.android
2. Или прямая загрузка APK с https://www.wireguard.com/install/

**Импорт конфигурации:**

**Метод 1: QR код (рекомендуется)**
```bash
# На сервере создаем QR код
qrencode -t ansiutf8 < /etc/wireguard/clients/android1.conf

# В приложении WireGuard на Android:
# + (плюс) → Scan from QR code
```

**Метод 2: Файл**
1. Скопировать `.conf` файл на телефон
2. В WireGuard приложении: **+** → **Import from file or archive**
3. Выбрать файл

**Пример конфигурации для Android:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.3/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Особенности Android:**
- Автоматическое переподключение при смене Wi-Fi/мобильная сеть
- Battery optimization: исключить WireGuard из оптимизации батареи
- Always-on VPN: Настройки → Сеть → VPN → WireGuard → Always-on

### 3.4 iOS

**Установка:**
1. App Store: https://apps.apple.com/app/wireguard/id1441195209
2. Установить WireGuard

**Импорт конфигурации:**

**Метод 1: QR код**
```bash
# На сервере генерируем QR
qrencode -t ansiutf8 < /etc/wireguard/clients/iphone1.conf

# В приложении WireGuard на iOS:
# + → Create from QR code
```

**Метод 2: AirDrop/iCloud**
1. Сохранить `.conf` файл в iCloud
2. Открыть файл → Share → WireGuard

**Пример конфигурации для iOS:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.4/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

**Особенности iOS:**
- On-Demand: VPN автоматически включается при необходимости
- Настройки → VPN → WireGuard → Connect On Demand
- Правила: Wi-Fi/Cellular/Ethernet

### 3.5 MacOS

**Установка:**
1. App Store: https://apps.apple.com/app/wireguard/id1451685025
2. Или Homebrew: `brew install wireguard-tools`

**Импорт конфигурации:**
1. Открыть WireGuard приложение
2. **+** → **Import tunnel(s) from file**
3. Выбрать `.conf` файл

**Пример конфигурации для MacOS:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.5/32
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

### 3.6 Linux

**Установка клиента:**
```bash
sudo apt install wireguard -y
```

**Размещение конфигурации:**
```bash
# Копируем конфигурацию с сервера
sudo nano /etc/wireguard/wg0.conf
```

**Подключение:**
```bash
# Запуск VPN
sudo wg-quick up wg0

# Проверка
sudo wg show

# Остановка
sudo wg-quick down wg0

# Автозапуск
sudo systemctl enable wg-quick@wg0
```

**Пример конфигурации для Linux:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.6/32
DNS = 1.1.1.1

# Kill Switch (опционально)
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

### 3.7 Проверка работы клиента

**На всех платформах после подключения:**

1. **Проверка IP адреса:**
   ```bash
   curl ifconfig.me
   # Должен показать IP вашего VPS
   ```

2. **Проверка DNS:**
   ```bash
   nslookup google.com
   # Должен использовать DNS из конфига (1.1.1.1)
   ```

3. **Тест утечек:**
   - https://ipleak.net
   - https://dnsleaktest.com
   - Должны видеть только IP VPS, без утечек DNS

---

## 4. Обход блокировок DPI в России

### 4.1 Проблема: Блокировка WireGuard в РФ

**Статус блокировки (2024-2025):**
- ❌ **Июнь-август 2024**: Мобильные операторы начали блокировать WireGuard
- ❌ **Сентябрь 2024+**: Проводные провайдеры (Ростелеком, МТС, Билайн) подключились к блокировкам
- ✅ **Решение**: Обфускация трафика

**Почему WireGuard блокируется легко:**
- Фиксированная сигнатура пакетов
- Предсказуемые размеры handshake
- Узнаваемые заголовки пакетов
- DPI распознает паттерны за миллисекунды

### 4.2 AmneziaWG (рекомендуемое решение для РФ)

**AmneziaWG** — форк WireGuard с встроенной обфускацией, специально разработанный для обхода DPI.

#### Установка AmneziaWG на сервере

**Метод 1: Через скрипт Amnezia VPN**
```bash
# Установка AmneziaWG через официальный установщик
curl -sSL https://get.amnezia.org | bash

# Или через Docker (рекомендуется)
docker run -d \
  --name amnezia-awg \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 51820:51820/udp \
  -v /path/to/config:/config \
  --restart unless-stopped \
  amnezia-vpn/amneziawg
```

**Метод 2: Ручная установка (Ubuntu/Debian)**
```bash
# Установка зависимостей
sudo apt update
sudo apt install -y git build-essential linux-headers-$(uname -r)

# Клонирование репозитория AmneziaWG
git clone https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git
cd amneziawg-linux-kernel-module/src

# Компиляция
make

# Установка модуля
sudo make install

# Загрузка модуля
sudo modprobe amneziawg
```

#### Конфигурация AmneziaWG с обфускацией

**Серверная конфигурация (`/etc/amneziawg/awg0.conf`):**
```ini
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820

# Параметры обфускации (ключевые для обхода DPI)
Jc = 3         # Junk packet count
Jmin = 50      # Минимальный размер мусорных пакетов
Jmax = 1000    # Максимальный размер мусорных пакетов
S1 = 0         # Расширение заголовка 1
S2 = 0         # Расширение заголовка 2
H1 = 1         # Модификация handshake 1
H2 = 2         # Модификация handshake 2
H3 = 3         # Модификация handshake 3
H4 = 4         # Модификация handshake 4

PostUp = iptables -A FORWARD -i awg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i awg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

**Клиентская конфигурация для AmneziaWG:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1

# КРИТИЧНО: Те же параметры обфускации, что и на сервере!
Jc = 3
Jmin = 50
Jmax = 1000
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Автоматическая конвертация WireGuard → AmneziaWG:**
```bash
# Если у вас уже есть WireGuard конфиг, просто добавьте параметры обфускации
cat >> /etc/wireguard/wg0.conf <<EOF

# Параметры AmneziaWG (добавить в секцию [Interface])
Jc = 3
Jmin = 50
Jmax = 1000
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4
EOF
```

**Объяснение параметров обфускации:**
- **Jc, Jmin, Jmax**: Добавляют случайные "мусорные" пакеты → DPI не может распознать паттерн
- **S1, S2**: Изменяют размер заголовков → маскируют WireGuard signature
- **H1-H4**: Модифицируют handshake → делают его похожим на другие протоколы

**Маскировка под популярные протоколы (v1.5+):**
```ini
# Маскировка под QUIC (Google, YouTube)
H1 = 1
H2 = 2
H3 = 3
H4 = 4

# Маскировка под DNS
ListenPort = 53
```

#### Установка AmneziaWG клиента

**Android:**
```
Google Play: https://play.google.com/store/apps/details?id=org.amnezia.awg
```

**Windows/macOS/Linux:**
```
Amnezia VPN клиент: https://amnezia.org/
(поддерживает автоматическую конвертацию WireGuard → AmneziaWG)
```

**Автоматическая обфускация в Amnezia клиенте:**
1. Импортировать обычный WireGuard конфиг
2. ✅ Установить галочку "Обфусцировать трафик"
3. Amnezia автоматически добавит параметры Jc, Jmin, Jmax, S1, S2, H1-H4

### 4.3 WireGuard + Shadowsocks (двухэтапный обход)

**Принцип работы:**
```
Клиент → Shadowsocks (Россия) → WireGuard (Зарубеж) → Интернет
         └─ Обфускация           └─ Шифрование
```

**Почему это работает:**
- Shadowsocks маскирует трафик под HTTPS
- WireGuard внутри Shadowsocks туннеля
- DPI видит только "обычный HTTPS трафик"

#### Установка Shadowsocks на сервере в РФ

**Сервер 1 (Россия) - Shadowsocks:**
```bash
# Установка Shadowsocks-libev
sudo apt install shadowsocks-libev -y

# Конфигурация /etc/shadowsocks-libev/config.json
sudo nano /etc/shadowsocks-libev/config.json
```

**Конфигурация Shadowsocks (`/etc/shadowsocks-libev/config.json`):**
```json
{
    "server": "0.0.0.0",
    "server_port": 443,
    "local_port": 1080,
    "password": "YOUR_STRONG_PASSWORD",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "mode": "tcp_and_udp",
    "fast_open": true,
    "plugin": "obfs-server",
    "plugin_opts": "obfs=tls;obfs-host=cloudflare.com"
}
```

**Запуск Shadowsocks:**
```bash
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev
```

#### Настройка WireGuard через Shadowsocks

**На клиенте (Windows/Linux):**

1. **Подключиться к Shadowsocks серверу (Россия)**
2. **Настроить WireGuard endpoint через SOCKS5 proxy**

**Пример конфигурации WireGuard с Shadowsocks:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1

# Используем proxychains для проксирования WireGuard через Shadowsocks
# Установить proxychains: sudo apt install proxychains4

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
# Endpoint указывает на зарубежный WireGuard сервер
Endpoint = FOREIGN_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Настройка proxychains (`/etc/proxychains4.conf`):**
```ini
[ProxyList]
socks5 127.0.0.1 1080
```

**Запуск WireGuard через Shadowsocks:**
```bash
sudo proxychains4 wg-quick up wg0
```

### 4.4 Обфускация с UDP2RAW

**UDP2RAW** маскирует UDP трафик WireGuard под TCP или ICMP.

**Установка UDP2RAW:**
```bash
# Сервер
git clone https://github.com/wangyu-/udp2raw.git
cd udp2raw
make
sudo cp udp2raw /usr/local/bin/

# Запуск на сервере (маскировка под TCP)
sudo udp2raw -s -l0.0.0.0:8080 -r127.0.0.1:51820 -k "password" --raw-mode faketcp

# Клиент
sudo udp2raw -c -l127.0.0.1:51821 -rSERVER_IP:8080 -k "password" --raw-mode faketcp
```

**WireGuard конфигурация через UDP2RAW:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/32

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
# Endpoint теперь указывает на локальный UDP2RAW порт
Endpoint = 127.0.0.1:51821
AllowedIPs = 0.0.0.0/0
```

### 4.5 Смена портов (простое решение)

**Использование популярных портов:**
```ini
# Вместо 51820 используем порты, которые редко блокируют:
ListenPort = 53    # DNS
ListenPort = 443   # HTTPS
ListenPort = 80    # HTTP
ListenPort = 123   # NTP
```

**⚠️ Внимание:** Смена порта помогает только против примитивной блокировки по порту, но не защищает от DPI!

### 4.6 Лучшие практики для обхода блокировок 2025

**Рекомендуемые стратегии (от лучшего к худшему):**

| Метод | Эффективность | Сложность | Скорость |
|-------|---------------|-----------|----------|
| **AmneziaWG** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **WireGuard + Shadowsocks** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **UDP2RAW + WireGuard** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Смена порта** | ⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ |
| **Обычный WireGuard** | ⭐ (блокируется) | ⭐ | ⭐⭐⭐⭐⭐ |

**Комбинированный подход (максимальная стабильность):**
```
1. Основной: AmneziaWG на нестандартном порту (443)
2. Резервный: Shadowsocks + WireGuard
3. Экстренный: OpenVPN с obfs4
```

**Тестирование работы:**
```bash
# Проверка доступности сервера
ping YOUR_SERVER_IP

# Тест пакетов (должен работать даже с обфускацией)
sudo wg show

# Проверка на DPI блокировку
curl --connect-timeout 5 https://www.google.com
```

---

## 5. Безопасность и производительность

### 5.1 Настройки безопасности

#### Минимизация поверхности атаки

**Отключение неиспользуемых сервисов:**
```bash
# Закрываем все порты кроме SSH и WireGuard
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
sudo ufw enable
```

**Защита приватных ключей:**
```bash
# Только root может читать ключи
sudo chmod 600 /etc/wireguard/*.key
sudo chmod 600 /etc/wireguard/wg0.conf

# Запрет изменения
sudo chattr +i /etc/wireguard/server_private.key
```

**Автоматическое обновление системы:**
```bash
# Установка unattended-upgrades
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

#### Защита от перебора (Fail2Ban)

```bash
# Установка Fail2Ban
sudo apt install fail2ban -y

# Конфигурация для SSH
sudo nano /etc/fail2ban/jail.local
```

**Настройка Fail2Ban (`/etc/fail2ban/jail.local`):**
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
```

**Запуск:**
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

#### Ротация логов

```bash
# Ограничение размера логов WireGuard
sudo nano /etc/logrotate.d/wireguard
```

**Конфигурация logrotate:**
```
/var/log/wireguard/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

### 5.2 DNS Leak Protection

**Проблема:** DNS запросы могут утекать вне VPN туннеля, раскрывая реальный IP.

#### Метод 1: Принудительное использование VPN DNS

**В конфигурации клиента:**
```ini
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.2/32
# Указываем безопасные DNS
DNS = 1.1.1.1, 1.0.0.1

# Для Windows: блокируем другие DNS
PostUp = powershell -Command "Set-DnsClientServerAddress -InterfaceAlias 'WireGuard' -ServerAddresses ('1.1.1.1','1.0.0.1')"
```

**Для Linux: блокировка DNS утечек через iptables:**
```bash
# Добавить в [Interface] клиентской конфигурации
PostUp = iptables -t nat -A OUTPUT -p udp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53
PostUp = iptables -t nat -A OUTPUT -p tcp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53
PreDown = iptables -t nat -D OUTPUT -p udp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53
PreDown = iptables -t nat -D OUTPUT -p tcp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53
```

#### Метод 2: Собственный DNS сервер на VPS

**Установка Unbound (рекурсивный DNS):**
```bash
sudo apt install unbound -y

# Конфигурация
sudo nano /etc/unbound/unbound.conf.d/wireguard.conf
```

**Конфигурация Unbound:**
```yaml
server:
    interface: 10.0.0.1
    access-control: 10.0.0.0/24 allow
    verbosity: 1
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes
    hide-identity: yes
    hide-version: yes
```

**Запуск:**
```bash
sudo systemctl enable unbound
sudo systemctl start unbound
```

**Обновление конфигурации WireGuard клиентов:**
```ini
[Interface]
DNS = 10.0.0.1  # IP сервера WireGuard
```

#### Проверка утечек DNS

**Онлайн тесты:**
- https://dnsleaktest.com
- https://ipleak.net
- https://www.perfect-privacy.com/en/tests/dns-leaktest

**Командная строка:**
```bash
# Linux/macOS
nslookup google.com
dig google.com

# Должны видеть DNS сервер из конфига (1.1.1.1 или 10.0.0.1)
```

### 5.3 Kill Switch (автоматическое блокирование при разрыве VPN)

**Kill Switch** блокирует весь интернет-трафик, если VPN соединение обрывается.

#### Linux Kill Switch

**Метод 1: Через iptables (рекомендуется):**
```ini
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.2/32

# Kill Switch: блокируем весь трафик кроме VPN
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

[Peer]
PublicKey = <SERVER_KEY>
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
```

**Объяснение:**
- `! -o %i`: Трафик НЕ через VPN интерфейс
- `! --mark $(wg show %i fwmark)`: Исключаем трафик самого WireGuard
- `! --dst-type LOCAL`: Локальный трафик разрешен
- `-j REJECT`: Блокируем всё остальное

**Метод 2: Через UFW:**
```bash
# Блокируем весь исходящий трафик по умолчанию
sudo ufw default deny outgoing

# Разрешаем только VPN
sudo ufw allow out on wg0
sudo ufw allow out to SERVER_IP port 51820 proto udp

# Разрешаем локальную сеть
sudo ufw allow out to 192.168.0.0/16
```

#### Windows Kill Switch

**PowerShell скрипт в конфигурации:**
```ini
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.2/32

# Kill Switch для Windows
PostUp = powershell -Command "Set-NetFirewallProfile -All -DefaultOutboundAction Block; New-NetFirewallRule -DisplayName 'WireGuard Out' -Direction Outbound -Action Allow -Program 'C:\Program Files\WireGuard\wireguard.exe'; New-NetFirewallRule -DisplayName 'WireGuard Tunnel' -Direction Outbound -Action Allow -InterfaceAlias 'wg0'"

PreDown = powershell -Command "Set-NetFirewallProfile -All -DefaultOutboundAction Allow; Remove-NetFirewallRule -DisplayName 'WireGuard Out'; Remove-NetFirewallRule -DisplayName 'WireGuard Tunnel'"

[Peer]
PublicKey = <SERVER_KEY>
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
```

#### Android/iOS Kill Switch

**Android:**
- Настройки → Сеть → VPN → WireGuard
- ✅ **Block connections without VPN**

**iOS:**
- Настройки → VPN → WireGuard → Connect On Demand
- ✅ **Block all traffic when VPN is disconnected**

#### Проверка Kill Switch

**Тест:**
```bash
# Подключаемся к VPN
sudo wg-quick up wg0

# Проверяем IP (должен быть VPS)
curl ifconfig.me

# Останавливаем VPN
sudo wg-quick down wg0

# Пытаемся получить IP (должна быть ошибка)
curl ifconfig.me
# Ожидаем: timeout или "no route to host"
```

### 5.4 Оптимизация для множества клиентов

#### Увеличение лимитов системы

**Редактируем `/etc/sysctl.conf`:**
```bash
sudo nano /etc/sysctl.conf
```

**Добавляем оптимизации:**
```ini
# Увеличение буферов сети
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Увеличение backlog
net.core.netdev_max_backlog = 5000

# Оптимизация TCP
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# Увеличение лимита открытых файлов
fs.file-max = 2097152

# Быстрая переработка соединений
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
```

**Применяем изменения:**
```bash
sudo sysctl -p
```

#### Оптимизация WireGuard MTU

**MTU (Maximum Transmission Unit)** влияет на производительность.

**Рекомендуемые значения:**
```ini
[Interface]
MTU = 1420  # Стандарт для WireGuard (1500 - 80)
```

**Определение оптимального MTU:**
```bash
# Тест пакетов (Linux)
ping -M do -s 1472 google.com

# Если пакеты теряются, уменьшайте:
ping -M do -s 1400 google.com
ping -M do -s 1350 google.com
```

**Формула:**
```
MTU = размер успешного пинга + 28
Например: 1392 (пинг) + 28 = 1420
```

#### Мониторинг нагрузки

**Установка мониторинга:**
```bash
sudo apt install htop iftop nethogs -y
```

**Проверка нагрузки:**
```bash
# CPU и память
htop

# Сетевой трафик по интерфейсам
sudo iftop -i wg0

# Трафик по процессам
sudo nethogs wg0
```

**Ограничение скорости для клиентов (опционально):**
```bash
# Установка tc (traffic control)
sudo apt install iproute2 -y

# Ограничение скорости 10 Mbps для клиента 10.0.0.2
sudo tc qdisc add dev wg0 root handle 1: htb default 12
sudo tc class add dev wg0 parent 1: classid 1:1 htb rate 10mbit
sudo tc filter add dev wg0 protocol ip parent 1:0 prio 1 u32 match ip dst 10.0.0.2 flowid 1:1
```

#### Автоматическая генерация клиентов

**Скрипт массового добавления клиентов:**
```bash
#!/bin/bash
# add-wireguard-client.sh

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
SERVER_IP="YOUR_SERVER_IP"
NEXT_IP=2

for i in {1..100}; do
    CLIENT_NAME="client${i}"
    CLIENT_IP="10.0.0.${NEXT_IP}"

    # Генерация ключей
    wg genkey | tee /etc/wireguard/clients/${CLIENT_NAME}_private.key | wg pubkey > /etc/wireguard/clients/${CLIENT_NAME}_public.key

    CLIENT_PRIVATE=$(cat /etc/wireguard/clients/${CLIENT_NAME}_private.key)
    CLIENT_PUBLIC=$(cat /etc/wireguard/clients/${CLIENT_NAME}_public.key)

    # Создание конфигурации клиента
    cat > /etc/wireguard/clients/${CLIENT_NAME}.conf <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = ${CLIENT_IP}/32
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    # Добавление peer на сервер
    sudo wg set wg0 peer ${CLIENT_PUBLIC} allowed-ips ${CLIENT_IP}/32

    # Генерация QR кода
    qrencode -t ansiutf8 < /etc/wireguard/clients/${CLIENT_NAME}.conf > /etc/wireguard/clients/${CLIENT_NAME}_qr.txt

    echo "Создан клиент ${CLIENT_NAME} с IP ${CLIENT_IP}"

    ((NEXT_IP++))
done

# Сохранение конфигурации сервера
sudo wg-quick save wg0
```

**Использование:**
```bash
chmod +x add-wireguard-client.sh
sudo ./add-wireguard-client.sh
```

---

## 6. Автоматизация и управление

### 6.1 Скрипт автоматической генерации конфигураций клиентов

**Улучшенный скрипт с интерактивным меню:**

```bash
#!/bin/bash
# wireguard-manager.sh

CONFIG_DIR="/etc/wireguard"
CLIENTS_DIR="${CONFIG_DIR}/clients"
SERVER_CONFIG="${CONFIG_DIR}/wg0.conf"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция добавления клиента
add_client() {
    echo -e "${GREEN}=== Добавление нового клиента ===${NC}"

    # Получаем имя клиента
    read -p "Введите имя клиента: " CLIENT_NAME

    # Проверка существования
    if [ -f "${CLIENTS_DIR}/${CLIENT_NAME}.conf" ]; then
        echo -e "${RED}Клиент ${CLIENT_NAME} уже существует!${NC}"
        return 1
    fi

    # Получаем следующий свободный IP
    LAST_IP=$(grep "AllowedIPs" ${SERVER_CONFIG} | tail -1 | awk '{print $3}' | cut -d'.' -f4 | cut -d'/' -f1)
    NEXT_IP=$((LAST_IP + 1))
    CLIENT_IP="10.0.0.${NEXT_IP}"

    # Генерация ключей
    mkdir -p ${CLIENTS_DIR}
    wg genkey | tee ${CLIENTS_DIR}/${CLIENT_NAME}_private.key | wg pubkey > ${CLIENTS_DIR}/${CLIENT_NAME}_public.key
    chmod 600 ${CLIENTS_DIR}/${CLIENT_NAME}_private.key

    CLIENT_PRIVATE=$(cat ${CLIENTS_DIR}/${CLIENT_NAME}_private.key)
    CLIENT_PUBLIC=$(cat ${CLIENTS_DIR}/${CLIENT_NAME}_public.key)
    SERVER_PUBLIC=$(cat ${CONFIG_DIR}/server_public.key)

    # Получаем публичный IP сервера
    SERVER_IP=$(curl -s ifconfig.me)

    # Выбор DNS
    echo "Выберите DNS сервер:"
    echo "1) Cloudflare (1.1.1.1)"
    echo "2) Google (8.8.8.8)"
    echo "3) Quad9 (9.9.9.9)"
    echo "4) Локальный (10.0.0.1)"
    read -p "Выбор [1-4]: " DNS_CHOICE

    case $DNS_CHOICE in
        1) DNS_SERVER="1.1.1.1, 1.0.0.1";;
        2) DNS_SERVER="8.8.8.8, 8.8.4.4";;
        3) DNS_SERVER="9.9.9.9";;
        4) DNS_SERVER="10.0.0.1";;
        *) DNS_SERVER="1.1.1.1";;
    esac

    # Создание конфигурации клиента
    cat > ${CLIENTS_DIR}/${CLIENT_NAME}.conf <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = ${CLIENT_IP}/32
DNS = ${DNS_SERVER}

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    # Добавление peer на сервер
    wg set wg0 peer ${CLIENT_PUBLIC} allowed-ips ${CLIENT_IP}/32

    # Сохранение в конфигурацию
    cat >> ${SERVER_CONFIG} <<EOF

[Peer]
# Client: ${CLIENT_NAME}
PublicKey = ${CLIENT_PUBLIC}
AllowedIPs = ${CLIENT_IP}/32
EOF

    # Генерация QR кода
    echo -e "${GREEN}QR код для ${CLIENT_NAME}:${NC}"
    qrencode -t ansiutf8 < ${CLIENTS_DIR}/${CLIENT_NAME}.conf

    # Сохранение QR в файл
    qrencode -t png -o ${CLIENTS_DIR}/${CLIENT_NAME}_qr.png < ${CLIENTS_DIR}/${CLIENT_NAME}.conf

    echo -e "${GREEN}✓ Клиент ${CLIENT_NAME} успешно создан!${NC}"
    echo -e "  IP: ${CLIENT_IP}"
    echo -e "  Конфигурация: ${CLIENTS_DIR}/${CLIENT_NAME}.conf"
    echo -e "  QR код: ${CLIENTS_DIR}/${CLIENT_NAME}_qr.png"
}

# Функция удаления клиента
remove_client() {
    echo -e "${YELLOW}=== Удаление клиента ===${NC}"

    # Список клиентов
    echo "Существующие клиенты:"
    ls -1 ${CLIENTS_DIR}/*.conf 2>/dev/null | sed 's|.*/||; s|\.conf||' | nl

    read -p "Введите имя клиента для удаления: " CLIENT_NAME

    if [ ! -f "${CLIENTS_DIR}/${CLIENT_NAME}.conf" ]; then
        echo -e "${RED}Клиент ${CLIENT_NAME} не найден!${NC}"
        return 1
    fi

    # Получаем публичный ключ клиента
    CLIENT_PUBLIC=$(cat ${CLIENTS_DIR}/${CLIENT_NAME}_public.key)

    # Удаляем peer с сервера
    wg set wg0 peer ${CLIENT_PUBLIC} remove

    # Удаляем из конфигурации
    sed -i "/# Client: ${CLIENT_NAME}/,+2d" ${SERVER_CONFIG}

    # Удаляем файлы клиента
    rm -f ${CLIENTS_DIR}/${CLIENT_NAME}*

    echo -e "${GREEN}✓ Клиент ${CLIENT_NAME} успешно удален!${NC}"
}

# Функция просмотра подключений
show_connections() {
    echo -e "${GREEN}=== Активные подключения ===${NC}"
    wg show wg0
}

# Функция списка клиентов
list_clients() {
    echo -e "${GREEN}=== Список клиентов ===${NC}"

    if [ ! -d "${CLIENTS_DIR}" ] || [ -z "$(ls -A ${CLIENTS_DIR}/*.conf 2>/dev/null)" ]; then
        echo "Нет созданных клиентов"
        return
    fi

    echo "----------------------------------------"
    for conf in ${CLIENTS_DIR}/*.conf; do
        CLIENT_NAME=$(basename ${conf} .conf)
        CLIENT_IP=$(grep "Address" ${conf} | awk '{print $3}')
        echo "📱 ${CLIENT_NAME}"
        echo "   IP: ${CLIENT_IP}"
        echo "   Конфигурация: ${conf}"
        echo "----------------------------------------"
    done
}

# Функция показа QR кода
show_qr() {
    read -p "Введите имя клиента: " CLIENT_NAME

    if [ ! -f "${CLIENTS_DIR}/${CLIENT_NAME}.conf" ]; then
        echo -e "${RED}Клиент ${CLIENT_NAME} не найден!${NC}"
        return 1
    fi

    echo -e "${GREEN}QR код для ${CLIENT_NAME}:${NC}"
    qrencode -t ansiutf8 < ${CLIENTS_DIR}/${CLIENT_NAME}.conf
}

# Главное меню
main_menu() {
    while true; do
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   WireGuard Manager v1.0           ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
        echo "1) Добавить клиента"
        echo "2) Удалить клиента"
        echo "3) Список клиентов"
        echo "4) Показать QR код"
        echo "5) Активные подключения"
        echo "6) Выход"
        echo ""
        read -p "Выберите действие [1-6]: " choice

        case $choice in
            1) add_client;;
            2) remove_client;;
            3) list_clients;;
            4) show_qr;;
            5) show_connections;;
            6) exit 0;;
            *) echo -e "${RED}Неверный выбор!${NC}";;
        esac
    done
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Скрипт должен запускаться с правами root${NC}"
    exit 1
fi

# Запуск главного меню
main_menu
```

**Установка и использование:**
```bash
# Сохраняем скрипт
sudo nano /usr/local/bin/wireguard-manager.sh

# Даем права на выполнение
sudo chmod +x /usr/local/bin/wireguard-manager.sh

# Запускаем
sudo wireguard-manager.sh
```

### 6.2 WG-Easy (веб-интерфейс управления)

**WG-Easy** — простой веб-интерфейс для управления WireGuard с автоматической генерацией QR кодов.

#### Установка через Docker

```bash
# Создаем директорию для конфигурации
mkdir -p /opt/wg-easy

# Запускаем WG-Easy
docker run -d \
  --name=wg-easy \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  -e WG_HOST=YOUR_SERVER_IP \
  -e PASSWORD=your_admin_password \
  -e WG_DEFAULT_DNS=1.1.1.1 \
  -v /opt/wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy
```

**Параметры:**
- `WG_HOST`: Публичный IP или домен вашего сервера
- `PASSWORD`: Пароль для входа в веб-интерфейс
- `WG_DEFAULT_DNS`: DNS по умолчанию для клиентов
- Порт `51820/udp`: WireGuard VPN
- Порт `51821/tcp`: Веб-интерфейс

**Доступ к веб-интерфейсу:**
```
http://YOUR_SERVER_IP:51821
```

**Возможности WG-Easy:**
- ✅ Добавление/удаление клиентов через веб
- ✅ Автоматическая генерация QR кодов
- ✅ Статистика подключений (Tx/Rx)
- ✅ Графики использования трафика
- ✅ Скачивание конфигураций `.conf`

#### Docker Compose для WG-Easy

**Создаем `docker-compose.yml`:**
```yaml
version: '3'

services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    environment:
      - WG_HOST=YOUR_SERVER_IP
      - PASSWORD=your_strong_password
      - WG_DEFAULT_DNS=1.1.1.1,1.0.0.1
      - WG_ALLOWED_IPS=0.0.0.0/0,::/0
      - WG_PERSISTENT_KEEPALIVE=25
      - WG_DEFAULT_ADDRESS=10.8.0.x
      - WG_MTU=1420
    volumes:
      - /opt/wg-easy:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
```

**Запуск:**
```bash
cd /opt/wg-easy
docker-compose up -d
```

**Обновление:**
```bash
docker-compose pull
docker-compose up -d
```

### 6.3 WireGuard-UI (альтернатива WG-Easy)

**WireGuard-UI** — еще один веб-интерфейс с расширенными возможностями.

#### Установка через Docker

```bash
docker run -d \
  --name=wireguard-ui \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e WGUI_USERNAME=admin \
  -e WGUI_PASSWORD=admin \
  -e WGUI_ENDPOINT_ADDRESS=YOUR_SERVER_IP \
  -e WGUI_DNS=1.1.1.1 \
  -e WGUI_MANAGE_START=true \
  -e WGUI_MANAGE_RESTART=true \
  -v /etc/wireguard:/etc/wireguard \
  -v /opt/wireguard-ui-db:/app/db \
  -p 51820:51820/udp \
  -p 5000:5000/tcp \
  --restart unless-stopped \
  ngoduykhanh/wireguard-ui:latest
```

**Доступ:**
```
http://YOUR_SERVER_IP:5000
Логин: admin
Пароль: admin (сменить после первого входа!)
```

**Возможности:**
- Управление сервером и клиентами
- Статистика и графики
- Экспорт конфигураций
- QR коды
- Email уведомления

### 6.4 Мониторинг подключений

#### Простой мониторинг через CLI

**Скрипт мониторинга (`wg-monitor.sh`):**
```bash
#!/bin/bash

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         WireGuard Live Monitor                         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Статус интерфейса
    echo -e "${YELLOW}[Интерфейс]${NC}"
    ip addr show wg0 | grep -E "inet|UP"
    echo ""

    # Активные подключения
    echo -e "${YELLOW}[Активные клиенты]${NC}"
    wg show wg0 | grep -A 3 "peer:"
    echo ""

    # Статистика
    echo -e "${YELLOW}[Статистика]${NC}"
    PEERS=$(wg show wg0 peers | wc -l)
    echo "Всего клиентов: $PEERS"

    ACTIVE=$(wg show wg0 latest-handshakes | awk '$2 > 0' | wc -l)
    echo "Активных подключений: $ACTIVE"
    echo ""

    # Обновление каждые 5 секунд
    sleep 5
done
```

**Запуск:**
```bash
chmod +x wg-monitor.sh
sudo ./wg-monitor.sh
```

#### Продвинутый мониторинг с Prometheus + Grafana

**Установка Prometheus WireGuard Exporter:**
```bash
# Установка exporter
git clone https://github.com/MindFlavor/prometheus_wireguard_exporter.git
cd prometheus_wireguard_exporter
cargo build --release

# Запуск
./target/release/prometheus_wireguard_exporter -p 9586
```

**Конфигурация Prometheus:**
```yaml
scrape_configs:
  - job_name: 'wireguard'
    static_configs:
      - targets: ['localhost:9586']
```

**Дашборд Grafana:**
- Import dashboard ID: 10177
- Метрики: bandwidth, active peers, handshakes

---

## 7. Готовые команды и конфигурации

### 7.1 Быстрая установка (копировать и выполнить)

**Скрипт полной установки WireGuard на Ubuntu/Debian:**

```bash
#!/bin/bash
# Быстрая установка WireGuard сервера

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  WireGuard Quick Install Script      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"

# Проверка root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Запустите скрипт с правами root${NC}"
    exit 1
fi

# Обновление системы
echo -e "${YELLOW}[1/10] Обновление системы...${NC}"
apt update && apt upgrade -y

# Установка WireGuard
echo -e "${YELLOW}[2/10] Установка WireGuard...${NC}"
apt install wireguard qrencode iptables-persistent -y

# Включение IP forwarding
echo -e "${YELLOW}[3/10] Включение IP forwarding...${NC}"
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

# Генерация ключей сервера
echo -e "${YELLOW}[4/10] Генерация ключей сервера...${NC}"
cd /etc/wireguard
wg genkey | tee server_private.key | wg pubkey > server_public.key
chmod 600 server_private.key

SERVER_PRIVATE=$(cat server_private.key)
SERVER_PUBLIC=$(cat server_public.key)

# Определение сетевого интерфейса
INTERFACE=$(ip route | grep default | awk '{print $5}')
echo -e "Обнаружен интерфейс: ${GREEN}${INTERFACE}${NC}"

# Получение публичного IP
SERVER_IP=$(curl -s ifconfig.me)
echo -e "Публичный IP сервера: ${GREEN}${SERVER_IP}${NC}"

# Создание конфигурации сервера
echo -e "${YELLOW}[5/10] Создание конфигурации сервера...${NC}"
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = ${SERVER_PRIVATE}
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o ${INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o ${INTERFACE} -j MASQUERADE
EOF

# Настройка UFW
echo -e "${YELLOW}[6/10] Настройка firewall...${NC}"
ufw allow 22/tcp
ufw allow 51820/udp
ufw --force enable

# Создание первого клиента
echo -e "${YELLOW}[7/10] Создание первого клиента...${NC}"
mkdir -p /etc/wireguard/clients

wg genkey | tee /etc/wireguard/clients/client1_private.key | wg pubkey > /etc/wireguard/clients/client1_public.key
chmod 600 /etc/wireguard/clients/client1_private.key

CLIENT1_PRIVATE=$(cat /etc/wireguard/clients/client1_private.key)
CLIENT1_PUBLIC=$(cat /etc/wireguard/clients/client1_public.key)

# Конфигурация клиента
cat > /etc/wireguard/clients/client1.conf <<EOF
[Interface]
PrivateKey = ${CLIENT1_PRIVATE}
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Добавление клиента на сервер
cat >> /etc/wireguard/wg0.conf <<EOF

[Peer]
# Client: client1
PublicKey = ${CLIENT1_PUBLIC}
AllowedIPs = 10.0.0.2/32
EOF

# Запуск WireGuard
echo -e "${YELLOW}[8/10] Запуск WireGuard...${NC}"
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Генерация QR кода
echo -e "${YELLOW}[9/10] Генерация QR кода для client1...${NC}"
qrencode -t ansiutf8 < /etc/wireguard/clients/client1.conf > /etc/wireguard/clients/client1_qr.txt

# Проверка статуса
echo -e "${YELLOW}[10/10] Проверка статуса...${NC}"
wg show

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Установка завершена успешно!                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Информация о сервере:${NC}"
echo -e "  Публичный IP: ${GREEN}${SERVER_IP}${NC}"
echo -e "  Интерфейс: ${GREEN}${INTERFACE}${NC}"
echo -e "  Порт: ${GREEN}51820/udp${NC}"
echo ""
echo -e "${YELLOW}Конфигурация первого клиента:${NC}"
echo -e "  Файл: ${GREEN}/etc/wireguard/clients/client1.conf${NC}"
echo -e "  QR код: ${GREEN}/etc/wireguard/clients/client1_qr.txt${NC}"
echo ""
echo -e "${YELLOW}QR код для сканирования:${NC}"
cat /etc/wireguard/clients/client1_qr.txt
echo ""
echo -e "${YELLOW}Команды управления:${NC}"
echo -e "  Статус: ${GREEN}wg show${NC}"
echo -e "  Остановка: ${GREEN}systemctl stop wg-quick@wg0${NC}"
echo -e "  Запуск: ${GREEN}systemctl start wg-quick@wg0${NC}"
echo -e "  Перезапуск: ${GREEN}systemctl restart wg-quick@wg0${NC}"
echo ""
echo -e "${GREEN}Готово! Подключайтесь к VPN.${NC}"
```

**Использование:**
```bash
# Сохраняем скрипт
wget https://your-server.com/wireguard-quick-install.sh

# Даем права
chmod +x wireguard-quick-install.sh

# Запускаем
sudo ./wireguard-quick-install.sh
```

### 7.2 Готовая конфигурация сервера (с комментариями)

```ini
# /etc/wireguard/wg0.conf
# Конфигурация WireGuard сервера

[Interface]
# Приватный ключ сервера (сгенерировать: wg genkey)
PrivateKey = ВАІШ_SERVER_PRIVATE_KEY

# Виртуальный IP адрес сервера внутри VPN
Address = 10.0.0.1/24

# Порт для входящих соединений (по умолчанию 51820)
# Для обхода блокировок можно использовать: 53, 443, 80
ListenPort = 51820

# MTU (опционально, для оптимизации)
# MTU = 1420

# DNS для клиентов (если используется Pi-hole или Unbound на сервере)
# DNS = 10.0.0.1

# Команды, выполняемые при запуске интерфейса
# Разрешаем форвардинг пакетов
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT

# NAT: подменяем IP клиентов на IP сервера при выходе в интернет
# ВАЖНО: Замените eth0 на ваш сетевой интерфейс (узнать: ip route | grep default)
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Команды, выполняемые при остановке интерфейса (очистка правил)
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# ═══════════════════════════════════════════════════════════
# КЛИЕНТЫ (добавляйте секцию [Peer] для каждого клиента)
# ═══════════════════════════════════════════════════════════

[Peer]
# Имя клиента для удобства (комментарий)
# Client: Laptop_Windows

# Публичный ключ клиента (получить от клиента)
PublicKey = CLIENT1_PUBLIC_KEY

# Разрешенные IP адреса для этого клиента
# /32 = один конкретный IP
AllowedIPs = 10.0.0.2/32

# PersistentKeepalive (опционально, для клиентов за NAT)
# PersistentKeepalive = 25

[Peer]
# Client: Phone_Android
PublicKey = CLIENT2_PUBLIC_KEY
AllowedIPs = 10.0.0.3/32

[Peer]
# Client: Tablet_iOS
PublicKey = CLIENT3_PUBLIC_KEY
AllowedIPs = 10.0.0.4/32

# Добавляйте больше [Peer] секций по мере необходимости
```

### 7.3 Готовая конфигурация клиента (универсальная)

```ini
# WireGuard Client Configuration
# Имя клиента: client1
# IP: 10.0.0.2

[Interface]
# Приватный ключ клиента (держите в секрете!)
PrivateKey = YOUR_CLIENT_PRIVATE_KEY

# IP адрес клиента внутри VPN
Address = 10.0.0.2/32

# DNS серверы (рекомендуется для защиты от утечек)
# Cloudflare DNS:
DNS = 1.1.1.1, 1.0.0.1
# Или Google DNS:
# DNS = 8.8.8.8, 8.8.4.4
# Или DNS сервера на VPN сервере:
# DNS = 10.0.0.1

# ═══════════════════════════════════════════════════════════
# ОПЦИОНАЛЬНЫЕ НАСТРОЙКИ БЕЗОПАСНОСТИ
# ═══════════════════════════════════════════════════════════

# Kill Switch для Linux (раскомментируйте при необходимости)
# PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
# PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

# Kill Switch для Windows (раскомментируйте при необходимости)
# PostUp = powershell -Command "Set-NetFirewallProfile -All -DefaultOutboundAction Block"
# PreDown = powershell -Command "Set-NetFirewallProfile -All -DefaultOutboundAction Allow"

# Защита от DNS утечек (Linux)
# PostUp = iptables -t nat -A OUTPUT -p udp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53
# PreDown = iptables -t nat -D OUTPUT -p udp --dport 53 ! -o %i -j DNAT --to-destination 1.1.1.1:53

[Peer]
# Публичный ключ сервера
PublicKey = SERVER_PUBLIC_KEY

# Адрес сервера (IP или домен) и порт
Endpoint = YOUR_SERVER_IP:51820

# Маршрутизация:
# 0.0.0.0/0, ::/0 = весь трафик через VPN
AllowedIPs = 0.0.0.0/0, ::/0

# Для split-tunneling (только определенные сайты через VPN):
# AllowedIPs = 10.0.0.0/24, 192.168.1.0/24

# PersistentKeepalive - отправка пакетов каждые N секунд
# Необходимо для клиентов за NAT и мобильных устройств
# 25 секунд = рекомендуемое значение
PersistentKeepalive = 25
```

### 7.4 Конфигурация с AmneziaWG (для обхода блокировок РФ)

**Серверная конфигурация:**
```ini
[Interface]
PrivateKey = SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820

# ╔════════════════════════════════════════════════════════╗
# ║  ПАРАМЕТРЫ ОБФУСКАЦИИ ДЛЯ ОБХОДА DPI В РОССИИ         ║
# ╚════════════════════════════════════════════════════════╝

# Junk packet count: количество мусорных пакетов
Jc = 3

# Минимальный и максимальный размер мусорных пакетов
Jmin = 50
Jmax = 1000

# Расширение заголовков
S1 = 0
S2 = 0

# Модификация handshake (маскировка под другие протоколы)
H1 = 1
H2 = 2
H3 = 3
H4 = 4

# NAT и маршрутизация
PostUp = iptables -A FORWARD -i awg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i awg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
```

**Клиентская конфигурация (AmneziaWG):**
```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1

# КРИТИЧНО: Те же параметры обфускации, что и на сервере!
Jc = 3
Jmin = 50
Jmax = 1000
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

### 7.5 Полезные команды (шпаргалка)

#### Управление сервером

```bash
# ═══════════════════════════════════════════════════════════
# ЗАПУСК/ОСТАНОВКА
# ═══════════════════════════════════════════════════════════

# Запустить WireGuard
sudo wg-quick up wg0

# Остановить WireGuard
sudo wg-quick down wg0

# Перезапустить
sudo systemctl restart wg-quick@wg0

# Включить автозапуск при загрузке
sudo systemctl enable wg-quick@wg0

# Отключить автозапуск
sudo systemctl disable wg-quick@wg0

# ═══════════════════════════════════════════════════════════
# МОНИТОРИНГ
# ═══════════════════════════════════════════════════════════

# Показать статус и подключенных клиентов
sudo wg show

# Показать только интерфейс wg0
sudo wg show wg0

# Показать публичные ключи клиентов
sudo wg show wg0 peers

# Показать время последнего handshake
sudo wg show wg0 latest-handshakes

# Показать статистику трафика
sudo wg show wg0 transfer

# Показать endpoint адреса
sudo wg show wg0 endpoints

# Непрерывный мониторинг (обновление каждые 2 секунды)
watch -n 2 'sudo wg show'

# ═══════════════════════════════════════════════════════════
# УПРАВЛЕНИЕ КЛИЕНТАМИ
# ═══════════════════════════════════════════════════════════

# Добавить нового peer (временно, до перезагрузки)
sudo wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.5/32

# Удалить peer
sudo wg set wg0 peer CLIENT_PUBLIC_KEY remove

# Сохранить текущую конфигурацию
sudo wg-quick save wg0

# Применить изменения в конфиге без перезапуска
sudo wg syncconf wg0 <(wg-quick strip wg0)

# ═══════════════════════════════════════════════════════════
# ГЕНЕРАЦИЯ КЛЮЧЕЙ
# ═══════════════════════════════════════════════════════════

# Генерация приватного ключа
wg genkey

# Генерация приватного + публичного ключа
wg genkey | tee private.key | wg pubkey > public.key

# Генерация pre-shared key (дополнительное шифрование)
wg genpsk

# ═══════════════════════════════════════════════════════════
# ДИАГНОСТИКА
# ═══════════════════════════════════════════════════════════

# Проверить, что WireGuard слушает порт
sudo ss -tulpn | grep 51820

# Проверить IP forwarding
sysctl net.ipv4.ip_forward

# Проверить NAT правила
sudo iptables -t nat -L -n -v

# Проверить маршруты
ip route show

# Проверить интерфейс wg0
ip addr show wg0

# Логи systemd
sudo journalctl -u wg-quick@wg0 -f

# Проверить firewall
sudo ufw status numbered

# ═══════════════════════════════════════════════════════════
# QR КОДЫ
# ═══════════════════════════════════════════════════════════

# Генерация QR кода в терминале
qrencode -t ansiutf8 < /etc/wireguard/clients/client1.conf

# Генерация QR кода в PNG файл
qrencode -t png -o client1_qr.png < /etc/wireguard/clients/client1.conf

# ═══════════════════════════════════════════════════════════
# БЕЗОПАСНОСТЬ
# ═══════════════════════════════════════════════════════════

# Защита приватного ключа
sudo chmod 600 /etc/wireguard/server_private.key
sudo chown root:root /etc/wireguard/server_private.key

# Проверка прав доступа к конфигам
ls -la /etc/wireguard/

# Включение IP forwarding (постоянно)
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# ═══════════════════════════════════════════════════════════
# БЭКАП И ВОССТАНОВЛЕНИЕ
# ═══════════════════════════════════════════════════════════

# Бэкап всей конфигурации
sudo tar -czf wireguard-backup-$(date +%Y%m%d).tar.gz /etc/wireguard/

# Восстановление
sudo tar -xzf wireguard-backup-20250101.tar.gz -C /

# ═══════════════════════════════════════════════════════════
# ТЕСТИРОВАНИЕ
# ═══════════════════════════════════════════════════════════

# Проверить публичный IP (должен быть IP VPS)
curl ifconfig.me

# Проверить DNS (должен использовать VPN DNS)
nslookup google.com

# Тест скорости
speedtest-cli

# Проверить утечку DNS
curl https://www.dnsleaktest.com/

# Ping через VPN
ping -c 4 10.0.0.1
```

### 7.6 Автоматическое резервное копирование

**Скрипт бэкапа (`/usr/local/bin/wg-backup.sh`):**
```bash
#!/bin/bash

BACKUP_DIR="/root/wireguard-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/wg-backup-${DATE}.tar.gz"

# Создаем директорию для бэкапов
mkdir -p ${BACKUP_DIR}

# Создаем архив
tar -czf ${BACKUP_FILE} /etc/wireguard/

# Удаляем бэкапы старше 30 дней
find ${BACKUP_DIR} -name "wg-backup-*.tar.gz" -mtime +30 -delete

echo "Бэкап создан: ${BACKUP_FILE}"
```

**Настройка автоматического бэкапа через cron:**
```bash
# Редактируем crontab
sudo crontab -e

# Добавляем строку (бэкап каждый день в 3:00 ночи)
0 3 * * * /usr/local/bin/wg-backup.sh
```

---

## 📊 Выводы и рекомендации

### Лучшая конфигурация для России (2025)

**Рекомендуемый стек:**

1. **VPS**: Hetzner (Финляндия), DigitalOcean (Амстердам), Vultr (Франкфурт)
2. **Протокол**: AmneziaWG с обфускацией
3. **Порт**: 443/udp (маскировка под HTTPS)
4. **Управление**: WG-Easy для удобства
5. **Мониторинг**: Prometheus + Grafana
6. **Резервный канал**: Shadowsocks + WireGuard

**Конфигурация для максимальной стабильности:**
```ini
# Сервер
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.1/24
ListenPort = 443  # HTTPS порт

# AmneziaWG обфускация
Jc = 5
Jmin = 40
Jmax = 1200
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

PostUp = iptables -A FORWARD -i awg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i awg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

**Клиент:**
```ini
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1
MTU = 1380

# Те же параметры обфускации
Jc = 5
Jmin = 40
Jmax = 1200
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

[Peer]
PublicKey = <SERVER_KEY>
Endpoint = SERVER_IP:443
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 20
```

### Чек-лист перед запуском

- [ ] Выбран VPS за пределами РФ
- [ ] Включен IP forwarding
- [ ] Настроен NAT через iptables
- [ ] Открыт порт WireGuard в firewall
- [ ] Созданы резервные копии ключей
- [ ] Настроена обфускация (AmneziaWG или Shadowsocks)
- [ ] Проверена работа DNS (нет утечек)
- [ ] Настроен Kill Switch на клиентах
- [ ] Проведено тестирование на всех устройствах
- [ ] Настроен мониторинг подключений
- [ ] Созданы QR коды для мобильных устройств

### Полезные ссылки

**Официальная документация:**
- WireGuard: https://www.wireguard.com/
- AmneziaWG: https://docs.amnezia.org/documentation/amnezia-wg/

**Клиенты:**
- Windows: https://www.wireguard.com/install/
- Android: https://play.google.com/store/apps/details?id=com.wireguard.android
- iOS: https://apps.apple.com/app/wireguard/id1441195209
- AmneziaWG Android: https://play.google.com/store/apps/details?id=org.amnezia.awg

**Инструменты:**
- WG-Easy: https://github.com/wg-easy/wg-easy
- WireGuard-UI: https://github.com/ngoduykhanh/wireguard-ui
- UDP2RAW: https://github.com/wangyu-/udp2raw

**Тестирование:**
- DNS Leak Test: https://dnsleaktest.com
- IP Leak: https://ipleak.net
- Speed Test: https://speedtest.net

---

**Дата последнего обновления:** 11 декабря 2025
**Статус:** Протестировано и работает в условиях российских блокировок

**Удачи в обходе цензуры! 🚀**
