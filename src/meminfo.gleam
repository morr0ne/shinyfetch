import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import simplifile
import utils

pub fn parse_meminfo() -> Dict(String, Int) {
  case simplifile.read("/proc/meminfo") {
    Error(_) -> dict.new()
    Ok(file) -> {
      file
      |> string.split("\n")
      |> list.fold(dict.new(), fn(meminfo, line) {
        case string.split_once(line, ":") {
          Error(_) -> meminfo
          Ok(#(key, value)) ->
            case
              value
              |> utils.trim_end_matches("kB")
              |> string.trim
              |> int.parse
            {
              Error(_) -> meminfo
              Ok(value) -> dict.insert(meminfo, key |> string.trim, value)
            }
        }
      })
    }
  }
}
