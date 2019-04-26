module Date_time_extended : sig
  (*type t = Core.Time.t*)
  include (module type of Core.Time)
  
  val show : t -> Ppx_deriving_runtime.string
  val pp : Format.formatter -> t -> Ppx_deriving_runtime.unit
				      
  (*val to_string : t -> string*)
  val of_string : string -> t
	  
  val compare : t -> t -> Ppx_deriving_runtime.int
  val equal : t -> t -> Ppx_deriving_runtime.bool
			  
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> t Ppx_deriving_yojson_runtime.error_or
(*
  val to_xml : t -> Csvfields.Xml.xml list
  val of_xml : Csvfields.Xml.xml -> t
  val xsd : Csvfields.Xml.xml list*)
end
