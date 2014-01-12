
(*

 $ urweb -version
 The Ur/Web compiler, version 20131124 + 95aa74b577e3 tip

 $ urweb -dbms sqlite FormBug2
 :0:0: (to 0:0) Duplicate HTTP tag validator
 :0:0: (to 0:0) Function pnew needed for both a link and a form
 Make sure that the signature of the containing module hides any form handlers.
 :0:0: (to 0:0) Function pview needed for both a link and a form
 Make sure that the signature of the containing module hides any form handlers.

*)


sequence adv_s
table adv : {Id: int, Text : string}

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

fun validator (fview : int -> url) (ferr : string -> url) (i:int) (s:{Text:string}) : transaction page = 
  case eq s.Text "" of
      True =>
        redirect (ferr "Invalid form value")
    | False =>
        i <- nextval adv_s;
        dml(INSERT INTO adv (Id, Text) VALUES ({[i]}, {[s.Text]}));
        redirect (fview i)

fun form (fview : int -> url) (ferr : string -> url) (i:int) (sd:string) : transaction xbody = 
  return
    <xml>
      <form>
        <textarea{#Text}>
        {[sd]}
        </textarea>
        <br/>
        <submit action={validator fview ferr i}/>
      </form>
    </xml>

fun pview (err:string) (pid:int) =
  s <- oneRow(SELECT * FROM adv WHERE adv.Id = {[pid]});
  f <- form 
          (fn pid' => url (pview "" pid'))
          (fn e => url (pview e pid))
          0 s.Adv.Text;
  template (return
    <xml>
      {[err]}
      <hr/>
      {f}
    </xml>)

fun pnew (err:string) : transaction page =
  f <- form
        (fn i => url (pview "" i))
        (fn e => url (pnew e))
        1 "";
  template(
    return
      <xml>
        {[err]}
        <hr/>
        {f}
      </xml>)

fun main {} : transaction page =
  pnew ""

