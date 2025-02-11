# Build stage
FROM python:3.12 AS build

# Set working directory
COPY . /apps
WORKDIR /apps

# Install system dependencies (JDK, GCC, Python headers, etc.)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    gcc \
    python3-dev \
    libffi-dev

# Set JDK_HOME explicitly
ENV JDK_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_HOME=$JDK_HOME
ENV PATH=$JAVA_HOME/bin:$PATH

# Upgrade pip and install Cython first
RUN --mount=type=cache,mode=0755,target=/root/.cache/pip pip install --upgrade pip setuptools wheel
RUN --mount=type=cache,mode=0755,target=/root/.cache/pip pip install Cython

# Install Python dependencies
RUN --mount=type=cache,mode=0755,target=/root/.cache/pip pip install -r requirements.txt

# Runtime stage
FROM python:3.12-slim AS runtime
LABEL project="python" \
      author="vijay"

# Install runtime dependencies (JDK required for Pyjnius at runtime)
RUN apt-get update && apt-get install -y openjdk-17-jre

# Set JDK_HOME explicitly
ENV JDK_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_HOME=$JDK_HOME
ENV PATH=$JAVA_HOME/bin:$PATH

# Create a non-root user
ARG USERNAME=prawn
RUN groupadd -r ${USERNAME} && useradd -r -g ${USERNAME} ${USERNAME}

# Set up application directory
RUN mkdir -p /app && chown -R ${USERNAME}:${USERNAME} /app

# Copy built dependencies from the build stage
COPY --from=build /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=build /usr/local/bin/ /usr/local/bin/

# Copy application source code
COPY . /app
WORKDIR /app

# Switch to the non-root user
USER ${USERNAME}

# Expose application port
EXPOSE 8000

# Run the application
CMD [ "uvicorn", "saleor.asgi:application", "--host=0.0.0.0", "--port=8000" ]
