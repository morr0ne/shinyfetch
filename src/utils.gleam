import gleam/int
import gleam/string

pub fn trim_quotes(value: String) -> String {
  case value |> string.starts_with("\"") && value |> string.ends_with("\"") {
    True -> value |> string.drop_left(1) |> string.drop_right(1)
    False -> value
  }
}

// TODO: this could check for negative numbers using bool.guard
pub fn format_time(total: Int) -> String {
  let days = total / 86_400
  let hours = total % 86_400 / 3600
  let minutes = total % 86_400 % 3600 / 60
  let _secs = total % 86_400 % 3600 % 60

  let days = case days {
    0 -> ""
    _ -> int.to_string(days) <> " days, "
  }

  let hours = case hours {
    0 -> ""
    _ -> int.to_string(hours) <> " hours, "
  }

  let minutes = int.to_string(minutes) <> " mins"

  days <> hours <> minutes
}
