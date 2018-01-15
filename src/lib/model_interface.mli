module Pcre = Pcre
module Utilities = Utilities.Utilities
module Table = Table.Table
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Types_we_emit = Types_we_emit.Types_we_emit
module Mysql = Mysql
module Model :
  sig
    type t = {
      col_name : string;
      table_name : string;
      data_type : Types_we_emit.t;
      is_nullable : bool;
      is_primary_key : bool;
    }
    val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
    val show : t -> Ppx_deriving_runtime.string
    val is_primary_key : t -> bool
    val is_nullable : t -> bool
    val data_type : t -> Types_we_emit.t
    val table_name : t -> string
    val col_name : t -> string
    module Fields :
      sig
        val names : string list
        val is_primary_key :
          ([< `Read | `Set_and_create ], t, bool) Fieldslib.Field.t_with_perm
        val is_nullable :
          ([< `Read | `Set_and_create ], t, bool) Fieldslib.Field.t_with_perm
        val data_type :
          ([< `Read | `Set_and_create ], t, Types_we_emit.t)
          Fieldslib.Field.t_with_perm
        val table_name :
          ([< `Read | `Set_and_create ], t, string)
          Fieldslib.Field.t_with_perm
        val col_name :
          ([< `Read | `Set_and_create ], t, string)
          Fieldslib.Field.t_with_perm
        val make_creator :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> 'a -> ('b -> string) * 'c) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm ->
                      'c -> ('b -> string) * 'd) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm ->
                     'd -> ('b -> Types_we_emit.t) * 'e) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> 'e -> ('b -> bool) * 'f) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm ->
                          'f -> ('b -> bool) * 'g) ->
          'a -> ('b -> t) * 'g
        val create :
          col_name:string ->
          table_name:string ->
          data_type:Types_we_emit.t ->
          is_nullable:bool -> is_primary_key:bool -> t
        val map :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> string) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> string) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> Types_we_emit.t) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> bool) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> bool) ->
          t
        val iter :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> unit) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> unit) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> unit) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> unit) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> unit) ->
          unit
        val fold :
          init:'a ->
          col_name:('a ->
                    ([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> 'b) ->
          table_name:('b ->
                      ([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> 'c) ->
          data_type:('c ->
                     ([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> 'd) ->
          is_nullable:('d ->
                       ([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> 'e) ->
          is_primary_key:('e ->
                          ([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> 'f) ->
          'f
        val map_poly :
          ([< `Read | `Set_and_create ], t, 'a) Fieldslib.Field.user ->
          'a list
        val for_all :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> bool) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> bool) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> bool) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> bool) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> bool) ->
          bool
        val exists :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> bool) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> bool) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> bool) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> bool) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> bool) ->
          bool
        val to_list :
          col_name:(([< `Read | `Set_and_create ], t, string)
                    Fieldslib.Field.t_with_perm -> 'a) ->
          table_name:(([< `Read | `Set_and_create ], t, string)
                      Fieldslib.Field.t_with_perm -> 'a) ->
          data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                     Fieldslib.Field.t_with_perm -> 'a) ->
          is_nullable:(([< `Read | `Set_and_create ], t, bool)
                       Fieldslib.Field.t_with_perm -> 'a) ->
          is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                          Fieldslib.Field.t_with_perm -> 'a) ->
          'a list
        module Direct :
          sig
            val iter :
              t ->
              col_name:(([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
              table_name:(([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm -> t -> string -> 'b) ->
              data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> 'c) ->
              is_nullable:(([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> 'd) ->
              is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm -> t -> bool -> 'e) ->
              'e
            val fold :
              t ->
              init:'a ->
              col_name:('a ->
                        ([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> 'b) ->
              table_name:('b ->
                          ([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm -> t -> string -> 'c) ->
              data_type:('c ->
                         ([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> 'd) ->
              is_nullable:('d ->
                           ([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> 'e) ->
              is_primary_key:('e ->
                              ([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm -> t -> bool -> 'f) ->
              'f
            val for_all :
              t ->
              col_name:(([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
              table_name:(([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
              data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> bool) ->
              is_nullable:(([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> bool) ->
              is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm ->
                              t -> bool -> bool) ->
              bool
            val exists :
              t ->
              col_name:(([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
              table_name:(([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
              data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> bool) ->
              is_nullable:(([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> bool) ->
              is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm ->
                              t -> bool -> bool) ->
              bool
            val to_list :
              t ->
              col_name:(([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
              table_name:(([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
              data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> 'a) ->
              is_nullable:(([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> 'a) ->
              is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm -> t -> bool -> 'a) ->
              'a list
            val map :
              t ->
              col_name:(([< `Read | `Set_and_create ], t, string)
                        Fieldslib.Field.t_with_perm -> t -> string -> string) ->
              table_name:(([< `Read | `Set_and_create ], t, string)
                          Fieldslib.Field.t_with_perm ->
                          t -> string -> string) ->
              data_type:(([< `Read | `Set_and_create ], t, Types_we_emit.t)
                         Fieldslib.Field.t_with_perm ->
                         t -> Types_we_emit.t -> Types_we_emit.t) ->
              is_nullable:(([< `Read | `Set_and_create ], t, bool)
                           Fieldslib.Field.t_with_perm -> t -> bool -> bool) ->
              is_primary_key:(([< `Read | `Set_and_create ], t, bool)
                              Fieldslib.Field.t_with_perm ->
                              t -> bool -> bool) ->
              t
            val set_all_mutable_fields : 'a -> unit
          end
      end
    module Sequoia_support :
      sig
        module T :
          sig
            type t = {
              col : string;
              table : string;
              referenced_table : string;
              referenced_field : string;
            }
            val equal : t -> t -> Ppx_deriving_runtime.bool
            val compare : t -> t -> Ppx_deriving_runtime.int
            val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
            val show : t -> Ppx_deriving_runtime.string
            val referenced_field : t -> string
            val referenced_table : t -> string
            val table : t -> string
            val col : t -> string
            module Fields :
              sig
                val names : string list
                val referenced_field :
                  ([< `Read | `Set_and_create ], t, string)
                  Fieldslib.Field.t_with_perm
                val referenced_table :
                  ([< `Read | `Set_and_create ], t, string)
                  Fieldslib.Field.t_with_perm
                val table :
                  ([< `Read | `Set_and_create ], t, string)
                  Fieldslib.Field.t_with_perm
                val col :
                  ([< `Read | `Set_and_create ], t, string)
                  Fieldslib.Field.t_with_perm
                val make_creator :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm ->
                       'a -> ('b -> string) * 'c) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm ->
                         'c -> ('b -> string) * 'd) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm ->
                                    'd -> ('b -> string) * 'e) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm ->
                                    'e -> ('b -> string) * 'f) ->
                  'a -> ('b -> t) * 'f
                val create :
                  col:string ->
                  table:string ->
                  referenced_table:string -> referenced_field:string -> t
                val map :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> string) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> string) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> string) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> string) ->
                  t
                val iter :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> unit) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> unit) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> unit) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> unit) ->
                  unit
                val fold :
                  init:'a ->
                  col:('a ->
                       ([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> 'b) ->
                  table:('b ->
                         ([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> 'c) ->
                  referenced_table:('c ->
                                    ([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> 'd) ->
                  referenced_field:('d ->
                                    ([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> 'e) ->
                  'e
                val map_poly :
                  ([< `Read | `Set_and_create ], t, 'a) Fieldslib.Field.user ->
                  'a list
                val for_all :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> bool) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> bool) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> bool) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> bool) ->
                  bool
                val exists :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> bool) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> bool) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> bool) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> bool) ->
                  bool
                val to_list :
                  col:(([< `Read | `Set_and_create ], t, string)
                       Fieldslib.Field.t_with_perm -> 'a) ->
                  table:(([< `Read | `Set_and_create ], t, string)
                         Fieldslib.Field.t_with_perm -> 'a) ->
                  referenced_table:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> 'a) ->
                  referenced_field:(([< `Read | `Set_and_create ], t, string)
                                    Fieldslib.Field.t_with_perm -> 'a) ->
                  'a list
                module Direct :
                  sig
                    val iter :
                      t ->
                      col:(([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
                      table:(([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm -> t -> string -> 'b) ->
                      referenced_table:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'c) ->
                      referenced_field:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'd) ->
                      'd
                    val fold :
                      t ->
                      init:'a ->
                      col:('a ->
                           ([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm -> t -> string -> 'b) ->
                      table:('b ->
                             ([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm -> t -> string -> 'c) ->
                      referenced_table:('c ->
                                        ([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'd) ->
                      referenced_field:('d ->
                                        ([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'e) ->
                      'e
                    val for_all :
                      t ->
                      col:(([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
                      table:(([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm ->
                             t -> string -> bool) ->
                      referenced_table:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> bool) ->
                      referenced_field:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> bool) ->
                      bool
                    val exists :
                      t ->
                      col:(([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm -> t -> string -> bool) ->
                      table:(([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm ->
                             t -> string -> bool) ->
                      referenced_table:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> bool) ->
                      referenced_field:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> bool) ->
                      bool
                    val to_list :
                      t ->
                      col:(([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
                      table:(([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm -> t -> string -> 'a) ->
                      referenced_table:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'a) ->
                      referenced_field:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> 'a) ->
                      'a list
                    val map :
                      t ->
                      col:(([< `Read | `Set_and_create ], t, string)
                           Fieldslib.Field.t_with_perm ->
                           t -> string -> string) ->
                      table:(([< `Read | `Set_and_create ], t, string)
                             Fieldslib.Field.t_with_perm ->
                             t -> string -> string) ->
                      referenced_table:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> string) ->
                      referenced_field:(([< `Read | `Set_and_create ], 
                                         t, string)
                                        Fieldslib.Field.t_with_perm ->
                                        t -> string -> string) ->
                      t
                    val set_all_mutable_fields : 'a -> unit
                  end
              end
            val t_of_sexp : Sexplib.Sexp.t -> t
            val sexp_of_t : t -> Sexplib.Sexp.t
          end
        type t =
          T.t = {
          col : string;
          table : string;
          referenced_table : string;
          referenced_field : string;
        }
        val equal : t -> t -> Ppx_deriving_runtime.bool
        val compare : t -> t -> Ppx_deriving_runtime.int
        val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
        val show : t -> Ppx_deriving_runtime.string
        val referenced_field : t -> string
        val referenced_table : t -> string
        val table : t -> string
        val col : t -> string
        module Fields = T.Fields
        val t_of_sexp : Sexplib.Sexp.t -> t
        val sexp_of_t : t -> Sexplib.Sexp.t
        module Tset :
          sig
            module Elt :
              sig
                type t = T.t
                val t_of_sexp : Sexplib.Sexp.t -> t
                val sexp_of_t : t -> Sexplib.Sexp.t
                type comparator_witness =
                    Core_kernel__Core_set.Make(T).Elt.comparator_witness
                val comparator :
                  (t, comparator_witness) Core_kernel__.Comparator.comparator
              end
            module Tree :
              sig
                type t =
                    (Elt.t, Elt.comparator_witness)
                    Core_kernel__.Core_set_intf.Tree.t
                val compare : t -> t -> Core_kernel__.Import.int
                val length : t -> int
                val is_empty : t -> bool
                val iter : t -> f:(Elt.t -> unit) -> unit
                val fold :
                  t -> init:'accum -> f:('accum -> Elt.t -> 'accum) -> 'accum
                val fold_result :
                  t ->
                  init:'accum ->
                  f:('accum -> Elt.t -> ('accum, 'e) Base__.Result.t) ->
                  ('accum, 'e) Base__.Result.t
                val exists : t -> f:(Elt.t -> bool) -> bool
                val for_all : t -> f:(Elt.t -> bool) -> bool
                val count : t -> f:(Elt.t -> bool) -> int
                val sum :
                  (module Base__.Commutative_group.S with type t = 'sum) ->
                  t -> f:(Elt.t -> 'sum) -> 'sum
                val find : t -> f:(Elt.t -> bool) -> Elt.t option
                val find_map : t -> f:(Elt.t -> 'a option) -> 'a option
                val to_list : t -> Elt.t list
                val to_array : t -> Elt.t array
                val invariants : t -> bool
                val mem : t -> Elt.t -> bool
                val add : t -> Elt.t -> t
                val remove : t -> Elt.t -> t
                val union : t -> t -> t
                val inter : t -> t -> t
                val diff : t -> t -> t
                val symmetric_diff :
                  t -> t -> (Elt.t, Elt.t) Base__.Either.t Base__.Sequence.t
                val compare_direct : t -> t -> int
                val equal : t -> t -> bool
                val is_subset : t -> of_:t -> bool
                val subset : t -> t -> bool
                val fold_until :
                  t ->
                  init:'b ->
                  f:('b ->
                     Elt.t ->
                     ('b, 'stop)
                     Core_kernel__.Core_set_intf.Set_intf.Continue_or_stop.t) ->
                  ('b, 'stop)
                  Core_kernel__.Core_set_intf.Set_intf.Finished_or_stopped_early.t
                val fold_right : t -> init:'b -> f:(Elt.t -> 'b -> 'b) -> 'b
                val iter2 :
                  t ->
                  t ->
                  f:([ `Both of Elt.t * Elt.t
                     | `Left of Elt.t
                     | `Right of Elt.t ] -> unit) ->
                  unit
                val filter : t -> f:(Elt.t -> bool) -> t
                val partition_tf : t -> f:(Elt.t -> bool) -> t * t
                val elements : t -> Elt.t list
                val min_elt : t -> Elt.t option
                val min_elt_exn : t -> Elt.t
                val max_elt : t -> Elt.t option
                val max_elt_exn : t -> Elt.t
                val choose : t -> Elt.t option
                val choose_exn : t -> Elt.t
                val split : t -> Elt.t -> t * Elt.t option * t
                val group_by : t -> equiv:(Elt.t -> Elt.t -> bool) -> t list
                val find_exn : t -> f:(Elt.t -> bool) -> Elt.t
                val find_index : t -> int -> Elt.t option
                val nth : t -> int -> Elt.t option
                val remove_index : t -> int -> t
                val to_tree : t -> t
                val to_sequence :
                  ?order:[ `Decreasing | `Increasing ] ->
                  ?greater_or_equal_to:Elt.t ->
                  ?less_or_equal_to:Elt.t -> t -> Elt.t Base__.Sequence.t
                val merge_to_sequence :
                  ?order:[ `Decreasing | `Increasing ] ->
                  ?greater_or_equal_to:Elt.t ->
                  ?less_or_equal_to:Elt.t ->
                  t ->
                  t ->
                  (Elt.t, Elt.t)
                  Core_kernel__.Core_set_intf.Set_intf.Merge_to_sequence_element.t
                  Base__.Sequence.t
                val to_map :
                  t ->
                  f:(Elt.t -> 'data) ->
                  (Elt.t, 'data, Elt.comparator_witness)
                  Core_kernel__.Core_set_intf.Map.t
                val obs :
                  Elt.t Core_kernel__.Quickcheck.Observer.t ->
                  t Core_kernel__.Quickcheck.Observer.t
                val shrinker :
                  Elt.t Core_kernel__.Quickcheck.Shrinker.t ->
                  t Core_kernel__.Quickcheck.Shrinker.t
                val empty : t
                val singleton : Elt.t -> t
                val union_list : t list -> t
                val of_list : Elt.t list -> t
                val of_array : Elt.t array -> t
                val of_sorted_array : Elt.t array -> t Base__.Or_error.t
                val of_sorted_array_unchecked : Elt.t array -> t
                val of_increasing_iterator_unchecked :
                  len:int -> f:(int -> Elt.t) -> t
                val stable_dedup_list : Elt.t list -> Elt.t list
                val map :
                  ('a, 'b) Core_kernel__.Core_set_intf.Tree.t ->
                  f:('a -> Elt.t) -> t
                val filter_map :
                  ('a, 'b) Core_kernel__.Core_set_intf.Tree.t ->
                  f:('a -> Elt.t option) -> t
                val of_tree : t -> t
                val of_hash_set : Elt.t Core_kernel__.Hash_set.t -> t
                val of_hashtbl_keys :
                  (Elt.t, 'a) Core_kernel__.Core_hashtbl.t -> t
                val of_map_keys :
                  (Elt.t, 'a, Elt.comparator_witness)
                  Core_kernel__.Core_set_intf.Map.t -> t
                val gen :
                  Elt.t Core_kernel__.Quickcheck.Generator.t ->
                  t Core_kernel__.Quickcheck.Generator.t
                module Provide_of_sexp :
                  functor
                    (Elt : sig val t_of_sexp : Sexplib.Sexp.t -> Elt.t end) ->
                    sig val t_of_sexp : Sexplib.Sexp.t -> t end
                val t_of_sexp : Base__.Sexplib.Sexp.t -> t
                val sexp_of_t : t -> Base__.Sexplib.Sexp.t
              end
            type t = (Elt.t, Elt.comparator_witness) Base.Set.t
            val compare : t -> t -> Core_kernel__.Import.int
            val length : t -> int
            val is_empty : t -> bool
            val iter : t -> f:(Elt.t -> unit) -> unit
            val fold :
              t -> init:'accum -> f:('accum -> Elt.t -> 'accum) -> 'accum
            val fold_result :
              t ->
              init:'accum ->
              f:('accum -> Elt.t -> ('accum, 'e) Base__.Result.t) ->
              ('accum, 'e) Base__.Result.t
            val exists : t -> f:(Elt.t -> bool) -> bool
            val for_all : t -> f:(Elt.t -> bool) -> bool
            val count : t -> f:(Elt.t -> bool) -> int
            val sum :
              (module Base__.Commutative_group.S with type t = 'sum) ->
              t -> f:(Elt.t -> 'sum) -> 'sum
            val find : t -> f:(Elt.t -> bool) -> Elt.t option
            val find_map : t -> f:(Elt.t -> 'a option) -> 'a option
            val to_list : t -> Elt.t list
            val to_array : t -> Elt.t array
            val invariants : t -> bool
            val mem : t -> Elt.t -> bool
            val add : t -> Elt.t -> t
            val remove : t -> Elt.t -> t
            val union : t -> t -> t
            val inter : t -> t -> t
            val diff : t -> t -> t
            val symmetric_diff :
              t -> t -> (Elt.t, Elt.t) Base__.Either.t Base__.Sequence.t
            val compare_direct : t -> t -> int
            val equal : t -> t -> bool
            val is_subset : t -> of_:t -> bool
            val subset : t -> t -> bool
            val fold_until :
              t ->
              init:'b ->
              f:('b ->
                 Elt.t ->
                 ('b, 'stop)
                 Core_kernel__.Core_set_intf.Set_intf.Continue_or_stop.t) ->
              ('b, 'stop)
              Core_kernel__.Core_set_intf.Set_intf.Finished_or_stopped_early.t
            val fold_right : t -> init:'b -> f:(Elt.t -> 'b -> 'b) -> 'b
            val iter2 :
              t ->
              t ->
              f:([ `Both of Elt.t * Elt.t | `Left of Elt.t | `Right of Elt.t ] ->
                 unit) ->
              unit
            val filter : t -> f:(Elt.t -> bool) -> t
            val partition_tf : t -> f:(Elt.t -> bool) -> t * t
            val elements : t -> Elt.t list
            val min_elt : t -> Elt.t option
            val min_elt_exn : t -> Elt.t
            val max_elt : t -> Elt.t option
            val max_elt_exn : t -> Elt.t
            val choose : t -> Elt.t option
            val choose_exn : t -> Elt.t
            val split : t -> Elt.t -> t * Elt.t option * t
            val group_by : t -> equiv:(Elt.t -> Elt.t -> bool) -> t list
            val find_exn : t -> f:(Elt.t -> bool) -> Elt.t
            val find_index : t -> int -> Elt.t option
            val nth : t -> int -> Elt.t option
            val remove_index : t -> int -> t
            val to_tree : t -> Tree.t
            val to_sequence :
              ?order:[ `Decreasing | `Increasing ] ->
              ?greater_or_equal_to:Elt.t ->
              ?less_or_equal_to:Elt.t -> t -> Elt.t Base__.Sequence.t
            val merge_to_sequence :
              ?order:[ `Decreasing | `Increasing ] ->
              ?greater_or_equal_to:Elt.t ->
              ?less_or_equal_to:Elt.t ->
              t ->
              t ->
              (Elt.t, Elt.t)
              Core_kernel__.Core_set_intf.Set_intf.Merge_to_sequence_element.t
              Base__.Sequence.t
            val to_map :
              t ->
              f:(Elt.t -> 'data) ->
              (Elt.t, 'data, Elt.comparator_witness)
              Core_kernel__.Core_set_intf.Map.t
            val obs :
              Elt.t Core_kernel__.Quickcheck.Observer.t ->
              t Core_kernel__.Quickcheck.Observer.t
            val shrinker :
              Elt.t Core_kernel__.Quickcheck.Shrinker.t ->
              t Core_kernel__.Quickcheck.Shrinker.t
            val empty : t
            val singleton : Elt.t -> t
            val union_list : t list -> t
            val of_list : Elt.t list -> t
            val of_array : Elt.t array -> t
            val of_sorted_array : Elt.t array -> t Base__.Or_error.t
            val of_sorted_array_unchecked : Elt.t array -> t
            val of_increasing_iterator_unchecked :
              len:int -> f:(int -> Elt.t) -> t
            val stable_dedup_list : Elt.t list -> Elt.t list
            val map : ('a, 'b) Base.Set.t -> f:('a -> Elt.t) -> t
            val filter_map :
              ('a, 'b) Base.Set.t -> f:('a -> Elt.t option) -> t
            val of_tree : Tree.t -> t
            val of_hash_set : Elt.t Core_kernel__.Hash_set.t -> t
            val of_hashtbl_keys :
              (Elt.t, 'a) Core_kernel__.Core_hashtbl.t -> t
            val of_map_keys :
              (Elt.t, 'a, Elt.comparator_witness)
              Core_kernel__.Core_set_intf.Map.t -> t
            val gen :
              Elt.t Core_kernel__.Quickcheck.Generator.t ->
              t Core_kernel__.Quickcheck.Generator.t
            module Provide_of_sexp :
              functor
                (Elt : sig val t_of_sexp : Sexplib.Sexp.t -> Elt.t end) ->
                sig val t_of_sexp : Sexplib.Sexp.t -> t end
            module Provide_bin_io :
              functor
                (Elt : sig
                         val bin_t : Elt.t Bin_prot.Type_class.t
                         val bin_read_t : Elt.t Bin_prot.Read.reader
                         val __bin_read_t__ :
                           (Core_kernel__.Import.int -> Elt.t)
                           Bin_prot.Read.reader
                         val bin_reader_t : Elt.t Bin_prot.Type_class.reader
                         val bin_size_t : Elt.t Bin_prot.Size.sizer
                         val bin_write_t : Elt.t Bin_prot.Write.writer
                         val bin_writer_t : Elt.t Bin_prot.Type_class.writer
                         val bin_shape_t : Bin_prot.Shape.t
                       end) ->
                sig
                  val bin_size_t : t Bin_prot.Size.sizer
                  val bin_write_t : t Bin_prot.Write.writer
                  val bin_read_t : t Bin_prot.Read.reader
                  val __bin_read_t__ : (int -> t) Bin_prot.Read.reader
                  val bin_shape_t : Bin_prot.Shape.t
                  val bin_writer_t : t Bin_prot.Type_class.writer
                  val bin_reader_t : t Bin_prot.Type_class.reader
                  val bin_t : t Bin_prot.Type_class.t
                end
            module Provide_hash :
              functor
                (Elt : sig
                         val hash_fold_t :
                           Base__.Hash.state -> Elt.t -> Base__.Hash.state
                       end) ->
                sig
                  val hash_fold_t :
                    Ppx_hash_lib.Std.Hash.state ->
                    t -> Ppx_hash_lib.Std.Hash.state
                  val hash : t -> Ppx_hash_lib.Std.Hash.hash_value
                end
            val t_of_sexp : Base__.Sexplib.Sexp.t -> t
            val sexp_of_t : t -> Base__.Sexplib.Sexp.t
          end
        val get_any_foreign_key_references :
          ?conn:Mysql.dbd -> table_name:string -> (Tset.t, string) result
      end
    val get_fields_for_given_table :
      ?conn:Mysql.dbd ->
      table_name:Core.String.Map.Key.t ->
      (t list Core.String.Map.t, string) Core._result
    val make_regexp : string option -> Pcre.regexp option
    val get_fields_map_for_all_tables :
      regexp_opt:string option ->
      table_list_opt:string option ->
      conn:Mysql.dbd ->
      schema:string ->
      (Core.String.Map.Key.t, t list, Core.String.Map.Key.comparator_witness)
      Core.Map.t
    val construct_sql_query_function :
      table_name:Core.String.t ->
      map:(Core.String.t, t list, 'a) Core.Map.t ->
      host:Core.String.t ->
      user:Core.String.t ->
      password:Core.String.t -> database:Core.String.t -> Core.String.t
    val construct_body :
      table_name:Core.String.t ->
      map:t Core.List.t Core.String.Map.t ->
      ppx_decorators:string Core.Option.t ->
      host:Core.String.t ->
      user:Core.String.t ->
      password:Core.String.t -> database:Core.String.t -> Core.String.t
    val construct_mli :
      table_name:Core.String.t ->
      map:t Core.List.t Core.String.Map.t ->
      ppx_decorators:string Core.Option.t -> Core.String.t
    val write_module :
      outputdir:string -> fname:string -> body:string -> unit
    val copy_utilities : destinationdir:'a -> unit
    val construct_one_sequoia_struct :
      conn:Mysql.dbd ->
      table_name:Core.String.t ->
      map:t Core.List.t Core.String.Map.t -> Core.String.t
  end
