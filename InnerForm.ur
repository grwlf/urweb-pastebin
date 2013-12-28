fun template' (h: transaction unit) (mb:transaction xbody) : transaction page =
  b <- mb;
  return
    <xml>
      <head/>
      <body onload={h}>
      <h1>PasteBin in UrWeb </h1>
      {b}
      </body>
    </xml>

fun template mb = template' (return {}) mb


type nested = {A : string}
type nested2 = {A2 : string}
type tl = {N : nested , N2 : nested2}

fun topl (a1:tl) : transaction page =
  let
    fun handler (a:nested) =
      redirect (url (topl (a1 -- #N ++ {N = a})))

    fun nestedform (a:nested) : transaction xbody =
      return <xml>
          <form>
            <textarea{#A}>{[a.A]}</textarea>
            <submit action={handler}/>
          </form>
        </xml>

    fun handler2 (a:nested2) = 
      redirect (url (topl (a1 -- #N2 ++ {N2 = a})))

    fun nestedform2 (a:nested2) : transaction xbody =
      return <xml>
          <form>
            <textarea{#A2}>{[a.A2]}</textarea>
            <submit action={handler2}/>
          </form>
        </xml>
      
  in
    template (
      f1 <- nestedform a1.N;
      f2 <- nestedform2 a1.N2;
      return
        <xml>
          {f1}
          <hr/>
          {f2}
        </xml>
    )
  end

fun main {} : transaction page = topl {N = {A = "aaa"}, N2 ={ A2= "bbb"}}

