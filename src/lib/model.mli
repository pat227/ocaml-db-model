module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Model : sig
  type t = {
    col_name : string; 
    table_name : string;
    (*a type, such as Uint8.t, but as a string that we can use in directly in output.*)
    data_type : string;
    (*In our ml, if true, then the type is optional.*)
    is_nullable : bool;
  } [@@ppx_deriving show]
  val print_n_flish : string -> unit
  val getcon : host:string -> database:string -> password:string -> user:string -> unit -> Mysql.dbd
  val closecon : Mysql.dbd -> unit
  (*Returns a multimap where key is table name, values are tuples of field names and types*)
  val get_tables : unit -> string list
  val get_fields_for_given_table : table_name: string -> t list 
  val map_of_list : t list -> t list Core.Std.String.Map.t
  val construct_body : table_name:string -> map:t list Core.Std.String.Map.t -> string
  (*With a fully constructed body, save a module to a file*)
  val write_module : fname:string -> body:string -> unit
  (*For each key in the multi-map, construct the body of an Ocaml module
  val construct_modules : tables_and_fields:string * t list Core.Std.String.Map.t -> string list*)
end 
