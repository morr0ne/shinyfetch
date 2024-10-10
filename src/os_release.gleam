import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import simplifile
import utils

// FIXME: handle comments starting with #
pub fn parse_os_release() -> Dict(String, String) {
  case simplifile.read("/etc/os-release") {
    Error(_) -> dict.new()
    Ok(file) -> {
      file
      |> string.split("\n")
      |> list.fold(dict.new(), fn(os_release, line) {
        case string.split_once(line, "=") {
          Error(_) -> os_release
          Ok(#(key, value)) ->
            dict.insert(
              os_release,
              key,
              value |> string.trim |> utils.trim_quotes,
            )
        }
      })
    }
  }
}
