module Types_we_emit : sig
  type t =
    | Bignum
    | CoreInt64
    | CoreInt32
    | Uint8_extended_t
    | Uint16_extended_t
    (*| Uint24_extended_t ===TODO=== when switch to stdint *)
    | Uint32_extended_t
    | Uint64_extended_t
    | Float
    | Date
    | Time 
    | String
    | Bool
	[@@deriving show]

  val to_string : t:t -> is_nullable:bool -> string
  val converter_of_string_of_type : is_optional:bool -> t:t -> fieldname:string -> string
  val converter_to_string_of_type : is_optional:bool -> t:t -> string
  end 
