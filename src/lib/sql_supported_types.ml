module Uint8 = Uint8
module Uint16 = Uint16
module Uint32 = Uint32
module Uint64 = Uint64
open Core.Std

(*Types from mysql that are very safely mapped to Ocaml*)
module Sql_supported_types = struct
  type t =
      TINYINT_UNSIGNED
    | TINYINT_BOOL
    | SMALLINT_UNSIGNED
    | INTEGER
    | INTEGER_UNSIGNED
    | BIGINT
    | BIGINT_UNSIGNED
    | DECIMAL
    | FLOAT
    | DOUBLE
    | DATE
    | DATETIME
    | TIMESTAMP
    | BINARY
    | VARBINARY
    | VARCHAR
    | BLOB
  (*| ENUM*)
    | UNSUPPORTED

  (*Return a string we can use in writing a module that is a type. Cannot return a Uint8.t for example*)
  let ml_type_string_of_supported_sql_type t =
    match t with
      TINYINT_UNSIGNED -> Ok "Uint8.t"
    | TINYINT_BOOL -> Ok "bool"
    | SMALLINT_UNSIGNED -> Ok "Uint16.t"
    | INTEGER -> Ok "int"
    | INTEGER_UNSIGNED -> Ok "Uint64.t"
    | BIGINT -> Ok "Int64.t"
    | BIGINT_UNSIGNED -> Ok "Uint64.t"
    | DECIMAL
    | FLOAT 
    | DOUBLE -> Ok "float"
    | DATE -> Ok "Core.Std.Date.t"
    | DATETIME 
    | TIMESTAMP -> Ok "Core.Std.Time "
    | BINARY
    | BLOB
    | VARBINARY
    | VARCHAR -> Ok "string"
  (*| ENUM*)
    | UNSUPPORTED -> Error "to_ml_type::UNSUPPORTED_TYPE" 
	
  (*Given the data_type and column_type fields from info schema, determine if the mysql 
    type is supported or not, and if so which type; the data_type field is very easy to 
    match on but lacks the unsigned flag. The unsigned flag is disallowed if not in 
    combination with a numeric type in mysql, so we'll never see it here except with a 
    numeric type. *)
  let of_col_type_and_flags ~data_type ~col_type =
    let open Core.Std in 
    let is_unsigned = String.is_substring col_type ~substring:"unsigned" in
    let the_col_type s signed nullable =
      match signed, s with
      | true, "tinyint" -> TINYINT_UNSIGNED
      | false, "tinyint" -> TINYINT_BOOL 
      | true, "smallint" -> SMALLINT_UNSIGNED
      | true, "int" 
      | true, "integer" -> INTEGER_UNSIGNED
      | true, "bigint" -> BIGINT_UNSIGNED
      | false, "int" 
      | false, "integer" -> INTEGER
      | false, "bigint" -> BIGINT
      | false, "decimal" 
      | false, "float"
      | false, "double" -> FLOAT
      | false, "date" -> DATE 
      | false, "datetime" -> DATETIME
      | false, "timestamp" -> TIMESTAMP
      | false, "blob"
      | false, "binary"
      | false, "varbinary"
      | false, "varchar" -> VARCHAR
      | _, _ -> UNSUPPORTED in
    the_col_type data_type is_unsigned;;

  let one_step ~data_type ~col_type =
    let t = of_col_type_and_flags ~data_type ~col_type in
    let name_result = ml_type_string_of_supported_sql_type t in
    if is_ok name_result then
      (fun x -> match x with
	       | Ok name -> name
	       | Error s -> Error s) name_result
    else 
      Error "Unsupported sql type."
end 
(*  let of_string s =
    match s with
      "tinyint_bool" -> TINYINT_BOOL
    | "tinyint_unsigned" -> TINYINT_UNSIGNED
    | "smallint_unsigned" -> SMALLINT_UNSIGNED
    | "integer" 
    | "int" -> INTEGER
    | "integer_unsigned"
    | "int_unsigned" -> INTEGER_UNSIGNED
    | "bigint" -> BIGINT
    | "bigint_unsigned" -> BIGINT_UNSIGNED 
    | "date" -> DATE
    | "time" 
    | "datetime" -> DATETIME
    | "timestamp" -> TIMESTAMP
    | "blob" -> BLOB
    | "varchar" -> VARCHAR
    | _ -> UNSUPPORTED
end
 *)
