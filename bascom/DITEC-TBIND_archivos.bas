'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  DITECnet_archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.03.2019                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile

$projecttime = 631
'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
Declare Sub Vercfg()
Declare Sub Inivar()
Declare Sub Procser()
Declare Sub Inimdm()
Declare Sub Defaultvalues()

Declare Sub Espera(byval Tespera As Word)                   'Subrutina para delay

Declare Sub Txdata(byval Trama As Byte)                     ' Trama 0=Server WATCHING, 1=TS, 2=TS Talkback
Declare Sub Procdaa()
Declare Sub Genjsonts()
Declare Sub Leered()
Declare Sub Proced()

'RTC

Declare Sub Leeradc()
'Declare Sub Leertc()

Declare Sub Valippto()
'Subrutinas NM7010B
Declare Sub Wiz5100_init
Declare Sub Wiz5100_reset
Declare Sub Wiz5100_sendit
Declare Sub Wiz5100_waitfor(byval Parameter As String)
Declare Sub Wiz5100_receive
Declare Sub Dispvnet()
'Declare Sub Txudp()
'Declare Sub Cfgudp()
'Declare Sub Leerudp()
Declare Sub Cfgtcp()

Declare Sub Leer_ds18b20()
Declare Sub Leeidserial()
'Declare Sub Gettb()
'Declare Sub Getntp()
'Declare Sub Txtbdata()
Declare Sub Getcmd()
Declare Sub Gethoratb()




'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte , Tmpb2 As Byte , Tmpb3 As Byte , Tmpb4 As Byte , K As Byte
Dim Jed As Byte , J As Byte , H As Byte
Dim Tmpl As Long , Tmpl2 As Long , Tmplisr As Long , Lsyssec As Long
Dim Tmpw As Word , Tmpw2 As Word , Tmpw3 As Word
Dim Tmps As Single
Dim Enabug As Byte
Dim Resets As Bit
Dim Flagtbclk As Bit

Dim Cmdtmp As String * 6
Dim Atsnd As String * 200
Dim Cmderr As Byte
Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52
Dim Tmpstr3 As String * 3
Dim Tmpvar As String * 32


Dim Urlbase As String * 32 , Urlbaseeep As Eram String * 32,       'APN
'NTP
Dim Ip As Long                                              ' IP number of time server
'Dim IpSTRtmp As Long
Dim Idx As Byte                                             ' socket number
Dim Lsntp As Long
Dim Ptrntp As Byte
Dim Ntpok As Bit
Dim Newskt As Byte

'Variables TIMER0
Dim T0c As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led As Byte
Dim Iluminar As Bit
Dim Inidelay As Bit
Dim Cntrdelay As Word
Dim T0delay As Bit
Dim Topdelay As Word
Dim T0cntrsms As Word , T0inisms As Bit , T0toutsms As Bit
Dim Idserial As String * 22


'TIMER1
Dim Newseg As Bit
Dim T1wait As Byte
Dim T1cntr As Byte
Dim T1tout As Bit
Dim T1ini As Bit
Dim Iniauto As Byte
Dim T1tick As Byte
Dim T1tmp As Byte
Dim T1tmp0 As Byte
Dim Cntrtredmenos(ednum) As Word
Dim Cntrtredmas(ednum) As Word
Dim Evmenos As Byte                                         ' Almacena en un bit nuevo evento de mas a menos
Dim Evmas As Byte                                           ' Almacena en un bit nuevo evento de menos a mas
Dim Tmped As Byte

'DS18B20
Dim Crc As Byte
Dim T1 As Single , Bint As Integer , Tr As Byte , Ti As Byte
Dim T1ant As Single
Dim Bt(9) As Byte
'Dim Cntrtemp As Byte
Dim Signo As String * 2
Dim Cntrerrortemp As Byte
Dim Errortemp As Bit , Cntrmax As Byte , Cntrttemp As Byte
Dim Cntrcrcerr As Word
'timer 2
Dim Tmpt2 As Byte
Dim Tmpt21 As Byte
'dim tmplisr as long
Dim Tbl_timeaut(numtxaut) As Long
Dim Inipoll As Bit
Dim Inicpoll As Bit
Dim Cntrpoll As Byte
Dim Cntrpollant As Byte

'Variables utilizadas para el modulo Ethernet
Dim Valueant As Byte
Dim Value As Byte
Dim Adres As Word
Dim Adresl As Byte At Adres Overlay
Dim Adresh As Byte At Adres + 1 Overlay

Dim Pointer As Word
Dim Pointerl As Byte At Pointer Overlay
Dim Pointerh As Byte At Pointer + 1 Overlay

Dim Size As Word
Dim Sizel As Byte At Size Overlay
Dim Sizeh As Byte At Size + 1 Overlay

Dim Bpointer As Word

Dim X As Word
Dim Freesize As Word
Dim Sendsize As Integer
Dim Tmp_str As String * 1
Dim Tmp_value As Byte

Dim Startpos As Word
Dim Tx_wr As Word
Dim Ofsetnet As Word
Dim Offsend As Word
Dim Uppersize As Word
Dim Startadress As Word
Dim Highbyte As Byte
Dim Lowbyte As Byte
Dim Buffer As String * Lonbuffer
Dim Glaenge As Word

Dim Parameter As String * 3
Dim Reaction As String * 3
Dim Preaction As Byte
Dim Timeout As Bit
Dim Wiz5100_opcode_read As Byte
Dim Wiz5100_opcode_write As Byte
Dim Numbyte As Word

Dim Ipreg(6) As Byte                                        'Arreglo para almacenar registros IP
Dim Ptoreg(2) As Byte
Dim Gwreg(4) As Byte                                        'Arreglo para almacenar direccion IP para configurar Gateway
Dim Gwregeep(4) As Eram Byte                                'Arreglo para almacenar direccion IP para configurar Gateway en EEPROM
Dim Mskreg(4) As Byte                                    'Arreglo para almacenar direccion IP para configurar Mskreg
Dim Mskregeep(4) As Eram Byte                            'Arreglo para almacenar direccion IP para configurar Mskreg en EEPROM
Dim Ipmdc(4) As Byte                                        'Arreglo para almacenar direccion IP del modulo
Dim Ipmdceep(4) As Eram Byte                             'Arreglo para almacenar direccion IP del modulo en EEPROM
Dim Iptmp(4) As Byte
Dim Macreg(6) As Byte                                    'Arreglo para alamcenar MAC address
Dim Macregeep(6) As Eram Byte                            'Arreglo para alamcenar MAC address
'Dim Iptx As String * 30 , Prtotx As String * 6
Dim Cntrerr As Byte
Dim Cntrerrsis As Byte
Dim Iptxl As Long                                           'IP para tx
Dim Prtotxl As Word

Dim Initx As Bit
Dim Inimodem As Bit
Dim Newtx As Bit
Dim Ipptook As Bit
Dim Getfechatb As Bit
Dim Mestxt As String * 4
Dim Mes As String * 4

Dim Ipmval As Long                                          ' ip modulo
Dim Gwval As Long                                           'ip gateway
Dim Mskval As Long
Dim Initout As Bit
Dim Cntrseg As Byte
Dim Timevalue As Byte
Dim Tout As Bit
Dim Cntrsegant As Byte
Dim Result As Word
Dim Resultant As Word
'SMS
'Dim Ls_str2 As String * 2
'Dim Tf_num1 As String * 15                                  ', Tf_num As String * 10
'Dim Fecha_rx As String * 17 , Msglong As Byte
'Dim Smsok As Bit

'GPRS
Dim Txok As Bit
Dim Cntrtx As Byte
'Dim Iptx As String * 30 , Prtotx As String * 6
Dim Bufntp(60) As Byte

'THINGSPEAK
Dim Keyapitmp As String * 64
Dim Habfeed(8) As Byte                                      'Arreglo para indicar habilitacion de feed en TS
Dim Valfeed(8) As String * 64                               ' Arreglo para almacenar valor de feed
Dim Fechaed As String * 10
Dim Horaed As String * 10
Dim Datamdc As String * 255
Dim Cntrdata As Byte
Dim Keyapi As String * 20
Dim Keyapieep As Eram String * 20


'OPERACION
Dim Cntrini As Word
Dim Cntrinieep As Eram Word
Dim Cntrinimdc As Word
Dim Cntrinimdceep As Eram Word
Dim Inivariables As Bit
Dim Tmpbit As Bit
Dim Tmpbit1 As Bit

' Variables para ADC
Dim Tmpwadc As Word
Dim Adccntri As Single
Dim Cntrsmpli As Byte
Dim Adcvali As Single
Dim Adck As Single                                          'Constante de proporcionalidad ADC
Dim Adckeep As Eram Single
Dim Iniadc As Bit
Dim Samplerdy As Bit
Dim Horamin As Long
Dim Horamineep As Eram Long

'RTC
Dim Dow As Byte
Dim Actclk As Bit

'ED
'Variables ED
Dim Tredmas(ednum) As Word
Dim Tredmaseep(ednum) As Eram Word
Dim Tredmenos(ednum) As Word
Dim Tredmenoseep(ednum) As Eram Word
Dim Edpol As Byte
Dim Edpoleep As Eram Byte
Dim Edname(ednum) As String * 6
Dim Ednameeep(ednum) As Eram String *
Dim Eddat As Byte
Dim Edsta(ednum) As Byte
Dim Edstaant(ednum) As Byte
'Textos reportes ED
Dim Txtrepmas(ednum) As String * 64
Dim Txtrepmaseep(ednum) As Eram String * 64
Dim Txtrepmenos(ednum) As String * 64
Dim Txtrepmenoseep(ednum) As Eram String * 64
Dim Edhab As Byte
Dim Edhabeep As Eram Byte


'Variables para transmisiones automáticas
Dim Autoval(numtxaut) As Long , Autovaleep(numtxaut) As Eram Long
Dim Offset(numtxaut) As Long , Offseteep(numtxaut) As Eram Long
'Dim Iniauto As Word

'Variables SERIAL1
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(16) As String * 64
Dim Ipsplit(8) As String * 6
Dim Iptx As String * 64
Dim Iptxant As String * 64
Dim Iptxeep As Eram String * 64
Dim Ipvaltmp As String * 64
Dim Prtotx As String * 64
Dim Prtotxeep As Eram String * 64

Dim Ntpsrv(Numntpsrv) As String * 16
Dim Ntpsrveep(Numntpsrv) As Eram String * 16


Dim Cfgokeep As Eram Byte
Dim Cfgok As Byte

Dim Apikeytb As String * 20
Dim Apikeytbeep As Eram String * 20

Dim Canalcmd As String * 16
Dim Canalcmdeep As Eram String * 16

