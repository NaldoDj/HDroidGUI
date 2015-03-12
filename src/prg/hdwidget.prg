/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDWidget
 */

#include "hbclass.ch"

Function hd_SetCtrlName( oCtrl, cName )
   LOCAL nPos

   IF !Empty( cName ) .AND. ValType( cName ) == "C" .AND. oCtrl:oParent != Nil .AND. ! "[" $ cName
      IF ( nPos :=  RAt( ":", cName ) ) > 0 .OR. ( nPos :=  RAt( ">", cName ) ) > 0
         cName := SubStr( cName, nPos + 1 )
      ENDIF
      oCtrl:objName := Upper( cName )
   ENDIF

   RETURN Nil

CLASS HDGroup INHERIT HDGUIObject

   DATA oParent
   DATA aItems   INIT {}

   DATA objName

   METHOD New()
   METHOD FindByName( cName )
   METHOD ToString()

ENDCLASS

METHOD New() CLASS HDGroup

   ::oParent := ::oDefaultParent
   ::oDefaultParent := Self
   IF !Empty( ::oParent )
      Aadd( ::oParent:aItems, Self )
   ENDIF

   RETURN Self

METHOD FindByName( cName ) CLASS HDGroup
 
   LOCAL aItems := ::aItems, oItem, o

   FOR EACH oItem IN aItems
      IF !Empty( oItem:objname ) .AND. oItem:objname == cName
         RETURN oItem
      ELSEIF __ObjHasMsg( oItem, "AITEMS" ) .AND. !Empty( o := oItem:FindByName( cName ) )
         RETURN o
      ENDIF
   NEXT

   RETURN Nil

METHOD ToString() CLASS HDGroup

   LOCAL sRet := "[(", i, nLen := Len( ::aItems )

   FOR i := 1 TO nLen
      sRet += ::aItems[i]:ToString() + Iif( i<nLen, ",,/","" )
   NEXT

   RETURN sRet + ")]"

CLASS HDLayout INHERIT HDGroup

   DATA lHorz
   DATA nWidth, nHeight
   DATA nMarginL, nMarginT, nMarginR, nMarginB
   DATA bColor
   DATA oFont

   METHOD New( lHorz, nWidth, nHeight, bcolor, oFont )
   METHOD ToString()

ENDCLASS

METHOD New( lHorz, nWidth, nHeight, bcolor, oFont ) CLASS HDLayout

   ::Super:New()

   ::lHorz := !Empty( lHorz )
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::bColor := bColor

   RETURN Self

METHOD ToString() CLASS HDLayout

   LOCAL sRet := "lay:" + ::objName

   IF !Empty( ::lHorz )
      sRet += ",,o:h"
   ELSE
      sRet += ",,o:v"
   ENDIF
   IF ::nWidth != Nil
      sRet += ",,w:" + Ltrim(Str(::nWidth))
   ENDIF
   IF ::nHeight != Nil
      sRet += ",,h:" + Ltrim(Str(::nHeight))
   ENDIF
   IF ::bColor != Nil
      sRet += ",,cb:" + Iif( Valtype(::bColor)=="C", ::bColor, hd_ColorN2C(::bColor) )
   ENDIF
   IF ::nMarginL != Nil
      sRet += ",,ml:" + Ltrim(Str(::nMarginL))
   ENDIF
   IF ::nMarginT != Nil
      sRet += ",,mt:" + Ltrim(Str(::nMarginT))
   ENDIF
   IF ::nMarginR != Nil
      sRet += ",,mr:" + Ltrim(Str(::nMarginR))
   ENDIF
   IF ::nMarginB != Nil
      sRet += ",,mb:" + Ltrim(Str(::nMarginB))
   ENDIF

   sRet += ::Super:ToString()

   RETURN sRet

CLASS HDWidget INHERIT HDGUIObject

   DATA oParent
   DATA cText
   DATA nWidth, nHeight
   DATA nMarginL, nMarginT, nMarginR, nMarginB
   DATA nPaddL, nPaddT, nPaddR, nPaddB
   DATA tColor, bColor
   DATA oFont

   DATA objName

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD GetText()
   METHOD SetText( cText )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDWidget

   ::oParent := ::oDefaultParent
   IF !Empty( ::oParent )
      Aadd( ::oParent:aItems, Self )
   ENDIF

   ::cText := cText
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::tColor := tColor
   ::bColor := bColor
   ::oFont := oFont

   RETURN Self

METHOD GetText() CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := hd_calljava_s_s( "gettxt:" + ::objname + ":" )
   ENDIF

   RETURN ::cText

