module Cakefile where

import Development.Cake3
import Development.Cake3.Ext.UrWeb
import Cakefile_P

instance IsString File where fromString = file

project = do

  a <- uwapp "-dbms sqlite" "Pastebin.urp" $ do
    ur (sys "option")
    ur (pair "Job.ur")
    ur (pair "Job2.ur")
    ur (pair "Pastebin.ur")
    safeGet "Pastebin/main"
    safeGet "Pastebin/monitor"
    safeGet "Job/callback"
    safeGet "Pastebin/J/callback"
    allow mime "text/javascript"
    allow mime "text/css"
    database "dbname=Pastebin.db"
    sql "Pastebin.sql"
    library' (externalMake "../urweb-callback/lib.urp")
    debug

  db2 <- rule $do
    let db = file "Pastebin.db"
    shell [cmd|-rm @db|]
    shell [cmd|touch @db|]
    shell [cmd|sqlite3 @db < $(urpSql (toUrp a)) |]

  rule $ do
    phony "clean"
    unsafeShell [cmd|rm -rf .cake3 $(tempfiles a)|]

  rule $ do
    phony "all"
    depend a
    depend db2

main = do
  writeMake (file "Makefile") (project)
  writeMake (file "Makefile.devel") (selfUpdate >> project)