Dim Gws_ini As Bit , Gwsnew As Bit
Dim Gwsdata As String * 255 , Gwsproc As String * 255
Dim Mdcbuf(numbuf) As String * 200
Dim Txbuf(numbuf) As Byte
Dim Ptrbuf As Byte
Dim Ptrtx As Byte


Dim Serdata As String * 200 , Serrx As Byte , Serproc As String * 200

'SERIAL 2
Dim Newrd As Bit
Dim Ptrrd As Word

Dim Bufrd(numrd) As Byte
Dim Bufferrx As String * Long_buffer At Bufrd(1) Overlay
Dim Buffer1 As String * Long_buffer



'*******************************************************************************
'* END public part                                                             *
'*******************************************************************************


Goto Loaded_arch

'*******************************************************************************
' INTERRUPCIONES
'*******************************************************************************

'*******************************************************************************
' Subrutina interrupcion de puerto serial 1
'*******************************************************************************
At_serialint:
   Serrx = Udr
   Select Case Serrx
      Case "%":
         Ser_ini = 1
         Serdata = ""
      Case "$":
         Gws_ini = 1
         Gwsdata = ""
      Case 13:
         If Ser_ini = 1 Then
            Ser_ini = 0
            Serdata = Serdata + Chr(0)
            Serproc = Serdata
            Sernew = 1
         End If
         If Gws_ini = 1 Then
            Gws_ini = 0
            Gwsdata = Gwsdata + Chr(0)
            'Gwsproc = Gwsdata
            Ptrbuf = Ptrbuf Mod Numbuf
            Incr Ptrbuf
            Mdcbuf(ptrbuf) = Gwsdata
            'If Gwsdata = "OK" Then Set Dataok
            Txbuf(ptrbuf) = 1
            Gwsdata = ""
            Gwsnew = 1
         End If
      Case Is > 31
         If Ser_ini = 1 Then
            Serdata = Serdata + Chr(serrx)
         End If
         If Gws_ini = 1 Then
            Gwsdata = Gwsdata + Chr(serrx)
         End If
   End Select

Return



'*******************************************************************************



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer0:
   Timer0 = 184
   Incr T0c
   T0c = T0c Mod 8
   If T0c = 0 Then
      Num_ventana = Num_ventana Mod 32
      Estado = Lookup(estado_led , Tabla_estado)
         'Toggle Estado                                    'Cambia estado de leds 1=Encendido; 0=Apagado
         Iluminar = Estado.num_ventana
         Toggle Iluminar
         Led0 = Iluminar
      Incr Num_ventana
   End If

   If Inidelay = 1 Then
      Incr Cntrdelay
      If Cntrdelay = Topdelay Then
         Set T0delay
         Reset Inidelay
      End If
   End If

   If T0inisms = 1 Then
      Incr T0cntrsms
      If T0cntrsms = 1800 Then
         Set T0toutsms
         T0cntrsms = 0
      End If
   Else
      T0cntrsms = 0
   End If

Return


Int_timer1:
   'Timer1 = &H8F80                                          'Ints cada segundo
   'Timer1 = &HFC3B                                          'Ints cada 0.1 segundo
   Timer1 = &HF4C0                                          ' Ints cada 10 Hz
   Incr T1tick
   T1tick = T1tick Mod 10
   If T1tick = 0 Then
      If T1ini = 1 Then
         Incr T1cntr
         T1cntr = T1cntr Mod T1wait
         If T1cntr = 0 Then
            Set T1tout
         End If
      Else
         T1cntr = 0
      End If
      If Initout = 1 Then
         'Incr T0tck
         'T0tck = T0tck Mod 100                                 'Contador 1s
         'If T0tck = 0 Then
            Incr Cntrseg
            If Cntrseg = Timevalue Then
               Set Tout
               Reset Initout
               Cntrseg = 0
            End If
         'End If
      End If

   End If
   'Timer1 = &HCF2C
   Tmpbit1 = Ed0 Xor Edpol.0
   Eddat.0 = Tmpbit1

   Tmpbit1 = Ed1 Xor Edpol.1
   Eddat.1 = Tmpbit1

   Tmpbit1 = Ed2 Xor Edpol.2
   Eddat.2 = Tmpbit1

   Tmpbit1 = Ed3 Xor Edpol.3
   Eddat.3 = Tmpbit1

   Tmpbit1 = Ed0 Xor Edpol.4
   Eddat.4 = Tmpbit1

   Tmpbit1 = Ed1 Xor Edpol.5
   Eddat.5 = Tmpbit1

   For T1tmp = 1 To Ednum
      T1tmp0 = T1tmp - 1
      Select Case Edsta(t1tmp)

         Case 0:                                               'Normal
            If Eddat.t1tmp0 = 0 Then
               Edsta(t1tmp) = 2
            End If

         Case 1:                                            'Alarma
            If Eddat.t1tmp0 = 1 Then
               Edsta(t1tmp) = 3
            End If

         Case 2:                                               'Prealarma
            If Eddat.t1tmp0 = 1 Then
               Edsta(t1tmp) = 0
               Cntrtredmenos(t1tmp) = 0
            Else
               Incr Cntrtredmenos(t1tmp)
               Cntrtredmenos(t1tmp) = Cntrtredmenos(t1tmp) Mod Tredmenos(t1tmp)
               If Cntrtredmenos(t1tmp) = 0 Then
                  Edsta(t1tmp) = 1
                  Set Evmenos.t1tmp0
                  'Incr Cntr_off(t1tmp)
               End If
            End If

         Case 3:                                               'Prenormal
            If Eddat.t1tmp0 = 0 Then
               Edsta(t1tmp) = 1
               Cntrtredmas(t1tmp) = 0
            Else
               Incr Cntrtredmas(t1tmp)
               Cntrtredmas(t1tmp) = Cntrtredmas(t1tmp) Mod Tredmas(t1tmp)
               If Cntrtredmas(t1tmp) = 0 Then
                  Edsta(t1tmp) = 0
                  Set Evmas.t1tmp0
                 ' Incr Cntr_on(t1tmp)
               End If
            End If

      End Select
   Next

Return

Sectic:
   Set Newseg
   Lsyssec = Syssec()
   For Tmpt2 = 1 To Numtxaut
      Tmpt21 = Tmpt2 - 1
      Tmplisr = Lsyssec + Offset(tmpt2)
      Tmplisr = Tmplisr Mod Autoval(tmpt2)
      If Tmplisr = 0 Then
       Set Iniauto.tmpt21
       Tbl_timeaut(tmpt2) = Lsyssec
      End If
   Next

   Tmplisr = Lsyssec Mod Tsampling
   If Tmplisr = 0 Then Set Iniadc

   If Inicpoll = 1 Then
      Incr Cntrpoll
      Cntrpoll = Cntrpoll Mod Tpoll
      If Cntrpoll = 0 Then
         Set Inipoll
         Reset Inicpoll
      End If
   End If



Return


'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************
Sub Vercfg()
   Print #1 , "Verificar Config. Inicial"
   Cfgok = Cfgokeep
   Tmpb2 = 0
   Estado_led = 15
   Do
      If Sernew = 1 Then                                       'DATOS SERIAL 1
         Reset Sernew
         Print #1 , "SER1=" ; Serproc
         Call Procser()
         Cfgok = Cfgokeep
      End If
      If Newseg = 1 Then
         Reset Newseg
         Incr Tmpb
         Incr Tmpb2
         Tmpb = Tmpb Mod 10
         If Tmpb = 0 Then
            Print #1 , "Ingrese valores de configuracion"
         End If
      End If
   Loop Until Cfgok = 1                                     'Cfgok = 1
   Print #1 , "CONFIG. INICIAL OK"
   Estado_led = 1

End Sub

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
Sub Inivar()
Reset Led0
Print #1 , "************ DRIVER SIM908 ************"
Print #1 , Version(1)
Print #1 , Version(2)
Print #1 , Version(3)
Estado_led = 1

Urlbase = Urlbaseeep
Print #1 , "Urlbase=" ; Urlbase

Iptx = Iptxeep
Prtotx = Prtotxeep
'Iptx = "181.199.76.185"
'Prtotx = "3000"

Print #1 , "IP <" ; Iptx ; ">"
Print #1 , "Puerto <" ; Prtotx ; ">"
'Keyapitmp = "3F0J7U4QBNDJDOVA"

