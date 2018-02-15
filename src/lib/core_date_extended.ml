open Core
open Sexplib.Std
open Sexplib
(*Need to support yojson if client project wants it*)
module Core_date_extended = struct
  include Core.Date

  let sexp_of_t t =
    let a x = Sexp.Atom x and
	l x = Sexp.List x in
    l [ a "core_date_extended.t";
	(Core.String.sexp_of_t
	   (Date.to_string t))];;
    
  let t_of_sexp se =
    let s = Sexp.to_string se in
    let rec parse s i =
      match s.[i] with
      | '(' -> parse_list s (i+1)
      | ')' -> failwith "Unexpected closing parens"
      | _ -> parse_list s (i+1)
    and parse_list s i =
      let eoft = findend s (i+1) in
      let stype = Core.String.sub s ~pos:i ~len:20 in
      match stype with
      | "core_date_extended.t" -> parse_type s (i+20) eoft
      | _ -> failwith ("Unexpected type (expecting core_date_extended.t; found " ^ s ^ ")")
    and findend s i =
      match s.[i] with
      | ')' -> i
      | _ -> findend s (i+1)
    and parse_type s i j =
      try
	let s = Core.String.sub s ~pos:i ~len:(j-i) in
	Core.Date.of_string s
      with _ -> failwith ("Failed to parse:" ^ s ^"; pos:" ^
			    (Core.Int.to_string i) ^ "len:" ^
			      (Core.Int.to_string j))
    in
    parse s 0;;

  let sexp_of_core_date_extended = sexp_of_t    
  let core_date_extended_of_sexp = t_of_sexp
  let pp fmt t = (Format.fprintf fmt "%s") (Core.Date.to_string t)
  let show t = Core.Date.to_string t
  let pp_core_time_extended = pp
  let show_core_time_extended = show

  let equal_core_time_extended t1 t2 =
    not (Core.Date.(=) t1 t2) &&
      not (Core.Date.(=) t1 t2);;
    
  let compare_core_time_extended t1 t2 =
    if Core.Date.(>) t1 t2 then 1
    else
      if Core.Date.(<) t1 t2 then -1
      else 0;;
	  
  let equal = equal_core_time_extended
  let compare = compare_core_time_extended
	    
  (*NEED TO TEST*)
  let to_yojson t =
    let s = Core.Date.to_string t in
    let s2 = Core.String.concat ["{date:";s;"}"] in
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = Core.String.split s ':' in
      let value_half = List.nth_exn splits 1 in
      let rbracket_i = Core.String.index_exn value_half '}' in 
      let value = Core.String.slice value_half 0 rbracket_i in 
      Result.Ok (Core.Date.of_string value)
    with err -> Error "core_date_extended::of_yojson() failed.";;
    
end 
