FROM python:3.12 AS build
COPY . /apps
WORKDIR /apps
RUN --mount=type=cache,mode=0755,target=/root/.cache/pip pip install Cython
RUN --mount=type=cache,mode=0755,target=/root/.cache/pip pip install -r requirements.txt


FROM python:3.12-slim AS runtime
LABEL project="python" \
      author="vijay"
      
ARG USERNAME=prawn
RUN groupadd -r ${USERNAME} && useradd -r -g ${USERNAME} ${USERNAME}
RUN mkdir -p /app && chown -R ${USERNAME}:${USERNAME} /app/  
COPY --from=build /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY . /app       
WORKDIR /app
USER ${USERNAME}
EXPOSE 8000
CMD [ "uvicorn","saleor.asgi:application", "--host=0.0.0.0" ]
