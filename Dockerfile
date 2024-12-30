FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine

# add project code
COPY . /build/

# compile the project
RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build

# run the server
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

# then in clie, run
# docker build -t todo_app . 
# then
# docker run --env-file .env -d -p 3000:3000 todo_app