import bytesize
import cpuinfo
import envoy
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam_community/ansi
import os_release
import simplifile
import utils

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
  let uname = uname()
  let user = envoy.get("USER") |> result.unwrap("unknown")
  // TODO: Improve shell parsing
  let shell =
    envoy.get("SHELL")
    |> result.unwrap("unknown")
    |> string.split("/")
    |> list.last
    |> result.unwrap("unknown")

  let os_release = os_release.parse_os_release()

  let cpu =
    cpuinfo.parse_cpuinfo()
    |> list.first
    |> result.unwrap(dict.new())
    |> dict.get("model name")
    |> result.unwrap("unknown")

  let meminfo = parse_meminfo()

  let memavailable =
    { meminfo |> dict.get("MemAvailable") |> result.unwrap(0) }
    |> bytesize.kib
    |> bytesize.to_string

  let memtotal =
    { meminfo |> dict.get("MemTotal") |> result.unwrap(0) }
    |> bytesize.kib
    |> bytesize.to_string

  io.println({ user <> "@" <> uname.nodename } |> ansi.bright_cyan)
  io.println("----------------")
  io.println(
    "OS: " |> ansi.bright_cyan
    <> os_release |> dict.get("PRETTY_NAME") |> result.unwrap("Unknown"),
  )
  io.println("Kernel: " |> ansi.bright_cyan <> uname.release)
  io.println("Uptime: " |> ansi.bright_cyan <> uptime() |> utils.format_time)
  io.println("Shell: " |> ansi.bright_cyan <> shell)
  io.println("CPU: " |> ansi.bright_cyan <> cpu)
  io.println(
    "Memory: " |> ansi.bright_cyan <> memavailable <> " / " <> memtotal,
  )
}

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
