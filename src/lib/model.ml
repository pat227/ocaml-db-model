module Pcre = Pcre
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
    let open Core in 
    (*Only column_type gives us the acceptable values of an enum type if present, 
      unsigned; use the column_comment to input per field directives for ppx 
      extensions...way down the road, such as key or default for json ppx extension. 
      In future for compare ppx extension, perhaps set all fields to return zero 
      EXCEPT for the primary key of table? This is also useful for Core Comparable 
      interface.*)
    let fields_query = String.concat [
			   "SELECT column_name, is_nullable, column_comment,
			    column_type, data_type, column_key, extra, column_comment FROM 
			    information_schema.columns 
			    WHERE table_name='";table_name;"';"] in
    (* numeric_scale, column_default, character_maximum_length, 
    character_octet_length, numeric_precision,*)
    let rec helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let col_name =
	       Utilities.extract_field_as_string_exn
		 ~fieldname:"column_name" ~results ~arrayofstring in 
	     let data_type =
	       Utilities.extract_field_as_string_exn
		 ~fieldname:"data_type" ~results ~arrayofstring in 
	     let col_type =
	       Utilities.extract_field_as_string_exn
		 ~fieldname:"column_type" ~results ~arrayofstring in 
	     let is_nullable =
	       Utilities.parse_bool_field_exn
		 ~fieldname:"is_nullable" ~results ~arrayofstring in 
	     let is_primary_key =
	       let is_pri = Utilities.extract_field_as_string_exn
			      ~fieldname:"column_key" ~results ~arrayofstring in 
	       (fun x -> match x with "pri" -> true | _ -> false) is_pri in
	     (*--todo--convert data types and nullables into ml types as 
               strings for use in writing a module*)
	     let type_for_module =
	       Sql_supported_types.one_step ~data_type ~col_type ~col_name in
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
	    let () = Utilities.print_n_flush
		       (String.concat ["\nError ";(Exn.to_string err);
				       " getting tables from db."]) in
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
       let () = Utilities.print_n_flush
		  ("Query for table names returned nothing.  ... \n") in
       let () = Utilities.closecon conn in
       Error "model.ml::get_fields_for_given_table() Error in sql"
    | StatusOK -> let () = Utilities.print_n_flush "\nGot fields for table." in 
		  helper String.Map.empty queryresult (fetch queryresult);;

  let make_regexp s =
    let open Core in 
    match s with
    | Some sr ->
       (try
	   let () = Utilities.print_n_flush
		      (String.concat ["make_regexp() from ";sr]) in 
	   let regexp = Pcre.regexp sr in Some regexp
	 with
	 | err -> let () = Utilities.print_n_flush "\nFailed to parse regexp..." in
	raise err
       )
    | None -> None;;
    
  let parse_list s =
    let open Core in 
    try
      match s with
      | Some sl ->
	 (try
	     let () = Utilities.print_n_flush (String.concat ["parse_list() from ";sl]) in
	     let l = Core.String.split sl ~on:',' in
	     let len = Core.List.count l ~f:(fun x -> true) in
	     if len > 1 then Some l else None
	   with
	   | err ->
	      let () = Utilities.print_n_flush
			 "\nFailed parsing table name list..." in
	      raise err
	 )
      | None -> None
    with
    | _ -> None;;
    
  let get_fields_map_for_all_tables ~regexp_opt ~table_list_opt ~conn ~schema =
    let open Core in
    let open Core.Result in 
    let table_list_result = Table.get_tables ~conn ~schema in
    if is_ok table_list_result then
      let tables = ok_or_failwith table_list_result in
      let regexp_opt = make_regexp regexp_opt in
      let table_list_opt = parse_list table_list_opt in 
      let rec helper ltables map =
	let update_map ~table_name =
	  let fs_result = get_fields_for_given_table ~conn ~table_name in
	  if is_ok fs_result then
	    let newmap = ok_or_failwith fs_result in
	     let combinedmaps =
	       Map.merge
		 map newmap
		 ~f:
		 (fun ~key vals ->
		  match vals with
		  | `Left v1 -> Some v1
		  | `Right v2 -> Some v2
		  | `Both (v1,v2) -> raise (Failure "Duplicate table name!?!") 
		 ) in  
	     combinedmaps
	  else  
	    map in 
	match ltables with
	| [] -> map
	| h::t ->
	   (**---filter on regexp or list here, if present at all---*)
	   (match regexp_opt, table_list_opt with
	    | None, Some l ->
	       if List.mem l h.Table.table_name ~equal:String.equal then
		 let newmap = update_map ~table_name:h.Table.table_name in
		 helper t newmap
	       else
		 helper t map
	    | Some r, None ->
	       (try
		   let _intarray =
		     Pcre.pcre_exec ?rex:(Some r) h.Table.table_name in
		   let newmap = update_map ~table_name:h.Table.table_name in
		   helper t newmap
		 with
		 | _ -> helper t map
	       )
	    | Some r, Some l -> (*--presume regexp over list---*)
	       (try
		   let _intarray =
		     Pcre.pcre_exec ?rex:(Some r) h.Table.table_name in
		   let newmap = update_map ~table_name:h.Table.table_name in
		   helper t newmap
		 with
		 | _ -> helper t map
	       )
	    | None, None -> 
	       let newmap = update_map ~table_name:h.Table.table_name in
	       helper t newmap
	   ) in
      helper tables String.Map.empty
    else
      let () = Utilities.print_n_flush "\nFailed to get list of tables.\n" in
      String.Map.empty;;
    
  (**Construct an otherwise tedious function that creates instances of type t from
     a query; for each field in struct, get the string option from the string 
     option array provided by Mysql under the same name, parse it into it's correct 
     type using the correct conversion function, and then use Fields.create to 
     create a new record, add it to an accumulator, and finally return that 
     accumulator after we have exhausted all the records returned by the query. 
     Cannot use long line continuation backslashes here; screws up the formatting 
     in the output.*)
  let construct_sql_query_function ~table_name ~map ~host
				   ~user ~password ~database =
    let open Core in 
    let preamble =
      String.concat ["  let get_from_db ~query =\n    let open Mysql in \n    let open Core.Result in \n    let open Core in \n    let conn = Utilities.getcon ";
		     "~host:\"";host;"\" ~user:\"";user;"\" \n                               ~password:\"";password;"\" ~database:\"";database;"\" in \n"] in
    let helper_preamble =
      "    let rec helper accum results nextrow = \n      (match nextrow with \n       | None -> Ok accum \n       | Some arrayofstring ->\n          try " in
    let suffix =
      String.concat 
	["    let queryresult = exec conn query in\n    let isSuccess = status conn in\n    match isSuccess with\n    | StatusEmpty ->  Ok [] \n    | StatusError _ -> \n       let () = Utilities.print_n_flush (\"Error during query of table ";
	 table_name;"...\") in\n       let () = Utilities.closecon conn in\n       Error \"get_from_db() Error in sql\"\n    | StatusOK -> \n       let () = Utilities.print_n_flush \"Query successful from ";table_name;" table.\" in \n       helper [] queryresult (fetch queryresult);;"] in
    let rec for_each_field ~flist ~accum =
      match flist with
      | [] -> String.concat ~sep:"\n" accum
      | h :: t ->
	 let parser_function_call =
	   Types_we_emit.converter_of_string_of_type
	     ~is_optional:h.is_nullable ~t:h.data_type ~fieldname:h.col_name in
	 let output = String.concat
			["            let ";h.col_name;" = ";
			 parser_function_call;" in "] in
	 for_each_field ~flist:t ~accum:(output::accum) in
    let rec make_fields_create_line ~flist ~accum =
      match flist with
      | [] -> let fields = String.concat ~sep:" " accum in
	      String.concat ["            let new_t = Fields.create ";fields;" in "]
      | h :: t ->
	 let onef = String.concat ["~";h.col_name] in
	 make_fields_create_line ~flist:t ~accum:(onef::accum) in 
    let fields_list = Map.find_exn map table_name in
    let creation_line = make_fields_create_line ~flist:fields_list ~accum:[] in
    let recursive_call = "            helper (new_t :: accum) results (fetch results) " in 
    let parser_lines = for_each_field fields_list [] in
    String.concat ~sep:"\n" [preamble;helper_preamble;parser_lines;creation_line;
			     recursive_call;"          with\n          | err ->";
			     "             let () = Utilities.print_n_flush (String.concat [\"\\nError: \";(Exn.to_string err);\"Skipping a record...\"]) in \n             helper accum results (fetch results)\n      ) in";suffix];;
      
  let construct_body ~table_name ~map ~ppx_decorators
		     ~host ~user ~password ~database =
    let open Core in 
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase module_first_char in
    let module_name = Bytes.of_string table_name in
    let () = Bytes.set module_name 0 uppercased_first_char in 
    let start_module = String.concat ["module ";(Bytes.to_string module_name);" = struct\n"] in
    let other_modules =
      String.concat ~sep:"\n" ["module Utilities = Utilities.Utilities";
			       "module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp";
			       "module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp";
			       "module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp";
			       "module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp";
			       "open Sexplib.Std\n"] in
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = String.Map.find_exn map table_name in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush
	       (String.concat ["\nList of fields found of length:";
			       (Int.to_string (List.length tfields_list))]) in 
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t ->
	 let string_of_data_type =
	   Types_we_emit.to_string h.data_type h.is_nullable in 
	 let tbody_new =
	   Core.String.concat [tbody;"\n    ";h.col_name;" : ";
				   string_of_data_type;";"] in
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    let almost_done =
      Core.String.concat [other_modules;start_module;start_type_t;
			      tbody;"\n";end_type_t] in
    let finished_type_t =
      match ppx_decorators with
      | [] -> String.concat [almost_done;"end"]
      | h :: t ->
	 let ppx_extensions = String.concat ~sep:"," ppx_decorators in
	 String.concat [almost_done;" [@@deriving ";ppx_extensions;"]\n"] in
    (*Insert a few functions and variables.*)
    let table_related_lines =
      String.concat ["  let tablename=\"";table_name;
		     "\" \n\n  let get_tablename () = tablename;;\n"] in
    (*General purpose query...client code can create others*)
    let sql_query_function =
      "  let get_sql_query () = \n    let open Core in\n    let fs = Fields.names in \n    let fs_csv = String.concat ~sep:\",\" fs in \n    String.concat [\"SELECT \";fs_csv;\"FROM \";tablename;\" WHERE TRUE;\"];;\n" in
    let query_function = construct_sql_query_function ~table_name ~map ~host
						      ~user ~password ~database in 
    String.concat ~sep:"\n" [finished_type_t;table_related_lines;sql_query_function;
			     query_function;"\nend"];;

  let construct_mli ~table_name ~map ~ppx_decorators =
    let open Core in 
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase module_first_char in
    let module_name = Bytes.of_string table_name in
    let () = Bytes.set module_name 0 uppercased_first_char in 
    let start_module = String.concat ["module ";(Bytes.to_string module_name);" : sig \n"] in 
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = String.Map.find_exn map table_name in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush
	       (String.concat ["\nList of fields found of length:";
			       (Int.to_string (List.length tfields_list))]) in 
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t ->
	 let string_of_data_type =
	   Types_we_emit.to_string ~t:h.data_type ~is_nullable:h.is_nullable in 
	 let tbody_new = Core.String.concat
			   [tbody;"\n    ";h.col_name;" : ";string_of_data_type;";"] in	 
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    let almost_done = String.concat [start_module;start_type_t;tbody;"\n";end_type_t] in
    let with_ppx_decorators = 
      match ppx_decorators with
      | [] -> String.concat [almost_done;"end"]
      | h :: t ->
	 let ppx_extensions = String.concat ~sep:"," ppx_decorators in
	 String.concat [almost_done;" [@@deriving ";ppx_extensions;"]\n"] in
    let function_lines =
      String.concat
	~sep:"\n"
	["  val get_tablename : unit -> string";
	 "  val get_sql_query : unit -> string";
	 "  val get_from_db : query:string -> (t list, string) Core.Result.t";
	 "end"] in
    String.concat ~sep:"\n" [with_ppx_decorators;function_lines];;

  (*Intention is for invocation from root dir of a project from Make file. 
    In which case current directory sits atop src and build subdirs.*)
  let write_module ~outputdir ~fname ~body = 
    let open Core.Unix in
    let myf sbuf fd = single_write fd ~buf:sbuf in
    let check_or_create_dir ~dir =
      try 
	let _stats = stat dir in ()	
      with _ ->
	mkdir ~perm:0o774 dir in
    try
      let () = check_or_create_dir ~dir:outputdir in 
      let _bytes_written =
	with_file (Core.String.concat [outputdir;fname]) ~mode:[O_RDWR;O_CREAT;O_TRUNC]
		  ~perm:0o664 ~f:(myf body) in ()
    with _ -> Utilities.print_n_flush "\nFailed to write to file.\n"

  (*NOT USED YET -- do NOT use while testing in place else we'll overwrite our own version.*)
  let copy_utilities ~destinationdir =
    let open Core in 
    let open Core.Unix in
    (*--how to specify the (opam install) path to utilities.ml---most likely 
     would need to use ocamlfind query <thispackagename> just to get the directory.*)
    let r = system (String.concat ["cp src/lib/utilities.ml ";destinationdir]) in
    let result = Core.Unix.Exit_or_signal.to_string_hum r in 
    let () = Utilities.print_n_flush result in 
    match r with
    | Result.Ok () -> Utilities.print_n_flush "\nCopied the utilities file."
    | Error e -> Utilities.print_n_flush "\nFailed to copy the utilities file."
       
end
