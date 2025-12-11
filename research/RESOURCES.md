# 📦 Ресурсы и ссылки для WireGuard VPN

## 🔗 Официальные ресурсы

### WireGuard
- **Официальный сайт:** https://www.wireguard.com
- **GitHub:** https://github.com/WireGuard
- **Документация:** https://www.wireguard.com/quickstart/

### AmneziaWG (для обхода блокировок в РФ)
- **Официальный сайт:** https://www.amnezia.org
- **GitHub:** https://github.com/amnezia-vpn/amneziawg
- **Документация:** https://docs.amnezia.org
- **Релизы Windows:** https://github.com/amnezia-vpn/amneziawg-windows-client/releases
- **Релизы Android:** https://github.com/amnezia-vpn/amneziawg-android/releases

---

## 📥 Скачивание клиентов

### Windows
- **WireGuard:** https://download.wireguard.com/windows-client/
- **AmneziaWG:** https://github.com/amnezia-vpn/amneziawg-windows-client/releases/latest

### macOS
- **App Store:** https://apps.apple.com/us/app/wireguard/id1451685025
- **AmneziaWG:** https://www.amnezia.org/ru/downloads

### Linux
```bash
# Ubuntu/Debian
sudo apt install wireguard

# Fedora
sudo dnf install wireguard-tools

# Arch Linux
sudo pacman -S wireguard-tools
```

### Android
- **Google Play (WireGuard):** https://play.google.com/store/apps/details?id=com.wireguard.android
- **Google Play (Amnezia):** https://play.google.com/store/apps/details?id=org.amnezia.vpn
- **F-Droid (WireGuard):** https://f-droid.org/packages/com.wireguard.android/

### iOS
- **App Store (WireGuard):** https://apps.apple.com/us/app/wireguard/id1441195209
- **App Store (Amnezia):** https://apps.apple.com/app/amnezia-vpn/id1600529900

---

## 🛠️ Готовые скрипты установки

### Автоматическая установка WireGuard
```bash
# Скрипт установки от hwdsl2
wget https://git.io/wireguard -O wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

# Репозиторий
https://github.com/hwdsl2/wireguard-install
```

### Установка AmneziaWG
```bash
# Официальный установщик
curl -sSL https://get.amnezia.org | bash
```

### WireGuard + Web UI (управление через браузер)

#### WG-Easy
```bash
docker run -d \
  --name=wg-easy \
  -e WG_HOST=<YOUR_SERVER_IP> \
  -e PASSWORD=<ADMIN_PASSWORD> \
  -v ~/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy
```
- **GitHub:** https://github.com/wg-easy/wg-easy
- **Веб-интерфейс:** http://YOUR_SERVER_IP:51821

#### WireGuard-UI
```bash
docker run -d \
  --name wireguard-ui \
  -p 5000:5000 \
  -v /etc/wireguard:/etc/wireguard \
  -v wireguard-ui-data:/app/db \
  --cap-add=NET_ADMIN \
  ngoduykhanh/wireguard-ui:latest
```
- **GitHub:** https://github.com/ngoduykhanh/wireguard-ui
- **Веб-интерфейс:** http://YOUR_SERVER_IP:5000

---

## 🌐 Рекомендуемые VPS провайдеры

### Для размещения сервера (за пределами РФ)

| Провайдер | Расположение | Цена/мес | Особенности |
|-----------|--------------|----------|-------------|
| **Hetzner** | Германия, Финляндия | от €3.79 | Высокая скорость, близко к РФ |
| **DigitalOcean** | Нидерланды, Германия | от $6 | Простота, 200 ГБ трафика |
| **Vultr** | Германия, Нидерланды | от $6 | Гибкость, почасовая оплата |
| **Linode (Akamai)** | Германия | от $5 | Быстрая сеть |
| **OVH** | Франция | от €3.50 | Дешево, защита от DDoS |

**Рекомендация:** Hetzner (Финляндия) — лучшее соотношение цена/скорость/расстояние от РФ.

---

## 📚 Полезные статьи и гайды

### Блокировки и обход DPI
- **WireGuard Воскрес (Amnezia):** https://habr.com/ru/companies/amnezia/articles/813149/
- **Обход блокировки VPN:** https://sysattack.com/posts/bypass-rkn-vpn/
- **Bypassing Russia's WireGuard block:** https://hub.xeovo.com/posts/27-bypassing-russias-wireguard-block-meet-amneziawg

