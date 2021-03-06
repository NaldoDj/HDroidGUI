/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDActivity - Activity class
 */

#include "hbclass.ch"
#include "error.ch"

#define MAX_BACKUPW  16

CLASS HDGUIObject

   CLASS VAR oDefaultParent SHARED

   DATA cargo

ENDCLASS

CLASS HDWindow INHERIT HDGUIObject

   CLASS VAR aWindows SHARED  INIT {}
   CLASS VAR aBackupW SHARED  INIT {}
   CLASS VAR nIdSch   SHARED  INIT 1
   CLASS VAR lMain    SHARED  INIT .T.
   CLASS VAR nIdWdg   SHARED  INIT 1

   DATA id
   DATA title
   DATA bInit, bExit, bBack

   DATA aItems   INIT {}

   METHOD New( cTitle, bInit, bExit )
   METHOD Init()
   METHOD Close( cId )
   METHOD FindByName( cName )

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDWindow

   ::oDefaultParent := Self

   ::title := cTitle
   IF ::lMain
      ::id := "0"
      ::lMain := .F.
   ELSE
      ::id := Ltrim( Str( ++::nIdSch ) )
   ENDIF

   ::bInit := bInit
   ::bExit := bExit

   Aadd( ::aWindows, Self )

   RETURN Self

METHOD Init() CLASS HDWindow

   IF !Empty( ::bInit )
      Eval( ::bInit )
   ENDIF
   RETURN Nil

METHOD Close( cId ) CLASS HDWindow
   LOCAL i, o

   IF !Empty( ::aWindows )
      FOR i := Len( ::aWindows ) TO 1 STEP -1
         IF ( cId == Nil .AND. ::aWindows[i] == Self ) .OR. ( cId != Nil .AND. ::aWindows[i]:id == cId )
            o := ::aWindows[i]
            IF Len( ::aBackupW ) < MAX_BACKUPW
               Aadd( ::aBackupW, o )
            ELSE
               ADel( ::aBackupW, 1 )
               ::aBackupW[MAX_BACKUPW] := o
            ENDIF
            ADel( ::aWindows, i )
            ASize( ::aWindows, Len(::aWindows)-1 )
            EXIT
         ENDIF
      NEXT
      IF !Empty(o) .AND. Valtype( o:bExit ) == "B"
         Eval( o:bExit, o )
      ENDIF
   ENDIF

   RETURN Nil

METHOD FindByName( cName ) CLASS HDWindow
 
   LOCAL aItems := ::aItems, oItem, o

   FOR EACH oItem IN aItems
      IF !Empty( oItem:objname ) .AND. oItem:objname == cName
         RETURN oItem
      ELSEIF __ObjHasMsg( oItem, "AITEMS" ) .AND. !Empty( o := oItem:FindByName( cName ) )
         RETURN o
      ENDIF
   NEXT

   RETURN Nil

CLASS HDActivity INHERIT HDWindow

   DATA oFont
   DATA aMenu
   DATA oStyleHead
   DATA lNoTitle  INIT .F.

   METHOD New( cTitle, bInit, bExit )
   METHOD Activate()

   METHOD AddMenu( nId, cTitle )
   METHOD EndMenu()
   METHOD AddMenuItem( cTitle, nId, bAction )

   METHOD ToArray()
   ERROR HANDLER OnError()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDActivity

   ::Super:New( cTitle, bInit, bExit )
   IF cTitle == Nil
      ::lNoTitle := .T.
   ENDIF

   RETURN Self

METHOD Activate() CLASS HDActivity

   local s := hb_jsonEncode( ::ToArray() )
   //hd_wrlog( s )
   hd_calljava_s_v( s, "activ" )

   RETURN Nil

METHOD AddMenu( nId, cTitle ) CLASS HDActivity

   IF Valtype( ::aMenu ) == "A"
   ELSE
      ::aMenu := {}
   ENDIF

   RETURN Nil

METHOD EndMenu() CLASS HDActivity

   RETURN Nil

METHOD AddMenuItem( cTitle, nId, bAction ) CLASS HDActivity

   LOCAL nLen

   IF Valtype( ::aMenu ) != "A"
      RETURN Nil
   ENDIF

   nLen := Len( ::aMenu )
   IF nLen > 0 .AND. Len( ::aMenu[nLen] ) > 3
   ELSE
      nLen ++
      nId := Iif( nId == Nil, nLen, nId )
      AAdd( ::aMenu, { cTitle, nId, bAction } )
   ENDIF

   RETURN Nil

METHOD ToArray() CLASS HDActivity

   LOCAL arr := { "act:" + ::id }, arr2, i

   IF !Empty( ::title )
      Aadd( arr, "t:" + ::title )
   ENDIF
   IF ::lNoTitle
      Aadd( arr, "notitle:1" )
   ENDIF
   IF ::oStyleHead != Nil
      IF Valtype( ::oStyleHead ) == "O"
         Aadd( arr, "stlh:" + Ltrim(Str(::oStyleHead:id)) )
      ENDIF
   ENDIF

   IF !Empty( ::aMenu )
      Aadd( arr, arr2 := { "menu" } )
      FOR i := 1 TO Len( ::aMenu )
         Aadd( arr2, ::aMenu[i,1] )
      NEXT
   ENDIF
   IF !Empty( ::aItems )     
      Aadd( arr, ::aItems[1]:ToArray() )
   ENDIF

   RETURN arr

