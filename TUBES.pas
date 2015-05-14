{
Filename    : manajemen.pas
Description : Program Manajemen Supermarket (Manajemen Gudang dan Kasir)
Date        : 3 Mei 2015
Author		: Group 09
}

program manajemen_supermarket;

uses crt, sysutils;

type
	tabel = record 		{ tabel all barang }
		no,kode_barang,stok,stok_min,harga,terjual,jmlpesan : longint;
		nama_barang : string[17];
		supplier : string[10];
		tanggal_input,tanggal_update : string;
	end;
	tabel2 = record 	{ tabel pengadaan barang }
		no,kode_barang,jumlah,stok_min,harga : longint;
		nama_barang : string[17];
		supplier : string[10];
		tanggal_update : string;
	end;
	tabel3 = record 	{ tabel penjualan }
		no,kode_barang,idpembeli,harga,qty,total : longint;
		tanggal : string;
		nama_barang : string[17];
	end;
	filetabel = file of tabel;

var
	listbarang : filetabel;
	pengadaan : file of tabel2;
	faktur : file of tabel3;

procedure writecenter(s : string);				// Procedure untuk menulis ditengah layar
begin
	gotoxy(41 - (length(s) div 2),wherey);
	writeln(s);
end;

procedure watermark;							// Procedure untuk menulis 'IF 38 08'
begin
	textcolor(3);
	gotoxy(1,2); writecenter(' _  ____    ___  ___   ___  ___ ');
	gotoxy(1,3); writecenter('| ||  __|  |__ || _ | | _ || _ |');
	gotoxy(1,4); writecenter('| ||  __|  |__ || _ | ||_||| _ |');
	gotoxy(1,5); writecenter('|_||_|     |___||___| |___||___|');
	gotoxy(1,7);
	textcolor(7);
end;
	
procedure gudang;
{ I.S. : sembarang
F.S. : menu gudang ditampilkan }
	forward;
	
procedure insert;
{ I.S. : file list_barang.mkt terdefinisi/terinisialisas
F.S. : file list_barang.mkt terinisialisasi }
	forward;

procedure tampilsort;
{ I.S. : sembarang
F.S. : menu tampil sorting ditampilkan }
	forward;
	
procedure sort(format : integer);
{ I.S. : file list_barang.mkt terinisialisasi 
F.S. : file list_barang.mkt ditampilkan terurut tergantung formatnya.
format = 1 --> list barang ditampilkan menaik berdasarkan kode barang
format = 2 --> list barang ditampilkan menurun berdasarkan qty terjual }
	forward;
	
procedure pengadaan_barang;
{ I.S. : sembarang, file pengadaan.mkt terinisialisasi
F.S. : list pengadaan barang ditampilkan }
	forward;
	
procedure preorder;
{ I.S. : sembarang
F.S. : barang yang harus dipesan ditampilkan }
	forward;
	
procedure editjmlpesanan;
{ I.S. : file list_barang.mkt terinisialisasi
F.S. : field jmlpesan pada file termodifikasi }
	forward;
	
procedure konfirmasi;
{ I.S. : file list_barang.mkt dan pengadaan.mkt terinisialisasi
F.S. : file pengadaan.mkt diupdate }
	forward;
	
procedure edit;
{ I.S. : sembarang, file list_barang.mkt terinisialisasi
F.S. : file list_barang.mkt termodifikasi }
	forward;
	
procedure update;
{ I.S. : file list_barang.mkt terinisialisasi
F.S. : jumlah stok pada file list_barang ditambah }
	forward;
	
procedure hapus;
{ I.S. : file list_barang.mkt terinisialisasi
F.S. : file list_barang termodifikasi }
	forward;

procedure kasir;
{I.S. : sembarang
F.S. : menu kasir ditampilkan }
	forward;
	
procedure transaksi;
{ I.S. : file list_barang.mkt terinisialisasi
F.S. file faktur.mkt diupdate }
	forward;
	
procedure rekapfaktur;
{ I.S. : file faktur.mkt terinisialisasi
F.S. : file faktur.mkt ditampilkan }
	forward;

procedure about;
{ I.S. : sembarang
F.S. : menu about ditampilkan }
	forward;
	
procedure checkdir;
{ I.S. : sembarang
F.S. : terdapat folder db, tmp, faktur, dan purchaseOrder }
begin													// Cek folder yng dibutuhkan program
	if not DirectoryExists('db') then					// folder db untuk lokasi database program
		CreateDir('db');
	if not DirectoryExists('tmp') then					// folder tmp untuk file temporary yang digunakan program
		CreateDir('tmp');
	if not DirectoryExists('faktur') then				// folder faktur untuk menyimpan transaksi yang diprint
		CreateDir('faktur');
	if not DirectoryExists('purchaseOrder') then		// folder purchaseOrder untuk menyimpan file purchase order yang akan diprint
		CreateDir('purchaseOrder');
end;

procedure clearviewer;									// procedure untuk clear sebagian layar, digunakan untuk fitur pindah page
{I.S. : sembarang
F.S. : menghapus layar pada koordinat tertentu }
var
	i : integer;

begin
	for i := 1 to 13 do begin
		gotoxy(1,i+5);
		write('                                                                             ')
	end;
end;

function file_listbarang_ada : boolean;
{ fungsi akan memberikan nilai true apabila file list_barang.mkt terinisialisasi }
begin
	{$i-}
	reset(listbarang);
	{$i+}
	if ioresult <> 0 then
		file_listbarang_ada := false
	else
		file_listbarang_ada := true;
end;

function file_pengadaan_ada : boolean;
{ fungsi akan memberikan nilai true apabila file pengadaan.mkt terinisialisasi }
begin
	{$i-}
	reset(pengadaan);
	{$i+}
	if ioresult <> 0 then
		file_pengadaan_ada := false
	else
		file_pengadaan_ada := true;
end;

function file_faktur_ada : boolean;
{ fungsi akan memberikan nilai true apabila file faktur.mkt terinisialisasi }
begin
	{$i-}
	reset(faktur);
	{$i+}
	if ioresult <> 0 then
		file_faktur_ada := false
	else
		file_faktur_ada := true;
end;

function barang_ada(kode_barang : longint; var penampung : filetabel) : boolean;
{ fungsi akan memberikan nilai true apabila kode barang yang dicari ada pada suatu tabel }
var
	found : boolean;
	barang : tabel;

begin
	found := false;										// Pencarian dengan boolean
	reset(penampung);
	while not(eof(penampung)) and not(found) do begin
		read(penampung,barang);
		if (kode_barang = barang.kode_barang) then
			found := true;
	end;
	barang_ada := found;
