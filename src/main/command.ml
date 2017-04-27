module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
open Core.Std
module Command = struct

  let execute () =
    let map = Model.get_fields_for_given_table ~table_name:"nyt" in 
    let body = Model.construct_body ~table_name:nyt ~map in
    Model.print_n_flush body;;
  
  let main_command =
    let open Core.Std.Command in
    Core.Std.Command.basic
      ~summary:"Connect to a mysql db, get schema"
      ~readme: (fun () -> "README")
      Core.Std.Command.Spec.(empty) execute;;   

  let () =
    let open Core.Std.Command in
    run ~version:"0.1" main_command;;
end 
