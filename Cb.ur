
datatype aval t = Ready of t | Future of (channel t) * (source t)

fun getXml a =
  case a of
      Ready p => p
    | Future (c,s) =>
        <xml>
          <dyn signal={signal s}/>
          <active code={spawn (v <- recv c; set s v); return <xml/>}/>
        </xml>

