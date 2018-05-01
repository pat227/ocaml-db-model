open Stdint
module Uint16_extended = struct
  include Uint16
			 
  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)
  let show t = Uint16.to_string t

  let pp_uint16 = pp
  let show_uint16 = show

  let equal_uint16 t1 t2 = if Uint16.compare t1 t2 == 0 then true else false
  let compare_uint16 t1 t2 = Uint16.compare t1 t2
  let equal = equal_uint16
  let compare = compare_uint16

  let to_yojson t =
    let s = Uint16.to_string t in
    let s2 = String.concat "" ["{uint16:";s;"}"] in
    Yojson.Safe.from_string s2;;
    
  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = String.split_on_char ':' s in
      let value_half = List.nth splits 1 in
      let rbracket_i = String.index value_half '}' in 
      let value = String.sub value_half 0 rbracket_i in 
      Result.Ok (Uint16.of_string value)
    with err -> Error "uint16_extended::of_yojson() failed.";;

end 
