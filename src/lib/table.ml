module Utilities = Utilities.Utilities
		     
module Table = struct
  type t = {
    table_name : string;
    table_type: string;
    engine : string;
  } [@@deriving fields]
   
  let get_tables () =
    let open Mysql in
    let open Core.Std in 
    let table_query = "SELECT table_name, table_type, engine FROM 
		       information_schema.tables" in
    let rec table_helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let table_name =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get table name."
		    (Mysql.column results
				  ~key:"table_name" ~row:arrayofstring)) in
	     let table_type =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get table_type."
		    (Mysql.column results
				  ~key:"table_type" ~row:arrayofstring)) in
	     let engine =
	       String.strip
		 ~drop:Char.is_whitespace
		   (Option.value_exn
		      ~message:"Failed to get table engine."
		      (Mysql.column results
				    ~key:"engine" ~row:arrayofstring)) in
	     let new_table_t =
	       Fields.create ~table_name ~table_type ~engine in
	     table_helper (new_table_t::accum) results (fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "table.ml::get_tables() line 46"
      ) in
    let conn = Utilities.getcon_defaults () in 
    let queryresult = exec conn table_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty ->
       let () = Utilities.print_n_flush ("Query for table names returned nothing  ... \n") in
       let () = Utilities.closecon conn in
       Ok []
    | StatusError _ -> 
       let () = Utilities.print_n_flush ("Error in query for table  ... \n") in
       let () = Utilities.closecon conn in
       Error "table.ml::get_tables() SQL error"
    | StatusOK -> let () = Utilities.closecon conn in
		  let () = Utilities.print_n_flush "\nGot table names..." in 
		  table_helper [] queryresult (fetch queryresult);;
end
