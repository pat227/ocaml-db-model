open Core.Std
module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp
module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp
module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp
module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp
(*Types from mysql that are relatively more safely mapped to Ocaml*)
module Types_we_emit = Types_we_emit.Types_we_emit
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
    | MEDIUMTEXT
    | VARCHAR
    | BLOB
  (*| ENUM*)
    | UNSUPPORTED


  let ml_type_of_supported_sql_type t =
    match t with
      TINYINT_UNSIGNED -> Ok Types_we_emit.Uint8_w_sexp_t
    | TINYINT_BOOL -> Ok Types_we_emit.Bool
    | SMALLINT_UNSIGNED -> Ok Types_we_emit.Uint16_w_sexp_t
    | INTEGER -> Ok Types_we_emit.Int
    | INTEGER_UNSIGNED -> Ok Types_we_emit.Uint64_w_sexp_t
    | BIGINT -> Ok Types_we_emit.Int64_t
    | BIGINT_UNSIGNED -> Ok Types_we_emit.Uint64_w_sexp_t
    | DECIMAL
    | FLOAT 
    | DOUBLE -> Ok Types_we_emit.Float
    | DATE -> Ok Types_we_emit.Date
    | DATETIME 
    | TIMESTAMP -> Ok Types_we_emit.Time
    | BINARY
    | BLOB
    | MEDIUMTEXT
    | VARBINARY
    | VARCHAR -> Ok Types_we_emit.String
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
    let the_col_type s signed =
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
      | false, "mediumtext" 
      | false, "varchar" -> VARCHAR
      | _, _ -> UNSUPPORTED in
    the_col_type data_type is_unsigned;;
    
  let one_step ~data_type ~col_type =
    let supported_t = of_col_type_and_flags ~data_type ~col_type in
    let name_result = ml_type_of_supported_sql_type supported_t in
    if is_ok name_result then
      (fun x -> match x with
	       | Ok name -> name
	       | Error s -> raise (Failure "sql_supported_types::one_step() Unsupported type")) name_result
    else 
      raise (Failure "Unsupported sql type.")
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
