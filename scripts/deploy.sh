#!/bin/bash
# ================================================================================
# Скрипт развертывания 3X-UI VPN на сервере
# ================================================================================
# Источник: research/3X-UI_DEPLOYMENT.md:107-128
#
# Описание:
#   Автоматическое развертывание 3X-UI панели с проверками зависимостей,
#   созданием необходимых директорий и запуском Docker контейнера.
#
# Использование:
#   chmod +x scripts/deploy.sh
#   ./scripts/deploy.sh
#
# Требования:
#   - Ubuntu/Debian сервер (20.04+)
#   - Root доступ или sudo
#   - Открытые порты: 443, 54321
# ================================================================================

set -e  # Остановить выполнение при любой ошибке
set -u  # Ошибка при использовании неопределенных переменных

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция логирования
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Заголовок
echo "========================================"
echo "  3X-UI VPN Deployment Script"
echo "========================================"
echo ""

# 1. Проверка прав root
if [ "$EUID" -ne 0 ]; then
    log_error "Требуются root права. Запустите с sudo:"
    echo "  sudo ./scripts/deploy.sh"
    exit 1
fi

log_info "Проверка root прав: OK"

# 2. Проверка операционной системы
if [ -f /etc/os-release ]; then
    . /etc/os-release
    log_info "Операционная система: $PRETTY_NAME"
else
    log_error "Не удалось определить операционную систему"
    exit 1
fi

# 3. Обновление пакетов системы
log_info "Обновление списка пакетов..."
apt-get update -qq

# 4. Проверка и установка Docker
if ! command -v docker &> /dev/null; then
    log_warn "Docker не установлен. Устанавливаю..."

    # Установка зависимостей
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Добавление официального GPG ключа Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Добавление репозитория Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Установка Docker
    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Запуск Docker
    systemctl start docker
    systemctl enable docker

    log_info "Docker установлен успешно"
else
    log_info "Docker уже установлен: $(docker --version)"
fi

# 5. Проверка Docker Compose
if ! docker compose version &> /dev/null; then
    log_error "Docker Compose не найден. Установите Docker Compose v2"
    exit 1
fi

log_info "Docker Compose: $(docker compose version)"

# 6. Создание директорий для данных
log_info "Создание директорий для данных..."
mkdir -p ./data/db ./data/cert ./backup
chmod -R 755 ./data ./backup

log_info "Директории созданы:"
log_info "  - ./data/db    (база данных SQLite)"
log_info "  - ./data/cert  (SSL сертификаты)"
log_info "  - ./backup     (резервные копии)"

# 7. Проверка портов
# Используем ss (socket statistics) вместо lsof - доступен на всех Linux системах
log_info "Проверка доступности портов..."
for port in 443 54321; do
    if ss -tuln | grep -q ":$port " ; then
        log_warn "Порт $port уже занят!"
        log_warn "Список процессов на порту $port:"
        ss -tuln | grep ":$port "
        read -p "Продолжить? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Развертывание отменено пользователем"
            exit 1
        fi
    else
        log_info "Порт $port свободен"
    fi
done

# 8. Остановка существующего контейнера (если есть)
if [ "$(docker ps -q -f name=3x-ui)" ]; then
    log_warn "Обнаружен запущенный контейнер 3x-ui. Останавливаю..."
    docker compose down
fi

# 9. Запуск контейнера
log_info "Запуск 3X-UI контейнера..."
docker compose up -d

# 10. Ожидание запуска
log_info "Ожидание запуска сервиса (15 секунд)..."
sleep 15

# 11. Проверка статуса
log_info "Проверка статуса контейнера..."
if docker ps | grep -q 3x-ui; then
    log_info "Контейнер 3x-ui успешно запущен!"
else
    log_error "Контейнер 3x-ui не запущен. Проверьте логи:"
    echo "  docker logs 3x-ui"
    exit 1
fi

# 12. Получение IP адреса сервера
SERVER_IP=$(curl -s ifconfig.me || echo "UNKNOWN")

# 13. Вывод информации для доступа
echo ""
echo "========================================"
echo -e "${GREEN}  Развертывание завершено успешно!${NC}"
echo "========================================"
echo ""
echo "Панель управления: http://${SERVER_IP}:54321"
echo ""
echo "Учетные данные по умолчанию:"
echo "  Логин: admin"
echo "  Пароль: admin"
echo ""
echo -e "${RED}⚠ ОБЯЗАТЕЛЬНО СМЕНИТЬ ПАРОЛЬ!${NC}"
echo ""
echo "Следующие шаги:"
echo "  1. Откройте панель в браузере"
echo "  2. Войдите с учетными данными admin/admin"
echo "  3. Смените пароль: Panel Settings → Username/Password"
echo "  4. Создайте VLESS+Reality inbound на порту 443"
echo "  5. Добавьте пользователей с IP Limit = 1"
echo ""
echo "Полезные команды:"
echo "  Просмотр логов:    docker logs -f 3x-ui"
echo "  Перезапуск:        docker compose restart"
echo "  Остановка:         docker compose down"
echo "  Резервная копия:   docker cp 3x-ui:/etc/x-ui/x-ui.db ./backup/"
echo ""
echo "Документация: ./research/ или GitHub: https://github.com/leonid998/WG"
echo "========================================"
