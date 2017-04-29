module Utilities = Utilities.Utilities
module Table = Table.Table
module Sql_supported_types = Sql_supported_types.Sql_supported_types
module Mysql = Mysql
module Uint8 = Uint8
module Uint16 = Uint16
module Uint32 = Uint32
module Uint64 = Uint64

module Model = struct
  type t = {
    col_name : string; 
    table_name : string;
    data_type : string;
    is_nullable : bool;
  } [@@deriving show, fields]

  let get_fields_for_given_table ~table_name =
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
	     helper (new_field_record::accum) results (fetch results)
	    )
	  with err ->
	    let () = Utilities.print_n_flush ("\nError " ^ (Exn.to_string err) ^
				      " getting tables from db.") in
	    Error "Failed to get tables from db."
      ) in
    let conn = Utilities.getcon_defaults () in 
    let queryresult = exec conn fields_query in
    let isSuccess = status conn in
    match isSuccess with
    | StatusEmpty ->  let () = Utilities.closecon conn in Ok []
    | StatusError _ -> 
		     let () = Utilities.print_n_flush ("Query for table names returned nothing.  ... \n") in
		     let () = Utilities.closecon conn in
		     Error "model.ml::get_fields_for_given_table() Error in sql"
    | StatusOK -> let () = Utilities.closecon conn in
		  let () = Utilities.print_n_flush "\nGot fields for table." in 
		  helper [] queryresult (fetch queryresult);;


  let map_of_list ~tlist =
    let open Core.Std in 
    let rec helper l map =
    match l with
    | [] -> map
    | h :: t -> let newmap = String.Map.add_multi map h.table_name h in
		helper t newmap in
    helper tlist String.Map.empty;;

  (*Supply only keys that exist else find_exn will fail.*)
  let construct_body ~table_name ~map =
    let open Core.Std in 
    (*todo - ensure capital first letter in module name *)
    let module_first_char = String.get table_name 0 in
    let uppercased_first_char = Char.uppercase module_first_char in
    let module_name = String.copy table_name in
    let () = String.set module_name 0 uppercased_first_char in 
    let start_module = "module " ^ module_name ^ " = struct \n" in 
    let start_type_t = "type t = {" in
    let end_type_t = "}\n" in 
    let tfields_list = String.Map.find_exn map table_name in
    let rec helper l tbody =
      match l with
      | [] -> tbody
      | h :: t -> tbody ^ "\n" ^ h.col_name ^ ":" ^ h.data_type in
    let tbody = helper tfields_list "" in
    start_module ^ start_type_t ^ tbody ^ "\n" ^ end_type_t ^ "end";;
    
  let write_module ~fname ~body = 
    let open Core.Std.Unix in
    let myf sbuf fd = single_write fd ~buf:sbuf in
    try
      let _ = with_file ~mode:[O_RDWR;O_CREAT;O_TRUNC] ~perm:0o644 ~f:(myf body) in ();
    with _ -> Utilities.print_n_flush "Failed to write to file."
end 


(*
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
