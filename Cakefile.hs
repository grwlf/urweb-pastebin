module Cakefile where

import Development.Cake3
import Development.Cake3.Ext.UrWeb
import Cakefile_P

instance IsString File where fromString = file

project = do

  let dbn = "Pastebin"

  a <- uwapp "-dbms postgres" "Pastebin.urp" $ do
    ur (sys "option")
    ur (pair "Cb.ur")
    ur (pair "Job3.ur")
    ur (pair "Pastebin.ur")
    safeGet "Pastebin/main"
    safeGet "Pastebin/monitor"
    safeGet "Pastebin/pview"
    safeGet "Pastebin/gview"
    safeGet "Pastebin/gnew"
    safeGet "Pastebin/pnew"
    safeGet "Job/callback"
    safeGet "Pastebin/J/callback"
    allow mime "text/javascript"
    allow mime "text/css"
    database ("dbname="++dbn)
    sql "Pastebin.sql"
    library' (externalMake "../urweb-callback/lib.urp")
    library' (externalMake "../urweb-monad-pack/lib.urp")
    library' (externalMake "../uru/lib.urp")
    debug

  db2 <- rule $ do
    phony "db"
    shell [cmd|dropdb --if-exists $(string dbn)|]
    shell [cmd|createdb $(string dbn)|]
    shell [cmd|psql -f $(urpSql (toUrp a)) $(string dbn)|]

  rule $ do
    phony "clean"
    unsafeShell [cmd|rm -rf .cake3 $(tempfiles a)|]

  rule $ do
    phony "all"
    depend a

main = do
  writeMake (file "Makefile") (project)
  writeMake (file "Makefile.devel") (selfUpdate >> project)

