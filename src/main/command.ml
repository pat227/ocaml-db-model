module Utilities = Utilities.Utilities
module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
open Core.Std
module Command = struct

  let execute host user password database () =
    let open Core.Std.Result in
    let conn = Utilities.getcon ~host ~user ~password ~database in
    let fields_map = Model.get_fields_map_for_all_tables ~conn () in
    let keys = Map.keys fields_map in 
    let rec helper klist map =
      match klist with
      | [] -> ()
      | h::t ->
	 let body = Model.construct_body ~table_name:h ~map in
	 let mli = Model.construct_mli ~table_name:h ~map in
	 let () = Model.write_module ~fname:(h ^ ".ml") ~body in
	 let () = Model.write_module ~fname:(h ^ ".mli") ~body:mli in
	 let () = Utilities.print_n_flush ("\nWrote ml and mli for table:" ^ h) in
	 helper t map in
    helper keys fields_map;;
	 
    (*
    if is_ok list_result then
      let l = ok_or_failwith list_result in
      let map = Model.map_of_list ~tlist:l in 
      let body = Model.construct_body ~table_name:"scrapings" ~map in 
      let () = Utilities.print_n_flush body in
      let () = Model.write_module ~fname:"test_module.ml" ~body in
      let body = Model.construct_mli ~table_name:"scrapings" ~map in 
      let () = Model.write_module ~fname:"test_module.mli" ~body in ()
    else
      Utilities.print_n_flush "Failed to get fields for table."

*)  
  let main_command =
    let open Core.Std.Command in
    Core.Std.Command.basic
      ~summary:"Connect to a mysql db, get schema"
      ~readme: (fun () -> "README")
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
