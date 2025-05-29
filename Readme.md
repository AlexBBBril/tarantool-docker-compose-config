Инструкция по использованию:

1. Подготовка
    ```bash
    # Сделайте скрипт управления исполняемым
    chmod +x manage.sh
    ```
2. Первый запуск

    ```bash
    # Настройка директорий и запуск
    ./manage.sh setup
    ./manage.sh start
    ```
   
3. Проверьте статус

    ```bash
    ./manage.sh status
    ```
   
4. Посмотрите логи

    ```bash
   ./manage.sh logs 
    ```
   
5. Help
   ```bash
    $ ./manage.sh help
    Управление Tarantool в Docker
    
    Использование: ./manage.sh [команда]
    
    Команды:
    start     - Запустить Tarantool
    stop      - Остановить Tarantool
    restart   - Перезапустить Tarantool
    status    - Показать статус
    logs      - Показать логи (follow режим)
    console   - Подключиться к консоли Tarantool
    backup    - Создать бэкап снэпшотов
    clean     - Удалить все данные
    setup     - Создать необходимые директории
    fix-perms - Исправить права доступа
    files     - Показать содержимое директорий

   ```
