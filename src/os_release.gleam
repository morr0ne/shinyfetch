import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/dict.{type Dict}
import gleam/string
import utils

pub fn parse_os_release() -> Dict(String, String) {
  case file_stream.open_read("/etc/os-release") {
    Error(_) -> dict.new()
    Ok(stream) -> do_os_release_parse(stream, dict.new())
  }
}

// FIXME: handle comments starting with #
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
            dict.insert(
              os_release,
              key,
              value |> string.trim |> utils.trim_quotes,
            ),
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
