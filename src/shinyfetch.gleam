import envoy
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
  let uname = uname()
  let user = result.unwrap(envoy.get("USER"), "unknown")
  io.println(user <> "@" <> uname.nodename)
  io.println("----------------")
  io.println("Kernel: " <> uname.release)
  io.println("Uptime: " <> format_time(uptime()))
}

fn format_time(total: Int) -> String {
  let days = total / 86_400
  let hours = total % 86_400 / 3600
  let minutes = total % 86_400 % 3600 / 60
  let _secs = total % 86_400 % 3600 % 60

  let days = case days == 0 {
    True -> ""
    False -> int.to_string(days) <> " days, "
  }

  let hours = case hours == 0 {
    True -> ""
    False -> int.to_string(hours) <> " hours, "
  }

  let minutes = int.to_string(minutes) <> " mins"

  days <> hours <> minutes
}
