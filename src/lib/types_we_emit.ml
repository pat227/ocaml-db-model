module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp
module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp
module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp
module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp

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
		
  (**
   is_optional - is the field, of whatever type, optional in the type t of the module
   *)
  let converter_of_string_for_type ~is_optional ~t =
    match is_optional t with
      false, String -> None
    | true, String -> None
    | false, Bool -> Some "Utilities.parse_boolean_field"
    | true, Bool -> Some "Utilities.parse_optional_boolean_field"
    | false, Int -> Some "Core.Std.Int.of_string"
    | true, Int -> Some "Utilities.parse_optional_int"
    | false, Uint8_w_sexp_t -> Some "Uint8_w_sexp.of_string"
    | true, Uint8_w_sexp_t -> Some "Utilities.parse_optional_uint8"
    | false, Uint16_w_sexp_t -> Some "Uint16_w_sexp.of_string"
    | true, Uint16_w_sexp_t -> Some "Utilities.parse_optional_uint16"
    | false, Uint32_w_sexp_t -> Some "Uint32_w_sexp.of_string"
    | true, Uint32_w_sexp_t -> Some "Utilities.parse_optional_uint32"
    | false, Uint64_w_sexp_t -> Some "Uint64_w_sexp.of_string"
    | true, Uint64_w_sexp_t -> Some "Utilities.parse_optional_uint64"
    (*These are from Core.Std*)
    | false, Float -> Some "Core.Std.Float.of_string"
    | true, Float -> Some "Utilities.parse_optional_float"
    | false, Date -> Some "Core.Std.Date.of_string"
    | true, Date -> Some "Utilities.parse_optional_date"
    | false, Time -> -> Some "Core.Std.Time.of_string"
    | true, Time -> -> Some "Utilities.parse_optional_time"
end 
