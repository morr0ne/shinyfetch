build:
    mkdir -p priv
    cargo build --release
    cp target/release/libfetcher.so priv/
    gleam build

run:
    mkdir -p priv
    cargo build
    cp target/debug/libfetcher.so priv/
    gleam run
