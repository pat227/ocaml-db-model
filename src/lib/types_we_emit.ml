module Uint64_extended = Uint64_extended.Uint64_extended
module Uint32_extended = Uint32_extended.Uint32_extended
(* In order to provide the uint24 bit type, need to stop using uint and use stdint library instead. 
   Save it for later.			   
module Uint24_extended = Uint24_extended.Uint24_extended*)
module Uint16_extended = Uint16_extended.Uint16_extended
module Uint8_extended = Uint8_extended.Uint8_extended
(*Upon further reflection--use specific int types, as specific as possible, such as 
  Int64 from Core or Int32 over plain ints. In future we might write a version that
  is sans Core in case anyone cares.*)
module Types_we_emit = struct
  type t =
    (*  Int
    | Int64
    | Int32*)
    (*Note that bignum type can handle signed and unsigned numbers; no need to 
      distinguish between the two with a type for each*)
    | Bignum
    | CoreInt64
    | CoreInt32
    (*| Int8 ===TODO===support this type when switch to stdint *)
    | Uint8_extended_t
    | Uint16_extended_t
    (*| Uint24_extended_t    ===todo=== when switch to stdint *)
    | Uint32_extended_t
    | Uint64_extended_t
    | Float
    | Date
    | Time 
    | String
    | Bool
	[@@deriving show]
(*Return a string we can use in writing a module that is a type. Cannot return a 
  Uint8.t for example NOTE THAT Unfortunately there is no way to distinguish a 
  field created with bool from a field created with tinyint--except by some 
  naming convention, which we do--otherwise bool wouldn't be supported at all. 
  Also recall that BOOL cannot be combined with UNSIGNED in mysql.*)
  let to_string ~t ~is_nullable =
    if is_nullable then
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | Bignum -> "Bignum.t option"
      | CoreInt64 -> "Core.Int64.t option"
      | CoreInt32 -> "Core.Int32.t option"
      | Uint8_extended_t -> "Uint8_extended.t option"
      | Uint16_extended_t -> "Uint16_extended.t option"
      | Uint32_extended_t -> "Uint32_extended.t option"
      | Uint64_extended_t -> "Uint64_extended.t option"
      | Float -> "Core.Float.t option"
      | Date -> "Date_extended.t option"
      | Time -> "Core.Time.t option"
      | String -> "string option"
      | Bool -> "bool option"
    else 
      match t with
      (*  Int -> "int"
      | Int64 -> "int64"
      | Int32 -> "int32"*)
      | Bignum -> "Bignum.t"
      | CoreInt64 -> "Core.Int64.t"
      | CoreInt32 -> "Core.Int32.t"
      | Uint8_extended_t -> "Uint8_extended.t"
      | Uint16_extended_t -> "Uint16_extended.t"
      | Uint32_extended_t -> "Uint32_extended.t"
      | Uint64_extended_t -> "Uint64_extended.t"
      | Float -> "Core.Float.t"
      | Date -> "Date_extended.t"
      | Time -> "Core.Time.t"
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
    | false, Uint8_extended_t -> String.concat ["Utilities.parse_uint8_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint8_extended_t -> String.concat ["Utilities.parse_optional_uint8_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint16_extended_t -> String.concat ["Utilities.parse_uint16_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint16_extended_t -> String.concat ["Utilities.parse_optional_uint16_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint32_extended_t -> String.concat ["Utilities.parse_uint32_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint32_extended_t -> String.concat ["Utilities.parse_optional_uint32_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Uint64_extended_t -> String.concat ["Utilities.parse_uint64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Uint64_extended_t -> String.concat ["Utilities.parse_optional_uint64_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Bignum -> String.concat ["Utilities.parse_optional_bignum_field ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Bignum -> String.concat ["Utilities.parse_bignum_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Float -> String.concat ["Utilities.parse_float_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Float -> String.concat ["Utilities.parse_optional_float_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Date -> String.concat ["Utilities.parse_date_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Date -> String.concat ["Utilities.parse_optional_date_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | false, Time -> String.concat ["Utilities.parse_time_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
    | true, Time -> String.concat ["Utilities.parse_optional_time_field_exn ~fieldname:\"";fieldname;"\" ~results ~arrayofstring"]
end 
