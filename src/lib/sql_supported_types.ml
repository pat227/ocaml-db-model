module Uint64_extended = Uint64_extended.Uint64_extended
module Uint32_extended = Uint32_extended.Uint32_extended
module Uint16_extended = Uint16_extended.Uint16_extended
module Uint8_extended = Uint8_extended.Uint8_extended
(*Types from mysql that are relatively more safely mapped to Ocaml*)
module Types_we_emit = Types_we_emit.Types_we_emit
module Utilities = Utilities2copy.Utilities
module Sql_supported_types = struct
  type t =
      TINYINT
    | TINYINT_UNSIGNED
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
  (*| TIME <<<<====TODO *)
    | TIMESTAMP
    | BINARY
    | VARBINARY
    | MEDIUMTEXT
    | VARCHAR
    | BLOB
  (*| ENUM  -- generally not wise to use one of these anyway*)
    | UNSUPPORTED

  (*--by default just use int 64 type...*)
  let ml_type_of_supported_sql_type t =
    match t with
    | TINYINT -> Ok Types_we_emit.Int32  (*====TODO===find int8 type or make one *)
    | TINYINT_UNSIGNED -> Ok Types_we_emit.Uint8_extended_t
    | TINYINT_BOOL -> Ok Types_we_emit.Bool
    | SMALLINT_UNSIGNED -> Ok Types_we_emit.Uint16_extended_t
    | INTEGER -> Ok Types_we_emit.Int64
    | INTEGER_UNSIGNED -> Ok Types_we_emit.Uint64_extended_t
    | BIGINT -> Ok Types_we_emit.Int64
    | BIGINT_UNSIGNED -> Ok Types_we_emit.Uint64_extended_t
    | DECIMAL
    | FLOAT 
    | DOUBLE -> Ok Types_we_emit.Float
    | DATE -> Ok Types_we_emit.Date
  (*| TIME <<<<====TODO *)
    | DATETIME 
    | TIMESTAMP -> Ok Types_we_emit.DateTime
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
  let of_col_type_and_flags ~data_type ~col_type ~col_name =
    let is_unsigned = Str.string_match (Str.regexp "unsigned") col_type 0 in
    let the_col_type ~is_unsigned ~data_type =
      match is_unsigned, data_type with
      | _, "tinyint" -> if Str.string_match (Str.regexp "is_") col_name 0 then TINYINT_BOOL else TINYINT_UNSIGNED
      | true, "smallint" -> SMALLINT_UNSIGNED
      | true, "int" 
      | true, "integer" -> INTEGER_UNSIGNED
      | true, "bigint" -> BIGINT_UNSIGNED
      | false, "int" 
      | false, "integer" -> INTEGER
      | false, "bigint" -> BIGINT
      | false, "decimal" 
      | _, "float"
      | _, "double" -> FLOAT
      | false, "date" -> DATE 
      | false, "datetime" -> DATETIME
      | false, "timestamp" -> TIMESTAMP
(*    | false, "time" ->  <<<<===TODO -- support with use of Core.Time.Span.t *)
      | false, "blob"
      | false, "binary"
      | false, "varbinary"
      | false, "mediumtext" 
      | false, "varchar" -> VARCHAR
      | _, _ -> let () = Utilities.print_n_flush (String.concat "" [col_name;" with type ";col_type;" is not supported."])
		in UNSUPPORTED in
    the_col_type ~is_unsigned ~data_type;;
    
  let one_step ~data_type ~col_type ~col_name =
    let supported_t = of_col_type_and_flags ~data_type ~col_type ~col_name in
    let name_result = ml_type_of_supported_sql_type supported_t in
    match name_result with
    | Ok name -> name
    | Error s -> raise (Failure "sql_supported_types::one_step() Unsupported type")
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
