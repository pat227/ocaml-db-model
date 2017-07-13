module Types_we_emit : sig
  type t =
    | Int
    | Int64
    | Int32
    | CoreInt64
    | CoreInt32
    | Uint8_w_sexp_t
    | Uint16_w_sexp_t
    | Uint32_w_sexp_t
    | Uint64_w_sexp_t
    | Float
    | Date
    | Time 
    | String
    | Bool

  val to_string : t -> string
  val converter_of_string_of_type : is_optional:bool -> t:t -> string
  end 
