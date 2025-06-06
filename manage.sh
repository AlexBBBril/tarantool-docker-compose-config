#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_colored() {
    echo -e "${1}${2}${NC}"
}

show_help() {
    echo "Управление Tarantool в Docker"
    echo ""
    echo "Использование: $0 [команда]"
    echo ""
    echo "Команды:"
    echo "  start     - Запустить Tarantool"
    echo "  stop      - Остановить Tarantool"
    echo "  restart   - Перезапустить Tarantool"
    echo "  status    - Показать статус"
    echo "  logs      - Показать логи (follow режим)"
    echo "  console   - Подключиться к консоли Tarantool"
    echo "  backup    - Создать бэкап снэпшотов"
    echo "  clean     - Удалить все данные"
    echo "  setup     - Создать необходимые директории"
    echo "  fix-perms - Исправить права доступа"
    echo "  files     - Показать содержимое директорий"
    echo ""
}

setup_directories() {
    print_colored $BLUE "Создание директорий..."
    mkdir -p tarantool_data/main/var/lib/tarantool
    mkdir -p tarantool_data/main/var/log/tarantool
    mkdir -p tarantool_data/moscow/var/lib/tarantool
    mkdir -p tarantool_data/moscow/var/log/tarantool
    mkdir -p tarantool_data/spb/var/lib/tarantool
    mkdir -p tarantool_data/spb/var/log/tarantool
    mkdir -p tarantool_config
    mkdir -p backups

    # Определяем UID и GID пользователя tarantool в контейнере
    print_colored $BLUE "Определение UID и GID пользователя tarantool..."
    TARANTOOL_UID=$(docker run --rm tarantool/tarantool:latest id -u tarantool 2>/dev/null || echo "999")
    TARANTOOL_GID=$(docker run --rm tarantool/tarantool:latest id -g tarantool 2>/dev/null || echo "999")

    print_colored $YELLOW "UID пользователя tarantool: $TARANTOOL_UID"
    print_colored $YELLOW "GID пользователя tarantool: $TARANTOOL_GID"

    # Создаем .env файл с правильными UID и GID
    cat > .env << EOF
TARANTOOL_UID=$TARANTOOL_UID
TARANTOOL_GID=$TARANTOOL_GID
EOF
    print_colored $GREEN "Создан .env файл с UID=$TARANTOOL_UID и GID=$TARANTOOL_GID"

    print_colored $BLUE "Установка прав доступа..."

    # Пробуем установить права через sudo
    if command -v sudo >/dev/null 2>&1; then
        sudo chown -R $TARANTOOL_UID:$TARANTOOL_GID tarantool_data/
        sudo chmod -R 755 tarantool_data/
        print_colored $GREEN "Права установлены через sudo"
    else
        # Альтернативный способ через Docker
        print_colored $YELLOW "sudo недоступен, используем Docker для установки прав..."
        docker run --rm -v "$(pwd)/tarantool_data:/data" alpine:latest sh -c "chown -R $TARANTOOL_UID:$TARANTOOL_GID /data && chmod -R 755 /data"
        print_colored $GREEN "Права установлены через Docker"
    fi

    # Копируем конфиги если их нет
    if [ ! -f "tarantool_config/init.lua" ]; then
        print_colored $YELLOW "Создайте init.lua в директории tarantool_config/"
    fi

    print_colored $GREEN "Директории созданы и права установлены!"
}

start_tarantool() {
    print_colored $BLUE "Запуск Tarantool..."
    docker compose up -d
    print_colored $GREEN "Tarantool запущен!"
}

stop_tarantool() {
    print_colored $BLUE "Остановка Tarantool..."
    docker compose down
    print_colored $GREEN "Tarantool остановлен!"
}

restart_tarantool() {
    print_colored $BLUE "Перезапуск Tarantool..."
    docker compose restart
    print_colored $GREEN "Tarantool перезапущен!"
}

show_status() {
    print_colored $BLUE "Статус контейнеров:"
    docker compose ps
    echo ""
    print_colored $BLUE "Использование ресурсов:"
    docker stats tarantool_db --no-stream
}

show_logs() {
    print_colored $BLUE "Логи Tarantool (Ctrl+C для выхода):"
    echo ""
    docker compose logs -f tarantool
}

connect_console() {
    print_colored $BLUE "Подключение к консоли Tarantool..."
    print_colored $YELLOW "Для выхода используйте: \\q или Ctrl+D"
    echo ""
    docker exec -it tarantool_db console
}

create_backup() {
    print_colored $BLUE "Создание бэкапа..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_dir="backups/backup_$timestamp"
    mkdir -p "$backup_dir"

    # Копируем снэпшоты и WAL файлы
    cp -r tarantool_data/main/var/lib/tarantool/*.snap "$backup_dir/" 2>/dev/null || true
    cp -r tarantool_data/main/var/lib/tarantool/*.xlog "$backup_dir/" 2>/dev/null || true
    cp -r tarantool_data/moscow/var/lib/tarantool/*.snap "$backup_dir/" 2>/dev/null || true
    cp -r tarantool_data/moscow/var/lib/tarantool/*.xlog "$backup_dir/" 2>/dev/null || true
    cp -r tarantool_data/spb/var/lib/tarantool/*.snap "$backup_dir/" 2>/dev/null || true
    cp -r tarantool_data/spb/var/lib/tarantool/*.xlog "$backup_dir/" 2>/dev/null || true

    # Создаем архив
    tar -czf "backups/tarantool_backup_$timestamp.tar.gz" -C "$backup_dir" .
    rm -rf "$backup_dir"

    print_colored $GREEN "Бэкап создан: backups/tarantool_backup_$timestamp.tar.gz"
}

clean_data() {
    print_colored $RED "ВНИМАНИЕ: Это удалит ВСЕ данные Tarantool!"
    read -p "Вы уверены? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        print_colored $BLUE "Остановка Tarantool..."
        docker compose down -v

        print_colored $BLUE "Удаление данных..."
        sudo rm -rf tarantool_data/*
        ls -la .

        print_colored $GREEN "Данные удалены!"
    else
        print_colored $YELLOW "Отменено."
    fi
}

view_files() {
    print_colored $BLUE "Содержимое директории данных:"
    ls -la tarantool_data/main/var/lib/tarantool/
    ls -la tarantool_data/moscow/var/lib/tarantool/
    echo ""
    print_colored $BLUE "Содержимое директории логов:"
    ls -la tarantool_data/main/var/log/tarantool/
    ls -la tarantool_data/moscow/var/log/tarantool/
}

fix_permissions() {
    print_colored $BLUE "Определение UID и GID пользователя tarantool..."

    # Останавливаем контейнер если он запущен
    docker compose down 2>/dev/null

    # Узнаем UID и GID пользователя tarantool в контейнере
    TARANTOOL_UID=$(docker run --rm tarantool/tarantool:latest id -u tarantool 2>/dev/null || echo "999")
    TARANTOOL_GID=$(docker run --rm tarantool/tarantool:latest id -g tarantool 2>/dev/null || echo "999")

    print_colored $YELLOW "UID пользователя tarantool: $TARANTOOL_UID"
    print_colored $YELLOW "GID пользователя tarantool: $TARANTOOL_GID"

    print_colored $BLUE "Исправление прав доступа..."

    # Устанавливаем права
    if command -v sudo >/dev/null 2>&1; then
        sudo chown -R $TARANTOOL_UID:$TARANTOOL_GID tarantool_data/
        sudo chmod -R 755 tarantool_data/
        print_colored $GREEN "Права исправлены через sudo"
    else
        # Альтернативный способ через Docker
        print_colored $YELLOW "Используем Docker для исправления прав..."
        docker run --rm -v "$(pwd)/tarantool_data:/data" alpine:latest sh -c "chown -R $TARANTOOL_UID:$TARANTOOL_GID /data && chmod -R 755 /data"
        print_colored $GREEN "Права исправлены через Docker"
    fi

    print_colored $BLUE "Проверка прав доступа:"
    ls -la tarantool_data/main/var/lib/tarantool/
    ls -la tarantool_data/main/var/log/tarantool/
    ls -la tarantool_data/moscow/var/lib/tarantool/
    ls -la tarantool_data/moscow/var/log/tarantool/
    ls -la tarantool_data/moscow-replica/var/lib/tarantool/
    ls -la tarantool_data/moscow-replica/var/log/tarantool/
    ls -la tarantool_data/spb/var/lib/tarantool/
    ls -la tarantool_data/spb/var/log/tarantool/
    ls -la tarantool_data/spb-replica/var/lib/tarantool/
    ls -la tarantool_data/spb-replica/var/log/tarantool/
}

# Основная логика
case "${1:-help}" in
    start)
        setup_directories
        start_tarantool
        ;;
    stop)
        stop_tarantool
        ;;
    restart)
        restart_tarantool
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    console)
        connect_console
        ;;
    backup)
        create_backup
        ;;
    clean)
        clean_data
        ;;
    setup)
        setup_directories
        ;;
    fix-perms)
        fix_permissions
        ;;
    files)
        view_files
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_colored $RED "Неизвестная команда: $1"
        show_help
        exit 1
        ;;
esac