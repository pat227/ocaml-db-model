(*Unfortunately Uint64 module does not define sexp converters, so we have to. 
  See below. Needed for ppx sexp extension.*)
module Uint64 = Uint64
open Sexplib.Std
open Sexplib
module Uint64_extended = struct
  include Uint64

  let sexp_of_t t =
    let a x = Sexp.Atom x and
	l x = Sexp.List x in
    l [ a "uint64.t"; (Core.String.sexp_of_t (Uint64.to_string t))];;
      
  let t_of_sexp se =
    let s = Sexp.to_string se in
    let rec parse s i =
      match s.[i] with
      | '(' -> parse_list s (i+1)
      | ')' -> failwith "Unexpected closing parens"
      | _ -> parse_list s (i+1)
    and parse_list s i =
      let eoft = findend s (i+1) in
      let stype = Core.String.sub s ~pos:i ~len:8 in
      match stype with
      | "uint64.t" -> parse_uint64t s (i+9) eoft
      | _ -> failwith ("Unexpected type (expecting uint64.t; found " ^ s ^ ")")
    and findend s i =
      match s.[i] with
      | ')' -> i
      | _ -> findend s (i+1)
    and parse_uint64t s i j =
      try
	let s = Core.String.sub s ~pos:i ~len:(j-i) in
	Uint64.of_string s
      with _ -> failwith ("Failed to parse:" ^ s ^"; pos:" ^
			    (Core.Int.to_string i) ^ "len:" ^
			      (Core.Int.to_string j))
    in
    parse s 0;;

  let sexp_of_uint64 = sexp_of_t
    
  let uint64_of_sexp = t_of_sexp
			 
  let pp fmt t = (Format.fprintf fmt "%s") (to_string t)
  let show t = Uint64.to_string t

  let pp_uint64 = pp
  let show_uint64 = show

  let equal_uint64 t1 t2 = if Uint64.compare t1 t2 == 0 then true else false
  let compare_uint64 t1 t2 = Uint64.compare t1 t2
  let equal = equal_uint64
  let compare = compare_uint64
end 
