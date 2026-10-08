'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 10.10.23
'


$version 0 , 1 , 318
$regfile = "m1284pdef.dat"
$crystal = 7372800
$baud = 9600



$hwstack = 256
$swstack = 256
$framesize = 256

$projecttime = 292
$lib "datetime.lbx"
$bigstrings


'CONSTANTES
Const Numrd = 1000
'Const Tryon = 5
'Const Trysimon = 15
'Const Numcmd = 9
Const Numbuf = 16
Const Long_buffer = 1200
'Const Cant_leds = 8

Const Ednum = 6
Const Ednum_1 = Ednum - 1
Const Ednum_masuno = Ednum + 1

Const Numtxaut = 4                                          ' 1 Mainboard, 2 No usado, 3 ACTCLK, 4-11 es T1-8
Const Numtxaut_mas_uno = Numtxaut + 1

Const Tsampling = 5

Const Numntpsrv = 8
Const Numntpsrv_masuno = Numntpsrv + 1
Const Lonbuffer = 2400
Const Tactipini = 120

'RTC
Const Ds3231r = &B11010001                                  'DS3231 is very similar to DS1307 but it include a precise crystal
Const Ds3231w = &B11010000

Const Tpoll = 5

'Configuracion de entradas/salidas
Led0 Alias Portb.0
Config Led0 = Output

Set Led0

'ENTRADAS
Ed0 Alias Pinc.0
Ed1 Alias Pinc.1
Ed2 Alias Pinc.2
Ed3 Alias Pinc.3
Ed4 Alias Pinc.4
Ed5 Alias Pinc.5

Config Ed0 = Input
Config Ed1 = Input
Config Ed2 = Input
Config Ed3 = Input
Config Ed4 = Input
Config Ed5 = Input

Set Portc.0
Set Portc.1
Set Portc.2
Set Portc.3
Set Portc.4


'WIZ3150
Wiz5100_cs Alias Portb.3                                    'Chipselect WIZ810MJ
Config Wiz5100_cs = Output

Wiz5100_res Alias Portb.2                                   'reset of WIZ810MJ
Config Wiz5100_res = Output

'$include "w3150a.inc"


'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz si Timer0=184
On Timer0 Int_timer0
Enable Timer0
Start Timer0

'TIMER1
Config Timer1 = Timer , Prescale = 256                      'Ints a 100Hz si Timer0=184
On Timer1 Int_timer1
Enable Timer1
Start Timer1

On Urxc At_serialint
Enable Urxc
Open "com1:" For Binary As #1

Dim Dummy As Byte
Config Date = Dmy , Separator = /                           ' ANSI-Format, Timer2
Config Clock = Soft , Gosub = Sectic

Config 1wire = Portc.5

'Config Sda = Portd.0
'Config Scl = Portd.1
'Config I2cdelay = 10
'Waitms 100
'I2cinit

'Bus SPI
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 0
Spiinit

'Print #1 , "CONFIG TCP"
Config Tcpip = Noint , _
               Mac = 00.08.dc.01.01.22 , _
               Ip = 192.168.0.57 , _
               Submask = 255.255.255.0 , _
               Gateway = 192.168.0.129 , _
               Localport = 1 , _
               Chip = W5200 , _
               Spi = 1 , _
               Cs = Portb.3 , _
               Tx = $55 , Rx = $55 , Noinit = 1

'ADC
Config Adc = Single , Prescaler = Auto                      ', Reference = Internal
Enable Adc
Start Adc

Enable Interrupts

'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "DITEC-TBIND_archivos.bas"
'Dim Ip As Long

Do
   Call Inivar()
   Call Vercfg()

'Programa principal
   'Call Leertc()


