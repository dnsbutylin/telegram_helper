PROJECT := telegram_helper
VERSION := v0.1.0

VENV := .venv
REPORTS := .reports

SOURCES := $(PROJECT)
TESTS := tests

PY_FILES := $(shell find $(SOURCES) $(TESTS) -name "*.py")

IMAGE_NAME := $(PROJECT)
SSH_KEY_PATH := $(HOME)/.ssh/id_rsa

help:  ## Показать описание всех команд
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean:  ## Очистка рабочего окружения
	rm -rf .mypy_cache
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf $(REPORTS)
	rm -rf $(VENV)
	find . -name '__pycache__' | xargs rm -rf

$(VENV):
	poetry install --no-root

$(REPORTS):
	mkdir $(REPORTS)

setup: $(VENV) $(REPORTS) ## Настройка рабочего окружения

flake8: setup
	poetry run flake8 $(SOURCES) $(TESTS)
	poetry run flake8-markdown "*.md"

mypy: setup
	poetry run mypy $(SOURCES) $(TESTS)

bandit: setup
	poetry run bandit -qr $(PROJECT) -c .bandit.yml -o $(REPORTS)/bandit.json -f json

pylint: setup
	poetry run pylint $(PROJECT) $(TESTS) > $(REPORTS)/pylint.txt

isort: setup
	poetry run isort $(SOURCES) $(TESTS)

isort-lint: setup
	poetry run isort -c $(SOURCES) $(TESTS)

black: setup
	poetry run black . --quiet

black-lint: setup
	poetry run black . --check

yesqa: setup
	poetry run yesqa $(PY_FILES) || true

cyclonedx-bom: setup
	poetry run cyclonedx-py -p -i poetry.lock -o $(REPORTS)/cyclonedx-bom.xml --force

integration-tests: setup  ## Запуск интеграционных тестов
	poetry run pytest $(TESTS)

all-tests: integration-tests  ## Запуск всех тестов

format: yesqa isort black  ## Форматирование исходного кода

lint: flake8 mypy bandit pylint isort-lint black-lint cyclonedx-bom  ## Запуск статического анализа

.PHONY: ci
ci:  ## Запуск CI-конвейера
	make -C ci build all rmi

release: setup  ## Создание релиза
	poetry run cz bump --check-consistency --files-only

build:  ## Сборка Docker-образа
	DOCKER_BUILDKIT=1 docker build . \
		--ssh default=$(SSH_KEY_PATH) \
		--tag $(IMAGE_NAME) \
		--pull \
		--no-cache

echo-image-name:
	@echo $(IMAGE_NAME)

echo-image-tag:
	@echo $(IMAGE_NAME):$(VERSION)

all: format lint build  ## Последовательный запуск основных команд

.DEFAULT_GOAL := all
