module Core_int64_extended = Core_int64_extended.Core_int64_extended
module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp
module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp
module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp
module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp
(*Upon further reflection--use specific int types, as specific as possible, such as 
  Int64 from Core or Int32 over plain ints. In future we might write a version that
  is sans Core in case anyone cares.*)
module Types_we_emit = struct
  type t =
    (*  Int
    | Int64
    | Int32*)
    | CoreInt64
    | CoreInt32
    (*| Int8 ===TODO===support this type *)
    | Uint8_w_sexp_t
    | Uint16_w_sexp_t
    | Uint32_w_sexp_t
    | Uint64_w_sexp_t
    | Float
    | Date
    | Time 
    | String
    | Bool
	[@@deriving show]
(*Return a string we can use in writing a module that is a type. Cannot return a Uint8.t for example
NOTE THAT Unfortunately there is no way to distinguish a field created with bool from a field created 
with tinyint--except by some naming convention, which we do--otherwise bool wouldn't be supported at all.
Also recall that BOOL cannot be combined with UNSIGNED in mysql.*)
  let to_string ~t ~is_nullable =
    if is_nullable then
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | CoreInt64 -> "Core_int64_extended.t option"
      | CoreInt32 -> "Core.Int32.t option"
      | Uint8_w_sexp_t -> "Uint8_w_sexp.t option"
      | Uint16_w_sexp_t -> "Uint16_w_sexp.t option"
      | Uint32_w_sexp_t -> "Uint32_w_sexp.t option"
      | Uint64_w_sexp_t -> "Uint64_w_sexp.t option"
      | Float -> "Core.Float.t option"
      | Date -> "Core.Date.t option"
      | Time -> "Core_time_extended.t option"
      | String -> "string option"
      | Bool -> "bool option"
    else 
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | CoreInt64 -> "Core_int64_extended.t"
      | CoreInt32 -> "Core.Int32.t"
      | Uint8_w_sexp_t -> "Uint8_w_sexp.t"
      | Uint16_w_sexp_t -> "Uint16_w_sexp.t"
      | Uint32_w_sexp_t -> "Uint32_w_sexp.t"
      | Uint64_w_sexp_t -> "Uint64_w_sexp.t"
      | Float -> "Core.Float.t"
      | Date -> "Core.Date.t"
      | Time -> "Core_time_extended.t"
      | String -> "string"
      | Bool -> "bool";;
		
  (**
   is_optional - is the field, of whatever type, optional in the type t of the module and nullable in the db?
   t - the type of the field
   *)
  let converter_of_string_of_type ~is_optional ~t ~fieldname =
    let open Core in 
    match is_optional, t with
      false, String ->
      String.concat ["Utilities.extract_field_as_string_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, String ->
       String.concat ["Utilities.extract_optional_field ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Bool ->
       String.concat ["Utilities.parse_bool_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Bool ->
       String.concat ["Utilities.parse_optional_bool_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    (*| false, Int -> "Utilities.parse_int_field_exn ~fieldname ~results ~arrayofstring"
    | true, Int -> "Utilities.parse_optional_int_field_exn ~fieldname ~results ~arrayofstring"*)
    | false, CoreInt64 ->
       String.concat ["Utilities.parse_int64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, CoreInt64 ->
       String.concat ["Utilities.parse_optional_int64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, CoreInt32 ->
       String.concat ["Utilities.parse_int64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, CoreInt32 ->
       String.concat ["Utilities.parse_optional_int64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    (*| false, Int64 -> 
    | true, Int32 ->
    | false, Int32 -> 
    | true, Int64 ->*) 
    | false, Uint8_w_sexp_t -> String.concat ["Utilities.parse_uint8_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint8_w_sexp_t -> String.concat ["Utilities.parse_optional_uint8_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint16_w_sexp_t -> String.concat ["Utilities.parse_uint16_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint16_w_sexp_t -> String.concat ["Utilities.parse_optional_uint16_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint32_w_sexp_t -> String.concat ["Utilities.parse_uint32_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint32_w_sexp_t -> String.concat ["Utilities.parse_optional_uint32_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint64_w_sexp_t -> String.concat ["Utilities.parse_uint64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint64_w_sexp_t -> String.concat ["Utilities.parse_optional_uint64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Float -> String.concat ["Utilities.parse_float_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Float -> String.concat ["Utilities.parse_optional_float_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Date -> String.concat ["Utilities.parse_date_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Date -> String.concat ["Utilities.parse_optional_date_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Time -> String.concat ["Utilities.parse_time_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Time -> String.concat ["Utilities.parse_optional_time_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]

  let to_string_for_sequoia ~t ~is_nullable =
    if is_nullable then
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | CoreInt64  
      | CoreInt32 -> "Null.int"
      | Uint8_w_sexp_t -> "Uint8_w_sexp.t option"
      | Uint16_w_sexp_t -> "Uint16_w_sexp.t option"
      | Uint32_w_sexp_t -> "Uint32_w_sexp.t option"
      | Uint64_w_sexp_t -> "Uint64_w_sexp.t option"
      | Float -> "Core.Float.t option"
      | Date -> "Core.Date.t option"
      | Time -> "Core_time_extended.t option"
      | String -> "string option"
      | Bool -> "bool option"
    else 
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | CoreInt64 
      | CoreInt32 -> "Field.int"
      | Uint8_w_sexp_t -> "Uint8_w_sexp.t"
      | Uint16_w_sexp_t -> "Uint16_w_sexp.t"
      | Uint32_w_sexp_t -> "Uint32_w_sexp.t"
      | Uint64_w_sexp_t -> "Uint64_w_sexp.t"
      | Float -> "Core.Float.t"
      | Date -> "Core.Date.t"
      | Time -> "Core_time_extended.t"
      | String -> "string"
      | Bool -> "bool";;
end 
