module Int64_extended = struct

  let pp fmt t = (Format.fprintf fmt "%s") (Int64.to_string t)
  let show t = Int64.to_string t

  let pp_int64 = pp
  let show_int64 = show

  let equal_int64 t1 t2 = if Int64.compare t1 t2 == 0 then true else false
  let compare_int64 t1 t2 = Int64.compare t1 t2
  let equal = equal_int64
  let compare = compare_int64

  let to_yojson t =
    let s = Int64.to_string t in
    let s2 = String.concat "" ["{coreint64:";s;"}"] in
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in 
      Result.Ok (Int64.of_string value)
    with err -> Error "core_int64_extended::of_yojson() failed.";;
end 
