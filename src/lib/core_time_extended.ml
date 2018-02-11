open Core
open Sexplib.Std
open Sexplib
(*Need to support yojson if client project wants it*)
module Core_time_extended = struct
  include Core.Time

  (*not strictly needed for anything but somewhere else long ago found a function like this useful*)
  let to_parts t =
    let s = Time.to_filename_string t ~zone:(Zone.of_utc_offset ~hours:0) in
    let halves = String.split ~on:'_' s in
    let former = String.split ~on:'-' (List.nth_exn halves 0) in
    let y = Int.of_string (List.nth_exn former 0) in
    let mon = Int.of_string (List.nth_exn former 1) in
    let d = Int.of_string (List.nth_exn former 2) in
    let latter = String.split ~on:'-' (List.nth_exn halves 1) in
    let h = Int.of_string (List.nth_exn latter 0) in
    let m = Int.of_string (List.nth_exn latter 1) in
    let s = Float.to_int (Float.of_string (List.nth_exn latter 2)) in
    [|y ; mon ; d ; h ; m ; s|];;

  (*NEED TO TEST*)
  let to_yojson t =
    let s = Core.Time.to_string t in
    let s2 = Core.String.concat ["{ts:";s;"}"] in
    Yojson.Safe.from_string s2;;

  let of_yojson j =
    try
      let s = Yojson.Safe.to_string j in
      let splits = Core.String.split s ':' in
      let value_half = List.nth_exn splits 1 in
      let rbracket_i = Core.String.index_exn value_half '}' in 
      let value = Core.String.slice value_half 0 rbracket_i in 
      Result.Ok (Core.Time.of_string value)
    with err -> Error "core_time_extended::of_yojson() failed.";;

  let sexp_of_t t =
    let a x = Sexp.Atom x and
	l x = Sexp.List x in
    l [ a "core_time_extended.t";
	(Core.String.sexp_of_t
	   (Time.to_filename_string t ~zone:(Time.Zone.of_utc_offset 0)))];;
    
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
      | "core_time_extended.t" -> parse_core_time_extended s (i+20) eoft
      | _ -> failwith ("Unexpected type (expecting core_time_extended.t; found " ^ s ^ ")")
    and findend s i =
      match s.[i] with
      | ')' -> i
      | _ -> findend s (i+1)
    and parse_core_time_extended s i j =
      try
	let s = Core.String.sub s ~pos:i ~len:(j-i) in
	Core.Time.of_filename_string s ~zone:(Core.Time.Zone.of_utc_offset 0)
      with _ -> failwith ("Failed to parse:" ^ s ^"; pos:" ^
			    (Core.Int.to_string i) ^ "len:" ^
			      (Core.Int.to_string j))
    in
    parse s 0;;

  let sexp_of_core_time_extended = sexp_of_t    
  let core_time_extended_of_sexp = t_of_sexp
  let pp fmt t = (Format.fprintf fmt "%s") (Time.to_filename_string t ~zone:(Time.Zone.of_utc_offset 0))
  let show t = Time.to_filename_string t ~zone:(Time.Zone.of_utc_offset 0)
  let pp_core_time_extended = pp
  let show_core_time_extended = show

  let equal_core_time_extended t1 t2 =
    not (Core.Time.is_earlier t1 ~than:t2) &&
      not (Core.Time.is_later t1 ~than:t2);;
    
  let compare_core_time_extended t1 t2 =
    if Core.Time.is_later t1 t2 then 1
    else
      if Core.Time.is_earlier t1 t2 then -1
      else 0;;
	  
  let equal = equal_core_time_extended
  let compare = compare_core_time_extended

    
end 
