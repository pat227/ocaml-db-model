module Date_extended : sig
  (*type t = Core.Date.t*)
  include (module type of Core.Date)  
  val show : t -> Ppx_deriving_runtime.string
  val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
  val to_string : t -> string
  val of_string_exn : string -> t
  val compare : t -> t -> Ppx_deriving_runtime.int
  val equal : t -> t -> Ppx_deriving_runtime.bool
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or

  val sexp_of_t : t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> t

  (*MUST use these*)
  val to_xml : t -> Csvfields.Xml.xml list
  val of_xml : Csvfields.Xml.xml -> t
  val xsd : Csvfields.Xml.xml list

(*  CANNOT USE THESE

>   val to_xml : t -> Xml_light.Xml.xml list
>   val of_xml : Xml_light.Xml.xml -> t
>   val xsd : Xml_light.Xml.xml list*)

end
