import gleam/int
import gleam/string

pub fn trim_matches(value: String, matcher: String) -> String {
  case
    value |> string.starts_with(matcher) && value |> string.ends_with(matcher)
  {
    True ->
      value
      |> string.drop_left(matcher |> string.length)
      |> string.drop_right(matcher |> string.length)
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
