module Pcre = Pcre
module Credentials = Credentials2copy.Credentials
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Types_we_emit = Types_we_emit.Types_we_emit
module Model : sig
  type t = {
    col_name : string; 
    table_name : string;
    (*a type, such as Uint8.t, but as a string that we can use in directly in output.*)
    data_type : Types_we_emit.t;
    (*In our ml, if true, then the type is optional.*)
    is_nullable : bool;
    is_primary_key: bool;
  } [@@deriving show, fields]
  module Sequoia_support : sig
    type t = {
      col : string;
      table : string;
      referenced_table : string;
      referenced_field : string;
    } [@@deriving eq, ord, show, fields, sexp]
    
    (*module TSet : sig
      include Core.Comparable.S with type t := t
    end*)
  end
			     
  val get_fields_map_for_all_tables :
    regexp_opt:string option -> table_list_opt:string option ->
    conn:Mysql.dbd -> schema:string -> t list Core.String.Map.t 
  val get_fields_for_given_table :
    conn:Mysql.dbd ->
    table_name:Core.String.Map.Key.t ->
    (t list Core.String.Map.t, string) Core.Result.t 
  val construct_body : table_name:string -> map:t list Core.String.Map.t ->
		       ppx_decorators:string option -> host:string -> user:string ->
		       password:string -> database:string ->
		       module_names:string list -> where2find_modules:string 
		       -> string
  val construct_mli : table_name:string -> map:t list Core.String.Map.t ->
		      ppx_decorators:string option -> module_names:string list ->
		      where2find_modules:string -> string
  val construct_db_credentials : credentials:Credentials.t -> destinationdir:string -> unit
  val write_module : outputdir:string -> fname:string -> body:string -> unit
  val write_appending_module : outputdir:string -> fname:string -> body:string -> unit
  (*For each key in the multi-map, construct the body of an Ocaml module
  val construct_modules : tables_and_fields:string * t list Core.String.Map.t -> string list*)
  val copy_utilities : destinationdir:string -> unit
  val construct_one_sequoia_struct : conn:Mysql.dbd -> table_name:string -> map:t list Core.String.Map.t -> string
end 
