use rand::{
    distributions::{self, Distribution},
    thread_rng,
};
use serde_json::json;
use std::env::args;

const URL: &str = concat!(
    "https://api.migadu.com/v1/domains/",
    env!("MIGADU_DOMAIN"),
    "/mailboxes/",
    env!("MIGADU_MAILBOX"),
    "/identities"
);

fn id() -> String {
    distributions::Alphanumeric
        .sample_iter(thread_rng())
        .take(8)
        .map(char::from)
        .map(|c| c.to_ascii_lowercase())
        .collect()
}

fn main() {
    for service in args().skip(1) {
        let localpart = format!("{}-{}", service.to_lowercase().replace(" ", ""), id());

        ureq::post(URL)
            .set("Authorization", concat!("Basic ", env!("MIGADU_AUTH")))
            .send_json(json!({"name": service, "local_part": localpart}))
            .unwrap();

        println!("{}@{}", localpart, env!("MIGADU_DOMAIN"));
    }
}
