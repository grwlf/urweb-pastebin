
structure E = Error.Trans(struct con m = Pure.pure end)

fun when [a ::: (Type -> Type)] (v:monad a) (b:bool) (m:a {}) = if b then m else return {}

sequence pasteTId
sequence pasteId
table paste : { Id : int, TId : int, Text : string, JobRef : int }

sequence commentId
table comments : {Id : int, Text : string, TId : int}

structure J = Callback.Make(
  struct
    val f = fn x => return (<xml>{[x.Stdout]}</xml> : xbody)
  end)

fun validate s = Pure.run (E.run (
  when (eq s.Text "") (E.fail "empty text");
  when (eq s.UserName "") (E.fail "empty user");
  return {}))

fun recent (n:int) : transaction xbody =
  queryX (SELECT * FROM paste LIMIT {n}) (fn p =>
    <xml><a link={gview p.Paste.Id}>#{[p.Paste.Id]}</a></xml>)

and template fb : transaction page =
  Uru.run (
  JQuery.add (
  Bootstrap.add (
  RespTabs.add (fn ftabs =>
  Uru.withBody ( fn _ =>
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

      fun form p : transaction xbody = 
        let

          fun handler s : transaction page =
            case validate s of
              | Error.ERight {} =>
                  tid <- (case p.TId > 0 of
                    | True => return p.TId
                    | False => nextval pasteTId);
                  pid <- nextval pasteId;
                  jr <- J.create "./compile.sh" s.Text;
                  dml(INSERT INTO paste(Id,TId,Text,JobRef) VALUES ({[pid]},{[tid]},{[s.Text]},{[jr]}));
                  redirect (url (gview pid))
              | Error.ELeft (e:string) =>
                  redirect (url (pview e pid))

        in
          return
            <xml>
              <a link={gnew {}}>Create a new paste</a>
              <form>
                <textarea{#Text} style="width:98%;height:300px">
                {[p.Text]}
                </textarea>
                <br/>
                User name: <textbox{#UserName} value=""/>
                <br/>
                <submit action={handler} value="Compile"/>
              </form>
            </xml>
        end

      fun form_comment p : transaction xbody =
        let
          fun chandler (s:{Text:string}) : transaction page =
            case eq s.Text "" of
              | True =>
                  redirect (url (pview "Invalid form value" pid))
              | False =>
                  cid <- nextval commentId;
                  dml(INSERT INTO comments(Id,Text,TId) VALUES ({[cid]},{[s.Text]},{[p.TId]}));
                  redirect (url (gview p.Id))
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
              (RespTabs.mktab "Text" "Log" (Callback.getXml j)) ::
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

