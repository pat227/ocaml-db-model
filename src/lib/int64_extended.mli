module Int64_extended : sig
  type t = int64
  val pp : Format.formatter -> int64 -> unit
  val show : int64 -> string
  val pp_int64 : Format.formatter -> int64 -> unit
  val show_int64 : int64 -> string
  val equal_int64 : int64 -> int64 -> bool
  val compare_int64 : int64 -> int64 -> int
  val equal : int64 -> int64 -> bool
  val compare : int64 -> int64 -> int
  val to_yojson : int64 -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> int64 Ppx_deriving_yojson_runtime.error_or
  val of_string : string -> t
end