Keyapi = Keyapieep
Print #1 , "Keyapi <" ; Keyapi ; ">"
Cntrini = Cntrinieep
Incr Cntrini
Cntrinieep = Cntrini
Print #1 , "CNTRINI=" ; Cntrini
Cntrinimdc = Cntrinimdceep
Print #1 , "CntriniMDC=" ; Cntrinimdc

   For Tmpb = 1 To Ednum
      Edname(tmpb) = Ednameeep(tmpb)
      Print #1 , "EDname " ; Tmpb ; "=" ; Edname(tmpb)
      Tredmas(tmpb) = Tredmaseep(tmpb)
      Print #1 , "T red + ED " ; Tmpb ; "=" ; Tredmas(tmpb) ; "x 0.1s"
      Tredmenos(tmpb) = Tredmenoseep(tmpb)
      Print #1 , "T red - ED " ; Tmpb ; "=" ; Tredmenos(tmpb) ; "x 0.1s"
      Edstaant(tmpb) = 5
      Txtrepmas(tmpb) = Txtrepmaseep(tmpb)
      Txtrepmenos(tmpb) = Txtrepmenoseep(tmpb)
      Print #1 , "TXT Rep. + ED" ; Tmpb ; " <" ; Txtrepmas(tmpb) ; ">"
      Print #1 , "TXT Rep. - ED" ; Tmpb ; " <" ; Txtrepmenos(tmpb) ; ">"
      'Cntr_on(tmpb) = Cntr_oneep(tmpb)
      'Print #1 , "CNTR ON=" ; Cntr_on(tmpb)
      'Cntr_off(tmpb) = Cntr_offeep(tmpb)
      'Print #1 , "CNTR OFF=" ; Cntr_off(tmpb)
   Next

   Edpol = Edpoleep
   Print #1 , "EDpol=" ; Bin(edpol)
   Edhab = Edhabeep
   Print #1 , "EDhab=" ; Bin(edhab)

   Tmpbit = Ed0 Xor Edpol.0
   If Tmpbit = 0 Then
      Edsta(1) = 2
   Else
      Edsta(1) = 3
   End If
   Tmpbit = Ed1 Xor Edpol.1
   If Tmpbit = 0 Then
      Edsta(2) = 2
   Else
      Edsta(2) = 3
   End If
   Tmpbit = Ed2 Xor Edpol.2

   If Tmpbit = 0 Then
      Edsta(3) = 2
   Else
      Edsta(3) = 3
   End If
   Tmpbit = Ed3 Xor Edpol.3
   If Tmpbit = 0 Then
      Edsta(4) = 2
   Else
      Edsta(4) = 3
   End If

   Horamin = Horamineep
   Print #1 , "Horamin=" ; Horamin
   Print #1 , Date(horamin)
   Print #1 , Time(horamin)

   Adck = Adckeep

   Print #1 , "ADCK=" ; Adck

   For J = 1 To Numtxaut
      Autoval(j) = Autovaleep(j)
      Offset(j) = Offseteep(j)
      Print #1 , "Aut" ; J ; "=" ; Autoval(j) ; ", OFF" ; J ; "=" ; Offset(j)
   Next
   Set Inipoll
   reset resets

   Print #1 , "IPMDC:"
   For Tmpb = 1 To 4
      Tmpb2 = Ipmdceep(tmpb)
      Ipmdc(tmpb) = Tmpb2
      Print #1 , Ipmdc(tmpb) ; ".";
   Next
   Print #1 ,

   Print #1 , "GATEWAY:"
   For Tmpb = 1 To 4
      Tmpb2 = Gwregeep(tmpb)
      Gwreg(tmpb) = Tmpb2
      Print #1 , Gwreg(tmpb) ; ".";
   Next
   Print #1 ,

   Print #1 , "MASK:"
   For Tmpb = 1 To 4
      Tmpb2 = Mskregeep(tmpb)
      Mskreg(tmpb) = Tmpb2
      Print #1 , Mskreg(tmpb) ; ".";
   Next
   Print #1 ,

   Print #1 , "MAC ADDRESS:"
   For Tmpb = 1 To 6
      Tmpb2 = Macregeep(tmpb)
      Macreg(tmpb) = Tmpb2
      Print #1 , Macreg(tmpb) ; ".";
   Next
   Print #1 ,

   Call Leeidserial()
   Print#1 , "IDser<" ; Idserial ; ">"

   For Tmpb = 1 To Numntpsrv
      Ntpsrv(tmpb) = Ntpsrveep(tmpb)
      Print #1 , "NTPsrv" ; Tmpb ; ">" ; Ntpsrv(tmpb)
   Next

   Canalcmd = Canalcmdeep
   Print #1 , "Canalcmd=" ; Canalcmd
   'Autoval(4) = 120                                         ' Al inicio verifico si es válida la IP que consigo por DNS
   Set Getfechatb                                           'Para igualar reloj en primera TX
   Reset Flagtbclk
End Sub


'*******************************************************************************
' LEE ID SERIAL DEL CHIP
'*******************************************************************************

 Sub Leeidserial()
   Tmpb = 0
   Tmpb2 = 0
   Do
      Idserial = ""
      For Tmpb = 14 To 23
         Idserial = Idserial + Hex(readsig(tmpb))
      Next
      Atsnd = Idserial
      Idserial = ""
      For Tmpb = 14 To 23
         Idserial = Idserial + Hex(readsig(tmpb))
      Next
      If Idserial = Atsnd Then
         Tmpb = 1
      End If
      Incr Tmpb2
      If Tmpb = 0 Then
         Waitms 500
         Print #1 , "Try " ; Tmpb2
      End If
   Loop Until Tmpb = 1 Or Tmpb2 = 10

 End Sub



'*****************************************************************************
' Subrutina para leer temperatura del DS18B20
'*****************************************************************************
Sub Leer_ds18b20()
   1wreset
   1wwrite &HCC
   1wwrite &H44
   Waitms 800
   1wreset                                                     ' reset the bus
   1wwrite &HCC
   1wwrite &HBE                                                ' read 9 data bytest
   For Tr = 1 To 9
       Bt(tr) = 1wread()
   Next                                                        ' read bytes in array
   1wreset
   If Err = 0 Then
      Crc = 0
      For Ti = 1 To 9
         Tr = Crc Xor Bt(ti)
         Crc = Lookup(tr , Crc8)
      Next
      If Crc = 0 Then                                          ' if is OK, calculate for
        Bint = Makeint(bt(1) , Bt(2))
        If Bt(2).3 = 0 Then                                       'Temp postiva
           T1 = Bint / 16
           Signo = "+"
        Else
           Bint = Not Bint                                        ' Comprobar esta subrutina
           Bint = Bint + 1
           T1 = Bint / 16
           T1 = -t1
           Signo = "-"
        End If
        If Enabug.0 = 1 Then
         Print #1 , Signo ; Fusing(t1 , "#.##")
        End If
        Reset Errortemp
        'Set Relpwr
      Else
         Incr Cntrcrcerr
         Print #1 , "CRC ERR," ; Cntrcrcerr
      End If
   Else
      Incr Cntrerrortemp
      If Cntrerrortemp = 5 Then
         Set Errortemp
         Cntrerrortemp = 0
         'Lcdat 4 , 1 , "T=Err "
      End If
   End If

End Sub
'*****************************************************************************


