module Credentials : sig
  type t
  val of_username_pw : username:string -> pw:string -> db:string -> t
  val getpw : t -> string
  val getuname : t -> string
  val getdb : t -> string
end
