FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/repo

WORKDIR /repo/services/api

RUN addgroup --system pecox && adduser --system --ingroup pecox pecox \
    && pip install --no-cache-dir uv

COPY services/api/pyproject.toml services/api/uv.lock ./
RUN uv sync --no-dev --frozen \
    && uv pip install --no-cache \
      --index-url https://download.pytorch.org/whl/cpu \
      --extra-index-url https://pypi.org/simple \
      "torch>=2.5,<3.0" \
      "torchvision>=0.20,<1.0" \
      "pillow>=11.0,<12.0" \
      "numpy>=2.0,<3.0"

COPY services/api /repo/services/api
COPY ml/inference /repo/ml/inference
COPY ml/training /repo/ml/training
COPY ml/evaluation/reports /repo/ml/evaluation/reports

RUN mkdir -p /repo/ml/artifacts && chown -R pecox:pecox /repo

USER pecox

ENV PATH="/repo/services/api/.venv/bin:$PATH"

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3)" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]
