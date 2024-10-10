use rustler::NifRecord;

#[derive(NifRecord)]
#[tag = "uname"]
struct UnicodeUname {
    sysname: String,
    nodename: String,
    release: String,
    version: String,
    machine: String,
    domainname: String,
}

impl UnicodeUname {
    pub fn new() -> Self {
        let uname = rustix::system::uname();

        Self {
            sysname: uname.sysname().to_string_lossy().to_string(),
            nodename: uname.nodename().to_string_lossy().to_string(),
            release: uname.release().to_string_lossy().to_string(),
            version: uname.version().to_string_lossy().to_string(),
            machine: uname.machine().to_string_lossy().to_string(),
            domainname: uname.domainname().to_string_lossy().to_string(),
        }
    }
}

#[rustler::nif]
pub fn uname() -> UnicodeUname {
    UnicodeUname::new()
}

rustler::init!("fetcher");
