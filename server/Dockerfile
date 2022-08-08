FROM rust:latest as builder
WORKDIR /usr/src/beerme
COPY . .
RUN cargo install --path .

FROM debian:buster-slim
COPY --from=builder /usr/local/cargo/bin/beer-server /usr/local/bin/beerme-server
CMD ["beerme-server"]
