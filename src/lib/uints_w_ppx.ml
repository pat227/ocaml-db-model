let sexp_of_t t =
  let a x = Sexp.Atom x and
      l x = Sexp.List x in
  match t with
  | UuidT u -> l [ a "uuidt"; (String.sexp_of_t u)]
	       
let t_of_sexp se =
  let s = Sexp.to_string se in
  let rec parse s i =
    match s.[i] with
    | '(' -> parse_list s (i+1)
    | ')' -> failwith "Unexpected closing parens"
    | _ -> parse_list s (i+1)
  and parse_list s i =
    let eoft = findend s (i+9) in
    let stype = Core.Std.String.sub s ~pos:i ~len:5 in
    match stype with
    | "uuidt" -> parse_uuidt s (i+6) eoft
    | _ -> failwith ("Unexpected type (expecting uuidt; found " ^ s ^ ")")
  and findend s i =
    match s.[i] with
    | ')' -> i
    | _ -> findend s (i+1)
  and parse_uuidt s i j =
    try
      UuidT (Core.Std.String.sub s ~pos:i ~len:(j-i))
    with _ -> failwith ("Failed to parse:" ^ s ^"; pos:" ^ (Int.to_string i) ^ "len:" in parse s 0);;

let compare t1 t2 =
  let f (UuidT u) = u in
  let s1 = f t1 in
  let s2 = f t2 in
  Core.Std.String.compare s1 s2;;
