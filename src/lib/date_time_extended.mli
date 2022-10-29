module Date_time_extended : sig
  (*type t = Core.Time.t*)
  include (module type of Core.Time)
  
  val show : ?zoneoffset:int -> t -> Ppx_deriving_runtime.string

  val to_string : ?zoneoffset:int -> t -> string
  (*of_string internally supports parsing date time values without time zone 
   offsets since mysql does not display time zone offsets even if a time zone 
   offset was supplied when inserting the value.*)
  val of_string : ?zoneoffset:int -> string -> t
	  
  val compare : t -> t -> Ppx_deriving_runtime.int
  val equal : t -> t -> Ppx_deriving_runtime.bool

  (*Type json changed to type t sometime after 4.06.0*)		  
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> t Ppx_deriving_yojson_runtime.error_or
(*Not useful unless have local hacked version of csvfields
 MUST use these
  val to_xml : t -> Csvfields.Xml.xml list
  val of_xml : Csvfields.Xml.xml -> t
  val xsd : Csvfields.Xml.xml list*)
end
