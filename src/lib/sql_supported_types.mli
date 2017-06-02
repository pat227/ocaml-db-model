module Sql_supported_types : sig 
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

  (*Return a stirng representation of the ml type we will use to write the module, such as Uint8.t from Sql_supported_types.TINYINT_UNSIGNED.
    Filter on field name for boolean fields based on prefix? Such as is_xxxx, else is an error unless unsigned tiny int.*)
  val ml_type_of_supported_sql_type : t -> (string, string) Core.Std.Result.t
  val of_col_type_and_flags : data_type:string -> col_type:Core.Std.String.t -> t
  val one_step : data_type:string -> col_type:string -> string
end
