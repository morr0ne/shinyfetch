import envoy
import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/string

// import file_streams/file_stream_error
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/result

pub type Uname {
  Uname(
    sysname: String,
    nodename: String,
    release: String,
    version: String,
    machine: String,
    domainname: String,
  )
}

@external(erlang, "fetcher", "uname")
pub fn uname() -> Uname

@external(erlang, "fetcher", "uptime")
pub fn uptime() -> Int

pub fn main() {
  let os_release = parse_os_release()
  let uname = uname()
  let user = result.unwrap(envoy.get("USER"), "unknown")

  io.println(user <> "@" <> uname.nodename)
  io.println("----------------")
  io.println(
    "OS: " <> result.unwrap(dict.get(os_release, "PRETTY_NAME"), "Unknown"),
  )
  io.println("Kernel: " <> uname.release)
  io.println("Uptime: " <> format_time(uptime()))
}

// TODO: this could check for negative numbers using bool.guard
fn format_time(total: Int) -> String {
  let days = total / 86_400
  let hours = total % 86_400 / 3600
  let minutes = total % 86_400 % 3600 / 60
  let _secs = total % 86_400 % 3600 % 60

  let days = case days {
    0 -> ""
    _ -> int.to_string(days) <> " days, "
  }

  let hours = case hours {
    0 -> ""
    _ -> int.to_string(hours) <> " hours, "
  }

  let minutes = int.to_string(minutes) <> " mins"

  days <> hours <> minutes
}

fn parse_os_release() -> Dict(String, String) {
  case file_stream.open_read("/etc/os-release") {
    Error(_) -> dict.new()
    Ok(stream) -> do_os_release_parse(stream, dict.new())
  }
}

fn do_os_release_parse(
  stream: FileStream,
  os_release: Dict(String, String),
) -> Dict(String, String) {
  case file_stream.read_line(stream) {
    Ok(line) -> {
      case string.split_once(line, "=") {
        Error(_) -> do_os_release_parse(stream, os_release)
        Ok(#(key, value)) ->
          do_os_release_parse(
            stream,
            dict.insert(os_release, key, trim_quotes(string.trim(value))),
          )
      }
    }
    Error(file_stream_error.Eof) -> {
      os_release
    }
    Error(_) -> {
      dict.new()
    }
  }
}

fn trim_quotes(value: String) -> String {
  case value {
    "\"" <> trimmed ->
      case string.reverse(trimmed) {
        "\"" <> trimmed -> string.reverse(trimmed)
        _ -> value
      }
    _ -> value
  }
}
