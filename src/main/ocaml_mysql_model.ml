module Utilities = Ocaml_db_model.Utilities
module Model = Ocaml_db_model.Model
module Sql_supported_types = Ocaml_db_model.Sql_supported_types
module Command = struct

  let execute regexp_opt table_list_opt ppx_list_opt fields2ignore host user password database destination () =
    try
      let conn = Utilities.getcon ~host ~user ~password ~database in
      let fields_map =
	Model.get_fields_map_for_all_tables
	  ~regexp_opt ~table_list_opt ~conn ~schema:database in
      let keys = Core.Map.keys fields_map in 
      let rec helper klist map =
	match klist with
	| [] -> ()
	| h::t ->
	   let ppx_decorators =
	     match ppx_list_opt with
	     (*default ppx extensions--not always are they all desired or useful or supported*)
	     | None -> ["fields";"eq";"make";"ord";"sexp";"show";"yojson"]
	     | Some ppx_list ->
		(*===TODO===check the list for sanity? Validity too: that each is supported? 
                  Else user could specify non-existent or not yet installed ppx rewriters?*)
		ppx_list in
	   let body = Model.construct_body ~table_name:h ~map ~ppx_decorators ~fields2ignore ~host ~user ~password ~database in
	   let mli = Model.construct_mli ~table_name:h ~map ~ppx_decorators ~fields2ignore in
	   let () = Model.write_module ~outputdir:destination ~fname:(Core.String.concat [h;".ml"]) ~body:(Bytes.of_string body) in
	   let () = Model.write_module ~outputdir:destination ~fname:(h ^ ".mli") ~body:(Bytes.of_string mli) in
           let title_cased_h = String.capitalize_ascii h in
	   let () = Model.write_appending_module
		      ~outputdir:destination ~fname:"tables.ml"
		      ~body:(Core.String.concat ["module ";title_cased_h;"=";title_cased_h;".";title_cased_h;"\n"]) in
	   let () = Utilities.print_n_flush ("\nWrote ml and mli for table:" ^ h) in
	   helper t map in
      helper keys fields_map
      
    with
    | Failure s -> Utilities.print_n_flush s

  let main_command =
    let usage_msg = "Connect to a mysql db, get schema, write modules and \
		     (mostly primitive) types out of thin air with ppx extensions and a \
		     utility module for parsing mysql strings. Output modules will reside \
                     within whatever destination directory you specify. \
		     Use basic regexp, or a list, to filter table names." in 
    let host = ref "" in
    let user = ref "" in
    let password = ref "" in
    let database = ref "" in
    let destination = ref "" in 
    let table_regexp = ref "" in
    let table_list = ref "" in
    let ppx_list = ref "" in
    let fields2ignore = ref "" in 
    let options = [("-host",Arg.Set_string host,"Required IP of db host");
		   ("-user",Arg.Set_string user,"Required DB username");
		   ("-password",Arg.Set_string password,"Required DB user password");
		   ("-db",Arg.Set_string database,"Required DB name");
		   ("-destination", Arg.Set_string destination, "Required directory into which generated Ocaml will be placed.");
		   ("-table-regexp",Arg.Set_string table_regexp,
		    "Optional Regular expression to be used to select only some \
		     tables; mutually exclusive of a provided list of tables, and \
		     without either option all tables are selected.");
		   ("-table-list", Arg.Set_string table_list,
		    "Optional explicit list of tables; this option is mutually \
		     exclusive of using a regexp, and without either option all \
		     tables are selected.");
		   ("-ppx-decorators", Arg.Set_string ppx_list,
		    "Optional list of ppx extensions to append to each type definition \
		     per module; use only commas or only semicolons.");
		     (*Added this arg b/c foresee need to exclude non-optional (not nullable) 
                       with default timestamp fields that might be present in tables that 
                       might not be present or relevant in input data, etc.*)
		   ("-fields2ignore", Arg.Set_string fields2ignore,
		    "Optional list field names to ignore (ie, not include in the \
		     generated modules) across all tables; use only commas or semicolons.")
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
    let ppx_list_opt =
      match String.length (!ppx_list) with
      | 0   (*unaware at present of any single letter ppx extensions, so a list of 
              one 2 letter extension is minimum we can expect.*)
      | 1 -> None 
      | _ -> (*this could be have more robust checking for sanity*)
	 if (Core.String.contains !ppx_list ',') then 
	   Some (Core.String.split !ppx_list ~on:',')
	 else if (Core.String.contains !ppx_list ';') then
	   Some (Core.String.split !ppx_list ~on:';')
	 else 
	   Some [!ppx_list] in
    let fields2ignore_opt =
      match String.length (!fields2ignore) with
      | 0   (*unaware at present of any single letter ppx extensions, so a list of 
              one 2 letter extension is minimum we can expect.*)
      | 1 -> None 
      | _ -> (*this could be have more robust checking for sanity*)
	 if (Core.String.contains !fields2ignore ',') then 
	   Some (Core.String.split !fields2ignore ~on:',')
	 else if (Core.String.contains !fields2ignore ';') then
	   Some (Core.String.split !fields2ignore ~on:';')
	 else 
	   Some [!fields2ignore] in
    execute regexp_opt table_list_opt ppx_list_opt fields2ignore_opt !host !user !password !database !destination ()
end
