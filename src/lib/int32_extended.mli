module Int32_extended : sig
	    
  val pp : Format.formatter -> int32 -> unit
  val show : int32 -> string
  val pp_int32 : Format.formatter -> int32 -> unit
  val show_int32 : int32 -> string
  val equal_int32 : int32 -> int32 -> bool
  val compare_int32 : int32 -> int32 -> int
  val equal : int32 -> int32 -> bool
  val compare : int32 -> int32 -> int
  val to_yojson : int32 -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> int32 Ppx_deriving_yojson_runtime.error_or
end
