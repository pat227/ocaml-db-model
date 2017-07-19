module Types_we_emit : sig
  type t =
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
	[@@deriving show]

  val to_string : t:t -> is_nullable:bool -> string
  val converter_of_string_of_type : is_optional:bool -> t:t -> fieldname:string -> string
  end 
