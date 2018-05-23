module Utilities = Utilities2copy.Utilities
		     
module Table = struct
  type t = {
    table_name : string;
    table_type: string;
    engine : string;
  } [@@deriving fields]
   
  let get_tables ~conn ~schema =
    (* Cannot open mysql and use pervasives result type (Ok / Error)
     let open Mysql in*)
    let table_query ~schema =
      "SELECT table_name, table_schema, table_type, engine FROM 
       information_schema.tables WHERE table_schema='" ^ schema ^ "';" in
    let rec table_helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let table_name =
	       String.map
		 (fun c -> if (Char.code c < 33 || Char.code c > 126) then '_' else c)
		 (Utilities.extract_field_as_string_exn ~fieldname:"table_name" ~results ~arrayofstring) in
	     let table_type =
	       String.map
		 (fun c -> if (Char.code c < 33 || Char.code c > 126) then '_' else c)
		 (Utilities.extract_field_as_string_exn ~fieldname:"table_type" ~results ~arrayofstring) in
	     let engine =
	       String.map
		 (fun c -> if (Char.code c < 33 || Char.code c > 126) then '_' else c)
		 (Utilities.extract_field_as_string_exn ~fieldname:"engine" ~results ~arrayofstring) in
	     let new_table_t =
	       Fields.create ~table_name ~table_type ~engine in
	     table_helper (new_table_t::accum) results (Mysql.fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError getting tables from db.") in 
	    Error "table.ml::get_tables() line 49"
      ) in
    (*let conn = (fun c -> if is_none c then Utilities.getcon else Option.value_exn c) conn in *)
    let queryresult = Mysql.exec conn (table_query ~schema) in
    let isSuccess = Mysql.status conn in
    match isSuccess with
    | Mysql.StatusEmpty ->
       let () = Utilities.print_n_flush ("Query for table names returned nothing  ... \n") in
       Ok []
    | Mysql.StatusError _ -> 
       let () = Utilities.print_n_flush ("Error in query for table  ... \n") in
       Error "table.ml::get_tables() SQL error"
    | Mysql.StatusOK ->
       let () = Utilities.print_n_flush "\nGot table names..." in 
       table_helper [] queryresult (Mysql.fetch queryresult);;
end