METHOD OnError() CLASS HDActivity

   LOCAL cMsg := __GetMessage()
   LOCAL oError
   LOCAL oItem

   IF ( oItem := ::FindByName( cMsg ) ) != Nil
      RETURN oItem
   ENDIF

   oError := ErrorNew()
   oError:severity    := ES_ERROR
   oError:genCode     := EG_LIMIT
   oError:subSystem   := "HCUSTOMWINDOW"
   oError:subCode     := 0
   oError:description := "Invalid class member"
   oError:canRetry    := .F.
   oError:canDefault  := .F.
   oError:fileName    := ""
   oError:osCode      := 0

   Eval( ErrorBlock(), oError )
   __errInHandler()

   RETURN NIL


CLASS HDDialog INHERIT HDWindow

   DATA aButtons
   DATA nRes, aRes

   METHOD New( cTitle, bInit, bExit )
   METHOD Activate()

   METHOD onBtnClick( cName )

   METHOD ToArray()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDDialog

   ::Super:New( cTitle, bInit, bExit )

   RETURN Self

METHOD Activate() CLASS HDDialog

   LOCAL i, nlen := Len( ::aItems )

   ::aButtons := {}
   FOR i := 1 TO nlen
      IF ::aItems[i]:classname == "HDBUTTON"
         Aadd( ::aButtons, ::aItems[i]:objName )
      ENDIF
   NEXT

   hd_calljava_s_v( hb_jsonEncode( ::ToArray() ), "adlg" )

   RETURN Nil


METHOD onBtnClick( cName ) CLASS HDDialog

   LOCAL arr, cBtn, nPos

   IF ( nPos := At( "[", cName ) ) != 0
      cBtn := Left( cName, nPos-1 )
      hb_jsonDecode( Substr( cName, nPos ), @arr )
      ::aRes := arr
   ELSE
      cBtn := cName
   ENDIF

   IF !Empty( ::aButtons )
      ::nRes := Ascan( ::aButtons, cBtn )
   ENDIF

   ::Close()

   RETURN "1"

METHOD ToArray() CLASS HDDialog

   LOCAL arr := { "dlg:" + ::id, "t:" + ::title, {} }, i, nLen := Len( ::aItems )

   FOR i := 1 TO nLen
      Aadd( Atail(arr), ::aItems[i]:ToArray() )
   NEXT

   RETURN arr


CLASS HDTimer INHERIT HDGUIObject

   CLASS VAR aTimers       INIT {}
   CLASS VAR nId SHARED    INIT 0

   DATA id
   DATA value
   DATA bAction

   METHOD New( value, bAction )
   METHOD TimerFunc( id )
   METHOD End()

ENDCLASS

METHOD New( value, bAction ) CLASS HDTimer

   ::id := LTrim( Str( ++::nId ) )
   ::value   := value
   ::bAction := bAction

   AAdd( ::aTimers, Self )
   hd_calljava_s_v( "set:" + ::id + ":" + LTrim( Str( ::value ) ), "timer" )

   RETURN Self

METHOD TimerFunc( id ) CLASS HDTimer

   LOCAL i

   FOR i := 1 TO Len( ::aTimers )
      IF ::aTimers[i]:id == id
         Eval( ::aTimers[i]:bAction, ::aTimers[i] )
         EXIT
      ENDIF
   NEXT

   RETURN ""

METHOD End() CLASS HDTimer

   LOCAL i := Ascan( ::aTimers, { |o|o:id == ::id } )

   IF i != 0
      ADel( ::aTimers, i )
      ASize( ::aTimers, Len( ::aTimers ) - 1 )
   ENDIF

   hd_calljava_s_v( "kill:" + ::id, "timer" )

   RETURN Nil

CLASS HDNotify INHERIT HDGUIObject

   CLASS VAR nId SHARED    INIT 100

   DATA id
   DATA lLight, lSound, lVibr
   DATA cTitle
   DATA cText
   DATA cSubtext

   METHOD New( lLight, lSound, lVibr, cTitle, cText, cSubtext )
   METHOD Run()

ENDCLASS

METHOD New( lLight, lSound, lVibr, cTitle, cText, cSubtext ) CLASS HDNotify

   ::id := Ltrim(Str( ++::nId ))
   ::lLight   := lLight
   ::lSound   := lSound
   ::lVibr    := lVibr
   ::cTitle   := Iif( Empty( cTitle ), "", cTitle )
   ::cText    := Iif( Empty( cText ), "", cText )
   ::cSubtext := Iif( Empty( cSubtext ), "", cSubtext )

   RETURN Self

METHOD Run() CLASS HDNotify
   RETURN hd_calljava_s_v( ::id + ",," + Iif(Empty(::lLight),"n","y") + ;
      Iif(Empty(::lSound),"n","y") + Iif(Empty(::lVibr),"n","y") + ",," + ;
      ::cTitle + ",," + ::cText + ",," + ::cSubtext + ",,", "notify" )
