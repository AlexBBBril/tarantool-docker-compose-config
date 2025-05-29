#!/usr/bin/env tarantool

-- Простая конфигурация для совместимости со старыми и новыми версиями
local log = require('log')

-- Проверяем версию Tarantool
local version = require('tarantool').version
log.info('Tarantool version: %s', version)

-- Базовая конфигурация
local config = {
    -- Сетевые настройки
    listen = 3301,

--     -- Пути к файлам данных и логов (упрощенные)
--     work_dir = '/var/lib/tarantool',

    -- Настройки логирования
    log_level = 'info',
    log = '/var/log/tarantool/tarantool.log',

    -- Настройки снэпшотов
    checkpoint_interval = 3600,  -- снэпшот каждый час
    checkpoint_count = 2,        -- хранить 2 последних снэпшота

--     Память
--     memtx_memory = 128 * 1024 * 1024,  -- 128MB

    -- Другие настройки
    read_only = false,
}

-- Применяем конфигурацию
if not box.cfg or not box.cfg.listen then
    box.cfg(config)
end

-- Ждем инициализации box
while not box.info.status or box.info.status == 'loading' do
    require('fiber').sleep(0.01)
end

-- Создание пользователя admin с паролем
box.once('init_user', function()
    -- Создание пользователя
    if not box.schema.user.exists('admin') then
        box.schema.user.create('admin', {password = 'password'})
        box.schema.user.grant('admin', 'read,write,execute', 'universe')
        log.info('User admin created')
    end
end)

-- Создание демо спейса
box.once('init_demo_space', function()
    -- Пример создания простого спейса
    local demo_space = box.schema.space.create('demo', {if_not_exists = true})
    demo_space:format({
        {name = 'id', type = 'unsigned'},
        {name = 'name', type = 'string'},
        {name = 'data', type = 'map', is_nullable = true}
    })
    demo_space:create_index('primary', {
        type = 'hash',
        parts = {'id'},
        if_not_exists = true
    })

    -- Вставка тестовых данных
    if demo_space:len() == 0 then
        demo_space:replace{1, 'test_record', {key = 'value'}}
        demo_space:replace{2, 'another_record', {foo = 'bar'}}
        log.info('Demo data inserted')
    end

    log.info('Demo space initialized')
end)

-- Включение консоли для удаленного подключения
require('console').start()

log.info('Tarantool ready on port 3301')
log.info('Data directory: /var/lib/tarantool/')
log.info('Log file: /var/log/tarantool/tarantool.log')