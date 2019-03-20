module Utilities = Ocaml_db_model.Utilities
module Model = Ocaml_db_model.Model
module Sql_supported_types = Ocaml_db_model.Sql_supported_types
module Command = struct

  let execute regexp_opt table_list_opt host user password database () =
    let open Core in 
    let open Core.Result in
    try
      let conn = Utilities.getcon ~host ~user ~password ~database in
      let fields_map =
	Model.get_fields_map_for_all_tables
	  ~regexp_opt ~table_list_opt ~conn ~schema:database in
      let keys = Map.keys fields_map in 
      let rec helper klist map =
	match klist with
	| [] -> ()
	| h::t ->
	   let ppx_decorators = ["fields";"eq";"make";"ord";"sexp";"show";"yojson";"xml"] in 
	   let body = Model.construct_body ~table_name:h ~map ~ppx_decorators ~host ~user ~password ~database in
	   let mli = Model.construct_mli ~table_name:h ~map ~ppx_decorators in
	   let () = Model.write_module ~outputdir:"src/tables/" ~fname:(String.concat [h;".ml"]) ~body:(Bytes.of_string body) in
	   let () = Model.write_module ~outputdir:"src/tables/" ~fname:(h ^ ".mli") ~body:(Bytes.of_string mli) in
	   let () = Utilities.print_n_flush ("\nWrote ml and mli for table:" ^ h) in
	   helper t map in
      helper keys fields_map
      (*--copy the utilities.ml(i) files into the project; do not depend on this 
          project for building, and allow user to tweak the utilities file.--*)
      
    with
    | Failure s -> Utilities.print_n_flush s

  (*===TODO===switch to using the non-core command parsing. Core's command parsing after 
    this went off the rails.*)
  let main_command =
    let usage_msg = "Connect to a mysql db, get schema, write modules and \
		     (mostly primitive) types out of thin air with ppx extensions and a \
		     utility module for parsing mysql strings. Output modules will reside \
                     within src/tables relative to root of project. \
		     Use basic regexp, or a list, to filter table names." in 
    let host = ref "" in
    let user = ref "" in
    let password = ref "" in
    let database = ref "" in
    let table_regexp = ref "" in
    let table_list = ref "" in
    let options = [("-host",Arg.Set_string host,"Required IP of db host");
		   ("-user",Arg.Set_string user,"Required DB username");
		   ("-password",Arg.Set_string password,"Required DB user password");
		   ("-db",Arg.Set_string database,"Required DB name");
		   ("-table-regexp",Arg.Set_string table_regexp,
		    "Optional Regular expression to be used to select only some \
		     tables; mutually exclusive of a provided list of tables, and \
		     without either option all tables are selected.");
		   ("-table-list", Arg.Set_string table_list,
		    "Optional explicit list of tables; this option is mutually \
		     exclusive of using a regexp, and without either option all \
		     tables are selected.")
		  ] in 
    let () = Arg.parse options (fun _x -> ()) usage_msg in
    let regexp_opt =
      match String.length (!table_regexp) with
      | 0 -> None
      | _ -> Some !table_regexp in
    let table_list_opt =
      match String.length (!table_list) with
      | 0 -> None
      | _ -> Some !table_list in 
    execute regexp_opt table_list_opt !host !user !password !database ()
end
      
