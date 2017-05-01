module Utilities = Utilities.Utilities
module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
open Core.Std
module Command = struct

  let execute () =
    let open Core.Std.Result in 
    let list_result = Model.get_fields_for_given_table ~table_name:"nyt" in
    if is_ok list_result then
      let l = ok_or_failwith list_result in
      let map = Model.map_of_list ~tlist:l in 
      let body = Model.construct_body ~table_name:"nyt" ~map in 
      Utilities.print_n_flush body
    else
      Utilities.print_n_flush "Failed to get fields for table."
  
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
