(*Unfortunately Uint64 module does not define sexp converters, so we have to.*)
module Uint64_extended :
sig
  type t = Uint64.t
  type uint64 = t
  val zero : uint64
  val one : uint64
  val add : uint64 -> uint64 -> uint64
  val sub : uint64 -> uint64 -> uint64
  val mul : uint64 -> uint64 -> uint64
  val div : uint64 -> uint64 -> uint64
  val rem : uint64 -> uint64 -> uint64
  val succ : uint64 -> uint64
  val pred : uint64 -> uint64
  val max_int : uint64
  val min_int : uint64
  val logand : uint64 -> uint64 -> uint64
  val logor : uint64 -> uint64 -> uint64
  val logxor : uint64 -> uint64 -> uint64
  val lognot : uint64 -> uint64
  val shift_left : uint64 -> int -> uint64
  val shift_right : uint64 -> int -> uint64
  val of_int : int -> uint64
  val to_int : uint64 -> int
  val of_float : float -> uint64
  val to_float : uint64 -> float
  val of_string : string -> uint64
  val to_string : uint64 -> string
  val to_string_bin : uint64 -> string
  val to_string_oct : uint64 -> string
  val to_string_hex : uint64 -> string
  val bits_of_float : float -> uint64
  val float_of_bits : uint64 -> float
  val compare : t -> t -> int
  val printer : Format.formatter -> uint64 -> unit
  val printer_bin : Format.formatter -> uint64 -> unit
  val printer_oct : Format.formatter -> uint64 -> unit
  val printer_hex : Format.formatter -> uint64 -> unit
						    
  val sexp_of_t : t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> t
  val sexp_of_uint64 : Uint64.t -> Sexplib.Sexp.t
  val uint64_of_sexp : Sexplib.Sexp.t -> Uint64.t
  val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val show : t -> Ppx_deriving_runtime.string
  val pp_uint64 : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val show_uint64 : t -> Ppx_deriving_runtime.string
  val equal_uint64 : Uint64.t -> Uint64.t -> bool
  val compare_uint64 : Uint64.t -> Uint64.t -> int
  val equal : t -> t -> bool
  val compare : t -> t -> int
end 
