module Core_time_extended :
sig
  include (module type of Core.Time)
	    
  val to_parts : Core.Time.t -> Core.Int.t array
  val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val show : t -> Ppx_deriving_runtime.string
  val t_of_sexp : Sexplib.Sexp.t -> t
  val sexp_of_t : t -> Sexplib.Sexp.t
  val compare : t -> t -> Ppx_deriving_runtime.int
  val equal : t -> t -> Ppx_deriving_runtime.bool
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
end