METHOD SetText( cText ) CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := cText
      hd_calljava_s_v( "settxt:" + ::objname + ":" + cText )
   ENDIF

   RETURN cText


METHOD ToString() CLASS HDWidget

   LOCAL sRet := ":" + ::objName

   IF !Empty( ::cText )
      sRet += ",,t:" + ::cText
   ENDIF
   IF  ::nWidth != Nil
      sRet += ",,w:" + Ltrim(Str(::nWidth))
   ENDIF
   IF ::nHeight != Nil
      sRet += ",,h:" + Ltrim(Str(::nHeight))
   ENDIF
   IF ::tColor != Nil
      sRet += ",,ct:" + Iif( Valtype(::tColor)=="C", ::tColor, hd_ColorN2C(::tColor) )
   ENDIF
   IF ::bColor != Nil
      sRet += ",,cb:" + Iif( Valtype(::bColor)=="C", ::bColor, hd_ColorN2C(::bColor) )
   ENDIF
   IF !Empty( ::oFont )
      sRet += ",,f:" + Ltrim(Str(::oFont:typeface)) + "/" + ;
            Ltrim(Str(::oFont:style)) + "/" + Ltrim(Str(::oFont:height))
   ENDIF
   IF ::nMarginL != Nil
      sRet += ",,ml:" + Ltrim(Str(::nMarginL))
   ENDIF
   IF ::nMarginT != Nil
      sRet += ",,mt:" + Ltrim(Str(::nMarginT))
   ENDIF
   IF ::nMarginR != Nil
      sRet += ",,mr:" + Ltrim(Str(::nMarginR))
   ENDIF
   IF ::nMarginB != Nil
      sRet += ",,mb:" + Ltrim(Str(::nMarginB))
   ENDIF
   IF ::nPaddL != Nil
      sRet += ",,pl:" + Ltrim(Str(::nPaddL))
   ENDIF
   IF ::nPaddT != Nil
      sRet += ",,pt:" + Ltrim(Str(::nPaddT))
   ENDIF
   IF ::nPaddR != Nil
      sRet += ",,pr:" + Ltrim(Str(::nPaddR))
   ENDIF
   IF ::nPaddB != Nil
      sRet += ",,pb:" + Ltrim(Str(::nPaddB))
   ENDIF

   RETURN sRet

CLASS HDTextView INHERIT HDWidget

   DATA lScroll INIT .F.

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, lScroll )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, lScroll ) CLASS HDTextView

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::lScroll := lScroll

   RETURN Self

METHOD ToString() CLASS HDTextView

   LOCAL sRet := ""

   IF !Empty( ::lScroll )
      sRet += ",,scroll:t"
   ENDIF

   RETURN "txt" + ::Super:ToString() + sRet


CLASS HDButton INHERIT HDWidget

   DATA bClick

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick ) CLASS HDButton

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   ::bClick := bClick

   RETURN Self

METHOD ToString() CLASS HDButton

   LOCAL sRet := ""

   IF ::bClick != Nil
      sRet += ",,bcli:1"
   ENDIF

   RETURN "btn" + ::Super:ToString() + sRet

CLASS HDEdit INHERIT HDWidget

   DATA cHint
   DATA bKeyDown

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, bKeyDown )
   METHOD getCursorPos( n )
   METHOD setCursorPos( nPos )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, bKeyDown ) CLASS HDEdit

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::cHint := cHint
   ::bKeyDown := bKeyDown

   RETURN Self

METHOD getCursorPos( n ) CLASS HDEdit

   LOCAL nPos := Val( hd_calljava_s_s( Iif( Empty(n).OR.n==1,"getsels:","getsele:" ) + ::objname + ":" ) )

   RETURN nPos

METHOD setCursorPos( nPos ) CLASS HDEdit

   hd_calljava_s_v( "setsels:" + ::objname + ":" + Ltrim(Str(nPos)) )

   RETURN Nil

METHOD ToString() CLASS HDEdit

   LOCAL sRet := ""

   IF ::cHint != Nil
      sRet += ",,hint:" + ::cHint
   ENDIF
   IF ::bKeyDown != Nil
      sRet += ",,bkey:1"
   ENDIF

   RETURN "edi" + ::Super:ToString() + sRet

CLASS HDCheckBox INHERIT HDWidget

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDCheckBox

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   RETURN Self

METHOD ToString() CLASS HDCheckBox

   RETURN "che" + ::Super:ToString()
