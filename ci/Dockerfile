FROM nexus.ucb.infra/dh/python:3.11-buster

ARG PROJECT=app
ARG POETRY_VERSION=1.3.2
ARG GIT_HOST=git.ucb.local

WORKDIR /home/$PROJECT

COPY . .

RUN --mount=type=ssh mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan -H -p 7999 $GIT_HOST >> ~/.ssh/known_hosts && \
    pip install -U pip poetry==$POETRY_VERSION && \
    make setup

RUN adduser --no-create-home $PROJECT && chown -R $PROJECT:$PROJECT /home/$PROJECT

USER $PROJECT

CMD ["make", "lint"]
