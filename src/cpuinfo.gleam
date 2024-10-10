import file_streams/file_stream.{type FileStream}
import gleam/dict.{type Dict}
import gleam/list

pub fn parse_cpuinfo() -> List(Dict(String, String)) {
  case file_stream.open_read("/proc/cpuinfo") {
    Error(_) -> list.new()
    Ok(stream) -> do_cpuinfo_parse(stream, list.new())
  }
}

fn do_cpuinfo_parse(
  stream: FileStream,
  os_release: List(Dict(String, String)),
) -> List(Dict(String, String)) {
  todo
  // case file_stream.read_line(stream) {
  //   Ok(line) -> {
  //     case string.split_once(line, "=") {
  //       Error(_) -> do_os_release_parse(stream, os_release)
  //       Ok(#(key, value)) ->
  //         do_os_release_parse(
  //           stream,
  //           dict.insert(os_release, key, trim_quotes(string.trim(value))),
  //         )
  //     }
  //   }
  //   Error(file_stream_error.Eof) -> {
  //     os_release
  //   }
  //   Error(_) -> {
  //     dict.new()
  //   }
  // }
}
