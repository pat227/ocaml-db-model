module Utilities = Utilities.Utilities
module Table = Table.Table
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Mysql = Mysql
module Model = struct
  type t = {
    col_name : string; 
    table_name : string;
    data_type : string;
    is_nullable : bool;
  } [@@deriving show, fields]

  let get_fields_for_given_table ?conn ~table_name =
    let open Mysql in
    let open Core.Std in 
    (*Only column_type gives us the acceptable values of an enum type if present, unsigned; use the 
      column_comment to input per field directives for ppx extensions...way down the road, such as
      key or default for json ppx extension.*)
    let fields_query = "SELECT column_name, is_nullable, column_comment,
			     column_type, data_type FROM 
			     information_schema.columns 
			     WHERE table_name='" ^ table_name ^ "';" in
    (*			     numeric_scale, column_key, column_default, character_maximum_length, 
			     character_octet_length, numeric_precision, extra*)
    let rec helper accum results nextrow =
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
	     let col_type =
	       String.strip
		 ~drop:Char.is_whitespace
		 (Option.value_exn
		    ~message:"Failed to get column_type."
		    (Mysql.column results
				  ~key:"column_type" ~row:arrayofstring)) in
	     let is_nullable =
	       let is_nullable_yesno =
		 String.strip
		   ~drop:Char.is_whitespace
		   (Option.value_exn
		      ~message:"Failed to get if field is nullable."
		      (Mysql.column results
				    ~key:"is_nullable" ~row:arrayofstring)) in
	       (fun x -> match x with "YES" -> true | _ -> false) is_nullable_yesno in 
	     (*--todo--convert data types and nullables into ml types as strings for use in writing a module*)
	     let type_for_module = Sql_supported_types.one_step ~data_type ~col_type in
	     let new_field_record =
	       Fields.create
		 ~col_name
		 ~table_name
		 ~data_type:type_for_module
		 ~is_nullable
	     in
	     let newmap = Core.Std.String.Map.add_multi accum table_name new_field_record in 
	     helper newmap results (fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in
    let conn = (fun c -> if is_none c then Utilities.getcon_defaults () else Option.value_exn c) conn in 
    let queryresult = exec conn fields_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty ->  Ok Core.Std.String.Map.empty
    | StatusError _ -> 
		     let () = Utilities.print_n_flush ("Query for table names returned nothing.  ... \n") in
		     let () = Utilities.closecon conn in
		     Error "model.ml::get_fields_for_given_table() Error in sql"
    | StatusOK -> let () = Utilities.print_n_flush "\nGot fields for table." in 
		  helper Core.Std.String.Map.empty queryresult (fetch queryresult);;

  let get_fields_map_for_all_tables ~conn ~schema =
    let open Core.Std in
    let open Core.Std.Result in 
    let table_list_result = Table.get_tables ~conn ~schema in
    if is_ok table_list_result then
      let tables = ok_or_failwith table_list_result in
      let rec helper ltables map =
	match ltables with
	| [] -> map
	| h::t ->
	   let fs_result = get_fields_for_given_table ~conn ~table_name:h.Table.table_name in
	   if is_ok fs_result then
	     let newmap = ok_or_failwith fs_result in 
	     helper t newmap
	   else	     
	     helper t map in
      helper tables Core.Std.String.Map.empty
    else
      let () = Utilities.print_n_flush "\nFailed to get list of tables.\n" in
      Core.Std.String.Map.empty;;

  let construct_body ~table_name ~map ~ppx_decorators =
    let open Core.Std in 
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase module_first_char in
    let module_name = String.copy table_name in
    let () = String.set module_name 0 uppercased_first_char in 
    let start_module = "module " ^ module_name ^ " = struct \n" in 
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = String.Map.find_exn map table_name in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush ("\nList of fields found of length:" ^
					(Int.to_string (List.length tfields_list))) in 
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t ->
	 let tbody_new = tbody ^ "\n    " ^ h.col_name ^ " : " ^ h.data_type ^ ";" in
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    let almost_done = start_module ^ start_type_t ^ tbody ^ "\n" ^ end_type_t in
    match ppx_decorators with
    | [] -> almost_done ^ "end"
    | h :: t ->
       let ppx_extensions = String.concat ~sep:"," ppx_decorators in
       almost_done ^ "\n             [@@deriving " ^ ppx_extensions ^ "]\nend";;

  let construct_mli ~table_name ~map ~ppx_decorators =
    let open Core.Std in 
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase module_first_char in
    let module_name = String.copy table_name in
    let () = String.set module_name 0 uppercased_first_char in 
    let start_module = "module " ^ module_name ^ " : sig \n" in 
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = String.Map.find_exn map table_name in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush ("\nList of fields found of length:" ^
					(Int.to_string (List.length tfields_list))) in 
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t ->
	 let tbody_new = tbody ^ "\n    " ^ h.col_name ^ ":" ^ h.data_type ^ ";" in
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    let almost_done = start_module ^ start_type_t ^ tbody ^ "\n" ^ end_type_t in
    match ppx_decorators with
    | [] -> almost_done ^ "end"
    | h :: t ->
       let ppx_extensions = String.concat ~sep:"," ppx_decorators in
       almost_done ^ "\n             [@@deriving " ^ ppx_extensions ^ "]\nend";;
    
  let write_module ~fname ~body = 
    let open Core.Std.Unix in
    let myf sbuf fd = single_write fd ~buf:sbuf in
    try
      let _bytes_written = with_file fname ~mode:[O_RDWR;O_CREAT;O_TRUNC] ~perm:0o644 ~f:(myf body) in ()
    with _ -> Utilities.print_n_flush "\nFailed to write to file.\n"
end 


(*
  let write2file ~len ~buf ~name =
    let open Unix in
    let func fd =
      Core.Std.Unix.write ~pos:0 ~len fd ~buf:(Bigbuffer.contents !buf) in
    Core.Std.Unix.with_file ~perm:0o600 name
			    ~mode:[O_RDWR;O_TRUNC;O_CREAT] ~f:func;;

The type of a database field. Each of these represents one or more MySQL data types.
type dbty =
| IntTy
| FloatTy
| StringTy
| SetTy
| EnumTy
| DateTimeTy
| DateTy
| TimeTy
| YearTy
| TimeStampTy
| UnknownTy
| Int64Ty
| BlobTy
| DecimalTy
*)		 
