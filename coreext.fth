: defer ( "name" -- )
   create ['] abort ,
does> ( ... -- ... )
   @ execute ;

: defer! ( xt2 xt1 -- )
   >body ! ;

: defer@ ( xt1 -- xt2 )
   >body @ ;
