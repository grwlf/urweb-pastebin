
datatype aval t = Ready of t | Future of (channel t) * (source t)

val getXml : aval xbody -> xbody 

