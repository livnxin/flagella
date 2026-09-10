FROM ghcr.io/astral-sh/uv:0.12-python3.13-alpine AS builder

# Set the working directory
WORKDIR /code

# Enable bytecode compilation for faster application startup
ENV UV_COMPILE_BYTECODE=1

# Copy only the files needed for dependency installation to leverage cache
COPY uv.lock pyproject.toml /code/

# Install dependencies into a virtual environment at /code/.venv
# --frozen ensures uv respects the exact versions in your uv.lock file
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-install-project

# ==========================================
# 2. Production Stage: Run the actual app
# ==========================================
FROM python:3.13-slim AS runner

WORKDIR /code

# Set critical Python environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Place the virtual environment's binaries at the front of the PATH
# This allows using "fastapi" directly without activating the venv
ENV PATH="/code/.venv/bin:$PATH"

# Copy the virtual environment from the builder stage
COPY --from=builder /code/.venv /code/.venv

# Copy your application source code
COPY ./app /code/app

# Create and switch to a non-root user for security
RUN useradd -m appuser && chown -R appuser:appuser /code
USER appuser

# Expose FastAPI's default port
EXPOSE 8000

# Run the application using the native fastapi CLI
CMD ["fastapi", "run", "app/main.py", "--port", "8000", "--host", "0.0.0.0"]