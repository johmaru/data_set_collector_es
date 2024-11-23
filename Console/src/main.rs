use std::process::Command;

fn main() {
    println!("実行環境をチェックします。");
    if !check_runtime() {
        println!("Erlangがインストールされていません。");
        println!("Erlangをインストールしてください。");
        println!("https://www.erlang.org/downloads");
        std::process::exit(1);
    }

    load_escript();
}

fn load_escript() {
    let output = Command::new("escript")
        .arg("data_set_collector_es")
        .output()
        .expect("Failed to execute command.");

    println!("{}", String::from_utf8_lossy(&output.stdout));
}

fn check_runtime() -> bool {
    let output = Command::new("erl")
        .arg("-eval")
        .arg("erlang:system_info(version), halt().")
        .output();

    match output {
        Ok(result) => {
            if result.status.success() {
                true
            } else {
                false
            }
        }
        Err(_) => false,
    }
}
