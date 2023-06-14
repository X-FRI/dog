module type T = sig
  val format : Recorder.t -> Target.t -> string
end

module Level = struct
  include Level

  let format_str_with_ascii (log_message : string) = function
      | Debug ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<blue> %s <blue>@}" log_message
      | Warn ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<yellow> %s <yellow>@}" log_message
      | Error ->
          Ocolor_format.kasprintf (fun s -> s) "@{<red> %s <red>@}" log_message
      | Info ->
          Ocolor_format.kasprintf
            (fun s -> s)
            "@{<green> %s <green>@}" log_message
end

module Builtin = struct
  module Formatter : T = struct
    let format (record : Recorder.t) (target : Target.t) : string =
        let time =
            match record.time with
            | Some time -> Time.to_string time
            | None -> "None"
        and thread =
            match record.thread with
            | Some thread -> Thread.to_string thread
            | None -> "None"
        and level = Level.to_string record.level in
            match target with
            | File _ ->
                Format.sprintf "| %s | %s | %s > %s" level time thread
                  record.log_message
            | Stdout | Stderr ->
                Ocolor_format.kasprintf
                  (fun s -> s)
                  "|@{<magenta> %s @}(@{<cyan> %s @}) %s" time thread
                  ((Level.format_str_with_ascii
                      (Format.sprintf "%s > %s" level record.log_message))
                     record.level)
  end
end
