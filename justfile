PREFIX := "usr"
BINARY := PREFIX / "bin"
LIBRARY := PREFIX / "lib"
DESTDIR := "/"

_:
	@just --list --unsorted

[group('build')]
build-native:
    mkdir -p priv
    cargo build --release
    cp target/release/libfetcher.so priv/

[group('build')]
build-release: build-native
    gleam export erlang-shipment

[group('build')]
build-escript: build-native
    gleam run -m gleescript

[group('development')]
run: build-native
    gleam run

[group('packaging')]
install:
