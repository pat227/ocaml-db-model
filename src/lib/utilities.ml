module Mysql = Mysql
open Core.Std
module Utilities = struct

  let oc = Core.Std.Out_channel.stdout;;    
  let print_n_flush s =
    let open Core.Std in 
    Out_channel.output_string oc s;
    Out_channel.flush oc;;

  let getcon ?(host="127.0.0.1") ~database ~password ~user =
    let open Mysql in 
    quick_connect
      ~host ~database ~password ~user ();;
    
  let getcon_defaults () =
    getcon ~host:"127.0.0.1" ~database:"nyt" ~password:"root" ~user:"root";;
    
  let closecon c = Mysql.disconnect c;;

end 
