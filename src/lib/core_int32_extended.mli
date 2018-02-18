module Int32 = Core.Int32
module Core_int32_extended : sig
  include (module type of Int32)

  val sexp_of_t : Core.Int32.t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> Core.Int32.t
  val sexp_of_int32 : Core.Int32.t -> Sexplib.Sexp.t
  val int32_of_sexp : Sexplib.Sexp.t -> Core.Int32.t
  val pp : Format.formatter -> t -> unit
  val show : Core.Int32.t -> string
  val pp_int32 : Format.formatter -> t -> unit
  val show_int32 : Core.Int32.t -> string
  val equal_int32 : Core.Int32.t -> Core.Int32.t -> bool
  val compare_int32 : Core.Int32.t -> Core.Int32.t -> int
  val equal : Core.Int32.t -> Core.Int32.t -> bool
  val compare : Core.Int32.t -> Core.Int32.t -> int
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or						    
end
