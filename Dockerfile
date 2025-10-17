FROM python:3.12-alpine

# Аргументы сборки для маркировки образа
ARG LAB_LOGIN
ARG LAB_TOKEN

RUN apk add --no-cache curl

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && rm requirements.txt

COPY --chown=appuser:appgroup app ./app

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8000
ENV PYTHONPATH=/app
ENV APP_ENV=production

LABEL org.lab.login="${LAB_LOGIN}" \
      org.lab.token="${LAB_TOKEN}"

USER appuser

RUN mkdir -p /tmp/gunicorn && chown appuser:appgroup /tmp/gunicorn

HEALTHCHECK --interval=25s --timeout=5s --start-period=10s --retries=2 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--timeout", "30", "app.app:app"]
