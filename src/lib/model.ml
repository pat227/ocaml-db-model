module Credentials = Credentials2copy.Credentials
module Mysql = Mysql
module Pcre = Pcre
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Table = Table.Table
module Types_we_emit = Types_we_emit.Types_we_emit
module Utilities = Utilities2copy.Utilities
(*module type S = Map.S*)
module type MapExtended = Mapextended.MapExtended
module Model = struct
  type t = {
    col_name : string; 
    table_name : string;
    data_type : Types_we_emit.t;
    is_nullable : bool;
    is_primary_key : bool;
  } [@@deriving show, fields]
  module StringKey = struct
    include String
  end 
  module String_Map = Map.Make(String);;
  module StringMap = struct
    include String_Map
    let keys m =
      let assoclist = String_Map.bindings m in
      let rec extract_keys l accum =
	match l with
	| [] -> accum
	| h :: t -> extract_keys t ((fst h)::accum) in
      extract_keys assoclist [];;
  end
  
  (*we only need this submodule to get foreign keys*)
  module Sequoia_support = struct
    module T = struct  
      type t = {
	col : string;
	table : string;
	referenced_table : string;
	referenced_field : string;
      } [@@deriving eq, ord, show, fields]
    end
    include T
    
    let get_any_foreign_key_references ~conn ~table_name = 
      (*work this into sequoia support...only way to discover foreign keys on a table*)
      let query_foreign_keys ~table_name =
	"SELECT CONSTRAINT_CATALOG, CONSTRAINT_SCHEMA, CONSTRAINT_NAME, TABLE_CATALOG,
	 TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, POSITION_IN_UNIQUE_CONSTRAINT,
	 REFERENCED_TABLE_SCHEMA, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM 
	 information_schema.key_column_usage WHERE table_name ='" ^
	  table_name ^
	    "' WHERE REFERENCED_TABLE_SCHEMA IS NOT NULL AND REFERENCED_TABLE_NAME 
	     IS NOT NULL AND REFERENCED_COLUMN_NAME IS NOT NULL;" in
      let query = query_foreign_keys ~table_name in  
      let rec helper accum results nextrow =
	(match nextrow with
	 | None -> Ok accum
	 | Some arrayofstring ->
	    try
	      (let col_name =
		 Utilities.extract_field_as_string_exn
		   ~fieldname:"column_name" ~results ~arrayofstring in	       
	       let referenced_table =
		 Utilities.extract_field_as_string_exn
		   ~fieldname:"referenced_table_name" ~results ~arrayofstring in 
	       let referenced_field =
		 Utilities.extract_field_as_string_exn
		   ~fieldname:"referenced_column_name" ~results ~arrayofstring in 
	       let new_fkey_record =
		 Fields.create
		   ~col:col_name ~table:table_name ~referenced_table ~referenced_field in
	       let newset = StringMap.add col_name new_fkey_record accum in 
	       helper newset results (Mysql.fetch results)
	      )
	    with err ->
	      let () = Utilities.print_n_flush ("\nError getting foreign key info from db.") in
	      Error "Failed to get foreign key info from db."
	) in
      (*let conn = (fun c -> if Core.Option.is_none c then
			     Utilities.getcon_defaults ()
			   else
			     Core.Option.value_exn c) conn in *)
      let queryresult = Mysql.exec conn query in
      let isSuccess = Mysql.status conn in
      match isSuccess with
      | Mysql.StatusEmpty ->  Ok StringMap.empty
      | Mysql.StatusError _ -> 
	 let () = Utilities.print_n_flush
		    ("Query for foreign keys returned nothing.  ... \n") in
	 let () = Utilities.closecon conn in
	 Error "model.ml::get_any_foreign_key_references() Error in sql"
      | Mysql.StatusOK -> let () = Utilities.print_n_flush "\nGot foreign key info for table." in
			  let empty = StringMap.empty in 
			  helper empty queryresult (Mysql.fetch queryresult);;
  end 

  let get_fields_for_given_table ~conn ~table_name =
    (*Only column_type gives us the acceptable values of an enum type if present, 
      unsigned; use the column_comment to input per field directives for ppx 
      extensions...way down the road, such as key or default for json ppx extension. 
      In future for compare ppx extension, perhaps set all fields to return zero 
      EXCEPT for the primary key of table? This is also useful for Core Comparable 
      interface.*)
    let fields_query = "SELECT column_name, is_nullable, column_comment,
			column_type, data_type, column_key, extra, column_comment
			FROM 
			information_schema.columns 
			WHERE table_name='" ^ table_name ^ "';" in
    (* numeric_scale, column_default, character_maximum_length, 
    character_octet_length, numeric_precision,*)
    let rec helper accum results nextrow =
      (match nextrow with
       | None -> Ok accum
       | Some arrayofstring ->
	  try
	    (let col_name =
	       let temp = Utilities.extract_field_as_string_exn
			    ~fieldname:"column_name" ~results ~arrayofstring in
	       let temp = String.lowercase_ascii temp in 
	       (*--cannot permit invalid literals or reserved keywords--must start
                with lowercase char or underscore and field names should not be
                case sensitive anyway. TODO: check for special chars and other
                reserved keywords.
		*)
	       let first_char = String.get temp 0 in
	       if Utilities.is_digit first_char ||
		    String.equal "type" temp ||
		      String.equal "module" temp ||
			String.equal "end" temp ||
			  String.equal "sig" temp 
	       then
		 (*--we have to do some name mangling or do not support such field names?--*)
		 String.concat "" ["x_";temp]
	       else 
		 temp in 
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
	     if StringMap.mem table_name accum then
	       let oldbinding = StringMap.find table_name accum in 
	       let newmap = StringMap.add table_name (new_field_record::oldbinding) accum in
	       helper newmap results (Mysql.fetch results)
	     else
	       let newmap = StringMap.add table_name [new_field_record] accum in 
	       helper newmap results (Mysql.fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in
    (*let conn = (fun c -> if is_none c then
			   Utilities.getcon_defaults ()
			 else
			   Option.value_exn c) conn in *)
    let queryresult = Mysql.exec conn fields_query in
    let isSuccess = Mysql.status conn in
    match isSuccess with
    | Mysql.StatusEmpty ->  Ok StringMap.empty
    | Mysql.StatusError _ -> 
       let () = Utilities.print_n_flush
		  ("Query for columns in " ^ table_name  ^  "returned nothing.  ... \n") in
       let () = Utilities.closecon conn in
       Error "model.ml::get_fields_for_given_table() Error in sql"
    | Mysql.StatusOK -> let () = Utilities.print_n_flush ("\nGot fields for table " ^ table_name) in 
			helper StringMap.empty queryresult (Mysql.fetch queryresult);;

  let make_regexp s =
    match s with
    | Some sr ->
       (try
	   let () = Utilities.print_n_flush ("make_regexp() from " ^ sr) in 
	   let regexp = Pcre.regexp sr in Some regexp
	 with
	 | err -> let () = Utilities.print_n_flush "\nFailed to parse regexp..." in
	raise err
       )
    | None -> None;;
    
  let get_fields_map_for_all_tables ~regexp_opt ~table_list_opt ~conn ~schema =
    let table_list_result = Table.get_tables ~conn ~schema in
    match table_list_result with
    | Ok tables -> 
      let regexp_opt = make_regexp regexp_opt in
      let table_list_opt = Utilities.parse_list table_list_opt in 
      let rec helper ltables map =
	let update_map ~table_name =
	  let fs_result = get_fields_for_given_table ~conn ~table_name in
	  (match fs_result with
	   | Ok newmap ->
	      StringMap.add table_name (StringMap.find table_name newmap) map
	      (*let combinedmaps =
		StringMap.merge
		  (fun key valLopt valRopt ->
		   match valLopt, valRopt with
		   | Some v1, None -> v1
		   | None, Some v2 -> v2
		   | None, None -> None
		   | Some v1, Some v2 -> raise (Failure "Duplicate table name!?!"))
		  map newmap
	      in  
	      combinedmaps*)
	   | Error _ -> map
	  ) in 
	(match ltables with
	 | [] -> map
	 | h::t ->
	    (**---filter on regexp or list here, if present at all---*)
	    (match regexp_opt, table_list_opt with
	     | None, Some l ->
		if List.mem h.Table.table_name l then
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
	    )
	) in
      helper tables StringMap.empty
    | Error _ -> 
       let () = Utilities.print_n_flush "\nFailed to get list of tables.\n" in
       StringMap.empty;;
    
  (**Construct an otherwise tedious function that creates instances of type t from
     a query; for each field in struct, get the string option from the string 
     option array provided by Mysql under the same name, parse it into it's correct 
     type using the correct conversion function, and then use Fields.create to 
     create a new record, add it to an accumulator, and finally return that 
     accumulator after we have exhausted all the records returned by the query. 
     Cannot use long line continuation backslashes here; screws up the formatting 
     in the output. If SEQUOIA allows us to generate legal SQL queries we can
     pass to such a function...that would be very good. *)
  let construct_sql_query_function ~table_name ~map ~host
				   ~user ~password ~database =
    let preamble =
      (*--do not place db creds into each file; one connection function with creds in utilities file; copied into the project.*)
      String.concat "" ["  let get_from_db ~query =\n    let open Mysql in \n    let open Core.Result in \n    let open Core in \n    let conn = Utilities.getcon () in \n";] in
    let helper_preamble =
      "    let rec helper accum results nextrow = \n      (match nextrow with \n       | None -> Ok accum \n       | Some arrayofstring ->\n          try " in
    let suffix =
      String.concat ""
	["    let queryresult = exec conn query in\n    let isSuccess = status conn in\n    match isSuccess with\n    | StatusEmpty ->  Ok [] \n    | StatusError _ -> \n       let () = Utilities.print_n_flush (\"Error during query of table ";
	 table_name;"...\") in\n       let () = Utilities.closecon conn in\n       Error \"get_from_db() Error in sql\"\n    | StatusOK -> \n       let () = Utilities.print_n_flush \"Query successful from ";table_name;" table.\" in \n       helper [] queryresult (fetch queryresult);;"] in
    let rec for_each_field ~flist ~accum =
      match flist with
      | [] -> String.concat "\n" accum
      | h :: t ->
	 let parser_function_call =
	   Types_we_emit.converter_of_string_of_type
	     ~is_optional:h.is_nullable ~t:h.data_type ~fieldname:h.col_name in
	 let output = String.concat ""
			["            let ";h.col_name;" = ";
			 parser_function_call;" in "] in
	 for_each_field ~flist:t ~accum:(output::accum) in
    let rec make_fields_create_line ~flist ~accum =
      match flist with
      | [] -> let fields = String.concat "" accum in
	      String.concat "" ["            let new_t = Fields.create ";fields;" in "]
      | h :: t ->
	 let onef = String.concat "" ["~";h.col_name] in
	 make_fields_create_line ~flist:t ~accum:(onef::accum) in 
    let fields_list = StringMap.find table_name map in
    let creation_line = make_fields_create_line ~flist:fields_list ~accum:[] in
    let recursive_call = "            helper (new_t :: accum) results (fetch results) " in 
    let parser_lines = for_each_field fields_list [] in
    String.concat "\n" [preamble;helper_preamble;parser_lines;creation_line;
			     recursive_call;"          with\n          | err ->";
			     "             let () = Utilities.print_n_flush (\"\\nError: \" ^ (Exn.to_string err) ^ \"Skipping a record...\") in \n             helper accum results (fetch results)\n      ) in";suffix];;


  let list_of_user_modules = ref None;;

  let get_all_available_user_written_modules ~where2find_modules =
    let () = Utilities.print_n_flush "\nget_all_available_user_written_modules() " in
    let rec helper path2dir dirhandle accum =
      (try
	let nextfile = Unix.readdir dirhandle in
	let stat = Unix.stat (String.concat "" [path2dir;"/";nextfile]) in
	(match stat.Unix.st_kind with
	| Unix.S_REG -> 
	   if Utilities.is_suffix nextfile "mli" then
	     helper where2find_modules dirhandle accum
	   else if Utilities.is_suffix nextfile "ml" then 
	     let () = Utilities.print_n_flush ("\nIncluding module " ^ nextfile) in 
	     helper where2find_modules dirhandle ((String.lowercase_ascii nextfile)::accum)
	   else
	     helper where2find_modules dirhandle accum
	| _ -> helper where2find_modules dirhandle accum)
      with End_of_file ->
	let () = Unix.closedir dirhandle in accum) in
    (match !list_of_user_modules with
    | None ->
       let dir_handle = Unix.opendir where2find_modules in
       let l = helper where2find_modules dir_handle [] in
       let () = list_of_user_modules := (Some l) in l
    | Some l -> l)
    
  let construct_body ~table_name ~map ~ppx_decorators
		     ~host ~user ~password ~database
		     ~module_names ~where2find_modules =
    let client_modules =
      match where2find_modules with
      | None -> None
      | Some path -> Some (get_all_available_user_written_modules ~where2find_modules:path) in 
    let module_name = String.capitalize_ascii table_name in
    (*===todo===either make fields mandatory or default, or else remove all the
      functions that depend on fields extension when generating modules, ie, the 
      query functions.*)
    let ppx_decorators_list =
      match ppx_decorators with
      | Some ppx_decorators_l ->
	 let r = Utilities.parse_list ppx_decorators in
	 (match r with
	  | Some l -> l
	  | None -> raise (Failure "model.ml::line 343")
	 )
      | None -> 
	 ["fields";"show";"sexp";"ord";"eq";"yojson"] in 
    let start_module = "module " ^ module_name ^ " = struct\n" in
    let other_modules =
      ["module Core_time_extended = Ocaml_db_model.Core_time_extended";
       "module Core_date_extended = Ocaml_db_model.Core_date_extended";
       "module Utilities = Utilities.Utilities";
       "module Uint64_extended = Ocaml_db_model.Uint64_extended";
       "module Uint32_extended = Ocaml_db_model.Uint32_extended";
       "module Uint16_extended = Ocaml_db_model.Uint16_extended";
       "module Uint8_extended = Ocaml_db_model.Uint8_extended";
       "module Core_int64_extended = Ocaml_db_model.Core_int64_extended";
       "module Core_int32_extended = Ocaml_db_model.Core_int32_extended"] in
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = StringMap.find table_name map in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush ("\nList of fields found of length:" ^
					(string_of_int (List.length tfields_list))) in
    (*--need to know which modules were added so we can add them to 
     other_modules defined above*)
    let rec helper l tbody added_modules =
      match l with
      | [] -> tbody
      | h :: t ->
	 (*--if client has defined a module of same name and desires to use it
           --as a type, do so here. Module must define some way to marshall
           --the type, ie, must have an of_string method. And a to_string
           --method in order to save it.*)
	 (match client_modules, module_names with
	  | Some clientmodules, Some modulenames -> 
	     if List.mem (String.lowercase_ascii h.col_name) clientmodules &&
		  List.mem (String.lowercase_ascii h.col_name) modulenames then
	       let tbody_new =
		 String.concat "" [tbody;"\n    ";h.col_name;" : ";
				   h.col_name;".t;"] in
	       helper t tbody_new (h.col_name :: added_modules)
	     else
	       helper t tbody added_modules
	  | _, _ -> 
	     let string_of_data_type =
	       Types_we_emit.to_string h.data_type h.is_nullable in 
	     let tbody_new =
	       String.concat "" [tbody;"\n    ";h.col_name;" : ";
				 string_of_data_type;";"] in
	     helper t tbody_new added_modules) in
    let more_specific_modules = [] in
    let tbody = helper tfields_list "" more_specific_modules in
    let other_modules =
      String.concat "\n" ((other_modules @
			     more_specific_modules) @
			    ["open Sexplib.Std\n"]) in 
    let almost_done =
      String.concat "" [other_modules;start_module;start_type_t;
			tbody;"\n";end_type_t] in
    let finished_type_t =
      match ppx_decorators_list with
      | [] -> almost_done ^ "\n"
      | h :: t ->
	 let ppx_extensions = String.concat "," ppx_decorators_list in
	 almost_done ^ " [@@deriving " ^ ppx_extensions ^ "]\n" in
    (*Insert a few functions and variables.*)
    let table_related_lines =
      String.concat "" ["  let tablename=\"";table_name;
	"\" \n\n  let get_tablename () = tablename;;\n"] in
    (*General purpose query...client code can create others*)
    let sql_query_function =
      "  let get_sql_query () = \n    let open Core in\n    let fs = Fields.names in \n    let fs_csv = String.concat ~sep:\",\" fs in \n    String.concat [\"SELECT \";fs_csv;\"FROM \";tablename;\" WHERE TRUE;\"];;\n" in
    let query_function = construct_sql_query_function ~table_name ~map ~host
						      ~user ~password ~database in 
    String.concat "\n" [finished_type_t;table_related_lines;sql_query_function;
			     query_function;"\nend"];;

  let construct_mli ~table_name ~map ~ppx_decorators
		    ~module_names ~where2find_modules =
    let client_modules =
      match where2find_modules with
      | None -> None
      | Some path -> Some (get_all_available_user_written_modules ~where2find_modules:path) in 
    (*at very least, fail if supplied csv list of ppx decorators is gibberish and 
      not a csv list  ===TODO===check that each is a true ppx extension, emit 
      warning if not. Still better than optional flags at command line, one for
      every possible ppx extension known and unknown in the future. *)
    let ppx_decorators_list =
      match ppx_decorators with
      | Some ppx_decs -> Utilities.parse_list ppx_decorators
      | None -> Some ["fields";"show";"sexp";"ord";"eq";"yojson"] in 
    let module_name = String.capitalize_ascii table_name in
    let other_modules =
      ["module Core_time_extended = Ocaml_db_model.Core_time_extended";
       "module Core_date_extended = Ocaml_db_model.Core_date_extended";
       "module Utilities = Utilities.Utilities";
       "module Uint64_extended = Ocaml_db_model.Uint64_extended";
       "module Uint32_extended = Ocaml_db_model.Uint32_extended";
       "module Uint16_extended = Ocaml_db_model.Uint16_extended";
       "module Uint8_extended = Ocaml_db_model.Uint8_extended";
       "module Core_int64_extended = Ocaml_db_model.Core_int64_extended";
       "module Core_int32_extended = Ocaml_db_model.Core_int32_extended"] in
    let start_type_t = "  type t = {" in
    let end_type_t = "  }" in
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = StringMap.find table_name map in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush ("\nList of fields found of length:" ^
					(string_of_int (List.length tfields_list))) in
    let more_specific_modules = [] in 
    let rec helper l tbody added_modules =
      match l with
      | [] -> tbody
      | h :: t ->
	 (match client_modules, module_names with
	  | Some clientmodules, Some modulenames ->
	     if List.mem h.col_name clientmodules &&
		  List.mem h.col_name modulenames then
	       let tbody_new =
		 String.concat
		   "" [tbody;"\n    ";h.col_name;" : ";h.col_name;".t;"] in
	       helper t tbody_new (h::added_modules)
	     else
	       helper t tbody added_modules
	  | _,_ ->
	     let string_of_data_type =
	       Types_we_emit.to_string ~t:h.data_type ~is_nullable:h.is_nullable in 
	     let tbody_new =
	       String.concat
		 "" [tbody;"\n    ";h.col_name;" : ";string_of_data_type;";"] in
	     helper t tbody_new added_modules) in 
    let tbody = helper tfields_list "" more_specific_modules in
    let other_modules = String.concat "\n" (other_modules @ more_specific_modules) in 
    let start_module = String.concat "" [other_modules;"\n";"module ";module_name;" : sig \n"] in 
    let almost_done = String.concat "" [start_module;start_type_t;tbody;"\n";end_type_t] in
    let with_ppx_decorators =
      match ppx_decorators_list with
      | None 
      | Some [] ->
	 String.concat "" [almost_done;" [@@deriving ";"fields";"show";"sexp";"ord";"eq";"yojson";"]\n"]
      | Some (l) ->
	 let ppx_extensions = String.concat "," l in
	 String.concat "" [almost_done;" [@@deriving ";ppx_extensions;"]\n"] in
    let function_lines =
      String.concat
	"\n" ["  val get_tablename : unit -> string";
	      "  val get_sql_query : unit -> string";
	      "  val get_from_db : query:string -> (t list, string) Core.Result.t";
	      "end"] in
    String.concat "\n" [with_ppx_decorators;function_lines];;

  (*Intention is for invokation from root dir of a project from Make file. 
    In which case current directory sits atop src and build subdirs.*)
  let write_module ~outputdir ~fname ~body = 
    let open Unix in
    let myf sbuf fd = single_write fd sbuf 0 (Bytes.length sbuf) in
    let check_or_create_dir ~dir =
      try 
	let _stats = stat dir in ()	
      with _ ->
	mkdir dir 0o770 in
    try
      let () = check_or_create_dir ~dir:outputdir in
      let name = (outputdir ^ fname) in
      let f = openfile name [O_RDWR;O_CREAT;O_TRUNC] 0o644 in
      let _bytes_written = myf body f in 
      close f
    with _ -> Utilities.print_n_flush ("\nFailed to write to file:" ^ fname)

  (*NOTE: unlike credentials in this project; the written module includes a set of credentials
    with user supplied values.
    let construct_db_credentials_mli () =
      "module Credentials : sig\n  type t\n  val of_username_pw : username:string -> pw:string -> db:string -> t\n  val getpw : t -> string\n  val getuname : t -> string\n  val getdb : t -> string\n  val credentials : t\nend";;
   *)
  let list_split_n l n =
    let rec helper i n li firsthalf secondhalf =
      match li with
      | [] -> (List.rev firsthalf),(List.rev secondhalf)
      | h :: t ->
	 if i < n then
	   helper (i+1) n t (h::firsthalf) secondhalf
	 else
	   helper (i+1) n t firsthalf (h::secondhalf) in
    let len = List.length l in
    if n > len then
      l,[]
    else
      if n < 0 then
	[],l
      else
	helper 0 n l [] [];;
				      
  let get_path2lib () =
    (*Use CAML_LD_LIBRARY_PATH env var. It is /home/<homedir>/.opam/4.04.1/lib/stublibs; extract version*)
    let ldpath = Sys.getenv "CAML_LD_LIBRARY_PATH" in
    let pathelems = String.split_on_char '/' ldpath in
    let paths = list_split_n pathelems ((List.length pathelems) - 1) in
    let path_elems_less_stublibs = fst paths in
    String.concat "/" path_elems_less_stublibs;;

  let input_lines inchan =
    let rec helper inc accum =
      try
	helper inc ((input_line inc)::accum)
      with End_of_file -> List.rev accum in
    helper inchan [];;

  let filteri list startindex endindex =
    let rec helper l x i n accum =
      if x >= i && x <= n then 
	helper l (x+1) i n ((List.nth l x)::accum)
      else (*if x >= i && x > n then*)  
	List.rev accum
    in
    match (startindex > endindex), (startindex < 0), (endindex >= (List.length list)) with
    | false, false, false ->
       helper list startindex startindex endindex []
    | _, _, _ -> raise (Failure "filteri arguments either out of bounds or order.");;
    
  let construct_db_credentials ~credentials ~destinationdir =
    (*==========================================================================
      DESPITE being so short, copy it to avoid maintaining this module and mli 
      in 2 places, ie, avoid code duplication
      ==========================================================================
let body_start = "module Credentials = struct\n  type t = {\n    username: string;\n    pw:string;\n    db:string\n  }\n  let of_username_pw ~username ~pw ~db =\n    { username = username;\n      pw = pw;\n      db = db;\n    };;\n  let getuname t = t.username;;\n  let getpw t = t.pw;;\n  let getdb t = t.db;;\n  let credentials = of_username_pw ~username:\"" in*)
    let path2lib = get_path2lib () in 
    let inchan = open_in (String.concat "" [path2lib;"/ocaml_db_model/credentials2copy.ml"]) in
    let lines = input_lines inchan in
    (*insert a value here and into mli*)
    let lines2to16 = String.concat "\n" (filteri lines 0 15) in
    let body = String.concat "" [lines2to16;"  let credentials = of_username_pw ~username:\"";(Credentials.getusername credentials);"\" ~pw:\"";(Credentials.getpw credentials);"\" ~db:\"";(Credentials.getdb credentials);"\";;\nend"] in
    let () = write_module ~outputdir:destinationdir ~fname:"credentials.ml" ~body in
    let inchan_mli = open_in (String.concat "" [path2lib;"/ocaml_db_model/credentials2copy.mli"]) in
    let lines_mli = input_lines inchan_mli in
    let lines_first6 = String.concat "\n" (filteri lines_mli 0 5) in
    let body_mli = String.concat "" [lines_first6;"  val credentials : t\nend"] in
    write_module ~outputdir:destinationdir ~fname:"credentials.mli" ~body:body_mli;;

  let write_appending_module ~outputdir ~fname ~body = 
    let open Unix in
    let myf sbuf fd = single_write fd sbuf 0 (Bytes.length sbuf) in
    let check_or_create_dir ~dir =
      try 
	let _stats = stat dir in ()	
      with _ ->
	mkdir dir 0o770 in
    try
      let () = check_or_create_dir ~dir:outputdir in
      let name = (outputdir ^ fname) in
      let f = openfile name [O_RDWR;O_CREAT;O_TRUNC] 0o644 in
      let _bytes_written = myf body f in
      close f
    with _ -> Utilities.print_n_flush ("\nFailed to write (appending) to file:" ^ fname)

  (*==UNTIL actually install package, nothing to do here.*)
  let copy_utilities ~destinationdir =
    (*
    --how to specify the (opam install) path to utilities.ml?---
      Use ocamlfind query <packagename> after installing as a package via opam, then we'll
      have the path to directory in which to look.
     *)
    let path2lib = get_path2lib () in 
    let inchan = open_in (String.concat "" [path2lib;"/ocaml_db_model/utilities2copy.ml"]) in
    let lines = input_lines inchan in
    (*replace lines 1 through 7 with updated modules*)
    (*replace lines 18 through 24 and then write to location*)
    let lines8to17 = String.concat "\n" (filteri lines 6 16) in
    let lines25_toend = String.concat "\n" (filteri lines 23 ((List.length lines)-1)) in
    let replacement_lines =
      String.concat "\n"
		    ["  let getcon ?(host=\"127.0.0.1\")";
		     "	     ?(database=Credentials.getdb Credentials.credentials)";
		     "	     ?(password=Credentials.getpw Credentials.credentials)";
		     "	     ?(user=Credentials.getusername Credentials.credentials) () =";
		     "    let open Mysql in ";
		     "    quick_connect";
		     "      ~host ~database ~password ~user ();;"] in
    let replacement_modules =
      String.concat "\n"
		    ["module Core_time_extended = Ocaml_db_model.Core_time_extended";
		     "module Core_date_extended = Ocaml_db_model.Core_date_extended";
		     "module Uint64_extended = Ocaml_db_model.Uint64_extended";
		     "module Uint32_extended = Ocaml_db_model.Uint32_extended";
		     "module Uint16_extended = Ocaml_db_model.Uint16_extended";
		     "module Uint8_extended = Ocaml_db_model.Uint8_extended";
		     "module Core_int64_extended = Ocaml_db_model.Core_int64_extended";
		     "module Core_int32_extended = Ocaml_db_model.Core_int32_extended";
		     "module Credentials = Credentials.Credentials"] in 
    let modified_utils = String.concat "\n" [replacement_modules;lines8to17;replacement_lines;lines25_toend] in
    let () = write_module ~outputdir:destinationdir ~fname:"utilities.ml" ~body:modified_utils in
    let inchan_mli = open_in (String.concat "" [path2lib;"/ocaml_db_model/utilities2copy.mli"]) in
    let lines_mli = input_lines inchan_mli in
    (*replace line 10 and then write to location*)
    let lines7to9 = String.concat "\n" (filteri lines_mli 5 8) in
    let lines11_toend = String.concat "\n" (filteri lines_mli 9 ((List.length lines)-1)) in
    let replacement_line = "  val getcon : ?host:string -> ?database:string -> ?password:string -> ?user:string -> unit -> Mysql.dbd" in
    let modified_utils_mli = String.concat "\n" [replacement_modules;lines7to9;replacement_line;lines11_toend] in
    write_module ~outputdir:destinationdir ~fname:"utilities.mli" ~body:modified_utils_mli;;    

  let construct_one_sequoia_struct ~conn ~table_name ~map =
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase_ascii module_first_char in
    let module_name = Bytes.copy table_name in
    let () = Bytes.set module_name 0 uppercased_first_char in 
    let start_module = "module " ^ module_name ^ " = struct\n" in
    let include_line = String.concat "" ["  include (val Mysql.table \"";table_name;"\")"] in 
    (*Supply only keys that exist else find_exn will fail.*)
    let tfields_list_reversed = StringMap.find table_name map in
    let tfields_list = List.rev tfields_list_reversed in 
    let () = Utilities.print_n_flush ("\nList of fields found of length:" ^
					(string_of_int (List.length tfields_list))) in
    let fkeys_map_result = Sequoia_support.get_any_foreign_key_references ~conn ~table_name in
    let fkeys_map = 
      match fkeys_map_result with
      | Ok fkeys_map -> fkeys_map
      | Error _err -> 
	 let () = Utilities.print_n_flush "\nFailed to get references tables and fields for sequoia support...\n" in
	 raise (Failure "Could not get referenced tables and fields for sequoia support.") in 
    (*create list of lines, each is a let statement per field, with a type found in Sequoia's field.mli*)
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t ->
	 (*==TODO==support foreign keys===right here in concat somehow*)
	 let string_of_data_type =
	   Types_we_emit.to_string h.data_type h.is_nullable in
	 let tbody_new =
	   if StringMap.mem h.col_name fkeys_map then
	     let reference_record = StringMap.find h.col_name fkeys_map in
	     let referenced_table = reference_record.Sequoia_support.table in	     
	     String.concat "" [tbody;"\n  let ";h.col_name;" = Field.foreign_key ";
			       h.col_name;" ~references:";referenced_table;".";
			       reference_record.Sequoia_support.referenced_field]
	   else 
	     String.concat "" [tbody;"\n  let ";h.col_name;" = ";
			       string_of_data_type;" ";h.col_name] in
	 helper t tbody_new in 
    let tbody = helper tfields_list "" in
    String.concat "" [start_module;include_line;tbody;"\n";"end"];;        
       
end
