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
import gleam_community/colour
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
  let memtotal = meminfo |> dict.get("MemTotal") |> result.unwrap(0)
  let memavailable = meminfo |> dict.get("MemAvailable") |> result.unwrap(0)

  let total_ram =
    memtotal
    |> bytesize.kib
    |> bytesize.to_string

  let used_ram =
    memtotal - memavailable
    |> bytesize.kib
    |> bytesize.to_string

  let assert Ok(blue) = colour.from_rgb255(91, 206, 250)
  let assert Ok(pink) = colour.from_rgb255(245, 169, 184)
  let assert Ok(white) = colour.from_rgb255(255, 255, 255)

  let _transgender_colors = [blue, pink, white, pink, blue]

  // io.println(arch_logo)

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
  io.println("Memory: " |> ansi.bright_cyan <> used_ram <> " / " <> total_ram)
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

const arch_logo = "                  -`
                 .o+`
                `ooo/
               `+oooo:
              `+oooooo:
              -+oooooo+:
            `/:-:++oooo+:
           `/++++/+++++++:
          `/++++++++++++++:
         `/+++ooooooooooooo/`
        ./ooosssso++osssssso+`
       .oossssso-````/ossssss+`
      -osssssso.      :ssssssso.
     :osssssss/        osssso+++.
    /ossssssss/        +ssssooo/-
  `/ossssso+/:-        -:/+osssso+-
 `+sso+:-`                 `.-/+oso:
`++:.                           `-/+/
.`                                 `"
