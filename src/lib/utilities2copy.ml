module Core_int64_extended = Core_int64_extended.Core_int64_extended
module Core_int32_extended = Core_int32_extended.Core_int32_extended
module Core_time_extended = Core_time_extended.Core_time_extended
module Uint8_extended = Uint8_extended.Uint8_extended
module Uint16_extended = Uint16_extended.Uint16_extended
module Uint32_extended = Uint32_extended.Uint32_extended
module Uint64_extended = Uint64_extended.Uint64_extended
module Mysql = Mysql
open Core
module Utilities = struct

  let oc = Core.Out_channel.stdout;;    
  let print_n_flush s =
    let open Core in 
    Out_channel.output_string oc s;
    Out_channel.flush oc;;

  (*Client code makefile supplies credentials and uses this function; credentials in client
   projects are stored in credentials.ml; this file is copied with modifications
   to make of type () -> Mysql.dbd with credentials optional with default values.*)
  let getcon ?(host="127.0.0.1") ~database ~password ~user =
    let open Mysql in 
    quick_connect
      ~host ~database ~password ~user ();;

  let closecon c = Mysql.disconnect c;;

  let oc = Core.Out_channel.stdout;;    
  let print_n_flush s =
    Core.Out_channel.output_string oc s;
    Core.Out_channel.flush oc;;

  let parse_list s =
    let open Core in 
    try
      match s with
      | Some sl ->
	 (try
	     let () = print_n_flush ("parse_list() from " ^ sl) in
	     let l = Core.String.split sl ~on:',' in
	     let len = Core.List.count l ~f:(fun x -> true) in
	     if len > 0 then Some l else None
	   with
	   | err ->
	      let () = print_n_flush
			 "\nFailed parsing table name list..." in
	      raise err
	 )
      | None -> None
    with
    | _ -> None;;


    
  let serialize_optional_field ~field ~conn =
    match field with
    | None -> "NULL"
    | Some s -> "'" ^ (Mysql.real_escape conn s) ^ "'";;
  let serialize_optional_field_with_default ~field ~conn ~default =
    match field with
    | None -> default
    | Some s -> "'" ^ (Mysql.real_escape conn s) ^ "'";;
  let serialize_boolean_field ~field =
    match field with
    | true -> "TRUE"
    | false -> "FALSE";;
  let serialize_optional_bool_field ~field =
    match field with
    | None -> "NULL"
    | Some b -> if b then "TRUE" else "FALSE";;
  let serialize_optional_float_field_as_int ~field =
    let open Core in 
    match field with
    | Some f -> Int.to_string (Float.to_int (f *. 100.0))
    | None -> "NULL";;
  let serialize_float_field_as_int ~field =
    let open Core in 
    Int.to_string (Float.to_int (field *. 100.0));;

  (*===========parsers=============*)
  let parse_boolean_field_exn ~field =
    match field with
    | "YES" -> true 
    | "NO" -> false 
    | _ -> raise (Failure "Utilities::parse_boolean_field unrecognized value")
    
  let parse_optional_boolean_field_exn ~field =
    match field with
    | None -> None
    | Some s ->
       let b = parse_boolean_field_exn ~field:s in
       Some b;;
(*		  
  let parse_64bit_int_field_exn ~field =
    Core.Std.Int64.of_string field
 *)
  let extract_field_as_string_exn ~fieldname ~results ~arrayofstring =
    try
      String.strip
	~drop:Char.is_whitespace
	(Option.value_exn
	   ~message:("Failed to get col " ^ fieldname)
	   (Mysql.column results
			 ~key:fieldname ~row:arrayofstring))
    with
    | _ ->
       let () = print_n_flush ("\nutilities.ml::extract_field_as_string_exn() failed. \
				most likely bad field name:" ^ fieldname) in
       raise (Failure "utilities.ml::extract_field_as_string_exn() failed. \
		       most likely bad field name")

  let extract_optional_field ~fieldname ~results ~arrayofstring =
    Mysql.column results ~key:fieldname ~row:arrayofstring;;
    (*
  let parse_int_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Int.of_string s;;
    
  let parse_optional_int_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Int.of_string s in Some i
    | None -> None;;
     *)

  let parse_int64_field_exn ~fieldname ~results ~arrayofstring =
    try
      let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
      Core_int64_extended.of_string s
    with err ->
	 let () = print_n_flush "\nutilities::parse_int64_field_exn() failed" in
	 raise err;;

  let parse_int32_field_exn ~fieldname ~results ~arrayofstring =
    try
      let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
      Core_int32_extended.of_string s
    with err ->
      let () = print_n_flush "\nutilities::parse_int32_field_exn() failed" in
      raise err;;
    
(*  let parse_optional_int_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Int.of_string s in Some i
    | None -> None;;*)
    
  let parse_optional_int64_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Int64.of_string s in Some i
    | None -> None;;

  let parse_optional_int32_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Int32.of_string s in Some i
    | None -> None;;
    
  let parse_uint8_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint8_extended.of_string s;;

  let parse_optional_uint8_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint8_extended.of_string s in Some i
    | None -> None;;

  let parse_uint16_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint16_extended.of_string s;;

  let parse_optional_uint16_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint16_extended.of_string s in Some i
    | None -> None;;

  let parse_uint32_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint32_extended.of_string s;;

  let parse_optional_uint32_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint32_extended.of_string s in Some i
    | None -> None;;

  let parse_uint64_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint64_extended.of_string s;;

  let parse_optional_uint64_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint64_extended.of_string s in Some i
    | None -> None;;
    
  (*-----booleans------*)
  let parse_bool_field_exn ~fieldname ~results ~arrayofstring = 
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    parse_boolean_field_exn ~field:s;;

  let parse_optional_bool_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let b = parse_boolean_field_exn ~field:s in Some b
    | None -> None;;
  (*----------------floats--------------*)
  let parse_float_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Core.Float.of_string s;;

  let parse_optional_float_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let f = Core.Float.of_string s in Some f
    | None -> None;;
  (*----------------date and time--------------*)
  let parse_date_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
    Core.Date.of_string s;;

  let parse_optional_date_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let dt = Core.Date.of_string s in Some dt
    | None -> None;;

  let parse_time_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
    Core_time_extended.of_string s;;

  let parse_optional_time_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let dt = Core_time_extended.of_string s in Some dt
    | None -> None;;

end