end;
//////////////////// UTAMA ////////////////////
procedure utama;
{ I.S. : sembarang
F.S. : menu utama ditampilkan '}
var
	ch : char;
	
begin
	checkdir;
	clrscr;
	cursoron;
	watermark;
	writecenter(' ================================ ');
	writecenter('|      Toserba DayKol Ceria      |');
	writecenter('|================================|');
	writecenter('| Jl.Telekomunikasi No.1 Bandung |');
	writecenter('|     No.Telp : (022)-428438     |');
	writecenter('|================================|');
	writecenter('|         SELAMAT DATANG         |');
	writecenter('|================================|');
	writecenter('| 1 | Gudang                     |');
	writecenter('| 2 | Kasir                      |');
	writecenter('| 3 | About                      |');
	writecenter('|   |                            |');
	writecenter('| 0 | Exit                       |');
	writecenter(' ================================ ');
	writecenter(' Pilih menu :                     ');
	gotoxy(38,wherey - 1);
	repeat
		ch := readkey;
	until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3');
	write(ch);
	case ch of
		'1' : gudang;
		'2' : kasir;
		'3' : about;
		'0' : 	begin
					gotoxy(1,25);
					halt(1);
				end;
	end;
end;
//////////////////// GUDANG ////////////////////
procedure gudang;
var
	ch : char;

begin
	clrscr;
	cursoron;
	watermark;
	writecenter(' ================================ ');
	writecenter('|      Toserba DayKol Ceria      |');
	writecenter('|================================|');
	writecenter('| Jl.Telekomunikasi No.1 Bandung |');
	writecenter('|     No.Telp : (022)-428438     |');
	writecenter('|================================|');
	writecenter('|             GUDANG             |');
	writecenter('|================================|');
	writecenter('| 1 | Insert Barang              |');
	writecenter('| 2 | Tampil List Barang         |');
	writecenter('| 3 | Tampil Pengadaan Barang    |');
	writecenter('| 4 | Barang yg Harus Direstock  |');
	writecenter('| 0 | Menu Utama                 |');
	writecenter(' ================================ ');
	writecenter(' Pilih menu :                     ');
	gotoxy(38, wherey - 1);
	repeat
		ch := readkey;
	until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = '4');
	write(ch);
	case ch of
		'1' : insert;
		'2' : tampilsort;
		'3' : pengadaan_barang;
		'4' : preorder;
		'0' : utama;
	end;
end;
//////////////////// INSERT ////////////////////
procedure insert;
var
	ch : char;
	barang : tabel;
	br_ada : tabel2;
	x,y : longint;

begin
	cursoron;
	assign(listbarang,'db\list_barang.mkt');
	assign(pengadaan,'db\pengadaan.mkt');
	if file_listbarang_ada then
		seek(listbarang,filesize(listbarang))
	else
		rewrite(listbarang);
	if file_pengadaan_ada then
		seek(pengadaan,filesize(pengadaan))
	else
		rewrite(pengadaan);
	x := filesize(listbarang);
	y := filesize(pengadaan);
	repeat
		inc(x);
		inc(y);
		barang.no := x;
		br_ada.no := y;
		barang.tanggal_input := FormatDateTime('DD-MMM-YY',now);
		barang.tanggal_update := FormatDateTime('DD-MMM-YY',now);
		br_ada.tanggal_update := FormatDateTime('DD-MMM-YY',now);
		barang.terjual := 0;
		clrscr;
		writeln('=========================');
		writeln('      INSERT BARANG      ');
		writeln('=========================');
		writeln('Input 00 untuk batal');
		writeln('=========================');
		writeln('Barang nomor ',barang.no);
		write('Kode Barang   [4] : '); readln(barang.kode_barang);
		if ((barang.kode_barang < 1000) or (barang.kode_barang > 9999)) and (barang.kode_barang <> 0) then begin
			writeln;
			writeln('Kode barang harus 4 digit!');
			writeln;
			cursoroff;
			writeln('Tekan tombol apa saja untuk melanjutkan...');
			close(listbarang);
			close(pengadaan);
			ch := readkey;
			insert;
		end;
		br_ada.kode_barang := barang.kode_barang;
		if (barang.kode_barang = 0) then begin
			dec(x);
			dec(y);
			close(listbarang);
			close(pengadaan);
			gudang;
		end
		else if barang_ada(barang.kode_barang,listbarang) then begin
			writeln;
			writeln('Barang sudah ada!');
			writeln;
			cursoroff;
			writeln('Tekan tombol apa saja untuk melanjutkan...');
			close(listbarang);
			close(pengadaan);
			ch := readkey;
			insert;
		end;
		write('Nama Barang  [17] : '); readln(barang.nama_barang);
		br_ada.nama_barang := barang.nama_barang;
		if (barang.nama_barang = '00') then begin
			dec(x);
			dec(y);
			close(listbarang);
			close(pengadaan);
			gudang;
		end;
		write('Supplier     [10] : '); readln(barang.supplier);
		br_ada.supplier := barang.supplier;
		if (barang.supplier = '00') then begin
			dec(x);
			close(listbarang);
			close(pengadaan);
			gudang;
		end;
		write('Banyaknya         : '); readln(barang.stok);
		br_ada.jumlah := barang.stok;
		if (barang.stok = 0) then begin
			dec(x);
			dec(y);
			close(listbarang);
			close(pengadaan);
			gudang;
		end;
		write('Stok Minimal      : '); readln(barang.stok_min);
		br_ada.stok_min := barang.stok_min;
		if (barang.stok_min = 0) then begin
			dec(x);
			dec(y);
			close(listbarang);
			close(pengadaan);
			gudang;
		end;
		write('Harga Satuan (RP) : '); readln(barang.harga);
		br_ada.harga := barang.harga;
		if (barang.harga = 0) then begin
			dec(x);
			dec(y);
			close(listbarang);
			close(pengadaan);
			gudang;
		end;
		writeln('=========================');
		write(listbarang,barang);
		write(pengadaan,br_ada);
		write('Input lagi? (Y/N) : ');
		repeat
			ch := readkey;
		until (ch = 'n') or (ch = 'N') or (ch = 'y') or (ch = 'Y');
	until (ch = 'n') or (ch = 'N');
	close(listbarang);
	close(pengadaan);
	gudang;
end;
//////////////////// PENGADAAN ////////////////////
procedure pengadaan_barang;
var
	br_ada : array of tabel2;
	idx,page,currpage,i : longint;
	ch : char;

