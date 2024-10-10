import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import simplifile

pub fn parse_cpuinfo() -> List(Dict(String, String)) {
  case simplifile.read("/proc/cpuinfo") {
    Error(_) -> []
    Ok(file) -> {
      file
      |> string.split("\n\n ")
      |> list.fold([], fn(cpuinfo, line) {
        let cpu =
          line
          |> string.split("\n")
          |> list.fold(dict.new(), fn(cpu, line) {
            case string.split_once(line, ":") {
              Error(_) -> cpu
              Ok(#(key, value)) ->
                dict.insert(cpu, key |> string.trim, value |> string.trim)
            }
          })

        [cpu, ..cpuinfo]
      })
    }
  }
}
