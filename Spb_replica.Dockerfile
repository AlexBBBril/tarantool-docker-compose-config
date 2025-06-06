FROM tarantool/tarantool:latest

USER root

RUN apt update && apt install -y \
    git \
    cmake \
    build-essential \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем vshard (можно и другие модули)
RUN tt rocks install vshard

COPY tarantool_config/spb-replica-entrypoint.sh /opt/tarantool/spb-replica-entrypoint.sh
RUN chmod +x /opt/tarantool/spb-replica-entrypoint.sh

# Копируем конфиги и init.lua внутрь контейнера
COPY ./tarantool_config /opt/tarantool

# Назначаем пользователя обратно (если надо)
USER tarantool

CMD ["tarantool", "/opt/tarantool/spb-replica.lua"]