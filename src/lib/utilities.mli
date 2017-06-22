module Utilities : sig
  val print_n_flush : string -> unit 
  val getcon : ?host:string -> database:string -> password:string -> user:string -> Mysql.dbd
  val getcon_defaults : unit -> Mysql.dbd
  val closecon : Mysql.dbd ->  unit
  val print_n_flush : string -> unit
  val serialize_optional_field : field:string option -> conn:Mysql.dbd -> string
  val serialize_optional_field_with_default :
    field:string option -> conn:Mysql.dbd -> default:string -> string
  val serialize_boolean_field : field:bool -> string
  val serialize_optional_bool_field : field:bool option -> string
  val serialize_optional_float_field_as_int : field:float option -> string
  val serialize_float_field_as_int : field:float -> string

  val parse_optional_boolean_field : string option -> bool
  val parse_int_field_exn : string option -> int
  val parse_int_field_option : string option -> int option
  val parse_string_field : string -> string
  val parse_boolean_field : string -> bool
  val parse_int_field : string -> int
  val parse_64bit_int_field : string -> Core.Std.Int64.t

  val extract_field_as_string :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:array string array option -> string
  val extract_optional_field_as_string :
    fieldname:string -> results:Mysql.result ->
    arrayofstring:array string array option -> string option

  val parse_mysql_int_field :
    fieldname:string -> results:Mysql.result ->
    arraystring:string array string option -> int
  val parse_mysql_optional_int_field :
    fieldname:string -> results:Mysql.result ->
    arraystring:string array string option -> int

end 
