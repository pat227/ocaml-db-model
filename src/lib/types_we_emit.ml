module Types_we_emit = struct
  type t =
      Int 
    | Uint8_w_sexp_t
    | Uint16_w_sexp_t
    | Uint32_w_sexp_t
    | Uint64_w_sexp_t
    | Float
    | Date
    | Time 
    | String
    | Bool

(*Return a string we can use in writing a module that is a type. Cannot return a Uint8.t for example
NOTE THAT Unfortunately there is no way to distinguish a field created with bool from a field created 
with tinyint--except by some naming convention, which we do--otherwise bool wouldn't be supported at all.
Also recall that BOOL cannot be combined with UNSIGNED in mysql.*)
  let to_string t =
    match t with
      Int -> "int"
    | Uint8_w_sexp_t -> "Uint8_w_sexp.t"
    | Uint16_w_sexp_t -> "Uint16_w_sexp.t"
    | Uint32_w_sexp_t -> "Uint32_w_sexp.t"
    | Uint64_w_sexp_t -> "Uint64_w_sexp.t"
    | Float -> "Core.Std.Float.t"
    | Date -> "Core.Std.Date.t"
    | Time -> "Core.Std.Time.t"
    | String -> "Core.Std.String.t"
    | Bool -> "bool"

  let converter_of_string_for_type t =
    match t with
      String -> None
    | Bool -> Some "(fun x -> match x with\
			  \"1\" -> true\
			| \"0\" -> false\
			| \"true\"\
			| \"TRUE\" -> true\
			| \"false\" \
			| \"FALSE\" -> false\
			| _ -> raise (Failure \"Unrecognized value, couldn't parse boolean.\") )"
    | Int -> Some "Core.Std.Int.of_string"
    | Uint8_w_sexp_t -> Some "Uint8_w_sexp.of_string"
    | Uint16_w_sexp_t -> Some "Uint16_w_sexp.of_string"
    | Uint32_w_sexp_t -> Some "Uint32_w_sexp.of_string"
    | Uint64_w_sexp_t -> Some "Uint64_w_sexp.of_string"
    (*These are from Core.Std*)
    | Float -> Some "Core.Std.Float.of_string"
    | Date -> Some "Core.Std.Date.of_string"
    | Time -> -> Some "Core.Std.Time.of_string"
end 
