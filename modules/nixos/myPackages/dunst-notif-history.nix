{
  lib,
  fetchFromGitHub,
  rustPlatform,
  writeText,
 #conf ? null,
  conf ? ''
use serde_json::{self, Value};
use std::env;
use std::process;
use std::io::Write;

fn get_json_input() -> String {
    let json_input = process::Command::new("dunstctl")
        .arg("history")
        .output()
        .expect("Failed to get Notifications history from dunst!");
    return String::from_utf8_lossy(&json_input.stdout).to_string();
}

fn get_value(json_input: String) -> (Vec<String>, Vec<i64>) {
    let mut output_vec_id: Vec<i64> = std::vec::Vec::new();
    let mut output_vec: Vec<String> = std::vec::Vec::new();
    let read_json: Value = serde_json::from_str(&json_input).unwrap();
    for data in read_json["data"].as_array().unwrap() {
        for item in data.as_array().unwrap() {
            let appname = item["appname"]["data"].as_str().unwrap().to_string();
            let summary = item["summary"]["data"].as_str().unwrap().to_string();
            let app_id = item["id"]["data"].as_i64().unwrap();
            let output: String = format!("{} - {}", appname, summary);
            output_vec.push(output);
            output_vec_id.push(app_id);
        }
    }
    return (output_vec, output_vec_id);
}

fn spawn_rofi(output_vec: &Vec<String>, prompt: &str, rofi_args: &[String]) -> Result<usize, String> {
    let mut cmd = process::Command::new("rofi");
    cmd.arg("-dmenu").arg("-p").arg(prompt);

    // Pass all command line arguments to rofi
    for arg in rofi_args {
        cmd.arg(arg);
    }

    let mut child = cmd.stdin(process::Stdio::piped())
        .stdout(process::Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to spawn rofi: {}", e))?;

    {
        let mut stdin = child.stdin.take().expect("Failed to open stdin");
        for item in output_vec {
            writeln!(stdin, "{}", item).map_err(|e| format!("Failed to write to stdin: {}", e))?;
        }
    }

    let output = child.wait_with_output().map_err(|e| format!("Failed to read stdout: {}", e))?;
    let stdout = String::from_utf8_lossy(&output.stdout);

    for (i, item) in output_vec.iter().enumerate() {
        if stdout.trim() == *item {
            return Ok(i);
        }
    }

    Err("No selection".to_string())
}

fn parse_args() -> Vec<String> {
    env::args().skip(1).collect()
}

fn main() {
    let rofi_args = parse_args();

    let mut output = get_value(get_json_input());
    match output.0.is_empty() {
        true => {
            output.0.push("Empty".to_string());
        }
        _ => {
            output.0.push("> Clear all History".to_string());
            output.1.push(-1);
            if output.0.len() != 2 {
                output.0.push("> Remove specific History".to_string());
                output.1.push(-2);
            }
        }
    }

    match spawn_rofi(&output.0, " 󰂚 History ", &rofi_args) {
        Ok(v) => {
            let vec_id = &output.1;
            if vec_id.is_empty() {
                process::exit(0);
            }
            match vec_id[v] {
                -1 => {
                    process::Command::new("dunstctl")
                        .arg("history-clear")
                        .spawn()
                        .expect("Failed to clear Dunst history");
                }
                -2 => {
                    let rm_output = get_value(get_json_input());
                    match spawn_rofi(&rm_output.0, " 󰂚 Remove History ", &rofi_args) {
                        Ok(v) => {
                            process::Command::new("dunstctl")
                                .arg("history-rm")
                                .arg(format!("{}", rm_output.1[v]))
                                .spawn()
                                .expect("Failed to remove the Notifications!");
                        }
                        Err(e) => {
                            println!("Error : {}", e);
                            process::exit(1);
                        }
                    }
                }
                _ => {
                    process::Command::new("dunstctl")
                        .arg("history-pop")
                        .arg(format!("{}", vec_id[v]))
                        .spawn()
                        .expect("Failed to pop the Notifications!");
                }
            };
        }
        Err(e) => {
            println!("Error : {}", e);
            process::exit(1);
        }
    }
}
  '',
}:

rustPlatform.buildRustPackage rec {
  pname = "dunst-notif-history";
  version = "2023-09-28";

  src = fetchFromGitHub {
    owner = "commrade-goad";
    repo = "dunst-notif-history";
    rev = "2b32bc4a0abc487568650a8265d27b1437f6c0f2";
    sha256 = "03vppbrnx5h1wc3ynwyb3284j184fwsaymbvqla21vbrryq5pa5b";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "main.rs" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/main.rs";

  cargoHash = "sha256-UempHOqm6FT/BRdFwcpZUMqXvpw3nAHdZVhwtWZWqsA=";

  meta = {
    description = " ";
    homepage = "https://github.com/commrade-goad/dunst-notif-history";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "dunst-notif-history";
  };
}
