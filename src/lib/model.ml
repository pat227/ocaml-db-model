module Utilities = Utilities.Utilities
module Table = Table.Table
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Types_we_emit = Types_we_emit.Types_we_emit
module Mysql = Mysql
module Model = struct
  type t = {
    col_name : string; 
    table_name : string;
    data_type : Types_we_emit.t;
    is_nullable : bool;
    is_primary_key : bool;
  } [@@deriving show, fields]

  let get_fields_for_given_table ?conn ~table_name =
    let open Mysql in
    let open Core.Std in 
    (*Only column_type gives us the acceptable values of an enum type if present, unsigned; use the 
      column_comment to input per field directives for ppx extensions...way down the road, such as
      key or default for json ppx extension. For comapre ppx extension, set all fields to return zero
      EXCEPT for the primary key of table. This is also useful for Core Comparable interface.*)
    let fields_query = "SELECT column_name, is_nullable, column_comment,
			     column_type, data_type, column_key, extra, column_comment FROM 
			     information_schema.columns 
			     WHERE table_name='" ^ table_name ^ "';" in
    (*			     numeric_scale, column_default, character_maximum_length, 
			     character_octet_length, numeric_precision,*)
    let rec helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let col_name =
	       Utilities.extract_field_as_string ~fieldname:"column_name" ~results ~arrayofstring in 
	     let data_type =
	       Utilities.extract_field_as_string ~fieldname:"data_type" ~results ~arrayofstring in 
	     let col_type =
	       Utilities.extract_field_as_string ~fieldname:"column_type" ~results ~arrayofstring in 
	     let is_nullable =
	       Utilities.parse_mysql_bool_field  ~fieldname:"is_nullable" ~results ~arrayofstring in 
	     let is_primary_key =
	       let is_pri = Utilities.extract_field_as_string ~fieldname:"column_key" ~results ~arrayofstring in 
	       (fun x -> match x with "pri" -> true | _ -> false) is_pri in
	     (*--todo--convert data types and nullables into ml types as strings for use in writing a module*)
	     let type_for_module = Sql_supported_types.one_step ~data_type ~col_type in
	     let new_field_record =
	       Fields.create
		 ~col_name
		 ~table_name
		 ~data_type:type_for_module
		 ~is_nullable
		 ~is_primary_key in
	     let newmap = String.Map.add_multi accum table_name new_field_record in 
	     helper newmap results (fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in
    let conn = (fun c -> if is_none c then
			   Utilities.getcon_defaults ()
			 else
			   Option.value_exn c) conn in 
    let queryresult = exec conn fields_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty ->  Ok String.Map.empty
    | StatusError _ -> 
       let () = Utilities.print_n_flush ("Query for table names returned nothing.  ... \n") in
       let () = Utilities.closecon conn in
       Error "model.ml::get_fields_for_given_table() Error in sql"
    | StatusOK -> let () = Utilities.print_n_flush "\nGot fields for table." in 
		  helper String.Map.empty queryresult (fetch queryresult);;

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
      helper tables String.Map.empty
    else
      let () = Utilities.print_n_flush "\nFailed to get list of tables.\n" in
      String.Map.empty;;
    
  (**Construct an otherwise tedious function that creates instances of type t from
     a query; for each field in struct, get the string option from the string option array
     provided by Mysql under the same name, parse it into it's correct type using the
     correct conversion function, and then use Fields.create to create a new record,
     add it to an accumulator, and finally return that accumulator after we have 
     exhausted all the records returned by the query.*)
  let construct_sql_query_function ~table_name ~map =
    let preamble =
      "  let get_from_db ~query =\
       let open Mysql in\
       let open Core.Std.Result in \n
       let open Core.Std in\
       let conn = Utilities.get_conn in" in 
    let helper_preamble =
      "    let rec helper accum results nextrow =\
       (match nextrow with\
       | None -> Ok accum\
       | Some arrayofstring ->\
       try" in
    let suffix =
      "    let queryresult = exec conn query in\
       let isSuccess = status conn in\
       match isSuccess with\
       | StatusEmpty ->  Ok []\
       | StatusError _ -> \
       let () = Utilities.print_n_flush (\"Error during query of table...\n\") in\
       let () = Utilities.closecon conn in\
       Error \"get_from_db() Error in sql\"\
       | StatusOK -> let () = Utilities.print_n_flush \"\nQuery successful from table.\" in \
       helper [] queryresult (fetch queryresult);;" in    
    let rec for_each_field flist accum =
      match flist with
      | [] -> String.concat ~sep:"\n" accum
      | h :: t ->
	 let non_optional_string_field =
	   String.concat ["let ";h.col_name;" = Utilities.extract_field_as_string ~fieldname:";
			  h.col_name;" ~results ~arrayofstring"] in
	 let optional_string_field =
	   String.concat ["let ";h.col_name;" = Utilities.extract_optional_field ~fieldname:";
			  h.col_name;"~results ~arrayofstring" in
	 (*NEED TO TRY TO PARSE AND RETURN Some t on success or None if fail---NEED TO PLACE CONVERSION FUNCTION INTO UTILS FILE, NOT HERE!*)
	 let optional_t_field =
	   let parser_function_of_string = Types_we_emit.converter_of_string_for_type ~is_optional:h.is_nullable  ~t:h.data_type in
	   match h.is_nullable with
	   | false ->
	      if is_None parser_function_of_string then
		"let " ^ h.col_name ^ " = \nlet s = String.strip\n~drop:Char.is_whitespace\n\
				       (Option.value_exn ~message:\"Failed to get from table " ^ h.table_name ^ " col\" " ^
		  h.col_name ^ ".\n(Mysql.column results ~key:" ^ h.col_name ^
		    "~row:arrayofstring)) in\n " ^ parser_function_of_string ^ " s \n"
	      else
		raise (Failure "Unsupported")
	   | true ->
	      if is_None parser_function_of_string then 
		"let " ^ h.col_name ^ " = \n Option.value_exn ~message:\"Failed to get from table " ^ h.table_name ^ " col\" " ^
		  h.col_name ^ ".\n(Mysql.column results ~key:" ^ h.col_name ^
		    "~row:arrayofstring)) in\n "
	      else
		"let " ^ h.col_name ^ " = \nlet s = String.strip\n~drop:Char.is_whitespace\n\
				       (Option.value_exn ~message:\"Failed to get from table " ^ h.table_name ^ " col\" " ^
		  h.col_name ^ ".\n(Mysql.column results ~key:" ^ h.col_name ^
		    "~row:arrayofstring)) in\n " ^ parser_function_of_string ^ " s \n"
	      
	   
    ();;
      
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
	 let string_of_data_type = Types_we_emit.to_string h.data_type in 
	 let tbody_new =
	   Core.Std.String.concat [tbody;"\n    ";h.col_name;" : ";string_of_data_type;";"] in
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    let almost_done = Core.Std.String.concat [start_module;start_type_t;tbody;"\n";end_type_t] in
    let finished_type_t =
      match ppx_decorators with
      | [] -> almost_done ^ "end"
      | h :: t ->
	 let ppx_extensions = String.concat ~sep:"," ppx_decorators in
	 almost_done ^ "\n             [@@deriving " ^ ppx_extensions ^ "]\n\n" in
    (*Insert a few functions and variables.*)
    let table_related_lines =
      "  let tablename=\"" ^ table_name ^
	"\" \n\n\
	  let get_tablename () = tablename;;\n" in
    (*General purpose query...client code can create others*)
    let sql_query_function =
      "  let get_sql_query () = \
       let fs = Fields.names in \
       let fs_csv = Core.Std.String.concat ~sep:',' fs in 
       \"SELECT \" ^ fs_csv ^ \"FROM \" ^ tablename ^ \" WHERE TRUE;;\"" in   
    finished_type_t ^ table_related_lines ^ sql_query_function ^ "\nend";;

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
	 let string_of_data_type = Types_we_emit.to_string h.data_type in 
	 let tbody_new = Core.Std.String.concat
			   [tbody;"\n    ";h.col_name;" : ";string_of_data_type;";"] in	 
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
      let _bytes_written =
	with_file fname ~mode:[O_RDWR;O_CREAT;O_TRUNC]
		  ~perm:0o644 ~f:(myf body) in ()
    with () -> Utilities.print_n_flush "\nFailed to write to file.\n"
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