'Do
   'Call Inivar()
   Call Inimdm()
   'Set Iniauto.3


   Print #1 , "MAIN"
   Set Iniauto.1                                            'Para tener igualación de reloj

   Do

      If Sernew = 1 Then                                    'DATOS SERIAL 1
         Reset Sernew
         Print #1 , "SER1=" ; Serproc
         Call Procser()
      End If

      Call Leered()

      If Iniadc = 1 Then
         Reset Iniadc
         Call Leeradc()
         If Enabug = 1 Then
           Print #1 , "ADC1=" ; Fusing(adcvali , "#.##")
         End If
         Call Leer_ds18b20()
         Err = 0
         'I2cinit
      End If


      If Inipoll = 1 Then
      '   Reset Inipoll
         Ptrtx = Ptrtx Mod Numbuf
         Incr Ptrtx
      End If

      If Enabug = 2 Then
         'Print #1 , "PTRTX=" ; Ptrtx
         If Cntrpollant <> Cntrpoll Then
            Print #1 , "Cntrpoll=" ; Cntrpoll
            Cntrpollant = Cntrpoll
         End If
      End If

      If Txbuf(ptrtx) = 1 Then
         Print #1 , "Ptrtx=" ; Ptrtx
         Txbuf(ptrtx) = 0
         Print #1 , "GWS=" ; Mdcbuf(ptrtx)
         Gwsproc = Mdcbuf(ptrtx)
         Call Procdaa()
         If Newtx = 1 Then
            Reset Newtx
            Txok = 0
            Cntrtx = 0
            Do
               'Call Vergprs()
               'If Gprsok = 1 Then
                  'Call Wiz5100_sendit
                  Ipvaltmp = Iptx
                  Call Valippto()
                  Call Txdata(1)
               'End If
               Incr Cntrtx
            Loop Until Txok = 1 Or Cntrtx = 2
            If Txok = 1 Then
               Txbuf(ptrtx) = 0
            End If
            Reset Inipoll
            Set Inicpoll
         Else
            Mdcbuf(ptrtx) = ""
         End If
      End If


      If Newtx = 1 Then
         Reset Newtx
         Print #1 , "New TX GPRS"
         Txok = 0
         Cntrtx = 0
         Do
            'Call Vergprs()
            'If Gprsok = 1 Then
            Ipvaltmp=Iptx
            Call Valippto()
               Call Txdata(0)
            'End If
            Incr Cntrtx
         Loop Until Txok = 1 Or Cntrtx = 2
      End If

      If Cntrerr > 3 Then
         Print #1 , "Cntrerr=" ; Cntrerr
         Cntrerr = 0
         Set Inimodem
         Incr Cntrerrsis
         Print #1 , "Cntrerrsis=" ; Cntrerrsis
      End If

      If Cntrerrsis > 4 Then
         Cntrerrsis = 0
         Set Resets
         Print #1 , "ERR sistema"
      End If


      If Inimodem = 1 Then
         Reset Inimodem
         Call Inimdm()
         Set Iniauto.3
         Autoval(4) = Tactipini
      End If

      If Iniauto.0 = 1 Then
         Reset Iniauto.0
         Incr Cntrdata
         Print #1 , "TX PER"
         Call Proced()
         Call Procdaa()
         If Newtx = 1 Then
            Reset Newtx
            Txok = 0
            Cntrtx = 0
            Do
               'Call Vergprs()
               'If Gprsok = 1 Then
               Ipvaltmp = Iptx
               Call Valippto()
               Call Txdata(1)
               If Getfechatb = 1 Then
                  Print #1 , "GET Hora TB"
                  Call Gethoratb()
               End If
               'End If
               Incr Cntrtx
            Loop Until Txok = 1 Or Cntrtx = 2
            If Txok = 1 Then
               Txbuf(ptrtx) = 0
            End If
            Reset Inipoll
            Set Inicpoll
         End If

      End If

      If Inivariables = 1 Then
         Reset Inivariables
         Call Inivar()
      End If

      If Iniauto.1 = 1 Then
         Reset Iniauto.1
         Print #1 , "NTP"
        ' Call Getntp()
        'Call Gethoratb()
        Set Getfechatb

      End If

      If Iniauto.2 = 1 Then
         Print #1 , "AUT3"
         Reset Iniauto.2
         'Call Leertc()
      End If

      If Iniauto.3 = 1 Then
         Print #1 , "Get URL2IP de " ; Urlbase
         Reset Iniauto.3
         Ip = Url2ip(urlbase)
         Ipvaltmp = Ip2str(ip)
         Print #1 , "Ip=" ; Ip
         If Ipvaltmp <> "0.0.0.0" Then
            Ipvaltmp = Ip2str(ip)
            Print #1 , "IP=" ; Ipvaltmp
            Iptx = Ipvaltmp
            If Iptx <> Iptxant Then
               Iptxeep = Iptx
               Print #1 , "Guarda nuevo iptx"
               Autoval(4) = Autovaleep(4)                   'Se configura a valor por defecto
            End If
         Else
            Print #1 , "Error leyendo URL"
         End If
         'Call Getcmd()
         'Call Txtbdata()
      End If

   Loop Until Resets = 1
   Resets = 0
Loop