type jobref = Callback.jobref

table jobs : {JobRef: int, ExitCode : option int, Cmd : string, Stdin : string, Stdout : string}

table handles : {JobRef : int, Channel : channel jobst}

fun callback (jr:jobref) : transaction page =
  j <- Callback.deref jr;
  ec <- (return (Callback.exitcode j));
  so <- (return (Callback.stdout j));
  dml( UPDATE jobs SET ExitCode = {[Some ec]}, Stdout = {[so]} WHERE JobRef = {[jr]});
  query1 (SELECT * FROM handles WHERE handles.JobRef = {[jr]}) (fn r s =>
    send r.Channel {ExitCode = ec, Stdout = so};
    return s) {};
  dml (DELETE FROM handles WHERE JobRef = {[jr]});
  Callback.cleanup j;
  return <xml/>

fun create (cmd:string) (inp:string) : transaction jobref =
  j <- Callback.create cmd inp 1024;
  jr <- (return (Callback.ref j));
  dml(INSERT INTO jobs(JobRef,ExitCode,Cmd,Stdin,Stdout) VALUES ({[jr]}, {[None]}, {[cmd]}, {[inp]}, ""));
  Callback.run j (url (callback jr));
  return jr

fun monitor (jr:jobref) (c:channel jobst) : transaction unit =
  r <- oneRow (SELECT jobs.ExitCode, jobs.Stdout FROM jobs WHERE jobs.JobRef = {[jr]});
  case r.Jobs.ExitCode of
      None => dml (INSERT INTO handles(JobRef,Channel) VALUES ({[jr]}, {[c]}))
    | Some (ec:int) => send c {ExitCode = ec, Stdout = r.Jobs.Stdout};
  return {}
  
  
