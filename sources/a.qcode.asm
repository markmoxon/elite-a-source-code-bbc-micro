 \ a.qcode - ELITE III second processor code

\OPT TABS=16
CPU 1
CODE% = &1000
ORG CODE%
LOAD% = &1000
\EXEC = boot_in

ptr = &07
cursor_x = &2C
cursor_y = &2D
vdu_stat = &72
dockedp = &A0
brk_line = &FD
brkv = &202
last_key = &300
ship_type = &311
cabin_t = &342
target = &344
view_dirn = &345
laser_t = &347
adval_x = &34C
adval_y = &34D
cmdr_mission = &358
cmdr_homex = &359
cmdr_homey = &35A
cmdr_gseed = &35B
cmdr_money = &361
cmdr_fuel = &365
cmdr_galxy = &367
cmdr_laser = &368
cmdr_ship = &36D
cmdr_hold = &36E
cmdr_cargo = &36F
cmdr_ecm = &380
cmdr_scoop = &381
cmdr_bomb = &382
cmdr_eunit = &383
cmdr_dock = &384
cmdr_ghype = &385
cmdr_escape = &386
cmdr_cour = &387
cmdr_courx = &389
cmdr_coury = &38A
cmdr_misl = &38B
cmdr_legal = &38C
cmdr_avail = &38D
cmdr_price = &39E
cmdr_kills = &39F
f_shield = &3A5
r_shield = &3A6
energy = &3A7
home_econ = &3AC
home_govmt = &3AE
home_tech = &3AF
data_econ = &3B8
data_govm = &3B9
data_tech = &3BA
data_popn = &3BB
data_gnp = &3BD
hype_dist = &3BF
data_homex = &3C1
data_homey = &3C2
s_flag = &3C6
cap_flag = &3C7
a_flag = &3C8
x_flag = &3C9
f_flag = &3CA
y_flag = &3CB
j_flag = &3CC
k_flag = &3CD
b_flag = &3CE
 \
save_lock = &233
new_file = &234
new_posn = &235
new_type = &36D
new_pulse = &3D0
new_beam = &3D1
new_military = &3D2
new_mining = &3D3
new_mounts = &3D4
new_missiles = &3D5
new_shields = &3D6
new_energy = &3D7
new_speed = &3D8
new_hold = &3D9
new_range = &3DA
new_costs = &3DB
new_max = &3DC
new_min = &3DD
new_space = &3DE
 \new_:	EQU &3DF
 \new_name:	EQU &74D

altitude = &FD1
osfile = &FFDD
oswrch = &FFEE
osword = &FFF1
osbyte = &FFF4
oscli = &FFF7

tube_r1s = &FEF8
tube_r1d = &FEF9
tube_r2s = &FEFA
tube_r2d = &FEFB
tube_r3s = &FEFC
tube_r3d = &FEFD
tube_r4s = &FEFE
tube_r4d = &FEFF



._117C

 EQUS ":0.E"

._1180

 EQUS "."

._1181

 EQUS "NEWCOME"

._1188

 EQUS &0D

.commander

 EQUB &00, &14, &AD, &4A, &5A, &48, &02, &53, &B7, &00, &00, &13
 EQUB &88, &3C, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &0F, &11, &00, &03, &1C, &0E
 EQUB &00, &00, &0A, &00, &11, &3A, &07, &09, &08, &00, &00, &00
 EQUB &00, &20, &F1, &58


.tube_write

 BIT tube_r1s
 NOP
 BVC tube_write
 STA tube_r1d
 RTS

.tube_read

 BIT tube_r2s
 NOP
 BPL tube_read
 LDA tube_r2d
 RTS

INCLUDE "sources/a.qcode_1.asm"

INCLUDE "sources/a.qcode_2.asm"

INCLUDE "sources/a.qcode_3.asm"

INCLUDE "sources/a.qcode_4.asm"

INCLUDE "sources/a.qcode_5.asm"

INCLUDE "sources/a.qcode_6.asm"

INCLUDE "sources/a.qship_1.asm"

INCLUDE "sources/a.qship_2.asm"

ship_total = 38


