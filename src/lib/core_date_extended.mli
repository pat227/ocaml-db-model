module Core_date_extended :
  sig
    type t = Core__.Core_date_intf.Date.t
    val t_of_sexp : Sexplib.Sexp.t -> t
    val sexp_of_t : t -> Sexplib.Sexp.t
    val hash_fold_t :
      Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state
    val bin_t : t Bin_prot.Type_class.t
    val bin_read_t : t Bin_prot.Read.reader
    val __bin_read_t__ : (Core_kernel__.Import.int -> t) Bin_prot.Read.reader
    val bin_reader_t : t Bin_prot.Type_class.reader
    val bin_size_t : t Bin_prot.Size.sizer
    val bin_write_t : t Bin_prot.Write.writer
    val bin_writer_t : t Bin_prot.Type_class.writer
    val bin_shape_t : Bin_prot.Shape.t
    val hash : t -> Core_kernel__.Import.int
    val hashable : t Core_kernel__.Hashable.Hashtbl.Hashable.t
    module Table = Core__Core_date.Table
    module Hash_set = Core__Core_date.Hash_set
    module Hash_queue = Core__Core_date.Hash_queue
    val of_string : string -> t
    val to_string : t -> string
    val ( >= ) : t -> t -> bool
    val ( <= ) : t -> t -> bool
    val ( = ) : t -> t -> bool
    val ( > ) : t -> t -> bool
    val ( < ) : t -> t -> bool
    val ( <> ) : t -> t -> bool
    val equal : t -> t -> bool
    val compare : t -> t -> int
    val min : t -> t -> t
    val max : t -> t -> t
    val ascending : t -> t -> int
    val descending : t -> t -> int
    val between : t -> low:t -> high:t -> bool
    val clamp_exn : t -> min:t -> max:t -> t
    val clamp : t -> min:t -> max:t -> t Base__.Or_error.t
    type comparator_witness = Core_kernel__Date0.comparator_witness
    val validate_lbound :
      min:t Base__.Maybe_bound.t -> t Base__.Validate.check
    val validate_ubound :
      max:t Base__.Maybe_bound.t -> t Base__.Validate.check
    val validate_bound :
      min:t Base__.Maybe_bound.t ->
      max:t Base__.Maybe_bound.t -> t Base__.Validate.check
    module Replace_polymorphic_compare =
      Core__Core_date.Replace_polymorphic_compare
    val comparator :
      (t, comparator_witness) Core_kernel__.Comparator.comparator
    module Map = Core__Core_date.Map
    module Set = Core__Core_date.Set
    val pp : Base__.Import.Caml.Format.formatter -> t -> unit
    val create_exn :
      y:Core_kernel__.Import.int ->
      m:Core_kernel__.Month.t -> d:Core_kernel__.Import.int -> t
    val of_string_iso8601_basic :
      Core_kernel__.Import.string -> pos:Core_kernel__.Import.int -> t
    val to_string_iso8601_basic : t -> Core_kernel__.Import.string
    val to_string_american : t -> Core_kernel__.Import.string
    val day : t -> Core_kernel__.Import.int
    val month : t -> Core_kernel__.Month.t
    val year : t -> Core_kernel__.Import.int
    val day_of_week : t -> Core_kernel__.Day_of_week.t
    val week_number : t -> Core_kernel__.Import.int
    val is_weekend : t -> Core_kernel__.Import.bool
    val is_weekday : t -> Core_kernel__.Import.bool
    val is_business_day :
      t ->
      is_holiday:(t -> Core_kernel__.Import.bool) ->
      Core_kernel__.Import.bool
    val add_days : t -> Core_kernel__.Import.int -> t
    val add_months : t -> Core_kernel__.Import.int -> t
    val diff : t -> t -> Core_kernel__.Import.int
    val diff_weekdays : t -> t -> Core_kernel__.Import.int
    val diff_weekend_days : t -> t -> Core_kernel__.Import.int
    val add_weekdays : t -> Core_kernel__.Import.int -> t
    val add_business_days :
      t ->
      is_holiday:(t -> Core_kernel__.Import.bool) ->
      Core_kernel__.Import.int -> t
    val dates_between : min:t -> max:t -> t Core_kernel__.Import.list
    val business_dates_between :
      min:t ->
      max:t ->
      is_holiday:(t -> Core_kernel__.Import.bool) ->
      t Core_kernel__.Import.list
    val weekdays_between : min:t -> max:t -> t Core_kernel__.Import.list
    val previous_weekday : t -> t
    val following_weekday : t -> t
    val first_strictly_after : t -> on:Core_kernel__.Day_of_week.t -> t
    val is_leap_year :
      year:Core_kernel__.Import.int -> Core_kernel__.Import.bool
    val gen : t Core_kernel__.Quickcheck.Generator.t
    val obs : t Core_kernel__.Quickcheck.Observer.t
    val shrinker : t Core_kernel__.Quickcheck.Shrinker.t
    val gen_incl : t -> t -> t Core_kernel__.Quickcheck.Generator.t
    val gen_uniform_incl : t -> t -> t Core_kernel__.Quickcheck.Generator.t
    module Stable = Core__Core_date.Stable
    module O = Core__Core_date.O
    val of_time :
      Core_kernel__.Time_float.t -> zone:Core_kernel__.Time_float.Zone.t -> t
    val today : zone:Core_kernel__.Time_float.Zone.t -> t
    val format : t -> string -> string
    val parse : fmt:string -> string -> t
    val of_tm : Core__.Core_unix.tm -> t

    val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
    val show : t -> Ppx_deriving_runtime.string
    val t_of_sexp : Sexplib.Sexp.t -> t
    val sexp_of_t : t -> Sexplib.Sexp.t
    val compare : t -> t -> Ppx_deriving_runtime.int
    val equal : t -> t -> Ppx_deriving_runtime.bool
    val to_yojson : t -> Yojson.Safe.json
    val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
  end
