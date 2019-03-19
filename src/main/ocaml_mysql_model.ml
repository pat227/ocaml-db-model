module Utilities = Utilities.Utilities
module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
open Core
module Command = struct

  let execute regexp_opt table_list_opt host user password database () =
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
	   let () = Model.write_module ~outputdir:"src/tables/" ~fname:(h ^ ".ml") ~body in
	   let () = Model.write_module ~outputdir:"src/tables/" ~fname:(h ^ ".mli") ~body:mli in
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
    let open Core.Command in
    Core.Command.basic
      ~summary:"Connect to a mysql db, get schema, write modules and (primitive) types \
		out of thin air with ppx extensions and a utility module for parsing \
		mysql strings into present directory. Use basic regexp, or a list, to filter table names."
      ~readme: (fun () -> "README")
      (*add option for each ppx extension? Or just default all of them?*)
      Core.Command.Spec.(empty
			     +> flag "-table_regexp" (optional string)
				     ~doc:"Only model those tables that match a regexp."
			     +> flag "-table_list" (optional string)
				     ~doc:"Csv-with-no-spaces table-name list"
			     +> flag "-host" (required string) ~doc:"ip of the db host."
			     +> flag "-user" (required string) ~doc:"db user."
			     +> flag "-password" (required string) ~doc:"db password."
			     +> flag "-db" (required string) ~doc:"db name."
			    ) execute;;

  let () =
    let open Core.Command in
    run ~version:"0.1" main_command;;
end 
