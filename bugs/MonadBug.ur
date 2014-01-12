(*
dev:[grwlf@greyblade:~/proj/urweb-pastebin]$ urweb  MonadBug
/home/grwlf/proj/urweb-pastebin/MonadBug.ur:15:17: (to 15:51) Don't know how to encode attribute/URL type
Type:
{Text : FFI(Basis.string), UserName : FFI(Basis.string)} ->
 UNBOUND_DATATYPE_1455
*)


structure E = Error.Trans(struct con m = Pure.pure end)

fun when [a ::: (Type -> Type)] (v:monad a) (b:bool) (m:a {}) = if b then m else return {}

fun validate (s:{Text:string, UserName:string}) : Error.either string int = Pure.run (E.run (
  when (eq s.Text "") (E.fail "empty text");
  when (eq s.UserName "") (E.fail "empty user");
  return 1))


and main {} : transaction page = 
  let

    fun validate (s:{Text:string, UserName:string}) : Error.either string int = Pure.run (E.run (
      when (eq s.Text "") (E.fail "empty text");
      when (eq s.UserName "") (E.fail "empty user");
      return 1))


    fun form {} : transaction xbody = 
      let

        fun handler s : transaction page =
          case validate s of
            | Error.ERight (i:int) =>
                debug ("i=" ^ (show i));
                redirect (url (fview {}))
            | Error.ELeft (e:string) =>
                debug ("e=" ^ e);
                redirect (url (fview {}))

      in
        return
          <xml>
            <form>
              <textarea{#Text} style="width:98%;height:300px"/>
              <br/>
              User name: <textbox{#UserName} value=""/>
              <br/>
              <submit action={handler} value="Send"/>
            </form>
          </xml>
      end

  in
  r <- (return (validate {Text="", UserName="bbb"}));
  v <- (return (case (r:Error.either string int) of
        | Error.ELeft e => <xml>Left {[e]}</xml>
        | Error.ERight x => <xml>Right {[x]}</xml>));
  f <- form {} ;
  return
    <xml>
      <head>
      </head>
      <body>
        Result: {v}
        <br/>
        {f}
      </body>
    </xml>
 end

and fview {} = main {}

