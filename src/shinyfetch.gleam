import envoy
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

pub fn main() {
  let uname = uname()
  let user = result.unwrap(envoy.get("USER"), "unknown")
  io.println(user <> "@" <> uname.nodename)
  io.println("----------------")
  io.println("Kernel: " <> uname.release)
}
