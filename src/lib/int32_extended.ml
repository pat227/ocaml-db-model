module Int32_extended = struct
  type t = int32
  let pp fmt t = (Format.fprintf fmt "%s") (Int32.to_string t)
  let show t = Int32.to_string t

  let pp_int32 = pp
  let show_int32 = show

  let equal_int32 t1 t2 = if Int32.compare t1 t2 == 0 then true else false
  let compare_int32 t1 t2 = Int32.compare t1 t2
  let equal = equal_int32
  let compare = compare_int32

  let to_yojson t =
    let s = Int32.to_string t in
    let s2 = String.concat "" ["{int32:";s;"}"] in
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in 
      Result.Ok (Int32.of_string value)
    with err -> Error "int32_extended::of_yojson() failed.";;
end 
