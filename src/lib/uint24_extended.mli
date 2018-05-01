open Stdint
module Uint24_extended :
sig
  type t = Uint24.t
  val zero : uint24
  val one : uint24
  val add : uint24 -> uint24 -> uint24
  val sub : uint24 -> uint24 -> uint24
  val mul : uint24 -> uint24 -> uint24
  val div : uint24 -> uint24 -> uint24
  val rem : uint24 -> uint24 -> uint24
  val succ : uint24 -> uint24
  val pred : uint24 -> uint24
  val max_int : uint24
  val min_int : uint24
  val logand : uint24 -> uint24 -> uint24
  val logor : uint24 -> uint24 -> uint24
  val logxor : uint24 -> uint24 -> uint24
  val lognot : uint24 -> uint24
  val shift_left : uint24 -> int -> uint24
  val shift_right : uint24 -> int -> uint24
  val of_int : int -> uint24
  val to_int : uint24 -> int
  val of_float : float -> uint24
  val to_float : uint24 -> float
  val of_string : string -> uint24
  val to_string : uint24 -> string
  val to_string_bin : uint24 -> string
  val to_string_oct : uint24 -> string
  val to_string_hex : uint24 -> string
  val compare : t -> t -> int
  val printer : Format.formatter -> uint24 -> unit
  val printer_bin : Format.formatter -> uint24 -> unit
  val printer_oct : Format.formatter -> uint24 -> unit
  val printer_hex : Format.formatter -> uint24 -> unit
						    
  val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val show : t -> Ppx_deriving_runtime.string
  val pp_uint24 : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val show_uint24 : t -> Ppx_deriving_runtime.string
  val equal_uint24 : Uint24.t -> Uint24.t -> bool
  val compare_uint24 : Uint24.t -> Uint24.t -> int
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
end 
