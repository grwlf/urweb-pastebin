(*
Input to exported function 'FormBug3/handler' involves one or more types that are disallowed for page handler inputs: Basis.url
*)

fun template (mb:transaction xbody) : transaction page =
    b <- mb;
    return
      <xml>
        <head/>
        <body>
          <h1>PasteBin in UrWeb </h1>
          {b}
        </body>
      </xml>

fun validate_and_apply f = return {}

fun handler (u:url) (f:{Text:string}) : transaction page = validate_and_apply f ; redirect u

fun form (u:url) : transaction xbody =
  return <xml><form>
    <textarea{#Text}/>
    <submit action={handler u}/>
  </form></xml>

fun viewA (idx:int) = template ( f<- form (url (viewA idx)); return <xml>{f}</xml>)
fun viewB (idx:int) = template ( f<- form (url (viewB idx)); return <xml>{f}</xml>)


fun main {} = viewA 0

