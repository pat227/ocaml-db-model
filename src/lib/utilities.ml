(*===TODO===Need to make a verison of this file as part of the output so that we can
share functions from here instead of repeating them, to allow easier refactoring, etc *)
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

  let parse_optional_boolean_field field =
    match field with
    | None -> None
    | Some s -> Some ((fun x ->
		 match x with
		   "1" -> true
		 | "0" -> false
		 | "true"
		 | "TRUE" -> true
		 | "false" 
		 | "FALSE" -> false
		 | _ -> raise (Failure "Utilities::parse_optional_boolean_field unrecognized value")
		) s)
  let parse_int_field_exn field =
    match field with
    | None -> raise (Failure "utilities::parse_optional_int_field optional string was NONE")
    | Some s -> Int.of_string s

  let parse_int_field_option field =
    match field with
    | None -> None
    | Some s -> Some (parse_int_field_exn field)

  let parse_string_field field =
    field
		     
  let parse_int_field field =
    Int.of_string field
		  
  let parse_64bit_int_field field =
    Core.Std.Int64.of_string field

  let parse_boolean_field field =
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

  (*--do not repeat this boilerplate within modules anymore---*)
  let extract_field_as_string ~fieldname ~results ~arrayofstring =
    String.strip
      ~drop:Char.is_whitespace
      (Option.value_exn
	 ~message:("Failed to get col " ^ fieldname)
	 (Mysql.column results
		       ~key:fieldname ~row:arrayofstring));;

  let extract_optional_field ~fieldname ~results ~arrayofstring =
    Mysql.column results ~key:fieldname ~row:arrayofstring;;

  let parse_mysql_int_field ~fieldname ~results ~arrayofstring =
    let s = extract_field_as_string ~fieldname ~results ~arrayofstring in 
    parse_int_field s;;

  let parse_mysql_optional_int_field ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field_as_string ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let i = parse_int_field s in Some i
    | None -> None;;

  let parse_mysql_bool_field ~fieldname ~results ~arrayofstring = 
    let s = extract_field_as_string ~fieldname ~results ~arrayofstring in 
    parse_boolean_field s;;

  let parse_mysql_optional_bool_field ~fieldname ~results ~arrayofstring =
    let s_opt = extract_optional_field_as_string ~fieldname ~results ~arrayofstring in
    match s_opt with
    | Some s -> let b = parse_boolean_field s in Some b
    | None -> None;;  
    
end 
