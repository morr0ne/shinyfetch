import cpuinfo
import envoy
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam_community/ansi
import os_release
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
}
