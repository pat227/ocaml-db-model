module Utilities = Utilities.Utilities
module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp
module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp
module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp
module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp
open Sexplib.Std
module Scrapings = struct
  type t = {
    id : Core.Std.Int64.t;
    url : string;
    thetext : string option;
    ts : Core.Std.Time.t;
    created : Core.Std.Time.t;
  } [@@deriving fields,show,sexp,eq,ord]

  let tablename="scrapings" 

  let get_tablename () = tablename;;

  let get_sql_query () = 
    let open Core.Std in
    let fs = Fields.names in 
    let fs_csv = String.concat ~sep:"," fs in 
    String.concat ["SELECT ";fs_csv;"FROM ";tablename;" WHERE TRUE;"];;

  let get_from_db ~query =
    let open Mysql in 
    let open Core.Std.Result in 
    let open Core.Std in 
    let conn = Utilities.getcon ~host:"127.0.0.1" ~user:"root"
				~password:"root" ~database:"nyt" in 

    let rec helper accum results nextrow = 
      (match nextrow with 
       | None -> Ok accum 
       | Some arrayofstring ->
          try 
            let id = Utilities.parse_int64_field_exn ~fieldname:"id" ~results ~arrayofstring in 
            let url = Utilities.extract_field_as_string_exn ~fieldname:"url" ~results ~arrayofstring in 
            let thetext = Utilities.extract_optional_field ~fieldname:"thetext" ~results ~arrayofstring in 
            let ts = Utilities.parse_time_field_exn ~fieldname:"ts" ~results ~arrayofstring in 
            let created = Utilities.parse_time_field_exn ~fieldname:"created" ~results ~arrayofstring in 
            let new_t = Fields.create ~id~url~thetext~ts~created in 
            helper (new_t :: accum) results (fetch results) 
          with
          | err ->
             let () = Utilities.print_n_flush ("\nError: " ^ (Exn.to_string err) ^ "Skipping a record...") in 
             helper accum results (fetch results)
      ) in
    let queryresult = exec conn query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty ->  Ok [] 
    | StatusError _ -> 
       let () = Utilities.print_n_flush ("Error during query of table scrapings...") in
       let () = Utilities.closecon conn in
       Error "get_from_db() Error in sql"
    | StatusOK -> 
       let () = Utilities.print_n_flush "Query successful from scrapings table." in 
       helper [] queryresult (fetch queryresult);;

end
