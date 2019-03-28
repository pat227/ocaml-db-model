module Date_time_extended = Date_time_extended.Date_time_extended
module Date_extended = Date_extended.Date_extended
module Uint8_extended = Uint8_extended.Uint8_extended
module Uint16_extended = Uint16_extended.Uint16_extended
(*module Uint24_extended = Uint24_extended.Uint24_extended*)
module Uint32_extended = Uint32_extended.Uint32_extended
module Uint64_extended = Uint64_extended.Uint64_extended
module Bignum_extended = Bignum_extended.Bignum_extended
module Utilities : sig
  val closecon : Mysql.dbd ->  unit
  val getcon : ?host:string -> database:string -> password:string -> user:string -> Mysql.dbd
  val print_n_flush : string -> unit

  val parse_list : string option -> string list option
  val is_suffix : string -> string -> bool
  val is_whitespace_char : char -> bool
  val is_digit : char -> bool
				     
  val serialize_optional_field : field:string option -> conn:Mysql.dbd -> string
  val serialize_optional_field_with_default :
    field:string option -> conn:Mysql.dbd -> default:string -> string
  val serialize_boolean_field : field:bool -> string
  val serialize_optional_bool_field : field:bool option -> string
  val serialize_optional_float_field_as_int : field:float option -> string
  val serialize_float_field_as_int : field:float -> string

  (*val parse_boolean_field_exn : field:string -> bool
  val parse_optional_boolean_field_exn : field:string option -> bool option
   *)							    
  (*
  val parse_int64_field_exn : string -> Core.Int64.t  
  val parse_int_field_exn : string option -> int
  val parse_int_field_option : string option -> int option
  val parse_string_field : string -> string
  val parse_boolean_field : string -> bool
  val parse_int_field : string -> int*)


  val extract_field_as_string_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> string
  val extract_optional_field :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> string option
  val parse_int64_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Core.Int64.t
  val parse_optional_int64_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Core.Int64.t option
  val parse_int32_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Core.Int32.t
  val parse_optional_int32_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Core.Int32.t option
  (*---uint 8,16,32,64----*)
  val parse_uint8_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint8_extended.t
  val parse_optional_uint8_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint8_extended.t option
  val parse_uint16_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint16_extended.t
  val parse_optional_uint16_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint16_extended.t option
(*  val parse_uint24_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint24_extended.t
  val parse_optional_uint24_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint24_extended.t option*)
  val parse_uint32_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint32_extended.t
  val parse_optional_uint32_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint32_extended.t option
  val parse_uint64_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint64_extended.t
  val parse_optional_uint64_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Uint64_extended.t option
  val parse_bignum_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Bignum_extended.t
  val parse_optional_bignum_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Bignum_extended.t option
  (*---bool---*)					   
  val parse_bool_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> bool
  val parse_optional_bool_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> bool option
  (*---float/double---*)
  val parse_float_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> float
  val parse_optional_float_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> float option
  (*---date/time---*)
  val parse_date_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Date_extended.t
  val parse_optional_date_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Date_extended.t option
  val parse_datetime_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Date_time_extended.t
  val parse_optional_datetime_field_exn :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:string option array -> Date_time_extended.t option
end 