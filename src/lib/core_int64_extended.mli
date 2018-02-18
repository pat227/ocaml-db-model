module Int64 = Core.Int64
module Core_int64_extended : sig
  include (module type of Int64)
	    
  val sexp_of_t : Core.Int64.t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> Core.Int64.t
  val sexp_of_int64 : Core.Int64.t -> Sexplib.Sexp.t
  val int64_of_sexp : Sexplib.Sexp.t -> Core.Int64.t
  val pp : Format.formatter -> t -> unit
  val show : Core.Int64.t -> string
  val pp_int64 : Format.formatter -> t -> unit
  val show_int64 : Core.Int64.t -> string
  val equal_int64 : Core.Int64.t -> Core.Int64.t -> bool
  val compare_int64 : Core.Int64.t -> Core.Int64.t -> int
  val equal : Core.Int64.t -> Core.Int64.t -> bool
  val compare : Core.Int64.t -> Core.Int64.t -> int
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
end