'*******************************************************************************
' Procesamiento de comandos
'*******************************************************************************
Sub Procser()
   'Print #1 , "$" ; Serproc
   Tmpstr52 = Mid(serproc , 1 , 6)
   Numpar = Split(serproc , Cmdsplit(1) , ",")
   'If Numpar > 0 Then
   '   For Tmpb = 1 To Numpar
   '      Print #1 , Tmpb ; ":" ; Cmdsplit(tmpb)
   '   Next
   'End If

   If Len(cmdsplit(1)) = 6 Then
      Cmdtmp = Cmdsplit(1)
      Cmdtmp = Ucase(cmdtmp)
      Cmderr = 255
      Select Case Cmdtmp
         Case "LEEVFW"
            Cmderr = 0
            Atsnd = "Version FW: Fecha <"
            Tmpstr52 = Version(1)
            Atsnd = Atsnd + Tmpstr52 + ">, Archivo <"
            Tmpstr52 = Version(3)
            Atsnd = Atsnd + Tmpstr52 + ">"

         Case "LEERID"
            Cmderr = 0
            Call Leeidserial()
            Atsnd = "ID ser <" + Idserial + ">"

         Case "SETLED"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb < 17 Then
                  Cmderr = 0
                  Atsnd = "Se configura setled a " + Str(tmpb)
                  Estado_led = Tmpb
               Else
                  Cmderr = 5
               End If
            Else
               Cmderr = 4
            End If

         Case "SETIPX"
            If Numpar = 2 Then
               Cmderr = 0
               Iptx = Cmdsplit(2)
               Iptxeep = Iptx
               Atsnd = "Se configuro Ip <" + Iptx + ">"
            Else
               Cmderr = 4
            End If

         Case "SETPTX"
            If Numpar = 2 Then
               Cmderr = 0
               Prtotx = Cmdsplit(2)
               Prtotxeep = Prtotx
               Atsnd = "Se configuro Puerto <" + Prtotx + ">"
            Else
               Cmderr = 4
            End If

         Case "LEEIPX"
            If Numpar = 1 Then
               Cmderr = 0
               Atsnd = "Ip <" + Iptx + ">"
            Else
               Cmderr = 4
            End If

         Case "LEEPTX"
            If Numpar = 1 Then
               Cmderr = 0
               Atsnd = "Puerto <" + Prtotx + ">"
            Else
               Cmderr = 4
            End If

         Case "RSTVAR"
            Cmderr = 0
            Call Defaultvalues()
            Atsnd = "Se configuran parametros a valores por defecto"

         Case "SETCFG"
            If Numpar = 2 Then
               Cfgok = Val(cmdsplit(2))
               Cfgokeep = Cfgok
               Cmderr = 0
               Atsnd = "Se configura CFGOK=" + Str(cfgok)
            Else
               Cmderr = 4
            End If

         Case "SETKDA"
            If Numpar = 2 Then
               Cmderr = 0
               Keyapi = Cmdsplit(2)
               Keyapieep = Keyapi
               Atsnd = "Se configuro APIkey <" + Keyapi + ">"
            Else
               Cmderr = 4
            End If

         Case "LEEKDA"
            Cmderr = 0
            Atsnd = "APIkey <" + Keyapi + ">"

         Case "SETKTB"
            If Numpar = 2 Then
               Cmderr = 0
               Apikeytb = Cmdsplit(2)
               Apikeytbeep = Apikeytb
               Atsnd = "Se configuro APIkey TB<" + Apikeytb + ">"
            Else
               Cmderr = 4
            End If

         Case "LEEKTB"
            Cmderr = 0
            Atsnd = "APIkey TB <" + Apikeytb + ">"

        Case "SETCLK"
            If Numpar = 2 Then
               If Len(cmdsplit(2)) = 12 Then
                  Cmderr = 0
                  Tmpstr52 = Mid(cmdsplit(2) , 7 , 2) + ":" + Mid(cmdsplit(2) , 9 , 2) + ":" + Mid(cmdsplit(2) , 11 , 2)
                  Print #1 , Tmpstr52
                  Tmpstr3 = Mid(cmdsplit(2) , 7 , 2)
                  _hour = Val(tmpstr3)
                  Tmpstr3 = Mid(cmdsplit(2) , 9 , 2)
                  _min = Val(tmpstr3)
                  Tmpstr3 = Mid(cmdsplit(2) , 11 , 2)
                  _sec = Val(tmpstr3)

                  'Time$ = Tmpstr52
                  Horaed = Tmpstr52
                  'Print #1 , "T>" ; Time$
                  Tmpstr52 = Mid(cmdsplit(2) , 1 , 2) + "/" + Mid(cmdsplit(2) , 3 , 2) + "/" + Mid(cmdsplit(2) , 5 , 2)
                  Print #1 , Tmpstr52
                  Tmpstr3 = Mid(cmdsplit(2) , 1 , 2)
                  _day = Val(tmpstr3)
                  Tmpstr3 = Mid(cmdsplit(2) , 3 , 2)
                  _month = Val(tmpstr3)
                  Tmpstr3 = Mid(cmdsplit(2) , 5 , 2)
                  _year = Val(tmpstr3)

                  'Date$ = Tmpstr52
                  Fechaed = Tmpstr52
                  'Print #1 , "D>" ; Date$
                  Tmpl = Syssec(horaed , Fechaed)
                  Print #1 , Tmpl
                  Tmpl = Syssec()
                  Print #1 , Tmpl

                  'Date$ = Date(tmpl)
                  'Date$ = Fechaed
                  'Time$ = Time(tmpl)
                  Atsnd = "WATCHING INFORMA. Se configuro reloj en " + Date(tmpl) + " a " + Time(tmpl)
                  Dow = Dayofweek()
                  'Call Setdateds3231()
                  'Call Settimeds3231()
                  'Call Getdatetimeds3231()
                  Horamin = Syssec()
                  Horamineep = Horamin
                  'Set Actclkok
               Else
                  Cmderr = 6
               End If
            Else
               Cmderr = 4
            End If

         Case "LEERTC"
            Cmderr = 0
            Atsnd = "Lee RTC no HAB"
            'Call Getdatetimeds3231()

         Case "SISCLK"
            Cmderr = 0
            Tmpl = Syssec()
            'Tmpstr52 = Time(tmpl)
            Tmpstr52 = Time$
            Atsnd = "Hora actual=" + Tmpstr52 + ", Fecha actual="
            'Tmpstr52 = Date(tmpl)
            Tmpstr52 = Date$
            Atsnd = Atsnd + Tmpstr52

         Case "LEECLK"
            Cmderr = 0
            Tmpstr52 = Time(horamin)
            Atsnd = "Ultima ACT CLK a =" + Tmpstr52 + ", del "
            'Tmpstr52 = Date(horamin)
            Tmpstr52 = Date$
            Atsnd = Atsnd + Tmpstr52

         Case "SETBUG"
            Cmderr = 0
            If Numpar = 2 Then
               Enabug = Val(cmdsplit(2))
               Atsnd = "Se habilita debug a" + Str(enabug)
            Else
               Cmderr = 6
            End If

         Case "LEEBUG"
            Cmderr = 0
            Atsnd = "ENABUG=" + Str(enabug)

         Case "SETADC"
            If Numpar = 2 Then
               Tmps = Val(cmdsplit(2))
               Adck = Tmps
               Adckeep = Adck
               Cmderr = 0
               Atsnd = "Se configuro K de ADC a  " + Str(adck)
            Else
               Cmderr = 4
            End If

         Case "LEEADC"
            If Numpar = 1 Then
               Cmderr = 0
               Atsnd = "K de ADC =" + Str(adck)
            Else
               Cmderr = 4
            End If

         Case "LEEVDC"
            Cmderr = 0
            Atsnd = "Voltaje de alimentacion=" + Fusing(adcvali , "#.##")

         Case "SETAUT"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 Tmpstr3 = Cmdsplit(3)
                 Tmpl2 = Val(tmpstr3)
                 Autoval(j) = Tmpl2
                 Autovaleep(j) = Tmpl2
                 Cmderr = 0
                 Print #1 , "$" ; J ; "," ; Autoval(j)
                 Print #1 , "$OK"
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(autoval(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "SETOFF"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 Tmpstr3 = Cmdsplit(3)
                 Tmpl2 = Val(tmpstr3)
                 Offset(j) = Tmpl2
                 Offseteep(j) = Tmpl2
                 Cmderr = 0
                 Print #1 , "$" ; J ; "," ; Offset(j)
                 Print #1 , "$OK"
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(offset(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEAUT"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  Tmpstr3 = Cmdsplit(3)
                  Atsnd = "Tx Aut " + Str(j) + ":" + Str(autoval(j))
                  Cmderr = 0
                  Print #1 , "$" ; J ; "," ; Autoval(j)
                  Print #1 , "$OK"
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEOFF"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  Tmpstr3 = Cmdsplit(3)
                  Atsnd = "Offset Aut " + Str(j) + ":" + Str(offset(j))
                  Cmderr = 0
                  Print #1 , "$" ; J ; "," ; Offset(j)
                  Print #1 , "$OK"
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "SETNEW"
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  Cmderr = 0
                  Tmpb = J - 1
                  Set Iniauto.tmpb
                  Atsnd = "Se activo Tx. AUT " + Str(j) + "," + Bin(iniauto)
               Else
                  Cmderr = 3
               End If

            Else
               Cmderr = 4
            End If

         Case "SETINI"
            If Numpar = 2 Then
               Cntrini = Val(cmdsplit(2))
               Cntrinieep = Cntrini
               Cmderr = 0
               Atsnd = "Se configuro Contador Inicios: " + Str(cntrini)
            Else
               Cmderr = 4
            End If

         Case "LEEINI"
            If Numpar = 1 Then
               Cmderr = 0
               Atsnd = "Contador inicios <" + Str(cntrini) + ">"
            Else
               Cmderr = 4
            End If

         Case "SETINM"
            If Numpar = 2 Then
               Cntrinimdc = Val(cmdsplit(2))
               Cntrinimdceep = Cntrinimdc
               Cmderr = 0
               Atsnd = "Se configuro Contador Inicios MDC: " + Str(cntrinimdc)
            Else
               Cmderr = 4
            End If

         Case "LEEINM"
            If Numpar = 1 Then
               Cmderr = 0
               Atsnd = "Contador inicios MDC<" + Str(cntrinimdc) + ">"
            Else
               Cmderr = 4
            End If

         Case "ESTADO"
            Cmderr = 0
            Atsnd = "WATCHING INFORMA. PT1="
            Tmpbit = Ed0 Xor Edpol.0
            If Tmpbit = 0 Then
               Atsnd = Atsnd + "ABIERTA, PT2="
            Else
               Atsnd = Atsnd + "CERRADA, PT2="
            End If

            Tmpbit = Ed1 Xor Edpol.1
            If Tmpbit = 0 Then
               Atsnd = Atsnd + "ABIERTA, AC="
            Else
               Atsnd = Atsnd + "CERRADA, AC="
            End If

            Tmpbit = Ed2 Xor Edpol.2
            If Tmpbit = 0 Then
               Atsnd = Atsnd + "FALLA, TVSS="
            Else
               Atsnd = Atsnd + "OK, TVSS="
            End If

            Tmpbit = Ed3 Xor Edpol.3
            If Tmpbit = 0 Then
               Atsnd = Atsnd + "FALLA, VIN="
            Else
               Atsnd = Atsnd + "OK, VIN="
            End If
            Atsnd = Atsnd + Fusing(adcvali , "#.##")
            Atsnd = Atsnd + ", T=" + Fusing(T1 , "#.##")

         Case "LEERED"
            Cmderr = 0
            Tmpbit = Ed0 Xor Edpol.0
            Atsnd = "WATCHING INFORMA. ED1=" + Str(tmpbit)
            Tmpbit = Ed1 Xor Edpol.1
            Atsnd = Atsnd + ", ED2=" + Str(tmpbit)
            Tmpbit = Ed2 Xor Edpol.2
            Atsnd = Atsnd + ", ED3=" + Str(tmpbit)
            Tmpbit = Ed3 Xor Edpol.3
            Atsnd = Atsnd + ", ED4=" + Str(tmpbit)

         Case "INIMDM"
            If Numpar = 2 Then
               Cmderr = 0
               Tmpb = Val(cmdsplit(2))
               If Tmpb = 0 Then
                  'Set Iniapagarmdm
                  Atsnd = "Apagar MDM"
               Else
                  Set Inimodem
                  Atsnd = "Iniciar MDM"
               End If
            Else
               Cmderr = 4
            End If

         Case "RESETS"
            Cmderr = 0
            Atsnd = "Reset por software"
            Set Resets

         Case "INIVAR"
            Cmderr = 0
            Atsnd = "Reinicio de variables"
            Set Inivariables

         Case "SETHAB"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Ednum_masuno Then
                  Cmderr = 0
                  Tmpb3 = Tmpb - 1
                  Tmpb2 = Val(cmdsplit(3))
                  If Tmpb2 = 0 Then
                     Reset Edhab.tmpb3
                  Else
                     Set Edhab.tmpb3
                  End If
                  Edhabeep = Edhab
                  Atsnd = "Se configuro HAB ED" + Str(tmpb) + "=" + Str(edhab.tmpb3)
               Else
                  Cmderr = 5
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEHAB"
            Select Case Numpar
               Case 1:
                  Cmderr = 0
                  Atsnd = "Hab ED=" + Bin(edhab)
               Case 2:
                  Tmpb = Val(cmdsplit(2))
                  If Tmpb > 0 And Tmpb < Ednum_masuno Then
                     Tmpb3 = Tmpb - 1
                     Cmderr = 0
                     Atsnd = "HAB ED" + Str(tmpb) + "=" + Str(edhab.tmpb3)
                  Else
                     Cmderr = 5
                  End If
               Case Else
                  Cmderr = 4
            End Select

         Case "SETNET"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < 5 Then
                  Ipvaltmp = Cmdsplit(3)
                  Call Valippto()
                  If Ipptook = 1 Then
                     Select Case Tmpb
                        Case 1:
                           Cmderr = 0
                           For Tmpb2 = 1 To 4
                              Ipmdc(tmpb2) = Iptmp(tmpb2)
                              Ipmdceep(tmpb2) = Ipmdc(tmpb2)
                           Next
                           Atsnd = "Se configuro IP DITEC a <" + Str(ipmdc(1)) + "."
                           Atsnd = Atsnd + Str(ipmdc(2)) + "." + Str(ipmdc(3)) + "."
                           Atsnd = Atsnd + Str(ipmdc(4)) + ">"
                        Case 2:
                           Cmderr = 0
                           For Tmpb2 = 1 To 4
                              Gwreg(tmpb2) = Iptmp(tmpb2)
                              Gwregeep(tmpb2) = Gwreg(tmpb2)
                           Next
                           Atsnd = "Se configuro IP GATEWAY a <" + Str(gwreg(1)) + "."
                           Atsnd = Atsnd + Str(gwreg(2)) + "." + Str(gwreg(3)) + "."
                           Atsnd = Atsnd + Str(gwreg(4)) + ">"
                        Case 3:
                           Cmderr = 0
                           For Tmpb2 = 1 To 4
                              Mskreg(tmpb2) = Iptmp(tmpb2)
                              Mskregeep(tmpb2) = Mskreg(tmpb2)
                           Next
                           Atsnd = "Se configuro IP MASK a <" + Str(mskreg(1)) + "."
                           Atsnd = Atsnd + Str(mskreg(2)) + "." + Str(mskreg(3)) + "."
                           Atsnd = Atsnd + Str(mskreg(4)) + ">"
                     End Select
                  Else
                     'Cmderr = 6
                     If Len(cmdsplit(3)) = 12 And Tmpb = 4 Then
                        Atsnd = "Se configuro MAC Adress <"
                        Cmderr = 0
                        For J = 1 To 6
                           Tmpb2 = 2 * J
                           Tmpb2 = Tmpb2 - 1
                           Tmpstr3 = Mid(cmdsplit(3) , Tmpb2 , 2)
                           Tmpb3 = Hexval(tmpstr3)
                           Macregeep(j) = Tmpb3
                           Macreg(j) = Tmpb3
                           Atsnd = Atsnd + Hex(tmpb3) + ":"
                        Next
                        Atsnd = Atsnd + ">"
                     Else
                        Cmderr = 6
                     End If

                  End If
               Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4
            End If

         Case "LEENET"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               Select Case Tmpb
                  Case 1:
                     Cmderr = 0
                     Atsnd = "IP DITEC <" + Str(ipmdc(1)) + "."
                     Atsnd = Atsnd + Str(ipmdc(2)) + "." + Str(ipmdc(3)) + "."
                     Atsnd = Atsnd + Str(ipmdc(4)) + ">"
                  Case 2:
                     Cmderr = 0
                     Atsnd = "IP GATEWAY <" + Str(gwreg(1)) + "."
                     Atsnd = Atsnd + Str(gwreg(2)) + "." + Str(gwreg(3)) + "."
                     Atsnd = Atsnd + Str(gwreg(4)) + ">"
                  Case 3:
                     Cmderr = 0
                     Atsnd = "IP MASK <" + Str(mskreg(1)) + "."
                     Atsnd = Atsnd + Str(mskreg(2)) + "." + Str(mskreg(3)) + "."
                     Atsnd = Atsnd + Str(mskreg(4)) + ">"
                  Case 4:
                     Cmderr = 0
                     Atsnd = "MAC Address <" + Hex(macreg(1)) + ":" + Hex(macreg(2)) + ":" + Hex(macreg(3)) + ":" + Hex(macreg(4)) + ":" + Hex(macreg(5)) + ":" + Hex(macreg(6)) + ">"

                  Case Else
                     Cmderr = 6

               End Select

            Else
               Cmderr = 4
            End If

            Case "SETPOL"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Ednum_masuno Then
                  Cmderr = 0
                  Tmpb3 = Tmpb - 1
                  Tmpb2 = Val(cmdsplit(3))
                  If Tmpb2 = 0 Then
                     Reset EdPOL.tmpb3
                  Else
                     Set Edpol.tmpb3
                  End If
                  Edpoleep = Edpol
                  Atsnd = "Se configuro Pol ED" + Str(tmpb) + "=" + Str(edpol.tmpb3)
               Else
                  Cmderr = 5
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEPOL"
            Select Case Numpar
               Case 1:
                  Cmderr = 0
                  Atsnd = "POL ED=" + Bin(edpol)
               Case 2:
                  Tmpb = Val(cmdsplit(2))
                  If Tmpb > 0 And Tmpb < Ednum_masuno Then
                     Tmpb3 = Tmpb - 1
                     Cmderr = 0
                     Atsnd = "POL ED" + Str(tmpb) + "=" + Str(edPOL.tmpb3)
                  Else
                     Cmderr = 5
                  End If
               Case Else
                  Cmderr = 4
            End Select

         Case "RSTVAR"
            Cmderr = 0
            Atsnd = "Se configuran variables a valores por defecto"
            Set Inivariables
            Cfgok = 1
            Cfgokeep = Cfgok
            Call Defaultvalues()

         Case "SETPAR"
            If Numpar = 5 Then
               Tmpb = Val(cmdsplit(2))
               Tmpb2 = Val(cmdsplit(3))
               Tmpb3 = Val(cmdsplit(4))

               Select Case Tmpb
                  Case 1:                                   ' ED
                     If Tmpb2 > 0 And Tmpb2 < Ednum_masuno Then
                        Select Case Tmpb3
                           Case 1:                          'Nombre
                              Edname(tmpb2) = Cmdsplit(5)
                              Ednameeep(tmpb2) = Edname(tmpb2)
                              Cmderr = 0
                              Atsnd = "Se config nombre ED" + Str(tmpb2) + "=" + Edname(tmpb2)

                           Case 2:                          ' Polaridad
                              Tmpb4 = Val(cmdsplit(5))
                              If Tmpb4 < 2 Then
                                 J = Tmpb2 - 1
                                 If Tmpb4 = 0 Then
                                    Reset Edpol.j
                                 Else
                                    Set Edpol.j
                                 End If
                                 Edpoleep = Edpol
                                 Cmderr = 0
                                 Atsnd = "EDpol" + Str(tmpb2) + "=" + Str(edpol.j)
                              Else
                                 Cmderr = 0
                                 Atsnd = "Valor de polaridad no valido"
                              End If

                           Case 3:                          ' Tactivacion +
                              Tredmas(tmpb2) = Val(cmdsplit(5))
                              Tredmaseep(tmpb2) = Tredmas(tmpb2)
                              Cmderr = 0
                              Atsnd = "Se config Tactivacion + ED" + Str(tmpb2) + "=" + Str(tredmas(tmpb2)) + "x100 ms"

                           Case 4:                          'T activacion -
                              Tredmenos(tmpb2) = Val(cmdsplit(5))
                              Tredmenoseep(tmpb2) = Tredmenos(tmpb2)
                              Cmderr = 0
                              Atsnd = "Se config Tactivacion - ED" + Str(tmpb2) + "=" + Str(tredmenos(tmpb2)) + "x100 ms"


                           Case Else
                              Cmderr = 0
                              Atsnd = "Parametro ED no valido"

                        End Select
                     Else
                        Cmderr = 0
                        Atsnd = "Num ED no valido"
                     End If

                  Case 2:                                   'EA
                     Cmderr = 0
                     Atsnd = "EA no hab en esta version"
'                     If Tmpb2 > 0 And Tmpb2 < Eanum_masuno Then
'                        Select Case Tmpb3
'                           Case 1:                          'Nombre
'                              Eaname(tmpb2) = Cmdsplit(5)
'                              Eanameeep(tmpb2) = Eaname(tmpb2)
'                              Cmderr = 0
'                              Atsnd = "Se config nombre EA" + Str(tmpb2) + "=" + Eaname(tmpb2)

'                           Case 2:                          ' Inicio de escala
'                              Iniescala(tmpb2) = Val(cmdsplit(5))
'                              Iniescalaeep(tmpb2) = Iniescala(tmpb2)
'                              Cmderr = 0
'                              Atsnd = "Inicio escala EA" + Str(tmpb2) + "=" + Str(iniescala(tmpb2))

'                           Case 3:                          ' Fondo de escala
'                              Fondoescala(tmpb2) = Val(cmdsplit(5))
'                              Fondoescalaeep(tmpb2) = Fondoescala(tmpb2)
'                              Cmderr = 0
'                              Atsnd = "Fondo escala EA" + Str(tmpb2) + "=" + Str(fondoescala(tmpb2))

'                           Case Else
'                              Cmderr = 0
'                              Atsnd = "Parametro EA no valido"

'                        End Select
'                     Else
'                        Cmderr = 5
'                     End If

'                  Case 3:                                   'MODBUS
'                     Cmderr = 0
'                     Atsnd = "MODBUS no implementado en esta version"

                  Case Else:
                     Cmderr = 0
                     Atsnd = "Tipo de entrada incorrecto"

               End Select

            Else
               Cmderr = 4
            End If

         Case "LEEPAR"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               Tmpb2 = Val(cmdsplit(3))
               Select Case Tmpb
                  Case 1:
                     Cmderr = 0                             'ED
                     If Tmpb2 > 0 And Tmpb2 < Ednum_masuno Then
                        J = Tmpb2 - 1
                        Atsnd = "ED" + Str(tmpb2) + ";Nombre=" + Edname(tmpb2) + ";POL=" + Str(edpol.j) + ";Tact+=" + Str(tredmas(tmpb2)) + "x100ms ;Tact-=" + Str(tredmenos(tmpb2)) + "x100ms"
                     Else
                        Cmderr = 0
                        Atsnd = "Num ED no valido"
                     End If

                  Case 2:                                   ' EA
                     Cmderr = 0                             'ED
                     Atsnd = "EA no hab en esta version"
'                     If Tmpb2 > 0 And Tmpb2 < Eanum_masuno Then
'                        Atsnd = "EA" + Str(tmpb2) + ";Nombre=" + Eaname(tmpb2) + ";Iniescala=" + Str(iniescala(tmpb2)) + ";Fondoescala=" + Str(fondoescala(tmpb2))
'                     Else
'                        Cmderr = 0
'                        Atsnd = "Num ED no valido"
'                     End If

'                  Case 3:                                      'MODBUS


               End Select
            Else
               Cmderr = 4
            End If


         Case "SETNTP"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Numntpsrv_masuno Then
                  Cmderr = 0
                  Ntpsrv(tmpb) = Cmdsplit(3)
                  Ntpsrveep(tmpb) = Ntpsrv(tmpb)
                  Atsnd = "Se config SRV NTP" + Str(tmpb) + " a " + Ntpsrv(tmpb)
               Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4
            End If

         Case "LEENTP"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Numntpsrv_masuno Then
                  Cmderr = 0
                  Atsnd = "SRV NTP" + Str(tmpb) + " = " + Ntpsrv(tmpb)
                  Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4
            End If

         Case "SETURL"
            If Numpar = 2 Then
               Cmderr = 0
               Urlbase = Cmdsplit(2)
               Urlbaseeep = Urlbase
               'Set Iniauto.3
               Atsnd = "Se config URL a " + Urlbase

            Else
               Cmderr = 4
            End If

         Case "LEEURL"
            Cmderr = 0
            Atsnd = "URL>" + Urlbase


         Case Else
            Cmderr = 1

      End Select

   Else
        Cmderr = 2
   End If

   If Cmderr > 0 Then
      Atsnd = Lookupstr(cmderr , Tbl_err)
   End If

   Print #1 , Atsnd

End Sub

'*******************************************************************************
' Subrutina para iniciar modem NET
'*******************************************************************************
Sub Inimdm()
   Cntrinimdc = Cntrinimdc + 1
   Cntrinimdceep = Cntrinimdc
   Print #1 , "INI WIZ5100>";Cntrinimdc
   Wiz5100_opcode_read = 15
   Wiz5100_opcode_write = 240
   Call Wiz5100_init
   Call Dispvnet()
   'Set Iniauto.3

End Sub




' Subrutina para generar espera
'*******************************************************************************
Sub Espera(byval Tespera As Word)
   Topdelay = Tespera
   Cntrdelay = 0
   Reset T0delay
   Set Inidelay
   While T0delay = 0
      Reset Watchdog
   Wend

End Sub


'*******************************************************************************
' Procesamiento de tramas para TS
'*******************************************************************************
Sub Procdaa()
   Print #1 , "DAA_data>" ; Gwsproc
   Numpar = Split(gwsproc , Cmdsplit(1) , ",")
   Print #1 , "Numpar>" ; Numpar
   If Numpar = 12 Then
      For K = 1 To 8
         Habfeed(k) = 0
      Next
      Fechaed = Cmdsplit(2)
      Horaed = Cmdsplit(3)
      If Fechaed <> "" And Horaed <> "" Then
         Tmpl = Syssec(horaed , Fechaed)
         'Tmpl = Tmpl - Husos
         Tmpl = Tmpl + 18000
         Fechaed = Date(tmpl)
         Horaed = Time(tmpl)
      Else
         Fechaed = ""
         Horaed = ""
      End If
      Keyapitmp = Cmdsplit(4)
      For K = 1 To 8
         Tmpb = K + 4
         If Cmdsplit(tmpb) <> "" Then
            Habfeed(k) = 1
            Valfeed(k) = Cmdsplit(tmpb)
         Else
            Print #1 , "No data field" ; K
         End If
      Next
      Set Newtx
   Else
      Print #1 , "Trama TS no valida"
   End If
End Sub

'*******************************************************************************
' Formatea trama en formato JSON
'*******************************************************************************
Sub Genjsonts()
   Datamdc = ""

   If Fechaed <> "" And Horaed <> "" Then
      Datamdc = Datamdc + "{" + Chr(34) + "values" + Chr(34) + ":" + "{"
      For K = 1 To 7
         If Habfeed(k) = 1 Then
            Tmpvar = Lookupstr(k , Tbl_vartb)
            Datamdc = Datamdc + Chr(34) + Tmpvar + Chr(34) + ":" + Valfeed(k) + ","
         End If
      Next
      K = 8
      If Habfeed(k) = 1 Then
         Tmpvar = Lookupstr(k , Tbl_vartb)
         Datamdc = Datamdc + Chr(34) + Tmpvar + Chr(34) + ":" + Valfeed(k)
      End If
      Datamdc = Datamdc + "}"
      Tmpl = Syssec(horaed , Fechaed)
      Print #1 , Tmpl
      Tmpl = Tmpl + 946684800
      Print #1 , Tmpl
      Datamdc = Datamdc + "," + Chr(34) + "ts" + Chr(34) + ":" + Str(tmpl) + "000"
      Datamdc = Datamdc + "}"
   Else
      Datamdc = Datamdc + "{"
      For K = 1 To 7
         If Habfeed(k) = 1 Then
            Tmpvar = Lookupstr(k , Tbl_vartb)
            Datamdc = Datamdc + Chr(34) + Tmpvar + Chr(34) + ":" + Valfeed(k) + ","
         End If
      Next
      K = 8
      If Habfeed(k) = 1 Then
         Tmpvar = Lookupstr(k , Tbl_vartb)
         Datamdc = Datamdc + Chr(34) + Tmpvar + Chr(34) + ":" + Valfeed(k)
      End If
      Datamdc = Datamdc + "}"
   End If

   Buffer = "POST /api/v1/" + Keyapitmp + "/telemetry HTTP/1.1" + Chr(13) + Chr(10)
'   Buffer = "POST /update HTTP/1.1" + Chr(13) + Chr(10)
   Call Wiz5100_sendit

   Buffer = "Host: datalog.molukas.com" + Chr(13) + Chr(10)
   Call Wiz5100_sendit

   'Buffer = "Connection: close" + Chr(13) + Chr(10)
   'Call Wiz5100_sendit

   Buffer = "Content-Type: application/json" + Chr(13) + Chr(10)
   Call Wiz5100_sendit

   Buffer = "Content-Length: "
   Call Wiz5100_sendit
   Tmpb = Len(datamdc)
   Buffer = Str(tmpb) + Chr(13) + Chr(10)
   Call Wiz5100_sendit

   Buffer = Chr(13) + Chr(10)
   Call Wiz5100_sendit
   Buffer = Datamdc
   Call Wiz5100_sendit
End Sub

Sub Gethoratb()
   Buffer = Buffer1
   Print #1 , "Lbuf=" ; Len(buffer)
   Tmpw = Instr(buffer , "date:")
   Print #1 , "Tw1=" ; Tmpw
   Tmpw2 = Instr(buffer , "GMT")
   Print #1 , "Tw2=" ; Tmpw2

   If Tmpw > 0 Then
      Tmpstr52 = ""
      Tmpw3 = Tmpw2 - Tmpw
      Tmpstr52 = Mid(buffer , Tmpw , Tmpw3)
      Print #1 , "FECHA>" ; Tmpstr52
      Numpar = Split(tmpstr52 , Cmdsplit(1) , " ")
      If Numpar = 7 Then
         Print #1 , "Dia=" ; Cmdsplit(3)
         Print #1 , "Mes=" ; Cmdsplit(4)
         Print #1 , "Año=" ; Cmdsplit(5)
         Print #1 , "Hora=" ; Cmdsplit(6)
         Mestxt = Cmdsplit(4)
         Fechaed = Cmdsplit(3)
         Tmpstr8 = Mid(cmdsplit(5) , 3 , 2)
         Select Case Mestxt
            Case "Jan" : Mes = "01"
            Case "Feb" : Mes = "02"
            Case "Mar" : Mes = "03"
            Case "Apr" : Mes = "04"
            Case "May" : Mes = "05"
            Case "Jun" : Mes = "06"
            Case "Jul" : Mes = "07"
            Case "Aug" : Mes = "08"
            Case "Sep" : Mes = "09"
            Case "Oct" : Mes = "10"
            Case "Nov" : Mes = "11"
            Case "Dec" : Mes = "12"
         End Select
         Fechaed = Fechaed + "/" + Mes + "/" + Tmpstr8
         Horaed = Cmdsplit(6)
         Tmpl2 = Syssec()
         Tmpl = Syssec(horaed , Fechaed)
         Tmpl = Tmpl - 18000
         Print #1 , "Hora=" ; Time(tmpl)
         Print #1 , "Fecha=" ; Date(tmpl)
         Tmpl2 = Tmpl2 - tmpl
         Print #1 , "Diferencia=";tmpl2
         Time$ = Time(tmpl)
         Date$ = Date(tmpl)
         Reset Getfechatb
         Set Flagtbclk
      End If
   End If


End Sub

'*******************************************************************************
'TX DATOS GPRS
'*******************************************************************************
Sub Txdata(byval Trama As Byte)
'   Txokflag = 0
   Estado_led = 8
   Txok = 0
   Print #1,
   Print #1 , "Ini TX"
   Print #1 , "OPEN socket"
   Valueant = 255
   Timevalue = 10
   Reset Tout
   Cntrseg = 0
   Cntrsegant = 255
   Set Initout
   Timevalue = 10

   'Tmpb = 3
   'Settcpregs &H19 , Tmpb , 1

   Newskt = 255
   Idx = 7
   Do
     Incr Idx
     Idx = Idx Mod 8
     Newskt = Getsocket(idx , Sock_stream , 0 , 0)
     Print #1 , "IDX:" ; Idx ; " Newskt:" ; Newskt
     Reset Watchdog
   Loop Until Newskt < 255 Or Tout = 1

   Print #1 , "IDX:" ; Idx ; " Newskt:" ; Newskt

   If Newskt < 255 Then
      Print #1 , "Conectando a " ; Ip2str(iptxl);
      Print #1 , " en PTO " ; Str(prtotxl)

      Reset Tout
      Cntrseg = 0
      Set Initout
      Timevalue = 6
      Result = 1
      Resultant = 99
      Cntrsegant = 255

      'Stop Watchdog
      Do
         Result = Socketconnect(newskt , Iptxl , Prtotxl)
         'Result = Socketconnect(newskt , 173.203.98.29 , 8081)
         'Print #1 , "R1=" ; Result
         'Reset Watchdog
         If Resultant <> Result Then
            Print #1 , "R" ; Result
            Resultant = Result
         End If
         If Cntrsegant <> Cntrseg Then
            Print #1 , "C" ; Cntrseg
            Cntrsegant = Cntrseg
            Reset Watchdog
         End If
      Loop Until Result = 0 Or Tout = 1

      Reset Initout

      If Tout = 1 Then
         Print #1 , "No se pudo inicializar socket"
         Estado_led = 13
         Incr Cntrerr
      Else
         If Result = 0 Then
            'Atsnd = Datamdc
            Call Genjsonts()
            Print #1 ,
            Print #1 , "Se envio dato"
            'Txokflag = 1
            'Cntr_errtx = 0
            Cntrerr = 0
            Txok = 1
            Estado_led = 11

         Else
            If Result = 1 Then
               Print #1 , "ERROR socket cerrado"
               Incr Cntrerr
               Estado_led = 13
            End If
         End If

         Print #1 , "Esperando respuesta del server"
         Print #1,

         Reset Tout
         Cntrseg = 0
         Set Initout
         Timevalue = 2
         Stop Watchdog
         Buffer1 = ""
         Do
            Result = Socketstat(newskt , Sel_recv)          ' get number of bytes waiting
            Reset Watchdog

            If Result > 0 Then
               Result = Tcpread(newskt , Buffer)
               Reset Watchdog
               If Buffer <> "" Then
                  Buffer1 = Buffer1 + Buffer
                  If Len(buffer1) > Long_buffer Then
                     Print #1 , "Overflow"
                     Buffer1 = ""
                  End If
               End If
               'Print #1 , Buffer1;
               Result = 0
            End If
            If Cntrsegant <> Cntrseg Then
               Print #1 , "CR" ; Cntrseg
               Cntrsegant = Cntrseg
               Reset Watchdog
            End If

         Loop Until Tout = 1                                'Or Result = 0
         'Start Watchdog
         Estado_led = 1
      End If

      Print #1,
      Print #1 , "Cerrando el socket"
      Socketclose Newskt
      'Print #1 , "B:" ; Buffer
      Print #1 , "B1:"                                      '
      Print #1 , Buffer1
      Reset Watchdog

      Print #1 , "Desconectando el socket"
      Socketdisconnect Newskt
      'Print #1 , "B:" ; Buffer
      'Print #1 , "B1:" ; Buffer1
      Reset Watchdog
      'Start Watchdog
   Else
      Print #1 , "Timeout mientras iniciaba socket"
      Estado_led = 12
      Incr Cntrerr

   End If

   Print #1 , "Cntrerr=" ; Cntrerr



End Sub


Sub Getcmd()

End Sub


'*******************************************************************************
' Valores por defecto
'*******************************************************************************
Sub Defaultvalues()
   'Apneep = "watching.porta.com.ec"
   Urlbaseeep = "thingsboard.cloud"
   Iptxeep = "44.194.165.190"
   Prtotxeep = "80"
   Cntrinieep = 0
   Cntrinimdceep = 0

   For J = 1 To Ednum
      Tmpstr52 = "ED" + Str(j)
      Ednameeep(j) = Tmpstr52
      Tredmaseep(j) = 20
      Tredmenoseep(j) = 20
      Tmpstr52 = Lookupstr(j , Tbl_repmas)
      Txtrepmaseep(j) = Tmpstr52
      Tmpstr52 = Lookupstr(j , Tbl_repmenos)
      Txtrepmenoseep(j) = Tmpstr52
   Next
   Ednameeep(1) = "PT1"
   Ednameeep(3) = "AC"
   Ednameeep(4) = "TVS"
   Tredmaseep(3) = 50                                       ' 5 SEGUNDOS PARA ACTIVACION EN AC
   Tredmenoseep(3) = 50


   Edpoleep = 0
   Edhabeep = &B00000101

   For Tmpb = 1 To Numtxaut
      Autoval(tmpb) = 300
      Autovaleep(tmpb) = Autoval(tmpb)
      Offset(tmpb) = 0
      Offseteep(tmpb) = 0
   Next

   Autovaleep(2) = 43200
   Offseteep(2) = 120

   Autovaleep(3) = 43200
   Offseteep(3) = 30

   Autovaleep(4) = 7200
   Offseteep(4) = 60


   Adckeep = 0.004297432

'   Ipmdceep(1) = 10
'   Ipmdceep(2) = 10
'   Ipmdceep(3) = 10
'   Ipmdceep(4) = 26

'   Gwregeep(1) = 10
'   Gwregeep(2) = 10
'   Gwregeep(3) = 10
'   Gwregeep(4) = 1
'   Mskregeep(1) = 255
'   Mskregeep(2) = 255
'   Mskregeep(3) = 255
'   Mskregeep(4) = 0
'   Cfgokeep = 1
'   Cfgok = 1

   Ntpsrveep(1) = "129.6.15.28"
   Ntpsrveep(2) = "132.163.97.1"
   Ntpsrveep(3) = "132.163.97.2"
   Ntpsrveep(4) = "132.163.97.3"
   Ntpsrveep(5) = "132.163.96.1"
   Ntpsrveep(6) = "132.163.96.2"
   Ntpsrveep(7) = "128.138.140.44"
   Ntpsrveep(8) = "128.138.141.172"
   'Apikeytbeep = "692MD2IN8RBKSTGY"
   'Idtbeep = "50352"
   Canalcmdeep = ""

   Set Inivariables
End Sub




'Subrutina para leer ED
'*******************************************************************************
'Subrutina para leer ED
'*******************************************************************************
Sub Leered()
   For Jed = 1 To Ednum
      If Edstaant(jed) <> Edsta(jed) Then
         Print #1 , "ED" ; Jed ; " de " ; Edstaant(jed) ; " a " ; Edsta(jed)
         Edstaant(jed) = Edsta(jed)
      End If
   Next

   For Tmped = 0 To Ednum_1
      Jed = Tmped + 1
      If Edhab.tmped = 1 Then
         If Evmas.tmped = 1 Then
            Reset Evmas.tmped
            Print #1 , "Nuevo evento Mas en ED" ; Jed
            Tmpl = Syssec()
            If Flagtbclk = 1 Then
               Horaed = Time$
               Fechaed = Date$
               Gwsproc = "$ED" + Str(tmped) + "," + Fechaed + "," + Horaed + "," + Keyapi
            Else
               Horaed = ""
               Fechaed = ""
               Gwsproc = "$ED" + Str(tmped) + "," + "," + "," + Keyapi
            End If
            Tmpbit = Ed0 Xor Edpol.0
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed1 Xor Edpol.1
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed2 Xor Edpol.2
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed3 Xor Edpol.3
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            If Samplerdy = 1 Then
               Gwsproc = Gwsproc + "," + Fusing(adcvali , "#.##")
            Else
               Gwsproc = Gwsproc + ","
            End If
            If Samplerdy = 1 Then
               Gwsproc = Gwsproc + "," + Fusing(t1 , "#.##")
            Else
               Gwsproc = Gwsproc + ","
            End If
            Gwsproc = Gwsproc + "," + Str(cntrini)
            Gwsproc = Gwsproc + "," + Str(cntrinimdc)
            Print #1 , Gwsproc
            Ptrbuf = Ptrbuf Mod Numbuf
            Incr Ptrbuf
            Mdcbuf(ptrbuf) = Gwsproc
            Txbuf(ptrbuf) = 1
            Print #1 , "PTRBUF=" ; Ptrbuf
         End If
         If Evmenos.tmped = 1 Then
            Reset Evmenos.tmped
            Print #1 , "Nuevo evento Menos en ED" ; Jed
            Tmpl = Syssec()
            If Flagtbclk = 1 Then
               Horaed = Time$
               Fechaed = Date$
               Gwsproc = "$ED" + Str(tmped) + "," + Fechaed + "," + Horaed + "," + Keyapi
            Else
               Horaed = ""
               Fechaed = ""
               Gwsproc = "$ED" + Str(tmped) + "," + "," + "," + Keyapi
            End If
            Tmpbit = Ed0 Xor Edpol.0
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed1 Xor Edpol.1
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed2 Xor Edpol.2
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            Tmpbit = Ed3 Xor Edpol.3
            Gwsproc = Gwsproc + "," + Str(tmpbit)
            If Samplerdy = 1 Then
               Gwsproc = Gwsproc + "," + Fusing(adcvali , "#.##")
            Else
               Gwsproc = Gwsproc + ","
            End If
            If Samplerdy = 1 Then
               Gwsproc = Gwsproc + "," + Fusing(t1 , "#.##")
            Else
               Gwsproc = Gwsproc + ","
            End If
            Gwsproc = Gwsproc + "," + Str(cntrini)
            Gwsproc = Gwsproc + "," + Str(cntrinimdc)
            Print #1 , Gwsproc
            Ptrbuf = Ptrbuf Mod Numbuf
            Incr Ptrbuf
            Mdcbuf(ptrbuf) = Gwsproc
            Txbuf(ptrbuf) = 1
            Print #1 , "PTRBUF=" ; Ptrbuf
         End If
      End If
   Next

End Sub



'*******************************************************************************
'Subrutina para leer ADC
'*******************************************************************************
Sub Leeradc()
   Tmpwadc = Getadc(2)                                      'Valor instantaneo
   'Print #1 , "ADCHEX=" ; Tmpwadc
   Adccntri = Adccntri + Tmpwadc
   Incr Cntrsmpli
   Cntrsmpli = Cntrsmpli Mod 4
   If Cntrsmpli = 0 Then
       Adcvali = Adccntri * Adck
       Adcvali = Adcvali + 0.3
       Adccntri = 0
       Set Samplerdy
   End If
End Sub

Sub Proced()
   Tmpl = Tbl_timeaut(1)
   If Flagtbclk = 1 Then
      Horaed = Time$
      Fechaed = Date$
      Gwsproc = "$EDSTA" + "," + Fechaed + "," + Horaed + "," + Keyapi
   Else
      Horaed = ""
      Fechaed = ""
      Gwsproc = "$EDSTA" + "," + "," + "," + Keyapi
   End If

   If Edsta(1) = 0 Or Edsta(1) = 2 Then
      Set Tmpbit
   End If
   If Edsta(1) = 1 Or Edsta(1) = 3 Then
      Reset Tmpbit
   End If
   Gwsproc = Gwsproc + "," + Str(tmpbit)

   If Edsta(2) = 0 Or Edsta(2) = 2 Then
      Set Tmpbit
   End If
   If Edsta(2) = 1 Or Edsta(2) = 3 Then
      Reset Tmpbit
   End If
   Gwsproc = Gwsproc + "," + Str(tmpbit)

   If Edsta(3) = 0 Or Edsta(3) = 2 Then
      Set Tmpbit
   End If
   If Edsta(3) = 1 Or Edsta(3) = 3 Then
      Reset Tmpbit
   End If
   Gwsproc = Gwsproc + "," + Str(tmpbit)

   If Edsta(4) = 0 Or Edsta(4) = 2 Then
      Set Tmpbit
   End If
   If Edsta(4) = 1 Or Edsta(4) = 3 Then
      Reset Tmpbit
   End If


   Gwsproc = Gwsproc + "," + Str(tmpbit)


'   Tmpbit = Ed0 Xor Edpol.0                                 'pt1
'   Gwsproc = Gwsproc + "," + Str(tmpbit)
'   Tmpbit = Ed1 Xor Edpol.1                                 'PT2
'   Gwsproc = Gwsproc + "," + Str(tmpbit)
'   Tmpbit = Ed2 Xor Edpol.2                                 'AC
'   Gwsproc = Gwsproc + "," + Str(tmpbit)
'   Tmpbit = Ed3 Xor Edpol.3                                 'TVSS
'   Gwsproc = Gwsproc + "," + Str(tmpbit)

   If Samplerdy = 1 Then
      Gwsproc = Gwsproc + "," + Fusing(adcvali , "#.##")
   Else
      Gwsproc = Gwsproc + ","
   End If

   If Samplerdy = 1 Then
      Gwsproc = Gwsproc + "," + Fusing(t1 , "#.##")
   Else
      Gwsproc = Gwsproc + ","
   End If

   Gwsproc = Gwsproc + "," + Str(cntrini)
   Gwsproc = Gwsproc + "," + Str(cntrinimdc)
   Print #1 , Gwsproc
End Sub






'*****************************************************************************
' Subrutinas WIZ5100
'*****************************************************************************
'*******************************************************************************
'Subrutinas modulo Ethernet
Sub Wiz5100_init
'   settcp macreg(1),IPmdc(1),MSKREG(1),GWREG(1)
   Incr Cntrinimdc
   Cntrinimdceep = Cntrinimdc

   Print #1 , "INI WIZ5200"
   Call Wiz5100_reset
   Tmpb2 = 6
   For Tmpb = 1 To 6
      Ipreg(tmpb2) = Macreg(tmpb)
      'Print #1,
      Decr Tmpb2
   Next

   Waitms 500

   Ipmval = Maketcp(ipmdc(1) , Ipmdc(2) , Ipmdc(3) , Ipmdc(4))
   Gwval = Maketcp(gwreg(1) , Gwreg(2) , Gwreg(3) , Gwreg(4))
   Mskval = Maketcp(mskreg(1) , Mskreg(2) , Mskreg(3) , Mskreg(4))

   Settcp Ipreg(1) , Ipmval , Mskval , Gwval
   'Settcp 0.1.1.1.1.1 , 192.168.0.59 , 255.255.255.0 , 192.168.0.129

   Tmpb = 3
   Settcpregs &H19 , Tmpb , 1
End Sub


Sub Wiz5100_reset
   Print #1 , "ini 2 RST WIZ820"
   Waitms 250
   Wiz5100_res = 1
   Reset Watchdog
   Waitms 250
   Reset Watchdog
   Wiz5100_res = 0
   Waitms 250                                               'Minimum 20 µs
   Wiz5100_res = 1
   Reset Watchdog
   Print #1 , "fin 2 RST WIZ820"
End Sub

Sub Wiz5100_sendit
   Print #1 , Buffer
   Result = Tcpwritestr(newskt , Buffer , 0)
End Sub

Sub Wiz5100_receive

End Sub

Sub Dispvnet()
   Print #1 , "Leyendo Configuracion WIZ820io"
   Print #1 , "IPM:";
   Ipreg(1) = Gettcpregs(15 , 4)
   Print #1 , Ipreg(4) ; "." ; Ipreg(3) ; "." ; Ipreg(2) ; "." ; Ipreg(1)

   Print #1 , "GW:";
   Ipreg(1) = Gettcpregs(1 , 4)
   Print #1 , Ipreg(4) ; "." ; Ipreg(3) ; "." ; Ipreg(2) ; "." ; Ipreg(1)

   Print #1 , "MSK:" ;
   Ipreg(1) = Gettcpregs(5 , 4)
   Print #1 , Ipreg(4) ; "." ; Ipreg(3) ; "." ; Ipreg(2) ; "." ; Ipreg(1)

   Print #1 , "MAC:";
   Ipreg(1) = Gettcpregs(9 , 6)
   Print #1 , Hex(ipreg(6)) ; "." ; Hex(ipreg(5)) ; "." ; Hex(ipreg(4)) ; "." ; Hex(ipreg(3)) ; "." ; Hex(ipreg(2)) ; "." ; Hex(ipreg(1))

   Print #1 , "RTR:";
   Ipreg(1) = Gettcpregs(&H17 , 2)
   Print #1 , Hex(ipreg(2)) ; Hex(ipreg(1))

   Print #1 , "RCR:";
   Ipreg(1) = Gettcpregs(&H19 , 1)
   Print #1 , Hex(ipreg(1))

   Reset Watchdog
End Sub

Sub Valippto()
   Reset Ipptook
   Tmpstr52 = ""
   Tmpb = Instr(iptx , ".")                                 'Busqueda del primer punto
   If Tmpb > 0 Then
      'Print "P:" ; Tmpb
      Tmpb2 = Tmpb - 1
      Tmpstr52 = Mid(iptx , 1 , Tmpb2)
      'Print Tmpstr52
      Ipreg(1) = Val(tmpstr52)
      Tmpb = Tmpb + 1
      Tmpb2 = Instr(tmpb , Iptx , ".")                      'Punto 2
      If Tmpb2 > 0 Then
         'Print "P:" ; Tmpb2
         Tmpb3 = Tmpb2 - Tmpb
         Tmpstr52 = ""
         Tmpstr52 = Mid(iptx , Tmpb , Tmpb3)
         'Print Tmpstr52
         Ipreg(2) = Val(tmpstr52)
         Tmpb2 = Tmpb2 + 1
         Tmpb = Instr(tmpb2 , Iptx , ".")
         If Tmpb > 0 Then                                   'Punto 3
            Tmpb3 = Tmpb - Tmpb2
            Tmpstr52 = ""
            Tmpstr52 = Mid(iptx , Tmpb2 , Tmpb3 )
            Ipreg(3) = Val(tmpstr52)
            Tmpb2 = Tmpb + 1
            Tmpb3 = Tmpb - Tmpb2
            Tmpstr52 = ""
            Tmpstr52 = Mid(iptx , Tmpb2 , Tmpb3)
            Ipreg(4) = Val(tmpstr52)
            'Print Tmpstr52
            Tmpw = Val(prtotx)
            Ptoreg(1) = High(tmpw )
            Ptoreg(2) = Low(tmpw)
            Print #1 , "1:" ; Hex(ptoreg(1))
            Print #1 , "2:" ; Hex(ptoreg(2))
            Iptxl = Maketcp(ipreg(1) , Ipreg(2) , Ipreg(3) , Ipreg(4))
            Prtotxl = Val(prtotx)

            Set Ipptook
         Else
            Print #1 , "IPreg3 no val"
         End If

      Else
         Print #1 , "IPreg2 no val"
      End If

   Else
      Print #1 , "IP no val"
   End If
End Sub

Sub Cfgtcp()


End Sub

'*******************************************************************************
'TABLA DE DATOS
'*******************************************************************************

Tbl_msgat:
Data "PWR GPS"                                              '0
Data "RST GPS"                                              '1
Data "Contexto GPRS"                                        '2
Data "Urlbase GPRS"                                             '3
Data "Linea DCD"                                            '4
Data "Network time"                                         '5
Data "Codigo no sol. CREG"                                  '6
Data "Codigo no sol. CGREG"                                 '7
Data "IP HEADER"                                            '8


Tbl_cmdat:
Data "AT+CGPSPWR=1"                                         '0
Data "AT+CGPSRST=1"                                         '1
Data "AT+SAPBR=3,1,{034}Contype{034},{034}GPRS{034}"        '2
Data "AT+SAPBR=3,1,{034}Urlbase{034},{034}"                     '3 AT+SAPBR=3,1,"Urlbase","watching.porta.com.ec"
Data "AT&C1"                                                '4
Data "AT+CLTS=1"                                            '5
Data "AT+CREG=1"                                            '6
Data "AT+CGREG=1"                                           '7
Data "AT+CIPHEAD=1"                                         '8


'******************************************************************************
Tbl_cmdfin:
Data ""                                                     '0
Data ""                                                     '1
Data ""                                                     '2
Data "{034}"                                                '3
Data ""                                                     '4
Data ""                                                     '5
Data ""                                                     '6
Data ""                                                     '7
Data ""                                                     '8


Tbl_err:
Data "OK"                                                   '0
Data "Comando no reconocido"                                '1
Data "Longitud comando no valida"                           '2
Data "Numero de usuario no valido"                          '3
Data "Numero de parametros invalido"                        '4
Data "Error longitud parametro 1"                           '5
Data "Error longitud parametro 2"                           '6
Data "Parametro no valido"                                  '7
Data "ERROR8"                                               '8
Data "ERROR SD. Intente de nuevo"                           '9

Tbl_repmas:
Data "1"                                                    'dummy data
Data "Reporte Mas ED1"
Data "Reporte Mas ED2"
Data "Reporte Mas ED3"
Data "Reporte Mas ED4"


Tbl_repmenos:
Data "0"                                                    'dummy data
Data "Reporte Menos ED1"
Data "Reporte Menos ED2"
Data "Reporte Menos ED3"
Data "Reporte Menos ED4"

Tabla_estado:
Data &B00000000000000000000000000000000&                    'Estado 0
Data &B00000000000000000000000000000011&                    'Estado 1
Data &B00000000000000000000000000110011&                    'Estado 2
Data &B00000000000000000000001100110011&                    'Estado 3
Data &B00000000000000000011001100110011&                    'Estado 4
Data &B00000000000000110011001100110011&                    'Estado 5
Data &B00000000000011001100000000110011&                    'Estado 6
Data &B00001111111111110000111111111111&                    'Estado 7
Data &B01010101010101010101010101010101&                    'Estado 8
Data &B00110011001100110011001100110011&                    'Estado 9
Data &B01110111011101110111011101110111&                    'Estado 10
Data &B10101010101010101010101010101010&                    'Estado 11
Data &B11111111111111000000000011001100&                    'Estado 12
Data &B11111111111111000000110011001100&                    'Estado 13
Data &B11111111111111001100110011001100&                    'Estado 14
Data &B11111111111111111111110000000000&                    'Estado 15
Data &B11111111111111111111111111111111&                    'Estado 16

Tbl_vartb:
Data "Dummy"
Data "pt1"
Data "pt2"
Data "ac1"
Data "tvs"
Data "pwr"
Data "t1"
Data "cini"
Data "cinimdc"

Crc8:
Data 0 , 94 , 188 , 226 , 97 , 63 , 221 , 131 , 194 , 156
Data 126 , 32 , 163 , 253 , 31 , 65 , 157 , 195 , 33 , 127
Data 252 , 162 , 64 , 30 , 95 , 1 , 227 , 189 , 62 , 96
Data 130 , 220 , 35 , 125 , 159 , 193 , 66 , 28 , 254 , 160
Data 225 , 191 , 93 , 3 , 128 , 222 , 60 , 98 , 190 , 224
Data 2 , 92 , 223 , 129 , 99 , 61 , 124 , 34 , 192 , 158
Data 29 , 67 , 161 , 255 , 70 , 24 , 250 , 164 , 39 , 121
Data 155 , 197 , 132 , 218 , 56 , 102 , 229 , 187 , 89 , 7
Data 219 , 133 , 103 , 57 , 186 , 228 , 6 , 88 , 25 , 71
Data 165 , 251 , 120 , 38 , 196 , 154 , 101 , 59 , 217 , 135
Data 4 , 90 , 184 , 230 , 167 , 249 , 27 , 69 , 198 , 152
Data 122 , 36 , 248 , 166 , 68 , 26 , 153 , 199 , 37 , 123
Data 58 , 100 , 134 , 216 , 91 , 5 , 231 , 185 , 140 , 210
Data 48 , 110 , 237 , 179 , 81 , 15 , 78 , 16 , 242 , 172
Data 47 , 113 , 147 , 205 , 17 , 79 , 173 , 243 , 112 , 46
Data 204 , 146 , 211 , 141 , 111 , 49 , 178 , 236 , 14 , 80
Data 175 , 241 , 19 , 77 , 206 , 144 , 114 , 44 , 109 , 51
Data 209 , 143 , 12 , 82 , 176 , 238 , 50 , 108 , 142 , 208
Data 83 , 13 , 239 , 177 , 240 , 174 , 76 , 18 , 145 , 207
Data 45 , 115 , 202 , 148 , 118 , 40 , 171 , 245 , 23 , 73
Data 8 , 86 , 180 , 234 , 105 , 55 , 213 , 139 , 87 , 9
Data 235 , 181 , 54 , 104 , 138 , 212 , 149 , 203 , 41 , 119
Data 244 , 170 , 72 , 22 , 233 , 183 , 85 , 11 , 136 , 214
Data 52 , 106 , 43 , 117 , 151 , 201 , 74 , 20 , 246 , 168
Data 116 , 42 , 200 , 150 , 21 , 75 , 169 , 247 , 182 , 232
Data 10 , 84 , 215 , 137 , 107 , 53
'*****************************************************************************


Loaded_arch: