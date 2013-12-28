
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

fun callback c x =
  let 
    val e = Option.unsafeGet x.ExitCode
    val so = x.Stdout
  in
    send c {ExitCode=e, Stdout=so}
  end

structure J = Job2.Make(
  struct
    val fl = callback
    val fr = callback
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
      s <- source <xml/>;
      c <- channel;
      r <- J.monitor jr c;
      template'
        ( r <- recv c;
          set s <xml>{[r.Stdout]}</xml> )
        ( f <- form' "oldsource here";
          return
            <xml>
              {f}
              <hr/>
              <dyn signal={signal s}/>
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

