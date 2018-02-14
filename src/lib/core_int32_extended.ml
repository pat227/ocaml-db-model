(*There might be an opportunity to use a functor to avoid repeating all this for 
native int32.t when we get around to supporting that type.*)
module Int32 = Core.Int32
open Sexplib.Std
open Sexplib
module Core_int32_extended = struct
  include Core.Int32

  let sexp_of_t t =
    let a x = Sexp.Atom x and
	l x = Sexp.List x in
    l [ a "coreint32.t"; (Core.String.sexp_of_t (Core.Int32.to_string t))];;
      
  let t_of_sexp se =
    let s = Sexp.to_string se in
    let rec parse s i =
      match s.[i] with
      | '(' -> parse_list s (Core.Int.(+) i 1)
      | ')' -> failwith "Unexpected closing parens"
      | _ -> parse_list s (Core.Int.(+) i 1)
    and parse_list s i =
      let eoft = findend s (Core.Int.(+) i 1) in
      let stype = Core.String.sub s ~pos:i ~len:8 in
      match stype with
      | "coreint32.t" -> parse_int32t s (Core.Int.(+) i 9) eoft
      | _ -> failwith ("Unexpected type (expecting coreint32.t; found " ^ s ^ ")")
    and findend s i =
      match s.[i] with
      | ')' -> i
      | _ -> findend s (Core.Int.(+) i 1)
    and parse_int32t s i j =
      try
	let s = Core.String.sub s ~pos:i ~len:(Core.Int.(-) j i) in
	Core.Int32.of_string s
      with _ -> failwith ("Failed to parse:" ^ s ^"; pos:" ^
			    (Core.Int.to_string i) ^ "len:" ^
			      (Core.Int.to_string j))
    in
    parse s 0;;

  let sexp_of_int32 = sexp_of_t
    
  let int32_of_sexp = t_of_sexp
			 
  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)
  let show t = Core.Int32.to_string t

  let pp_int32 = pp
  let show_int32 = show

  let equal_int32 t1 t2 = if Core.Int32.compare t1 t2 == 0 then true else false
  let compare_int32 t1 t2 = Core.Int32.compare t1 t2
  let equal = equal_int32
  let compare = compare_int32

  let to_yojson t =
    let s = Core.Int32.to_string t in
    let s2 = Core.String.concat ["{coreint32:";s;"}"] in
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = Core.String.split s ':' in
      let value_half = Core.List.nth_exn splits 1 in
      let rbracket_i = Core.String.index_exn value_half '}' in 
      let value = Core.String.slice value_half 0 rbracket_i in 
      Result.Ok (Core.Int32.of_string value)
    with err -> Error "core_int32_extended::of_yojson() failed.";;
		  
end 
