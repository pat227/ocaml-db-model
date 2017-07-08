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
   is_optional - is the field, of whatever type, optional in the type t of the module and nullable in the db?
   t - the type of the field
   *)
  let converter_of_string_for_type ~is_optional ~t =
    match is_optional, t with
      false, String -> "Utilities.extract_field_as_string_exn ~fieldname ~results ~arrayofstring"
    | true, String -> "Utilities.extract_optional_field ~fieldname ~results ~arrayofstring"
    | false, Bool -> "Utilities.parse_bool_field_exn ~fieldname ~results ~arrayofstring"
    | true, Bool -> "Utilities.parse_optional_bool_field_exn ~fieldname ~results ~arrayofstring"
    | false, Int -> "Utilities.parse_int_field_exn ~fieldname ~results ~arrayofstring"
    | true, Int -> "Utilities.parse_optional_int_field_exn ~fieldname ~results ~arrayofstring"
    | false, Uint8_w_sexp_t -> "Utilities.parse_uint8_field_exn ~fieldname ~results ~arrayofstring"
    | true, Uint8_w_sexp_t -> "Utilities.parse_optional_uint8_field_exn ~fieldname ~results ~arrayofstring"
    | false, Uint16_w_sexp_t -> "Utilities.parse_uint16_field_exn ~fieldname ~results ~arrayofstring"
    | true, Uint16_w_sexp_t -> "Utilities.parse_optional_uint16_field_exn ~fieldname ~results ~arrayofstring"
    | false, Uint32_w_sexp_t -> "Utilities.parse_uint32_field_exn ~fieldname ~results ~arrayofstring"
    | true, Uint32_w_sexp_t -> "Utilities.parse_optional_uint32_field_exn ~fieldname ~results ~arrayofstring"
    | false, Uint64_w_sexp_t -> "Utilities.parse_uint64_field_exn ~fieldname ~results ~arrayofstring"
    | true, Uint64_w_sexp_t -> "Utilities.parse_optional_uint64_field_exn ~fieldname ~results ~arrayofstring"
    | false, Float -> "Utilities.parse_float_field_exn ~fieldname ~results ~arrayofstring"
    | true, Float -> "Utilities.parse_optional_float_field_exn ~fieldname ~results ~arrayofstring"
    | false, Date -> "Utilities.parse_date_field_exn ~fieldname ~results ~arrayofstring"
    | true, Date -> "Utilities.parse_optional_date_field_exn ~fieldname ~results ~arrayofstring"
    | false, Time -> "Utilities.parse_time_field_exn ~fieldname ~results ~arrayofstring"
    | true, Time -> "Utilities.parse_optional_time_field_exn ~fieldname ~results ~arrayofstring"
end 
