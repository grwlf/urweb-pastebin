module Cake_Pastebin where

import Development.Cake3
import Development.Cake3.Ext.UrWeb
import Cake_Pastebin_P

import qualified Cake_Bootstrap as Bootstrap hiding(main)
import qualified Cake_MonadPack as MonadPack hiding(main)
import qualified Cake_Callback as Callback hiding(main)
import qualified Cake_RespTabs as RespTabs


(app,db) = uwapp_postgres (file "Pastebin.urp") $ do
  library Bootstrap.lib
  library MonadPack.lib
  library Callback.lib
  library RespTabs.lib

  allow mime "text/javascript"
  allow mime "text/css"
  safeGet "Pastebin/main"
  safeGet "Pastebin/monitor"
  safeGet "Pastebin/pview"
  safeGet "Pastebin/gview"
  safeGet "Pastebin/gnew"
  safeGet "Pastebin/pnew"
  safeGet "Job/callback"
  safeGet "Pastebin/J/callback"
  safeGet "Pastebin/J/C/callback"

  ur (sys "option")
  ur (file "Cb.ur")
  -- ur (pair "Job3.ur")
  ur (file "Pastebin.ur")

main = writeDefaultMakefiles $ do

  rule $ do
    phony "dropdb"
    depend db

  rule $ do
    phony "run"
    shell [cmd|$(app)|]

  rule $ do
    phony "all"
    depend app

