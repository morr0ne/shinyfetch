import envoy
import gleam/dict
import gleam/int
import gleam/io
import gleam/result
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
  let user = result.unwrap(envoy.get("USER"), "unknown")
  // TODO: Improve shell parsing
  let shell = result.unwrap(envoy.get("SHELL"), "unknown")
  let os_release = os_release.parse_os_release()
  // let cpus = parse_cpuinfo()

  io.println(user <> "@" <> uname.nodename)
  io.println("----------------")
  io.println(
    "OS: " <> result.unwrap(dict.get(os_release, "PRETTY_NAME"), "Unknown"),
  )
  io.println("Kernel: " <> uname.release)
  io.println("Uptime: " <> utils.format_time(uptime()))
  io.println("Shell: " <> shell)
}
