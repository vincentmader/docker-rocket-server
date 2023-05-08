FROM rust:1.67-alpine

# Setup the working directory (inside docker container).
# ─────────────────────────────────────────────────────────────────────────────

WORKDIR /var/www/docker-rocket

# Install required dependencies using Alpine's builtin package manager.
# ─────────────────────────────────────────────────────────────────────────────

RUN apk add musl-dev

# Pre-compile Rust dependencies.
# ─────────────────────────────────────────────────────────────────────────────

# Initialize empty Rust crates inside container.
RUN mkdir -p ./server/src && echo "fn main() {}" > ./server/src/main.rs;\
    mkdir -p ./client/src && touch ./client/src/lib.rs;\
    mkdir -p ./shared/src && touch ./shared/src/lib.rs

# Copy Cargo configuration files into container.
COPY ./server/Cargo.toml ./server/Cargo.toml
COPY ./client/Cargo.toml ./client/Cargo.toml
COPY ./shared/Cargo.toml ./shared/Cargo.toml
COPY ./Cargo.* ./

# Compile the dependencies (this will take a while).
RUN cargo build --release;

# Delete the binaries created from temporary crates.
RUN rm ./target/release/deps/server*

# Prepare for compilation of Rust project.
# ─────────────────────────────────────────────────────────────────────────────

# Only now copy the actual project's code into the the Docker container.
COPY ./server ./server
COPY ./client ./client
COPY ./shared ./shared

# Setup Rocket server configuration.
# ─────────────────────────────────────────────────────────────────────────────

# Expose the port that's used internally for running rocket.rs server.
EXPOSE 8000

# Define main entrypoint for Docker container.
# ─────────────────────────────────────────────────────────────────────────────

COPY ./entrypoint.sh ./entrypoint.sh
ENTRYPOINT ./entrypoint.sh
