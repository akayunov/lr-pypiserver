#!/bin/bash

set -e


# Функция для сборки контейнеров
build() {
    echo "Сборка контейнеров..."
    docker compose -f docker-compose.yml build
}

# Функция для старта контейнеров
start() {
    echo "Запуск контейнеров..."
    docker compose -f docker-compose.yml up -d
}

# Функция для остановки контейнеров
stop() {
    if [ "$1" = "-v" ]; then
        echo "Остановка и удаление контейнеров (включая volumes)..."
        docker compose -f docker-compose.yml down -v --timeout 0
    else
        echo "Остановка и удаление контейнеров..."
        docker compose -f docker-compose.yml down --timeout 0
    fi
}

# Функция для входа в тестовый контейнер
test() {
    docker compose exec -it pypi-server-test bash
}


download() {
  pip download \
    --only-binary=:all: \
    -r requirements.txt \
    -d ./tmp
}

upload() {
  #twine    upload  --verbose   --repository-url http://pypi-server:8080/ -u admin -p privetserver tmp/*.whl
  # с игнорирование ошибок
  #
  # for file in tmp/*.whl; do twine upload --repository-url http://pypi-server:8080/ -u admin -p privetserver "$file" || true; done
  for file in tmp/*.whl; do echo "Uploading $file..."; output=$(twine upload --repository-url http://pypi-server:8080/ -u admin -p privetserver "$file" 2>&1) || echo -e "❌ Error uploading $(basename "$file"):\n$output\n"; done
  # возможно прийдеться обновить версию pypiserver до 2.4.1
  # twine upload --verbose --repository-url http://pypi-server:8080/ -u admin -p privetserver tmp/charset_normalizer-3.4.7-cp313-*.whl
}
# Обработка переданного аргумента
case "$1" in
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop "${@:2}"
        ;;
    test)
        test
        ;;
    *)
        echo "Использование: $0 {build|start|stop|test}"
        exit 1
        ;;
esac



