module Utilities = Utilities.Utilities
module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
open Core.Std
module Command = struct

  let execute host user password database () =
    let open Core.Std.Result in
    let conn = Utilities.getcon ~host ~user ~password ~database in
    let fields_map = Model.get_fields_map_for_all_tables ~conn ~schema:database in
    let keys = Map.keys fields_map in 
    let rec helper klist map =
      match klist with
      | [] -> ()
      | h::t ->
	 let ppx_decorators = ["fields";"show";"sexp";"eq";"ord"] in 
	 let body = Model.construct_body ~table_name:h ~map ~ppx_decorators in
	 let mli = Model.construct_mli ~table_name:h ~map ~ppx_decorators in
	 let () = Model.write_module ~fname:(h ^ ".ml") ~body in
	 let () = Model.write_module ~fname:(h ^ ".mli") ~body:mli in
	 let () = Utilities.print_n_flush ("\nWrote ml and mli for table:" ^ h) in
	 helper t map in
    helper keys fields_map;;
	 

  let main_command =
    let open Core.Std.Command in
    Core.Std.Command.basic
      ~summary:"Connect to a mysql db, get schema"
      ~readme: (fun () -> "README")
      (*===TODO===add option for each ppx extension*)
      Core.Std.Command.Spec.(empty
			     +> flag "-host" (required string) ~doc:"ip of the db host."
			     +> flag "-user" (required string) ~doc:"db user."
			     +> flag "-password" (required string) ~doc:"db password."
			     +> flag "-db" (required string) ~doc:"db name."
			    ) execute;;

  let () =
    let open Core.Std.Command in
    run ~version:"0.1" main_command;;
end 