### Настройка и оптимизация
- **WireGuard installation Ubuntu/Debian:** https://github.com/hwdsl2/wireguard-install
- **Setup WireGuard VPN + Web UI:** https://www.tecmint.com/setup-wireguard-vpn-server-web-ui-ubuntu/
- **WireGuard with UFW:** https://www.procustodibus.com/blog/2021/05/wireguard-ufw/
- **WireGuard Firewall Rules:** https://www.cyberciti.biz/faq/how-to-set-up-wireguard-firewall-rules-in-linux/

### Безопасность
- **WireGuard Kill Switch (Linux):** https://www.ivpn.net/knowledgebase/linux/linux-wireguard-kill-switch/
- **DNS Leaks on Windows:** https://engineerworkshop.com/blog/dont-let-wireguard-dns-leaks-on-windows-compromise-your-security-learn-how-to-fix-it/

### Обфускация
- **WireGuard obfuscation with Shadowsocks:** https://www.starvpn.com/obfuscate-wireguard-vpn-with-shadowsocks
- **Mullvad: Shadowsocks Obfuscation:** https://mullvad.net/en/blog/introducing-shadowsocks-obfuscation-for-wireguard

---

## 🔍 Инструменты диагностики

### Проверка IP и утечек
- **IP адрес:** https://ifconfig.me
- **DNS leak test:** https://dnsleaktest.com
- **WebRTC leak test:** https://browserleaks.com/webrtc
- **Комплексная проверка:** https://ipleak.net

### Проверка скорости
- **Speedtest:** https://www.speedtest.net
- **Fast.com (Netflix):** https://fast.com

### Мониторинг WireGuard
```bash
# Статус интерфейса
wg show

# Детальная информация
wg show wg0

# Только список peers
wg show wg0 peers

# Передача данных
wg show wg0 transfer
```

---

## 📖 DNS провайдеры (для конфигурации)

| Провайдер | DNS адреса | Особенности |
|-----------|------------|-------------|
| **Cloudflare** | 1.1.1.1, 1.0.0.1 | Самый быстрый, приватность |
| **Google** | 8.8.8.8, 8.8.4.4 | Надежный, но собирает данные |
| **Quad9** | 9.9.9.9, 149.112.112.112 | Блокировка вредоносных сайтов |
| **AdGuard** | 94.140.14.14, 94.140.15.15 | Блокировка рекламы |
| **NextDNS** | Кастомные | Гибкая настройка, блокировка трекеров |

**Рекомендация:** Cloudflare (1.1.1.1) — лучший баланс скорости и приватности.

---

## 🎓 Обучающие материалы

### Видео
- **YouTube: WireGuard Setup 2024:** https://www.youtube.com/results?search_query=wireguard+setup+2024
- **YouTube: AmneziaWG Russia:** https://www.youtube.com/results?search_query=amneziawg

### Курсы и туториалы
- **DigitalOcean Community:** https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04
- **Linode Docs:** https://www.linode.com/docs/guides/set-up-wireguard-vpn-on-ubuntu/

---

## 🔧 Вспомогательные инструменты

### Генерация QR кодов
```bash
# Установка
sudo apt install qrencode

# Использование
qrencode -t ansiutf8 < client.conf
qrencode -o client_qr.png < client.conf
```

### Онлайн генераторы QR
- **QR Code Generator:** https://www.qr-code-generator.com
- **QR Code Monkey:** https://www.qrcode-monkey.com

### Мониторинг трафика
```bash
# Установка iftop
sudo apt install iftop

# Просмотр трафика на wg0
sudo iftop -i wg0
```

---

## 📞 Поддержка и сообщество

### WireGuard
- **Форум:** https://lists.zx2c4.com/mailman/listinfo/wireguard
- **Reddit:** https://www.reddit.com/r/WireGuard/

### AmneziaWG
- **Telegram (ru):** https://t.me/amnezia_vpn
- **GitHub Issues:** https://github.com/amnezia-vpn/amneziawg/issues

---

## 📝 Шаблоны конфигураций

### Базовый сервер
```ini
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

### Базовый клиент
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### AmneziaWG (с обфускацией)
```ini
[Interface]
PrivateKey = <KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1
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
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

---

**Дата обновления:** 11 декабря 2025
