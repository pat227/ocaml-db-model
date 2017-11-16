module Scrapings : sig 
  type t = {
    id : Core.Std.Int64.t;
    url : string;
    thetext : string option;
    ts : Core.Std.Time.t;
    created : Core.Std.Time.t;
  } [@@deriving fields,show,sexp,eq,ord]

  val get_tablename : unit -> string
  val get_sql_query : unit -> string
  val get_from_db : query:string -> (t list, string) Core.Std.Result.t
end