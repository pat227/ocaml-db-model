module Model = Model.Model
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Utilities = Utilities.Utilities
open Core.Std
module Command = struct

  let execute () =
    
  
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
