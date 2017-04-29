module Utilities : sig
  val print_n_flush : string -> unit 
  val getcon : ?host:string -> database:string -> password:string -> user:string -> Mysql.dbd
  val getcon_defaults : unit -> Mysql.dbd
  val closecon : Mysql.dbd ->  unit
end 
