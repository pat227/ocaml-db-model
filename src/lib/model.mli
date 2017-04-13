module Table = Table.Table
module Model : sig
  type t = { name : string; (* Name of the field *)
             table : Table.t; (*Parent table to which field belongs*)
             def : string option; (* Default value of the field *)
             field_type : Mysql.dbty; (*tbd*)
             max_length : int; (* Maximum width of field *)
             flags : int; (* Flags set *)
             decimals : int (* Number of decimals for numeric fields *)
           }
  (*Returns a multimap where key is table name, values are tuples of field names and types*)
  val get_tables : unit -> Table.t list
  val get_fields_for_given_table : table_name: string -> t list Core.Std.String.Map.t
  (*With a fully constructed body, save a module to a file*)
  val write_module : fname:string -> body\:string -> unit
  (*For each key in the multi-map, construct the body of an Ocaml module*)
  val construct_modules : tables_and_fields:string * t list Core.Std.String.Map.t -> string list
											    
end 
