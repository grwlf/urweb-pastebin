
sequence pasteTId
sequence pasteId
table paste : { Id : int, TId : int, Text : string, JobRef : int }

table comments : {Id : int, Text : string, TId : int}

structure J = Job3.Make(
  struct
    val f = fn x => return (<xml>{[x.Stdout]}</xml> : xbody)
  end)

fun recent (n:int) : transaction xbody =
  queryX (SELECT * FROM paste LIMIT {n}) (fn p =>
    <xml><a link={gview p.Paste.Id}>#{[p.Paste.Id]}</a></xml>)

and template fb : transaction page =
  Page.run (
  JQuery.add (
  Bootstrap.add (
  RespTabs.add (fn ftabs =>
  Page.withBody (
    b <- fb ftabs;
    r <- recent 50;
    return
      <xml>
        <div class={Bootstrap.container}>
          <div class={Bootstrap.row_fluid}>
          <h1>PasteBin in UrWeb</h1>
          </div>
          <div class={Bootstrap.row_fluid}>
            {r}
            <hr/>
          </div>
          <div class={Bootstrap.row_fluid}>
            {b}
          </div>
        </div>
      </xml>
  )))))

and pview (err:string) (pid:option int) =
  template (fn ftabs =>
    let

      fun validate (f:string -> transaction page) (s:{Text:string}) : transaction page = 
        case eq s.Text "" of
          | True => redirect (url (pview "Invalid form value" pid))
          | False => f s.Text

      fun form p : transaction xbody = 
        let

          fun handler (s:{Text:string}) : transaction page =
            case eq s.Text "" of
              | False =>
                  tid <- (case p.TId > 0 of
                    | True => return p.TId
                    | False => nextval pasteTId);
                  pid <- nextval pasteId;
                  jr <- J.create "./compile.sh" s.Text;
                  dml(INSERT INTO paste(Id,TId,Text,JobRef) VALUES ({[pid]},{[tid]},{[s.Text]},{[jr]}));
                  redirect (url (gview pid))
              | True =>
                  redirect (url (pview "Invalid form value" pid))

        in
          return
            <xml>
              <a link={gnew {}}>Create a new paste</a>
              <form>
                <textarea{#Text} style="width:98%;height:300px">
                {[p.Text]}
                </textarea>
                <br/>
                <submit action={handler} value="Compile"/>
              </form>
            </xml>
        end

      fun form_comment p : transaction xbody =
        let
          fun chandler (s:{Text:string}) : transaction page =
            validate (fn s =>
              dml(INSERT INTO comments(Id,Text,TId) VALUES ({[p.Id]},{[s]},{[p.TId]}));
              redirect (url (gview p.Id))) s

          (* fun chandler (s:{Text:string}) : transaction page = *)
          (*   case eq s.Text "" of *)
          (*     | True => *)
          (*         redirect (url (pview "Invalid form value" pid)) *)
          (*     | False => *)
          (*         dml(INSERT INTO comments(Id,Text,TId) VALUES ({[p.Id]},{[s.Text]},{[p.TId]})); *)
          (*         redirect (url (gview p.Id)) *)
        in
          return
            <xml>
              <form>
                <textarea{#Text} style="width:98%;height:100px"></textarea>
                <br/>
                <submit action={chandler} value="Comment"/>
              </form>
            </xml>
        end

    in

      case pid of
        | Some pid =>
            r <- oneRow (SELECT * FROM paste WHERE paste.Id = {[pid]});
            j <- J.monitor r.Paste.JobRef <xml/>;
            f <- form r.Paste;
            t <- ftabs (
              (RespTabs.mktab "Text" "Text" f) ::
              (RespTabs.mktab "Text" "View" <xml>{[r.Paste.Text]}</xml>) ::
              (RespTabs.mktab "Text" "Log" (Cb.getXml j)) ::
              []);
            c <- queryX (SELECT * FROM comments WHERE comments.TId = {[r.Paste.TId]}) (fn r =>
              <xml>
                <div>
                  #{[r.Comments.Id]}
                  <br/>
                  {[r.Comments.Text]}
                  <hr/>
                </div>
              </xml>);
            cf <- form_comment r.Paste;
            return
              <xml>
                {[err]}
                {t}
                <hr/>
                {c}
                {cf}
              </xml>

        | None =>
            f <- form {Id=0,TId=-1,Text="",JobRef=-1};
            t <- ftabs (
              (RespTabs.mktab "Text" "Text" f) ::
              []);
            return
              <xml>
                {[err]}
                <hr/>
                {t}
              </xml>

    end
  )

and gview i = pview "" (Some i)

and gnew {} = pview "" None

and main {} : transaction page = gnew {}

