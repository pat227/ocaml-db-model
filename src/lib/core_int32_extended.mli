module Int32 = Core.Int32
module Core_int32_extended :
  sig
    type t = int32
    val of_float : float -> t
    val to_float : t -> float
    val of_int_exn : int -> t
    val to_int_exn : t -> int
    val hash_fold_t :
      Base__.Ppx_hash_lib.Std.Hash.state ->
      t -> Base__.Ppx_hash_lib.Std.Hash.state
    type comparator_witness = Base__Int32.comparator_witness
    val validate_positive : t Base__.Validate.check
    val validate_non_negative : t Base__.Validate.check
    val validate_negative : t Base__.Validate.check
    val validate_non_positive : t Base__.Validate.check
    val is_positive : t -> bool
    val is_non_negative : t -> bool
    val is_negative : t -> bool
    val is_non_positive : t -> bool
    val sign : t -> Base__.Sign0.t
    val to_string_hum : ?delimiter:char -> t -> string
    val zero : t
    val one : t
    val minus_one : t
    val ( + ) : t -> t -> t
    val ( - ) : t -> t -> t
    val ( * ) : t -> t -> t
    val neg : t -> t
    val ( ~- ) : t -> t
    val ( /% ) : t -> t -> t
    val ( % ) : t -> t -> t
    val ( / ) : t -> t -> t
    val rem : t -> t -> t
    val ( // ) : t -> t -> float
    val ( land ) : t -> t -> t
    val ( lor ) : t -> t -> t
    val ( lxor ) : t -> t -> t
    val lnot : t -> t
    val ( lsl ) : t -> int -> t
    val ( asr ) : t -> int -> t
    val succ : t -> t
    val pred : t -> t
    val abs : t -> t
    val round :
      ?dir:[ `Down | `Nearest | `Up | `Zero ] -> t -> to_multiple_of:t -> t
    val round_towards_zero : t -> to_multiple_of:t -> t
    val round_down : t -> to_multiple_of:t -> t
    val round_up : t -> to_multiple_of:t -> t
    val round_nearest : t -> to_multiple_of:t -> t
    val pow : t -> t -> t
    val bit_and : t -> t -> t
    val bit_or : t -> t -> t
    val bit_xor : t -> t -> t
    val bit_not : t -> t
    val shift_left : t -> int -> t
    val shift_right : t -> int -> t
    val decr : t Base__.Import.ref -> unit
    val incr : t Base__.Import.ref -> unit
    val popcount : t -> int
    val of_int32_exn : int32 -> t
    val to_int32_exn : t -> int32
    val of_int64_exn : int64 -> t
    val to_int64 : t -> int64
    val of_nativeint_exn : nativeint -> t
    val to_nativeint_exn : t -> nativeint
    val of_float_unchecked : float -> t
    val num_bits : int
    val max_value : t
    val min_value : t
    val ( lsr ) : t -> int -> t
    val shift_right_logical : t -> int -> t
    module O = Core_kernel__Core_int32.O
    val of_int : int -> t option
    val to_int : t -> int option
    val of_int32 : int32 -> t
    val to_int32 : t -> int32
    val of_nativeint : nativeint -> t option
    val to_nativeint : t -> nativeint
    val of_int64 : int64 -> t option
    val bits_of_float : float -> t
    val float_of_bits : t -> float
    val typerep_of_t : t Typerep_lib.Std.Typerep.t
    val typename_of_t : t Typerep_lib.Std.Typename.t
    module Hex = Core_kernel__Core_int32.Hex
    val bin_t : t Bin_prot.Type_class.t
    val bin_read_t : t Bin_prot.Read.reader
    val __bin_read_t__ : (Core_kernel__.Import.int -> t) Bin_prot.Read.reader
    val bin_reader_t : t Bin_prot.Type_class.reader
    val bin_size_t : t Bin_prot.Size.sizer
    val bin_write_t : t Bin_prot.Write.writer
    val bin_writer_t : t Bin_prot.Type_class.writer
    val bin_shape_t : Bin_prot.Shape.t
    val of_string : string -> t
    val to_string : t -> string
    val ( >= ) : t -> t -> bool
    val ( <= ) : t -> t -> bool
    val ( = ) : t -> t -> bool
    val ( > ) : t -> t -> bool
    val ( < ) : t -> t -> bool
    val ( <> ) : t -> t -> bool
    val min : t -> t -> t
    val max : t -> t -> t
    val ascending : t -> t -> int
    val descending : t -> t -> int
    val between : t -> low:t -> high:t -> bool
    val clamp_exn : t -> min:t -> max:t -> t
    val clamp : t -> min:t -> max:t -> t Base__.Or_error.t
    val validate_lbound :
      min:t Base__.Maybe_bound.t -> t Base__.Validate.check
    val validate_ubound :
      max:t Base__.Maybe_bound.t -> t Base__.Validate.check
    val validate_bound :
      min:t Base__.Maybe_bound.t ->
      max:t Base__.Maybe_bound.t -> t Base__.Validate.check
    module Replace_polymorphic_compare =
      Core_kernel__Core_int32.Replace_polymorphic_compare
    val comparator :
      (t, comparator_witness) Core_kernel__.Comparator.comparator
    module Map = Core_kernel__Core_int32.Map
    module Set = Core_kernel__Core_int32.Set
    val hash : t -> Core_kernel__.Import.int
    val hashable : t Core_kernel__.Hashable.Hashtbl.Hashable.t
    module Table = Core_kernel__Core_int32.Table
    module Hash_set = Core_kernel__Core_int32.Hash_set
    module Hash_queue = Core_kernel__Core_int32.Hash_queue
    val gen : t Core_kernel__.Quickcheck.Generator.t
    val obs : t Core_kernel__.Quickcheck.Observer.t
    val shrinker : t Core_kernel__.Quickcheck.Shrinker.t
    val gen_incl : t -> t -> t Core_kernel__.Quickcheck.Generator.t
    val gen_uniform_incl : t -> t -> t Core_kernel__.Quickcheck.Generator.t
    val gen_log_uniform_incl :
      t -> t -> t Core_kernel__.Quickcheck.Generator.t
    val gen_log_incl : t -> t -> t Core_kernel__.Quickcheck.Generator.t
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
