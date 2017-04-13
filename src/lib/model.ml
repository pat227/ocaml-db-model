module Table = Table.Table
module Mysql = Mysql
open Mysql
open Core.Std
       
module Model = struct
  (*type of our fields -- almost exactly like that found in ocaml-mysql*)
  type t = { col_name : string; (* Name of the field *)
             table : Table.t;
	     is_nullable : bool;
             def : string option; (* Default value of the field *)
             data_type : Mysql.dbty; (*tbd*)
             max_length : int; (* Maximum width of field *)
             flags : int; (* Flags set *)
             decimals : int (* Number of decimals for numeric fields *)
           } [@@ppx_deriving fields]

	     
  let oc = Out_channel.stdout;;    
  let print_n_flush s =
    Out_channel.output_string oc s;
    Out_channel.flush oc;;
  (*Module name must be capital first letter*)
  let module_first_line ~name = "module " ^ name ^ " = struct\n";;
  let module_last_line = "end";;

  let getcon ?(host="127.0.0.1") ~database ~password ~user () =
    quick_connect
      ~host ~database ~password ~user ();;
  let closecon c = disconnect c;;
   
  let get_tables () =
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
	       Table.Fields.create
		   ~table_name ~table_type ~engine 
	     in
	     helper (table_t::accum) results (fetch results)
	    )
	  with err ->
	    let () = print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in 
    let queryresult = exec conn table_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty | StatusError _ -> 
		     let () = print_n_flush ("Query for table names returned nothing.  ... \n") in
		     let () = closecon conn in Ok(None)
    | StatusOK -> let () = closecon conn in
		  let () = print_n_flush "\nGot table names..." in 
		  helper queryresult (fetch queryresult);;

    
  let get_fields_for_given_table ~table_name =
    let fields_query_base = "SELECT column_name, data_type, is_nullable, 
			     column_default FROM information_schema.columns 
			     WHERE table_name='" in
    let rec table_helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let col_name =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get col name."
		    (Mysql.column results
				  ~key:"column_name" ~row:arrayofstring)) in
	     let data_type =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get data_type."
		    (Mysql.column results
				  ~key:"data_type" ~row:arrayofstring)) in
	     let is_nullable =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get if field is nullable."
		    (Mysql.column results
				  ~key:"is_nullable" ~row:arrayofstring)) in
	     let def =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get field default value."
		    (Mysql.column results
				  ~key:"def" ~row:arrayofstring)) in
	     let new_table_t =
	       Table.Fields.create
		 ~table_name ~table_type ~engine 
	     in
	     helper (table_t::accum) results (fetch results)
	    )
	  with err ->
	    let () = print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in 
    let queryresult = exec conn table_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty | StatusError _ -> 
		     let () = print_n_flush ("Query for table names returned nothing.  ... \n") in
		     let () = closecon conn in Ok(None)
    | StatusOK -> let () = closecon conn in
		  let () = print_n_flush "\nGot table names..." in 
		  helper queryresult (fetch queryresult);;


  let write_module ~fname ~body = 
    let open Core.Std.Unix in
    let myf sbuf fd = single_write fd ~buf:sbuf in
    try
      let _ = with_file f ~mode:[O_RDWR;O_CREAT;O_TRUNC] ~perm:0o644 ~f:(myf body) in ();
    with _ -> let () = print_n_flush "Failed to write to file.";;
end 
