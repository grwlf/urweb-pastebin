
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

structure J = Job3.Make(
  struct
    val f = fn x => return (<xml>{[x.Stdout]}</xml> : xbody)
  end)

fun form {} : transaction xbody = 
  let

    fun form' (s:string) =
      return
      <xml>
        <form>
          <textarea{#Text}>
          {[s]}
          </textarea>
          <br/>
          <submit action={validator}/>
        </form>
      </xml>

    and retry {} : transaction page = template (
      f <- form {};
      return
        <xml>
          String is empty, try again
          <hr/>
          {f}
        </xml>)

    and monitor jr : transaction page =
        a <- J.monitor jr <xml/>;
        template (
          f <- form' "oldsource here";
          return
            <xml>
              {f}
              <hr/>
              {Cb.getXml a}
            </xml>)

    and handler s : transaction page = 
      jr <- J.create "./compile.sh" s.Text;
      redirect (url (monitor jr))

    and validator s : transaction page = 
      case s.Text = "" of
          True => retry {}
        | False => handler s
  in
    form' ""
  end

fun main {} : transaction page = template (
  f <- form {};
  return <xml>{f}</xml>)

