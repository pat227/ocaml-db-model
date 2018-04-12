module Credentials = Credentials2copy.Credentials
module Utilities = Utilities2copy.Utilities
module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Command = struct

  let execute regexp_opt table_list_opt ppxlist_opt
	      module_names where2find_modules
	      sequoia host user password database () =
    let open Core in 
    let open Core.Result in
    (*==todo==refactor the below into a functon in model.ml*)
    try
      let credentials = Credentials.of_username_pw ~username:user ~pw:password ~db:database in
      let conn = Utilities.getcon ~host ~user ~password ~database in
      let ppx_decorators = ppxlist_opt in 
      let () = Model.construct_db_credentials ~credentials ~destinationdir:"src/lib/" in 
      let fields_map =
	Model.get_fields_map_for_all_tables
	  ~regexp_opt ~table_list_opt ~conn ~schema:database in
      let keys = Map.keys fields_map in 
      let rec helper klist map =
	match klist with
	| [] -> let () = Model.copy_utilities ~destinationdir:"src/lib/" in
		Utilities.closecon conn
	| h::t ->
	   let title_cased_h = String.capitalize h in 
	   let body =
	     Model.construct_body
	       ~table_name:h ~map ~ppx_decorators ~host ~user ~password ~database
	       ~module_names ~where2find_modules in
	   let mli = Model.construct_mli ~table_name:h ~map ~ppx_decorators ~module_names ~where2find_modules in
	   let () = if sequoia then
		      let seq_module = Model.construct_one_sequoia_struct
					 ~conn ~table_name:h ~map in
		      Model.write_appending_module
			~outputdir:"src/tables/" ~fname:(".ml") ~body:seq_module
		    else
		      () 
	   in
	   let mlfile = String.concat [h;".ml"] in
	   let mlifile = String.concat [h;".mli"] in 
	   let () = Model.write_module
		      ~outputdir:"src/tables/" ~fname:mlfile ~body in
	   let () = Model.write_module
		      ~outputdir:"src/tables/" ~fname:mlifile ~body:mli in
	   let () = Model.write_appending_module
		      ~outputdir:"src/tables/" ~fname:"tables.ml"
		      ~body:(String.concat ["module ";title_cased_h;"=";title_cased_h;".";title_cased_h;"\n"]) in
	   let () = Utilities.print_n_flush ("\nWrote ml and mli for table:" ^ h) in
	   helper t map in
      helper keys fields_map
      (*--copy the utilities.ml(i) files into the project; do not depend on this 
          project for building, and allow user to tweak the utilities file.--*)
    with
    | Failure s -> Utilities.print_n_flush s
(*
  let main_command =
    let open Core.Command in
    Core.Command.basic
      ~summary:"Connect to a mysql db, get schema, write modules and (primitive) \
		types out of thin air with ppx extensions and a utility module  \
		for parsing mysql strings into present directory. Use basic \
		regexp, or a list, to filter table names."
      ~readme: (fun () -> "README")
      (*add option for each ppx extension? Or just default all of them?*)
      Core.Command.Spec.(empty
			 +> flag "-table-regexp" (optional string)
				 ~doc:"Only model those tables that match a regexp."
			 +> flag "-table-list" (optional string)
				 ~doc:"Csv-with-no-spaces table-name list."
			 +> flag "-ppx-extensions" (optional string) 
				 ~doc:"Comma seperated list of ppx extensions; \
				       currently support fields, show, sexp, \
				       ord, eq, yojson, which are also defaults."
			 +> flag "-module-field-types" (optional string)
				 ~doc:"Force any db fields whose name matches any in the \
				       csv-with-no-spaces list to not be a primitive, but \
				       instead a type defined in a module of the same name.\ 
				       A directory must be provided where to find the source \
				       ml files for each in another (the next) arg. The name \
				       should not be sans suffix, ie, without \".ml\" or \".mli\""
			 (*==todo==make this one required if the prior is supplied*)
			 +> flag "-path-to-modules"
				 ~doc:"Absolute path to the directory within the project that \
				       contains any modules (mli files) specified by module-field-types arg."
			 +> flag "-sequoia" (no_arg)
				 ~doc:"Support for sequoia: optionally output \
				       modules suitable for use with the Sequoia\
				       library."
			 +> flag "-host" (required string) ~doc:"ipv4 of the db host."
			 +> flag "-user" (required string) ~doc:"db user."
			 +> flag "-password" (required string) ~doc:"db password."
			 +> flag "-db" (required string) ~doc:"db name."
			) execute;;
 *)

  let main_command_nocore =
    let usagemsg = "Connect to a mysql db, get schema, write modules and (primitive) \
		    types out of thin air with ppx extensions and a utility module  \
		    for parsing mysql strings into present directory. Use basic \
		    regexp, or a list, to filter table names." in
    let execute_namedargs ~regexp_opt ~table_list_opt ~ppxlist_opt
			  ~module_names ~where2find_modules
			  ~sequoia ~host ~user ~password ~database () =
      match host, user, password, database with
      | None, _, _, _ 
      | _, None, _, _ 
      | _, _, None, _, _ 
      | _, _, _, None -> Utilities.print_n_flush "Host, user, password, and database name are required args."
      | Some h, Some u, Some pwd, Some db ->
	 execute regexp_opt table_list_opt ppxlist_opt module_names where2fine_modules sequoia h u pwd db () in
    let command_ref = ref execute_namedargs in 
    let speclist = [("-host", Arg.String (fun s -> command_ref := !command_ref ~host:s) ,"ipv4 of the db host.");
		    ("-user",Arg.String (fun s -> command_ref := !command_ref ~user:s),"db user.");
		    ("-password",Arg.String (fun s -> command_ref := !command_ref ~password:s),"db password.");
		    ("-db",Arg.String (fun s -> command_ref := !command_ref ~database:s),"db name.");
		    ("table-regexp",,"Only model those tables that match a regexp.");
		    ("table-list",,"Csv-with-no-spaces table-name list.");
		    ("ppx-extensions",,"Comma seperated list of ppx extensions; currently support fields, show, sexp, ord, eq, yojson, which are also defaults.");
		    ("module-field-types",,"Force any db fields whose name matches any in the csv-with-no-spaces list to not be a primitive, but instead a type defined in a module of the same name. A directory must be provided where to find the source ml files for each in another (the next) arg. The name should not be sans suffix, ie, without \".ml\" or \".mli\"");
		    ("path-to-modules",,"Absolute path to the directory within the project that contains any modules (mli files) specified by module-field-types arg.");
		    ("-sequoia",,"Support for sequoia: optionally output modules suitable for use with the Sequoia library.")
		   ] in
    !command_ref ();;
    
  let () =
    let open Core.Command in
    run ~version:"0.1" main_command;;
end 
