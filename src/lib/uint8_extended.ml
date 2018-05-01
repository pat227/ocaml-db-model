open Stdint
module Uint8_extended = struct
  include Uint8

  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)
  let show t = Uint8.to_string t

  let pp_uint8 = pp
  let show_uint8 = show

  let equal_uint8 t1 t2 = if Uint8.compare t1 t2 == 0 then true else false
  let compare_uint8 t1 t2 = Uint8.compare t1 t2
  let equal = equal_uint8
  let compare = compare_uint8

  let to_yojson t =
    let s = Uint8.to_string t in
    let s2 = String.concat "" ["{uint8:";s;"}"] in
    Yojson.Safe.from_string s2;;
    
  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in 
      Result.Ok (Uint8.of_string value)
    with err -> Error "uint8_extended::of_yojson() failed.";;

end 