.ship_list

 EQUW	s_dodo,	s_coriolis,	s_escape,	s_alloys
 EQUW	s_barrel,	s_boulder,	s_asteroid,	s_minerals
 EQUW	s_shuttle1,	s_transporter,	s_cobra3,	s_python
 EQUW	s_boa,	s_anaconda,	s_worm,	s_missile
 EQUW	s_viper,	s_sidewinder,	s_mamba,	s_krait
 EQUW	s_adder,	s_gecko,	s_cobra1,	s_asp
 EQUW	s_ferdelance,	s_moray,	s_thargoid,	s_thargon
 EQUW	s_constrictor,	s_dragon,	s_monitor,	s_ophidian
 EQUW	s_ghavial,	s_bushmaster,	s_rattler,	s_iguana
 EQUW	s_shuttle2,	s_chameleon

 EQUW &0000


.ship_data

 EQUW	0,	s_missile,	0,	s_escape
 EQUW	s_alloys,	s_barrel,	s_boulder,	s_asteroid
 EQUW	s_minerals,	0,	s_transporter,	0
 EQUW	0,	0,	0,	0
 EQUW	s_viper,	0,	0,	0
 EQUW 0,	0,	0,	0
 EQUW	0,	0,	0,	0
 EQUW	0,	s_thargoid,	s_thargon,	s_constrictor
 	

.ship_flags

 EQUB	&00,	&00,	&40,	&41
 EQUB	&00,	&00,	&00,	&00
 EQUB	&00,	&21,	&61,	&20
 EQUB	&21,	&20,	&A1,	&0C
 EQUB	&C2,	&0C,	&0C,	&04
 EQUB	&0C,	&04,	&0C,	&04
 EQUB	&0C,	&02,	&22,	&02
 EQUB	&22,	&0C,	&04,	&8C


.ship_bits

	EQUD %00000000000000000000000000000100
	EQUD %00000000000000000000000000000100
	EQUD %00000000000000000000000000001000
	EQUD %00000000000000000000000000010000
	EQUD %00000000000000000000000000100000
	EQUD %00000000000000000000000001000000
	EQUD %00000000000000000000000010000000
	EQUD %00000000000000000000000100000000
	EQUD %00000000000000000000001000000000
	EQUD %00000000000000000000010000000000
	EQUD %00011111111000000011100000000000
	EQUD %00011001110000000011100000000000
	EQUD %00000000000000000011100000000000
	EQUD %00000000000000000100000000000000
	EQUD %00000001110000001000000000000000
	EQUD %00000000000000000000000000000010
	EQUD %00000000000000010000000000000000
	EQUD %00010001111111101000000000000000
	EQUD %00010001111111100000000000000000
	EQUD %00010001111111100000000000000000
	EQUD %00011001111110000011000000000000
	EQUD %00011001111111100000000000000000
	EQUD %00011001111111100010000000000000
	EQUD %00011001000000000000000000000000
	EQUD %00011111000000000010000000000000
	EQUD %00011001110000000011000000000000
	EQUD %00100000000000000000000000000000
	EQUD %01000000000000000000000000000000
	EQUD %10000000000000000000000000000000
	EQUD %00000000000000000100000000000000
	EQUD %00010001000000000011100000000000
	EQUD %00010001111000000011000000000000
	EQUD %00010000000000000011100000000000
	EQUD %00011101111100000000000000000000
	EQUD %00010001110000000011000000000000
	EQUD %00011101111100000010000000000000
	EQUD %00000000000000000000011000000000
	EQUD %00010001110000000011000000000000

	EQUD %00011111111111100111111000000000


.ship_bytes

 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 050, &00, 0, 0
 EQUB 050, &00, 0, 0
 EQUB 070, &80, 0, 2
 EQUB 065, &80, 0, 2
 EQUB 060, &80, 0, 2
 EQUB 010, &80, 0, 0
 EQUB 015, &00, 0, 0
 EQUB 000, &00, 0, 0
 EQUB 000, &80, 0, 2
 EQUB 090, &00, 0, 2
 EQUB 100, &80, 0, 2
 EQUB 100, &80, 0, 2
 EQUB 085, &80, 0, 2
 EQUB 080, &80, 0, 2
 EQUB 080, &80, 0, 2
 EQUB 010, &80, 0, 0
 EQUB 060, &80, 0, 1
 EQUB 060, &80, 0, 1
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 000, &00, 0, 2
 EQUB 003, &00, 0, 0
 EQUB 030, &80, 0, 0
 EQUB 075, &80, 0, 2
 EQUB 050, &80, 0, 1
 EQUB 075, &80, 0, 2
 EQUB 055, &80, 0, 1
 EQUB 060, &80, 0, 1
 EQUB 050, &00, 0, 0
 EQUB 045, &80, 0, 1

 EQUB 255, &00, 0, 0

SAVE "output/2.T.unpatched.bin", CODE%, P%, LOAD%