FROM python:3.11-slim as builder

COPY . .

RUN pip install -U --no-cache-dir pip wheel poetry
RUN poetry build -f wheel
RUN poetry export -f requirements.txt -o requirements.txt --without-hashes

RUN --mount=type=ssh mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan -H -p 7999 $GIT_HOST >> ~/.ssh/known_hosts
#    pip wheel -w dist -r requirements.txt

FROM python:3.11-slim as runtime

WORKDIR /app

ENV PYTHONOPTIMIZE=1

COPY --from=builder dist dist

RUN pip install --no-cache-dir --no-index dist/*.whl && \
    rm -rf dist

RUN useradd -r -UM app
USER app

CMD ["main:create_app", "-c"]
