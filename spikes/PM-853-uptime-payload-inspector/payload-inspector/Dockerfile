# syntax = docker/dockerfile:1.4

FROM ubuntu:22.04 AS base

FROM base AS builder

RUN set -eux; \
		apt update; \
		apt install -y --no-install-recommends curl ca-certificates gcc pkg-config libssl-dev libc6-dev;

# Install rustup
RUN --mount=type=cache,target=/root/.rustup \
    set -eux; \
		curl --location --fail \
			"https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
			--output rustup-init; \
		chmod +x rustup-init; \
		./rustup-init -y --no-modify-path --default-toolchain stable; \
		rm rustup-init;

# Add rustup to path, check that it works
ENV PATH=${PATH}:/root/.cargo/bin
RUN set -eux; \
		rustup --version;

WORKDIR /app
COPY ./src src
COPY Cargo.toml Cargo.lock ./

ARG AXUM_HTTP_REQUESTS_TOTAL="payload_inspector_requests_total"
ARG AXUM_HTTP_REQUESTS_DURATION_SECONDS="payload_inspector_requests_duration_seconds"
ARG AXUM_HTTP_REQUESTS_PENDING="payload_inspector_requests_pending"

RUN --mount=type=cache,target=/root/.rustup \
    --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
		--mount=type=cache,target=/app/target \
		set -eux; \
		cargo build --release; \
		cp target/release/payload-inspector .

FROM base AS app

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
		apt update; \
		apt install -y --no-install-recommends \
			ca-certificates \
			; \
		apt clean autoclean; \
		apt autoremove --yes; \
		rm -rf /var/lib/{apt,cache,log}/

WORKDIR /app
COPY --from=builder /app/payload-inspector .

CMD ["/app/payload-inspector"]
