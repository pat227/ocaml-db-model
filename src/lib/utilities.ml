(*===TODO===Need to make a verison of this file as part of the output so that we can
share functions from here instead of repeating them, to allow easier refactoring, etc *)
module Uint8_w_sexp = Uint8_w_sexp.Uint8_w_sexp
module Uint16_w_sexp = Uint16_w_sexp.Uint16_w_sexp
module Uint32_w_sexp = Uint32_w_sexp.Uint32_w_sexp
module Uint64_w_sexp = Uint64_w_sexp.Uint64_w_sexp
module Mysql = Mysql
open Core.Std
module Utilities = struct

  let oc = Core.Std.Out_channel.stdout;;    
  let print_n_flush s =
    let open Core.Std in 
    Out_channel.output_string oc s;
    Out_channel.flush oc;;

  let getcon ?(host="127.0.0.1") ~database ~password ~user =
    let open Mysql in 
    quick_connect
      ~host ~database ~password ~user ();;
    
  let getcon_defaults () = raise (Failure "Parameterless db connections no longer supported") 
    (*getcon ~host:"127.0.0.1" ~database:"test_model" ~password:"root" ~user:"root";;*)
    
  let closecon c = Mysql.disconnect c;;

  let oc = Core.Std.Out_channel.stdout;;    
  let print_n_flush s =
    Core.Std.Out_channel.output_string oc s;
    Core.Std.Out_channel.flush oc;;

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
    let open Core.Std in 
    match field with
    | Some f -> Int.to_string (Float.to_int (f *. 100.0))
    | None -> "NULL";;
  let serialize_float_field_as_int ~field =
    let open Core.Std in 
    Int.to_string (Float.to_int (field *. 100.0));;

  (*===========parsers=============*)
    
  let parse_boolean_field_exn ~field =
    match field with
      "1" -> true
    | "0" -> false
    | "YES"
    | "true"
    | "TRUE" -> true
    | "NO" 
    | "false" 
    | "FALSE" -> false
    | _ -> raise (Failure "Utilities::parse_boolean_field unrecognized value")
    
  let parse_optional_boolean_field_exn ~field =
    match field with
    | None -> None
    | Some s ->
       let b = parse_boolean_field_exn ~field:s in
       Some b;;
		  
  let parse_64bit_int_field_exn ~field =
    Core.Std.Int64.of_string field

  let extract_field_as_string_exn ~fieldname ~results ~arrayofstring =
    try
      String.strip
	~drop:Char.is_whitespace
	(Option.value_exn
	   ~message:("Failed to get col " ^ fieldname)
	   (Mysql.column results
			 ~key:fieldname ~row:arrayofstring))
    with
    | _ -> let () = print_n_flush ("\nutilities.ml::extract_field_as_string_exn() failed. \
				    most likely bad field name:" ^ fieldname) in
	   raise (Failure "utilities.ml::extract_field_as_string_exn() failed. \
			   most likely bad field name")

  let extract_optional_field ~fieldname ~results ~arrayofstring =
    Mysql.column results ~key:fieldname ~row:arrayofstring;;
    
  let parse_int_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Int.of_string s;;
    
  let parse_optional_int_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Int.of_string s in Some i
    | None -> None;;

  let parse_uint8_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint8_w_sexp.of_string s;;

  let parse_optional_uint8_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint8_w_sexp.of_string s in Some i
    | None -> None;;

  let parse_uint16_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint16_w_sexp.of_string s;;

  let parse_optional_uint16_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint16_w_sexp.of_string s in Some i
    | None -> None;;

  let parse_uint32_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint32_w_sexp.of_string s;;

  let parse_optional_uint32_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint32_w_sexp.of_string s in Some i
    | None -> None;;

  let parse_uint64_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Uint64_w_sexp.of_string s;;

  let parse_optional_uint64_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = Uint64_w_sexp.of_string s in Some i
    | None -> None;;
    
  (*-----booleans------*)
  let parse_bool_field_exn ~fieldname ~results ~arrayofstring = 
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    parse_boolean_field_exn s;;

  let parse_optional_bool_field ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let b = parse_boolean_field_exn s in Some b
    | None -> None;;
  (*----------------floats--------------*)
  let parse_float_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in 
    Core.Std.Float.of_string s;;

  let parse_optional_float_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let f = Core.Std.Float.of_string s in Some f
    | None -> None;;
  (*----------------date and time--------------*)
  let parse_date_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
    Core.Std.Date.of_string s;;

  let parse_optional_date_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let dt = Core.Std.Date.of_string s in Some dt
    | None -> None;;

  let parse_time_field_exn ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string_exn ~fieldname ~results ~arrayofstring in
    Core.Std.Time.of_string s;;

  let parse_optional_time_field_exn ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let dt = Core.Std.Time.of_string s in Some dt
    | None -> None;;

end
