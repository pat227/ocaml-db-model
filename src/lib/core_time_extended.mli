module Core_time_extended :
  sig
    module Zone = Core__Core_time_float.Zone
    module Ofday = Core__Core_time_float.Ofday
    type t = Core__.Import.Time.t
    type underlying = Core_kernel.Core_kernel_private.Time_float0.underlying
    val typerep_of_t : t Typerep_lib.Std.Typerep.t
    val typename_of_t : t Typerep_lib.Std.Typename.t
    val hash_fold_t :
      Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state
    type comparator_witness =
        Core_kernel.Core_kernel_private.Time_float0.comparator_witness
    module Replace_polymorphic_compare =
      Core__Core_time_float.Replace_polymorphic_compare
    module Span = Core__Core_time_float.Span
    val next : t -> t
    val prev : t -> t
    val to_span_since_epoch : t -> Span.t
    val of_span_since_epoch : Span.t -> t
    val utc_mktime : Core_kernel__.Date0.t -> Ofday.t -> t
    val to_days_since_epoch_and_remainder :
      t -> Core_kernel__.Import.int * Span.t
    val now : Core_kernel__.Import.unit -> t
    val add : t -> Span.t -> t
    val sub : t -> Span.t -> t
    val diff : t -> t -> Span.t
    val abs_diff : t -> t -> Span.t
    val is_earlier : t -> than:t -> Core_kernel__.Import.bool
    val is_later : t -> than:t -> Core_kernel__.Import.bool
    val of_date_ofday :
      zone:Zone.t ->
      Core_kernel.Core_kernel_private.Time_intf.Date.t -> Ofday.t -> t
    val of_date_ofday_precise :
      Core_kernel.Core_kernel_private.Time_intf.Date.t ->
      Ofday.t ->
      zone:Zone.t -> [ `Never of t | `Once of t | `Twice of t * t ]
    val to_date_ofday :
      t ->
      zone:Zone.t ->
      Core_kernel.Core_kernel_private.Time_intf.Date.t * Ofday.t
    val to_date_ofday_precise :
      t ->
      zone:Zone.t ->
      Core_kernel.Core_kernel_private.Time_intf.Date.t * Ofday.t *
      [ `Also_at of t
      | `Also_skipped of
          Core_kernel.Core_kernel_private.Time_intf.Date.t * Ofday.t
      | `Only ]
    val to_date :
      t -> zone:Zone.t -> Core_kernel.Core_kernel_private.Time_intf.Date.t
    val to_ofday : t -> zone:Zone.t -> Ofday.t
    val epoch : t
    val convert :
      from_tz:Zone.t ->
      to_tz:Zone.t ->
      Core_kernel.Core_kernel_private.Time_intf.Date.t ->
      Ofday.t -> Core_kernel.Core_kernel_private.Time_intf.Date.t * Ofday.t
    val utc_offset : t -> zone:Zone.t -> Span.t
    val to_filename_string : t -> zone:Zone.t -> Core_kernel__.Import.string
    val of_filename_string : Core_kernel__.Import.string -> zone:Zone.t -> t
    val to_string_trimmed : t -> zone:Zone.t -> Core_kernel__.Import.string
    val to_sec_string : t -> zone:Zone.t -> Core_kernel__.Import.string
    val of_localized_string : zone:Zone.t -> Core_kernel__.Import.string -> t
    val to_string_abs : t -> zone:Zone.t -> Core_kernel__.Import.string
    val to_string_abs_trimmed :
      t -> zone:Zone.t -> Core_kernel__.Import.string
    val to_string_abs_parts :
      t ->
      zone:Zone.t -> Core_kernel__.Import.string Core_kernel__.Import.list
    val to_string_iso8601_basic :
      t -> zone:Zone.t -> Core_kernel__.Import.string
    val occurrence :
      [ `First_after_or_at | `Last_before_or_at ] ->
      t -> ofday:Ofday.t -> zone:Zone.t -> t
    val next_multiple :
      ?can_equal_after:Core_kernel__.Import.bool ->
      base:t -> after:t -> interval:Span.t -> Core_kernel__.Import.unit -> t
    val t_of_sexp : Sexplib.Sexp.t -> t
    val sexp_of_t : t -> Sexplib.Sexp.t
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
    val equal : t -> t -> bool
    val compare : t -> t -> int
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
    val comparator :
      (t, comparator_witness) Core_kernel__.Comparator.comparator
    module Map = Core__Core_time_float.Map
    module Set = Core__Core_time_float.Set
    val hash : t -> Core_kernel__.Import.int
    val hashable : t Core_kernel__.Hashable.Hashtbl.Hashable.t
    module Table = Core__Core_time_float.Table
    module Hash_set = Core__Core_time_float.Hash_set
    module Hash_queue = Core__Core_time_float.Hash_queue
    val pp : Base__.Import.Caml.Format.formatter -> t -> unit
    val get_sexp_zone : unit -> Zone.t
    val set_sexp_zone : Zone.t -> unit
    val ( >=. ) : t -> t -> bool
    val ( <=. ) : t -> t -> bool
    val ( =. ) : t -> t -> bool
    val ( >. ) : t -> t -> bool
    val ( <. ) : t -> t -> bool
    val ( <>. ) : t -> t -> bool
    val robustly_compare : t -> t -> int
    val of_tm : Core__.Core_unix.tm -> zone:Zone.t -> t
    val to_string_fix_proto : [ `Local | `Utc ] -> t -> string
    val of_string_fix_proto : [ `Local | `Utc ] -> string -> t
    val of_string_abs : string -> t
    val of_string_gen :
      if_no_timezone:[ `Fail | `Local | `Use_this_one of Zone.t ] ->
      string -> t
    val t_of_sexp_abs : Core__.Import.Sexp.t -> t
    val sexp_of_t_abs : t -> zone:Zone.t -> Core__.Import.Sexp.t
    val pause : Span.t -> unit
    val interruptible_pause : Span.t -> [ `Ok | `Remaining of Span.t ]
    val pause_forever : unit -> Core__.Import.never_returns
    val format : t -> string -> zone:Zone.t -> string
    val parse : string -> fmt:string -> zone:Zone.t -> t
    module Stable = Core__Core_time_float.Stable
    module Exposed_for_tests = Core__Core_time_float.Exposed_for_tests
    val to_parts : Core.Time.t -> Core.Int.t array

    val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
    val show : t -> Ppx_deriving_runtime.string
    val t_of_sexp : Sexplib.Sexp.t -> t
    val sexp_of_t : t -> Sexplib.Sexp.t
    val compare : t -> t -> Ppx_deriving_runtime.int
    val equal : t -> t -> Ppx_deriving_runtime.bool
    val to_yojson : t -> Yojson.Safe.json
    val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
   (*NOT WHAT WE WANT: val of_yojson : Yojson.Safe.json -> [ `Error of string | `Ok of t ]*)
  end