begin
	clrscr;
	cursoroff;
	writeln(' ======================================================================== ');
	writeln('|                            PENGADAAN BARANG                            |');
	gotoxy(1,19);
	writeln('  0 | Kembali ke menu gudang');
	gotoxy(1,3);
	assign(pengadaan,'db\pengadaan.mkt');
	{$i-}
	reset(pengadaan);
	{$i+}
	if (ioresult <> 0) then begin
		writeln('|========================================================================|');
		writeln('|                              DATA  KOSONG                              |');
		writeln(' ------------------------------------------------------------------------ ');
		repeat
			ch := readkey;
		until (ch = '0');
		gudang;
	end
	else if (filesize(pengadaan) = 0) then begin
		close(pengadaan);
		writeln('|========================================================================|');
		writeln('|                              DATA  KOSONG                              |');
		writeln(' ------------------------------------------------------------------------ ');
		repeat
			ch := readkey;
		until (ch = '0');
		gudang;
	end
	else begin
		reset(pengadaan);
		writeln(' ------------------------------------------------------------------------ ');
		writeln('|  NO  | KODE |    NAMA BARANG    |  SUPPLIER  |   JUMLAH   | TGL UPDATE |');
		writeln('|========================================================================|');
		setlength(br_ada,filesize(pengadaan));
		idx := 0;
		while not eof(pengadaan) do begin
			read(pengadaan,br_ada[idx]);
			idx := idx + 1;
		end;
		idx := filesize(pengadaan) - 1;
		if ((idx + 1) mod 10 = 0) then
			page := (idx + 1) div 10
		else
			page := ((idx + 1) div 10) + 1;
		currpage := 1;
		ch := #75;
		repeat
			clearviewer;
			// TULIS
			gotoxy(1,6);
			for i := (currpage - 1) * 10 to (currpage * 10) - 1{idx} do begin
				if i > idx then break;
				writeln('| ',br_ada[i].no:4,' | ',br_ada[i].kode_barang:4,' | ',br_ada[i].nama_barang:17,' | ',br_ada[i].supplier:10,' | ',br_ada[i].jumlah:10,' | ',br_ada[i].tanggal_update:10,' |');
			end;
			writeln(' ------------------------------------------------------------------------ ');
			gotoxy(1,17);
			if page = 1 then
				writeln('                                                                          ')
			else if currpage = 1 then
				writeln('                                                               Next Item >')
			else if currpage = page then
				writeln('< Previous Item')
			else
				writeln('< Previous Item                                                Next Item >');
			repeat
				ch := readkey;
				if (ch = #75) and (currpage > 1) then
					currpage := currpage - 1
				else if (ch = #77) and (currpage < page) then
					currpage := currpage + 1;
			until (ch = '0') or (ch = #75) or (ch = #77);
		until (ch = '0');
	end;
	close(pengadaan);
	gudang;
end;
//////////////////// PRE ORDER ////////////////////
procedure preorder;
var
	barang : tabel;
	po : array of tabel;
	nomor,idx,page,currpage,i : longint;
	ch : char;
	printpo : textfile;

begin
	clrscr;
	cursoron;
	writeln(' ========================================================================== ');
	writeln('|             Toserba DayKol Ceria - Purchase Order  ',FormatDateTime('DD-MMM-YY',now):9,'             |');
	writeln('|--------------------------------------------------------------------------|');
	writeln('|  No  | KODE |    NAMA BARANG    |  STOK  | STOK MIN |  PESAN KE  |  QTY  |');
	writeln(' -------------------------------------------------------------------------- ');
	gotoxy(1,20);
	writeln('  1 | Edit Jumlah Pesanan');
	writeln('  2 | Print Purchase Order');
	writeln('  3 | Konfirmasi Terima Barang');
	writeln('  0 | Kembali');
	writeln('=========================');
	write('Pilih menu : ');
	gotoxy(1,6);
	nomor := 0;
	assign(listbarang,'db\list_barang.mkt');
	if file_listbarang_ada then begin
		if (filesize(listbarang)) <> 0 then begin
			while not(eof(listbarang)) do begin
				read(listbarang,barang);
				if (barang.stok < barang.stok_min) then begin
					nomor := nomor + 1;
				end;
			end;
			writeln(' -------------------------------------------------------------------------- ');
			if nomor = 0 then begin
				writeln('|                               DATA  KOSONG                               |');
				writeln(' -------------------------------------------------------------------------- ');
				gotoxy(14,25);
				repeat
					ch := readkey;
				until (ch = '0') or (ch = '1') or (ch = '2');
			end else begin
				setlength(po,nomor);
				reset(listbarang);
				idx := 0;
				while not eof(listbarang) do begin
					read(listbarang,barang);
					if (barang.stok < barang.stok_min) then begin
						po[idx] := barang;
						inc(idx);
					end;
				end;
				if (nomor mod 10 = 0) then
					page := nomor div 10
				else
					page := (nomor div 10) + 1;
				currpage := 1;
				ch := #75;
				repeat
					clearviewer;
					gotoxy(1,6);
					for i := (currpage - 1) * 10 to (currpage * 10) - 1 do begin
						if i > (nomor - 1) then break;
						writeln('| ',i + 1:4,' | ',po[i].kode_barang:4,' | ',po[i].nama_barang:17,' | ',po[i].stok:6,' | ',po[i].stok_min:8,' | ',po[i].supplier:10,' | ',po[i].jmlpesan:5,' |');
					end;
					writeln(' -------------------------------------------------------------------------- ');
					gotoxy(1,17);
					if page = 1 then
						writeln('':80)
					else if currpage = 1 then
						writeln('                                                                 Next Item >')
					else if currpage = page then
						writeln('< Previous Item')
					else
						writeln('< Previous Item                                                  Next Item >');
					gotoxy(14,25);
					repeat
						ch := readkey;
						if (ch = #75) and (currpage > 1) then
							currpage := currpage - 1
						else if (ch = #77) and (currpage < page) then
							currpage := currpage + 1;
					until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = #75) or (ch = #77);
				until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3');
			end;
		end
		else begin
			writeln('|                               DATA  KOSONG                               |');
			writeln(' -------------------------------------------------------------------------- ');
			gotoxy(14,25);
			repeat
				ch := readkey;
			until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3');
		end;
	end
	else begin
		writeln('|                               DATA  KOSONG                               |');
		writeln(' -------------------------------------------------------------------------- ');
		gotoxy(14,25);
		repeat
			ch := readkey;
		until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3');
	end;
	close(listbarang);
	write(ch);
	case ch of
		'0' : gudang;
		'1' : editjmlpesanan;
		'2' :	begin
					assign(printpo,'purchaseOrder\purchaseOrder.txt');
					rewrite(printpo);
					writeln(printpo,' ====================================================== ');
					writeln(printpo,'|   Toserba DayKol Ceria - Purchase Order  ',FormatDateTime('DD-MMM-YY',now):9,'   |');
					writeln(printpo,'|------------------------------------------------------|');
					writeln(printpo,'|  No  | KODE |    NAMA BARANG    |  QTY  |  PESAN KE  |');
					writeln(printpo,'|------------------------------------------------------|');
					for i := 0 to (nomor - 1) do
						writeln(printpo,'| ',i + 1:4,' | ',po[i].kode_barang:4,' | ',po[i].nama_barang:17,' | ',po[i].jmlpesan:5,' | ',po[i].supplier:10,' |');
					writeln(printpo,' ------------------------------------------------------ ');
					close(printpo);
					gotoxy(14,25);
					write(' ');
					gotoxy(40,23);
					write('Print Purchase Order Sukses!');
					cursoroff;
					readln;
					gotoxy(40,23); write('                              ');
					gotoxy(14,25);
					cursoron;
					repeat
						ch := readkey;
					until (ch = '0') or (ch = '1') or (ch = '3');
					case ch of
						'0' : gudang;
						'1' : editjmlpesanan;
						'3' : konfirmasi;
					end;
				end;
		'3' : konfirmasi;
	end;
	gudang;
end;
//////////////////// EDIT JML PESANAN ////////////////////
procedure editjmlpesanan;
var
	barang : tabel;
	kode_barang,qty : longint;
	found : boolean;

begin
	assign(listbarang,'db\list_barang.mkt');
	{$i-}
	reset(listbarang);
	{$i+}
	if (ioresult <> 0) then begin
		cursoroff;
		gotoxy(40,20);
		write('Barang Kosong!');
		readln;
		gotoxy(40,20);
		write('              ');
		preorder;
	end
	else if (filesize(listbarang) = 0) then begin
		close(listbarang);
		cursoroff;
		gotoxy(40,20);
		write('Barang Kosong!');
		readln;
		gotoxy(40,20);
		write('              ');
		preorder;
	end
	else begin
		gotoxy(40,20); write('Input 00 untuk Batal');
		gotoxy(40,21); write('Kode Barang : ');
		gotoxy(40,22); write('Qty         : ');
		gotoxy(40,23); write('                            ');
		repeat
			cursoron;
			reset(listbarang);
			found := false;
			gotoxy(54,21); readln(kode_barang);
			while not(eof(listbarang)) and not(found) do begin
				read(listbarang,barang);
				if (kode_barang = barang.kode_barang) then
					if (barang.stok < barang.stok_min) then begin
						found := true;
					end;
			end;
			if not(found) and (kode_barang <> 0) then begin
				cursoroff;
				gotoxy(54,21); write('Barang tidak ditemukan!');
				readln;
				gotoxy(54,21); write('                       ');
			end;
		until (kode_barang = 0) or found;
		if (kode_barang = 0) then begin
			close(listbarang);
			gotoxy(40,20); write('                    ');
			gotoxy(40,21); write('                    ');
			gotoxy(40,22); write('                    ');
			preorder;
		end;
		gotoxy(54,22); readln(qty);
		if (qty = 0) then begin
			close(listbarang);
			gotoxy(40,20); write('                    ');
			gotoxy(40,21); write('                    ');
			gotoxy(40,22); write('                    ');
			preorder;
		end
		else begin
			barang.jmlpesan := qty;
			seek(listbarang,filepos(listbarang) - 1);
			write(listbarang,barang);
			close(listbarang);
			gotoxy(40,23); write('Sukses Edit Jumlah Pesanan!');
			cursoroff;
			readln;
			gotoxy(40,20); write('                    ');
			gotoxy(40,21); write('                    ');
			gotoxy(40,22); write('                    ');
			gotoxy(40,23); write('                           ');
			preorder;
		end;
	end;
end;
//////////////////// KONFIRMASI TERIMA BARANG ////////////////////
procedure konfirmasi;
var
	barang : tabel;
	br_ada : tabel2;

begin
	cursoron;
	gotoxy(40,23); write('                              ');
	assign(listbarang,'db\list_barang.mkt');
	{$i-}
	reset(listbarang);
	{$i+}
	if (ioresult <> 0) then begin
		cursoroff;
		gotoxy(40,23);
		write('Barang Kosong!');
		readln;
		gotoxy(40,23);
		preorder;
	end
	else if (filesize(listbarang) = 0) then begin
		close(listbarang);
		cursoroff;
		gotoxy(40,23);
		write('Barang Kosong!');
		readln;
		gotoxy(40,23);
		preorder;
	end
	else begin
		assign(pengadaan,'db\pengadaan.mkt');
		reset(pengadaan);
		seek(pengadaan,filesize(pengadaan));
		while not(eof(listbarang)) do begin
			read(listbarang,barang);
			if (barang.stok < barang.stok_min) then begin
				barang.stok := barang.stok + barang.jmlpesan;
				seek(listbarang,filepos(listbarang) - 1);
				br_ada.no := filepos(pengadaan) + 1;
				br_ada.kode_barang := barang.kode_barang;
				br_ada.jumlah := barang.jmlpesan;
				barang.jmlpesan := 0;
				br_ada.stok_min := barang.stok_min;
				br_ada.harga := barang.harga;
				br_ada.nama_barang := barang.nama_barang;
				br_ada.supplier := barang.supplier;
				br_ada.tanggal_update := FormatDateTime('DD-MMM-YY',now);
				write(listbarang,barang);
				write(pengadaan,br_ada);
			end;
		end;
		close(pengadaan);
		close(listbarang);
		gotoxy(40,23); write('Sukses Terima Barang!');
		cursoroff;
		readln;
		gotoxy(40,23); write('                              ');
		preorder;
	end;
end;
//////////////////// MENU SORT ////////////////////
procedure tampilsort;
var
	ch : char;

begin
	clrscr;
	watermark;
	writecenter(' ================================ ');
	writecenter('|      Toserba DayKol Ceria      |');
	writecenter('|================================|');
	writecenter('| Jl.Telekomunikasi No.1 Bandung |');
	writecenter('|     No.Telp : (022)-428438     |');
	writecenter('|================================|');
	writecenter('|         TAMPIL  BARANG         |');
	writecenter('|================================|');
	writecenter('| 1 | Berdasarkan Kode           |');
	writecenter('| 2 | Berdasarkan Jumlah Terjual |');
	writecenter('|   |                            |');
	writecenter('|   |                            |');
	writecenter('| 0 | Kembali                    |');
	writecenter(' ================================ ');
	writecenter(' Pilih menu :                     ');
	gotoxy(38,wherey - 1);
	repeat
		ch := readkey;
	until (ch = '0') or (ch = '1') or (ch = '2');
	write(ch);
	case ch of
		'1' : sort(1);
		'2' : sort(2);
		'0' : gudang;
	end;
end;
//////////////////// TAMPIL SORT ////////////////////
procedure sort(format : integer);
var
	barang : array of tabel;
	temp : tabel;
	ch : char;
	idx,i,j,page,currpage : longint;

begin	
	clrscr;
	cursoron;
	writeln(' =========================================================================== ');
	writeln('|                               TAMPIL BARANG                               |');
	gotoxy(1,19);
	writeln('  1 | Insert Barang');
	writeln('  2 | Edit Barang (Nama, Stok Minimal, dan Harga)');
	writeln('  3 | Update Stok Barang');
	writeln('  4 | Hapus Barang');
	writeln('  0 | Kembali');
	writeln('=========================');
	write('Pilih menu : ');
	assign(listbarang,'db\list_barang.mkt');
	{$i-}
	reset(listbarang);
	{$i+}
	if (ioresult <> 0) then begin
		gotoxy(1,3);
		writeln('|===========================================================================|');
		writeln('|                               BARANG KOSONG                               |');
		writeln(' --------------------------------------------------------------------------- ');
		gotoxy(14,25);
		repeat
			ch := readkey;
		until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = '4');
		write(ch);
		case ch of
			'0' : tampilsort;
			'1' : insert;
			'2' : edit;
			'3' : update;
			'4' : hapus;
		end;
	end
	else if (filesize(listbarang) = 0) then begin
		close(listbarang);
		gotoxy(1,3);
		writeln('|===========================================================================|');
		writeln('|                               BARANG KOSONG                               |');
		writeln(' --------------------------------------------------------------------------- ');
		gotoxy(14,25);
		repeat
			ch := readkey;
		until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = '4');
		write(ch);
		case ch of
			'0' : tampilsort;
			'1' : insert;
			'2' : edit;
			'3' : update;
			'4' : hapus;
		end;
	end
	else begin
		gotoxy(1,3);
		writeln('|---------------------------------------------------------------------------|');
		writeln('|  NO  | KODE |    NAMA BARANG    |  STOK  | STOK MIN |   HARGA   | TERJUAL |');
		writeln('|===========================================================================|');
		setlength(barang,filesize(listbarang));
		idx := 0;
		while not(eof(listbarang)) do begin
			read(listbarang,barang[idx]);
			idx := idx + 1;
		end;
		idx := filesize(listbarang) - 1;
		// PROSES SORT
		case format of
			1 : for i := 0 to (idx) do
					for j := 0 to (idx - 1) do
						if barang[j].kode_barang > barang[j + 1].kode_barang then begin
							temp := barang[j];
							barang[j] := barang[j + 1];
							barang[j + 1] := temp;
						end;
			2 : for i := 0 to (idx) do
					for j := 0 to (idx - 1) do
						if barang[j].terjual < barang[j + 1].terjual then begin
							temp := barang[j];
							barang[j] := barang[j + 1];
							barang[j + 1] := temp;
						end;
		end;
	end;
	if ((idx + 1) mod 10 = 0) then
			page := (idx + 1) div 10
		else
			page := ((idx + 1) div 10) + 1;
	currpage := 1;
	ch := #75;
	// ROLL PAGE
	repeat
		clearviewer;
		// TULIS SORTED
		gotoxy(1,6);
		for i := (currpage - 1) * 10 to (currpage * 10) - 1{idx} do begin
			if i > idx then break;
			writeln('| ',i+1:4,' | ',barang[i].kode_barang:4,' | ',barang[i].nama_barang:17,' | ',barang[i].stok:6,' | ',barang[i].stok_min:8,' | ',barang[i].harga:9,' | ',barang[i].terjual:7,' |');
		end;
		writeln(' --------------------------------------------------------------------------- ');
		gotoxy(1,17);
		if page = 1 then
			writeln('                                                                             ')
		else if currpage = 1 then
			writeln('                                                                  Next Item >')
		else if currpage = page then
			writeln('< Previous Item')
		else
			writeln('< Previous Item                                                   Next Item >');
		gotoxy(14,25);
		repeat
			ch := readkey;
			if (ch = #75) and (currpage > 1) then
					currpage := currpage - 1
				else if (ch = #77) and (currpage < page) then
					currpage := currpage + 1;
		until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = '4') or (ch = #75) or (ch = #77);
	until (ch = '0') or (ch = '1') or (ch = '2') or (ch = '3') or (ch = '4');
	close(listbarang);
	write(ch);
	case ch of
		'0' : tampilsort;
		'1' : insert;
		'2' : edit;
		'3' : update;
		'4' : hapus;
	end;
end;
//////////////////// EDIT ////////////////////
procedure edit;
var
	barang : tabel;
	kode_barang : longint;

begin
	clrscr;
	writeln;
	writeln('=========================');
	writeln('       EDIT BARANG       ');
	writeln('=========================');
	assign(listbarang,'db\list_barang.mkt');
	if not(file_listbarang_ada) or (filesize(listbarang) = 0) then begin
		close(listbarang);
		writeln('Barang Kosong!');
		writeln('=========================');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		readkey;
		sort(1);
	end;
	writeln('Input 00 untuk batal');
	writeln('=========================');
	write('Masukkan kode barang yang akan diedit : '); readln(kode_barang);
	if (kode_barang = 0) then begin
		close(listbarang);
		sort(1);
	end;
	if barang_ada(kode_barang,listbarang) then begin
		seek(listbarang,filepos(listbarang) - 1);
		read(listbarang,barang);
		writeln('Barang nomor ',barang.no);
		writeln('Kode Barang  : ',barang.kode_barang);
		write('Nama Barang  : '); readln(barang.nama_barang);
		if (barang.nama_barang = '00') then begin
			close(listbarang);
			sort(1);
		end;
		write('Stok Minimal : '); readln(barang.stok_min);
		if (barang.stok_min = 0) then begin
			close(listbarang);
			sort(1);
		end;
		write('Harga Satuan : '); readln(barang.harga);
		if (barang.harga = 0) then begin
			close(listbarang);
			sort(1);
		end;
		writeln('=========================');
		seek(listbarang,filepos(listbarang) - 1);
		barang.tanggal_update := FormatDateTime('DD-MMM-YY',now);
		write(listbarang,barang);
		close(listbarang);
		writeln('Barang sukses diedit!');
		writeln('=========================');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		readkey;
		sort(1);
	end
	else begin
		writeln;
		writeln('Barang tidak ditemukan!');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		close(listbarang);
		readkey;
		sort(1);
	end;
end;
//////////////////// UPDATE ////////////////////
procedure update;
var
	barang : tabel;
	br_ada : tabel2;
	kode_barang,baru : longint;

begin
	clrscr;
	writeln;
	writeln('=========================');
	writeln('  UPDATE  STOK  BARANG   ');
	writeln('=========================');
	assign(listbarang,'db\list_barang.mkt');
	assign(pengadaan,'db\pengadaan.mkt');
	if file_pengadaan_ada then
		seek(pengadaan,filesize(pengadaan))
	else
		rewrite(pengadaan);
	if not(file_listbarang_ada) or (filesize(listbarang) = 0) then begin
		close(listbarang);
		close(pengadaan);
		writeln('Barang Kosong!');
		writeln('=========================');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		readkey;
		sort(1);
	end;
	writeln('Input 00 untuk batal');
	writeln('=========================');
	write('Masukkan kode barang yang akan diupdate : '); readln(kode_barang);
	br_ada.kode_barang := kode_barang;
	if (kode_barang = 0) then begin
		close(listbarang);
		close(pengadaan);
		sort(1);
	end;
	if barang_ada(kode_barang,listbarang) then begin
		seek(listbarang,filepos(listbarang) - 1);
		read(listbarang,barang);
		seek(listbarang,filepos(listbarang) - 1);
		write('Jumlah yang akan ditambahkan pada stok  : '); readln(baru);
		barang.stok := barang.stok + baru;
		br_ada.jumlah := baru;
		write('Supplier                                : '); readln(br_ada.supplier);
		barang.tanggal_update := FormatDateTime('DD-MMM-YY',now);
		br_ada.no := filesize(pengadaan) + 1;
		br_ada.nama_barang := barang.nama_barang;
		br_ada.stok_min := barang.stok_min;
		br_ada.harga := barang.harga;
		br_ada.tanggal_update := FormatDateTime('DD-MMM-YY',now);
		write(listbarang,barang);
		write(pengadaan,br_ada);
		close(listbarang);
		close(pengadaan);
		writeln('=========================');
		writeln('Stok barang sukses ditambah!');
		writeln('=========================');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		readkey;
		sort(1);
	end
	else begin
		writeln;
		writeln('Barang tidak ditemukan!');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		close(listbarang);
		close(pengadaan);
		readkey;
		sort(1);
	end;
end;
//////////////////// HAPUS ////////////////////
procedure hapus;
var
	ch : char;
	barang : tabel;
	kode_barang : longint;
	listbarangtemp : file of tabel;
	
begin
	clrscr;
	writeln;
	writeln('=========================');
	writeln('      HAPUS  BARANG      ');
	writeln('=========================');
	assign(listbarang,'db\list_barang.mkt');
	if not(file_listbarang_ada) or (filesize(listbarang) = 0) then begin
		close(listbarang);
		writeln('Barang Kosong!');
		writeln('=========================');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		ch := readkey;
		sort(1);
	end;
	writeln('Input 00 untuk batal');
	writeln('=========================');
	write('Masukkan kode barang yang akan dihapus : '); readln(kode_barang);
	if (kode_barang = 0) then begin
		close(listbarang);
		sort(1);
	end;
	if barang_ada(kode_barang,listbarang) then begin
		writeln;
		writeln('Barang dengan kode ',kode_barang,' akan dihapus.');
		write('Lanjutkan? (Y/N) : '); 
		repeat
			ch := readkey;
		until (ch = 'n') or (ch = 'N') or (ch = 'y') or (ch = 'Y');
		if (ch = 'n') or (ch = 'N') then begin
			close(listbarang);
			sort(1);
		end
		else begin
			reset(listbarang);
			assign(listbarangtemp,'tmp\list_barang.tmp');
			rewrite(listbarangtemp);
			while not(eof(listbarang)) do begin
				read(listbarang,barang);
				if (barang.kode_barang <> kode_barang) then begin
					barang.no := filepos(listbarangtemp) + 1;
					write(listbarangtemp,barang);
				end;
			end;
			rewrite(listbarang);
			reset(listbarangtemp);
			while not(eof(listbarangtemp)) do begin
				read(listbarangtemp,barang);
				write(listbarang,barang);
			end;
			erase(listbarangtemp);
			close(listbarangtemp);
			close(listbarang);
			writeln;
			writeln('=========================');
			writeln('Barang sukses dihapus!');
			writeln('=========================');
			cursoroff;
			writeln('Tekan tombol apa saja untuk melanjutkan...');
			ch := readkey;
			sort(1);
		end;
	end
	else begin
		writeln;
		writeln('Barang tidak ditemukan!');
		cursoroff;
		writeln('Tekan tombol apa saja untuk melanjutkan...');
		close(listbarang);
		readln;
		sort(1);
	end;
end;
//////////////////// KASIR ////////////////////
procedure kasir;
var
	ch : char;

begin
	clrscr;
	cursoron;
	watermark;
	writecenter(' ================================ ');
	writecenter('|      Toserba DayKol Ceria      |');
	writecenter('|================================|');
	writecenter('| Jl.Telekomunikasi No.1 Bandung |');
	writecenter('|     No.Telp : (022)-428438     |');
	writecenter('|================================|');
	writecenter('|           MENU KASIR           |');
	writecenter('|================================|');
	writecenter('| 1 | Transaksi                  |');
	writecenter('| 2 | Rekap Transaksi            |');
	writecenter('|   |                            |');
	writecenter('|   |                            |');
	writecenter('| 0 | Menu Utama                 |');
	writecenter(' ================================ ');
	writecenter(' Pilih menu :                     ');
	gotoxy(38,wherey - 1);
	repeat
		ch := readkey;
	until (ch = '0') or (ch = '1') or (ch = '2');
	write(ch);
	case ch of
		'1' : transaksi;
		'2' : rekapfaktur;
		'0' : utama;
	end;
end;
//////////////////// TRANSAKSI ////////////////////
procedure transaksi;
var
	barang : tabel;
	listbarangtemp : file of tabel;
	fakturtemp : file of tabel3;
	catat : tabel3;
	nomor,jumlah,qty,baris,bayar : longint;
	ch : char;
	kode_barang : longint;
	temp : string;
	printfaktur : textfile;
	terinput : boolean;

begin
	clrscr;
	writeln(' ============================================================================= ');
	writeln('|             Toserba DayKol Ceria - Transaksi Barang - ',FormatDateTime('DD-MMM-YY',now):9,'             |');
	writeln('|=============================================================================|');
	assign(listbarang,'db\list_barang.mkt');
	if file_listbarang_ada then
		reset(listbarang)
	else begin
		cursoroff;
		writeln('|                                GUDANG KOSONG                                |');
		writeln(' ----------------------------------------------------------------------------- ');
		repeat
			ch := readkey;
		until (ch = '0');
		kasir;
	end;
	if filesize(listbarang) = 0 then begin
		cursoroff;
		writeln('|                                GUDANG KOSONG                                |');
		writeln(' ----------------------------------------------------------------------------- ');
		repeat
			ch := readkey;
		until (ch = '0');
		kasir;
	end;
	assign(listbarangtemp,'tmp\list_barang.tmp');
	rewrite(listbarangtemp);
	while not(eof(listbarang)) do begin
		read(listbarang,barang);
		write(listbarangtemp,barang);
	end;
	close(listbarang);
	assign(faktur,'db\faktur.mkt');
	if file_faktur_ada then begin
		if (filesize(faktur)) = 0 then begin
			rewrite(faktur);
			catat.idpembeli := 1;
		end	
		else begin
			seek(faktur,filesize(faktur) - 1);
			read(faktur,catat);
			catat.idpembeli := catat.idpembeli + 1;
		end;
	end
	else begin
		rewrite(faktur);
		catat.idpembeli := 1;
	end;
	catat.tanggal := FormatDateTime('DD-MMM-YY',now);
	close(faktur);
	assign(fakturtemp,'tmp\faktur.tmp');
	rewrite(fakturtemp);
	nomor := 0;
	jumlah := 0;
	writeln('| Kode : ','Input 00 untuk batal |':70);
	writeln('| Qty  : ','|':70);
	writeln('|=============================================================================|');
	writeln('|  NO  | KODE |            NAMA BARANG            |  HARGA  | QTY |   TOTAL   |');
	writeln('|-----------------------------------------------------------------------------|');
	baris := 8;
	repeat
		terinput := false;
		cursoron;
		baris := baris + 1;
		nomor := nomor + 1;
		catat.no := nomor;
		gotoxy(10,4); write('':48);
		gotoxy(10,5); write('':69);
		gotoxy(10,4); readln(kode_barang);
		if (kode_barang = 0) then begin
			close(fakturtemp);
			close(listbarangtemp);
			kasir;
		end
		else if barang_ada(kode_barang,listbarangtemp) then begin
			seek(listbarangtemp,filepos(listbarangtemp) - 1);
			read(listbarangtemp,barang);
			catat.kode_barang := barang.kode_barang;
			catat.nama_barang := barang.nama_barang;
			catat.harga := barang.harga;
			seek(listbarangtemp,filepos(listbarangtemp) - 1);
			gotoxy(1,baris);
			writeln('| ','':4,' | ','':4,' | ','':33,' | ','':7,' | ','':3,' | ','':9,' |');
			writeln(' ----------------------------------------------------------------------------- ');
			gotoxy(3,baris); write(nomor);
			gotoxy(10,baris); write(kode_barang);
			gotoxy(17,baris); write(barang.nama_barang);
			gotoxy(53,baris); write(barang.harga);
			repeat
				cursoron;
				gotoxy(10,5); write('':69);
				gotoxy(10,5); readln(qty);
				if (qty = 0) then begin
					close(fakturtemp);
					close(listbarangtemp);
					kasir;
				end
				else if (qty <= barang.stok) then begin
					barang.stok := barang.stok - qty;
					catat.qty := qty;
					catat.total := barang.harga * qty;
					jumlah := jumlah + catat.total;
					barang.terjual := barang.terjual + qty;
					write(fakturtemp,catat);
					write(listbarangtemp,barang);
					terinput := true;
					gotoxy(63,baris); write(qty);
					gotoxy(69,baris); write(catat.total);
					gotoxy(23,4); write('Input lagi? (Y/N) : ');
					repeat
						ch := upcase(readkey);
					until (ch = 'Y') or (ch = 'N');
					gotoxy(23,4); write('':19);
				end
				else begin
					cursoroff;
					gotoxy(23,5); write('Stok barang tidak mencukupi!');
					readln;
				end;
			until (ch = 'N') or (terinput);
		end
		else begin
			nomor := nomor - 1;
			baris := baris - 1;
			cursoroff;
			gotoxy(23,4); write('Barang tidak ditemukan!');
			readln;
		end;
		if (ch = 'Y') then terinput := false;
	until (ch = 'N') or (terinput);
	gotoxy(1,baris + 2);
	writeln('| HARGA TOTAL ','':51,' | ','':9,' |');
	gotoxy(69,baris + 2);
	write(jumlah);
	gotoxy(1,baris + 3);
	writeln('| BAYAR ','':57,' | ','':9,' |');
	writeln(' ============================================================================= ');
	repeat
		cursoron;
		gotoxy(3,baris + 5);
		write('                     ');
		gotoxy(69,baris + 3);
		write('         ');
		gotoxy(69,baris + 3);
		readln(bayar);
		if (bayar = 0) then begin
			close(fakturtemp);
			kasir;
		end
		else if (bayar < jumlah) then begin
			cursoroff;
			gotoxy(3,baris + 5);
			write('Uang tidak mencukupi!');
			ch := readkey;
		end;
	until (bayar >= jumlah);
	writeln('| KEMBALI ','':55,' | ','':9,' |');
	gotoxy(69,baris + 4); writeln(bayar - jumlah);
	writeln(' ============================================================================= ');
	writeln('Tekan tombol apa saja untuk melanjutkan...');
	gotoxy(27,4); write('Terimakasih telah berbelanja','':23);
	gotoxy(27,5); write('  di Toserba DayKol Ceria!  ');
	cursoroff;
	// rewrite stok
	assign(listbarang,'db\list_barang.mkt');
	rewrite(listbarang);
	reset(listbarangtemp);
	while not(eof(listbarangtemp)) do begin
		read(listbarangtemp,barang);
		write(listbarang,barang);
	end;
	close(listbarang);
	close(listbarangtemp);
	// Change DB
	assign(faktur,'db\faktur.mkt');
	reset(fakturtemp);
	reset(faktur);
	if (filesize(faktur) = 0) then
		rewrite(faktur)
	else
		seek(faktur,filesize(faktur));
	while not(eof(fakturtemp)) do begin
		read(fakturtemp,catat);
		catat.no := filepos(faktur) + 1;
		write(faktur,catat);
	end;
	close(fakturtemp);
	close(faktur);
	// Print Faktur
	str(catat.idpembeli,temp);
	assign(printfaktur,'faktur\'+temp+'_'+FormatDateTime('DD-MMM-YY',now)+'.txt');
	rewrite(printfaktur);
	writeln(printfaktur,' ============================================================================= ');
	writeln(printfaktur,'|             Toserba DayKol Ceria - Transaksi Barang - ',FormatDateTime('DD-MMM-YY',now):9,'             |');
	writeln(printfaktur,'|=============================================================================|');
	writeln(printfaktur,'|            Terimakasih telah Berbelanja di Toserba DayKol Ceria!            |');
	writeln(printfaktur,'|=============================================================================|');
	writeln(printfaktur,'|  NO  | KODE |            NAMA BARANG            |  HARGA  | QTY |   TOTAL   |');
	writeln(printfaktur,'|-----------------------------------------------------------------------------|');
	assign(fakturtemp,'tmp\faktur.tmp');
	reset(fakturtemp);
	while not(eof(fakturtemp)) do begin
		read(fakturtemp,catat);
		writeln(printfaktur,'| ',catat.no:4,' | ',catat.kode_barang:4,' | ',catat.nama_barang:33,' | ',catat.harga:7,' | ',catat.qty:3,' | ',catat.total:9,' |');
	end;
	close(fakturtemp);
	writeln(printfaktur,'|-----------------------------------------------------------------------------|');
	writeln(printfaktur,'| HARGA TOTAL ','':51,' | ',jumlah:9,' |');
	writeln(printfaktur,'| BAYAR       ','':51,' | ',bayar:9,' |');
	writeln(printfaktur,'| KEMBALI     ','':51,' | ',bayar-jumlah:9,' |');
	writeln(printfaktur,' ============================================================================= ');
	// End Print Faktur
	close(printfaktur);
	readkey;
	kasir;
end;
//////////////////// REKAP FAKTUR ////////////////////
procedure rekapfaktur;
var
	catat : array of tabel3;
	idx,page,currpage,i : longint;
	ch : char;

begin
	clrscr;
	cursoroff;
	writeln(' ==================================================================== ');
	writeln('|               Toserba DayKol Ceria - Rekap Transaksi               |');
	writeln('|====================================================================|');
	assign(faktur,'db\faktur.mkt');
	if file_faktur_ada and (filesize(faktur) <> 0) then begin
		reset(faktur);
		writeln('|  NO  |  ID  | KODE |    NAMA BARANG    |  HARGA  | QTY | TGL  BELI |');
		writeln('|--------------------------------------------------------------------|');
		gotoxy(1,24);
		writeln('  0 | Kembali ke menu kasir');
		setlength(catat,filesize(faktur));
		idx := 0;
		while not(eof(faktur)) do begin
			read(faktur,catat[idx]);
			idx := idx + 1;
		end;
		idx := filesize(faktur) - 1;
		if ((idx + 1) mod 15 = 0) then
			page := (idx + 1) div 15
		else
			page := ((idx + 1) div 15) + 1;
		currpage := 1;
		ch := #75;
		repeat
			for i := 1 to 18 do begin
				gotoxy(1,i+5);
				write('                                                                             ')
			end;
			gotoxy(1,6);
			for i := (currpage - 1) * 15 to (currpage * 15) - 1 do begin
				if i > idx then break;
				writeln('| ',catat[i].no:4,' | ',catat[i].idpembeli:4,' | ',catat[i].kode_barang:4,' | ',catat[i].nama_barang:17,' | ',catat[i].harga:7,' | ',catat[i].qty:3,' | ',catat[i].tanggal:9,' |');
			end;
			writeln(' -------------------------------------------------------------------- ');
			gotoxy(1,22);
			if page = 1 then
				writeln('                                                                      ')
			else if currpage = 1 then
				writeln('                                                           Next Item >')
			else if currpage = page then
				writeln('< Previous Item')
			else
				writeln('< Previous Item                                            Next Item >');
				repeat
				ch := readkey;
				if (ch = #75) and (currpage > 1) then
					currpage := currpage - 1
				else if (ch = #77) and (currpage < page) then
					currpage := currpage + 1;
			until (ch = '0') or (ch = #75) or (ch = #77);
		until (ch = '0');
		{while not(eof(faktur)) do begin
			read(faktur,catat);
			writeln('| ',catat.no:4,' | ',catat.idpembeli:4,' | ',catat.kode_barang:4,' | ',catat.nama_barang:17,' | ',catat.harga:7,' | ',catat.qty:3,' | ',catat.tanggal:9,' |');
		end;}
		close(faktur);
		kasir;
	end
	else begin
		writeln('|                            DATA  KOSONG                            |');
		writeln(' -------------------------------------------------------------------- ');
		writeln;
		writeln('  0 | Kembali ke menu kasir');
		repeat
			ch := readkey;
		until (ch = '0');
		kasir;
	end;
	kasir;
end;
//////////////////// ABOUT ////////////////////
procedure about;

begin
	clrscr;
	watermark;
	writecenter(' ================================ ');
	writecenter('|      Toserba DayKol Ceria      |');
	writecenter('|================================|');
	writecenter('| Jl.Telekomunikasi No.1 Bandung |');
	writecenter('|     No.Telp : (022)-428438     |');
	writecenter('|================================|');
	writecenter('|          Hello World!          |');
	writecenter('|================================|');
	writecenter('|        Karina  Novianti        |');
	writecenter('|       M. Habib  Fikri S.       |');
	writecenter('|       Ni Gusti Ayu Mirah       |');
	writecenter('|         Wanda  Firdaus         |');
	writecenter('|                                |');
	writecenter(' ================================ ');
	gotoxy(27,21); textcolor(12); write(' _____  ____  _     ');textcolor(15);write('   _  _ ');
	gotoxy(27,22); textcolor(12); write('|_   _|| ___|| |   _');textcolor(15);write('_ | || |');
	gotoxy(27,23); textcolor(12); write('  | |  | ___|| |_ |_');textcolor(15);write('_|| || |');
	gotoxy(27,24); textcolor(12); write('  |_|  |____||___|  ');textcolor(15);write('  |____|');
	textcolor(7);
	cursoroff;
	readkey;
	utama;
end;

begin
	utama;
end.
