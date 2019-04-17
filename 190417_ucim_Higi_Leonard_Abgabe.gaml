//*Author: Leo
model new

global {
//GIS Data Setup
	file<geometry> shape_bezirke <- shape_file("../includes/Stadtbezirke_Stadtplanbasis_4326_4.shp", "EPSG:4326");
	//file<geometry> shape_buildings <- file("../includes/Stuttgart Mitte buildings Test.shp") parameter: "Shapefile Stuttgart Mitte Museen" category: "GIS Import"  // +Slider und Überschrift
	int factor_people <- 300 min: 1 max: 1000 step: 10 parameter: "Faktor Repräsentation" category: "Bevölkerung";
	int cursorsize <- 1000 min: 100 max: 10000 step: 10 parameter: "Cursor Size" category: "Modus 2";
	float mietaenderung <- 1.0 min: 0.8 max: 1.1 step: 0.1; // parameter: "Einfluss Nachfrage" category: "Mietentwicklung";
	//Shape Kulturbaustein Init
	file<geometry> shape_museum <- file("../includes/181128_stuttgart_museum_0938.shp");
	file<geometry> shape_club <- file("../includes/Club.shp");
	file<geometry> shape_konzert <- file("../includes/181128Stuttgart_Konzert1750.shp");
	file<geometry> shape_theater <- file("../includes/181217 Theater.shp");
	file<geometry> shape_sonstige <- file("../includes/190215 Sonstige.shp");
	file<geometry> shape_wahlbezirke <- shape_file("../includes/181130stuttgart_wahlbezirke_1024.shp", "EPSG:4326");

	////////GIS Data Setup final
	file<geometry> shape_hochkultur <- file("../includes/190403 hochkultur.shp");
	file<geometry> shape_alltagsnah <- file("../includes/190403 alltagsnah.shp");
	file<geometry> shape_freieszene <- file("../includes/190403 freieszene.shp");
	file<geometry> shape_imstadtraum <- file("../includes/190403 imstadtraum.shp");
	file<geometry> shape_temporaer <- file("../includes/190403 temporaer.shp");
	file<geometry> shape_clubtanz <- file("../includes/190403 clubtanz.shp");
	geometry shape <- envelope(shape_bezirke);
	// //Test Gebäude Import
	// 
	file<geometry> shape_buildings <- shape_file("../includes/181128Stuttgart_building_1637.shp", "EPSG:4326") parameter: "Shapefile Stuttgart Gebäude" category: "GIS Import";
	geometry shape_mitte <- envelope(shape_buildings);
	file ucim_background <- file("../includes/Background ucim_3 gesp.jpg");
	//Parameteränderung händisch
	int visitors_general <- 1 min: 1 max: 9 step: 1 parameter: "grösste Besuchergruppe (LFT)" category: "Parameter Kulturbaustein anpassen";
	float dist_abs_culture <- 2.0 min: 0.2 max: 10.0 step: 0.1 parameter: "Impact Radius Kulturbaustein" category: "Parameter Kulturbaustein anpassen";
	float sens_map <- 3.0 min: 0.5 max: 4.0 step: 0.5 parameter: "Empfindlichkeit Heatmap";
	int threshold_general <- 1 min: 1 max: 4 step: 1 parameter: "Schwellenwirkung anpassen" category: "Parameter Kulturbaustein anpassen";
	int public_space_general <- 1 min: 1 max: 4 step: 1 parameter: "Bezug zum öffentlichen Raum anpassen" category: "Parameter Kulturbaustein anpassen";

	//Kalibrierung Koeffizienten show_public / Submodell LFT-Ansprache
	float coeff_openness <- 0.1 min: 0.0 max: 1.0 step: 0.1 parameter: "Gewichtung Offenheit LFT" category: "Kalibrierung Koeffizienten Submodell LFT-Ansprache";
	float coeff_threshold <- 0.5 min: 0.0 max: 1.0 step: 0.1 parameter: "Gewichtung Schwellenwirkung KB" category: "Kalibrierung Koeffizienten Submodell LFT-Ansprache";
	float coeff_public_space <- 0.1 min: 0.0 max: 1.0 step: 0.1 parameter: "Gewichtung Bezug Öffentlicher Raum KB" category: "Kalibrierung Koeffizienten Submodell LFT-Ansprache";
	//Auswahl KB-Layer
	string map_layer <- "Gesamt" among: ["Hochkultur", "alltagsnah", "Freie Szene", "Kunst im Stadtraum", "Temporär", "Club / Tanzveranstaltung", "Gesamt"] parameter: "Layer"
	category: "Modell";
	int map_layer_lft <- "1" among: [1, 2, 3, 4, 5, 6, 7, 8, 9] parameter: "Layer" category: "Modell";

	//Auswahl Interaktionmodus
	string interact_mode <- "Standortcheck" among: ["Standortcheck", "Parameter KB anpassen", "leave_it"] parameter: "Modus:" category: "Modell";

	//Datenimport
	file data_stuttgart <- csv_file("../includes/190215 Daten Stadtbezirke.csv", ";");
	matrix data_stuttgart_data <- matrix(data_stuttgart);
	map<string, string> stadtbezirksname_map;
	map<string, int> kons_map;

	//Einwohner Data from CSV
	file people_stuttgart <- csv_file("../includes/Einwohnerzahlen nach Bezirken 2018.csv", ";");
	matrix people_data <- matrix(people_stuttgart);
	list<int> people;
	map<string, int> people_map;
	//Wohnungen nach Bezirk from CSV

	//LFT nach Bezirk from CSV
	file LFT_stuttgart <- csv_file("../includes/LFT nach Bezirken 2018.csv", ";");
	matrix LFT_data <- matrix(LFT_stuttgart);
	file bezirke_stuttgart <- csv_file("../includes/Bezirke Vert.csv", ";");
	matrix bezirke_stuttgart_data <- matrix(bezirke_stuttgart);
	list<string> bezirke_stuttgart_list;
	map<string, int> bezirke_stuttgart_map;
	//LFT_kons_map <- list<
	list<int> LFT_kons;
	map<string, int> LFT_kons_map <- map(bezirke_stuttgart_list collect (each::0));
	list<int> LFT_lib;
	list<int> LFT_ref;
	list<int> LFT_hed;
	list<int> LFT_auf;
	list<int> LFT_konv;
	list<int> LFT_trad;
	list<int> LFT_heim;
	list<int> LFT_unt;
	//Income Data from CSV
	file income_LFT <- csv_file("../includes/Einkommensverteilung nach LFT 2008.csv", ";");
	matrix income_data <- matrix(income_LFT);
	list<int> income_kons;
	list<int> income_lib;
	list<int> income_ref;
	list<int> income_hed;
	list<int> income_auf;
	list<int> income_konv;
	list<int> income_trad;
	list<int> income_heim;
	list<int> income_unt;

	// //LFT FROM SURVEY DATA
	file g_form <- csv_file("https://docs.google.com/spreadsheets/d/13wwmB-PNHNqLC0EdoqYBNzvYxr8FMOjE92lBEup8BfI/gviz/tq?tqx=out:csv&sheet=ExportCSV", ",");
	matrix g_data <- matrix(g_form);
	list<int> LFT;

	// //LFT_spec_visit per Culture Type FROM SURVEY DATA
	file g_form_spec_visit_lft <- csv_file("https://docs.google.com/spreadsheets/d/1cMCOHWwLWRsvmjjKsYigvClUpxJoXFEt3YZaQv6jnIk/gviz/tq?tqx=out:csv&sheet=spec_visit_lft", ",");
	matrix g_data_spec_visit_lft <- matrix(g_form_spec_visit_lft);
	map<string, float> spec_visit_lft1_map;
	map<string, float> spec_visit_lft2_map;
	map<string, float> spec_visit_lft3_map;
	map<string, float> spec_visit_lft4_map;
	map<string, float> spec_visit_lft5_map;
	map<string, float> spec_visit_lft6_map;
	map<string, float> spec_visit_lft7_map;
	map<string, float> spec_visit_lft8_map;
	map<string, float> spec_visit_lft9_map;

	// Kulturbaustein Configuration from Survey Data
	file g_kb_form <- csv_file("https://docs.google.com/spreadsheets/d/13yARJzFpNjyt81WNmpi_RXzMAp_UHWGrlHwjEvYr5rE/gviz/tq?tqx=out:csv&sheet=ExportCSVorig", ",");
	matrix g_kb_data <- matrix(g_kb_form);
	list<string> kb_name_list;
	list<int> kb_reach_list;
	map<string, int> kb_reach_map;
	map<string, int> kb_public_space_map;
	map<string, int> kb_threshold_map;
	map<string, int> kb_visitors_map;
	list<float> kb_public_space;
	list<float> kb_threshold;
	list<float> kb_visitors;
	//Anzeige aktuell erreichte Zielgruppe
	list public_temp;
	//Initialisation
	init {

	// CREATE Map of KB reach ##################################################################
		loop i from: 0 to: g_kb_data.rows - 1 {
			add (g_kb_data[0, i]::g_kb_data[1, i]) to: kb_reach_map;
		}

		write kb_reach_map;

		// CREATE Map of KB public space ##################################################################
		loop i from: 0 to: g_kb_data.rows - 1 {
			add (g_kb_data[0, i]::g_kb_data[2, i]) to: kb_public_space_map;
		}

		write kb_public_space_map;

		// CREATE Map of KB threshold ##################################################################
		loop i from: 0 to: g_kb_data.rows - 1 {
			add (g_kb_data[0, i]::g_kb_data[3, i]) to: kb_threshold_map;
		}

		write kb_threshold_map;

		// CREATE Map of KB visitors ##################################################################
		loop i from: 0 to: g_kb_data.rows - 1 {
			add (g_kb_data[0, i]::g_kb_data[4, i]) to: kb_visitors_map;
		}

		write kb_visitors_map;

		// Create Bezirke Map ########################################
		loop i from: 0 to: data_stuttgart_data.rows - 1 {
			add (data_stuttgart_data[0, i]::data_stuttgart_data[1, i]) to: stadtbezirksname_map;
		}

		// Create Bezirke Map ########################################
		loop i from: 0 to: data_stuttgart_data.rows - 1 {
			add (data_stuttgart_data[0, i]::data_stuttgart_data[3, i]) to: kons_map;
		}

		//CREATE People FROM CSV ##################################################################
		loop i from: 1 to: people_data.rows - 1 {
			add people_data[0, i]::people_data[1, i] to: people_map;
		}

		//CREATE LFT FROM CSV ##################################################################
		loop i from: 0 to: LFT_data.rows - 1 {
			add LFT_data[1, i] to: LFT_kons;
			add LFT_data[2, i] to: LFT_lib;
			add LFT_data[3, i] to: LFT_ref;
			add LFT_data[4, i] to: LFT_hed;
			add LFT_data[5, i] to: LFT_auf;
			add LFT_data[6, i] to: LFT_konv;
			add LFT_data[7, i] to: LFT_trad;
			add LFT_data[8, i] to: LFT_heim;
			add LFT_data[9, i] to: LFT_unt;
		}

		//CREATE Income FROM CSV ##################################################################
		loop i from: 1 to: income_data.columns - 1 {
			add income_data[i, 0] to: income_kons;
			add income_data[i, 1] to: income_lib;
			add income_data[i, 2] to: income_ref;
			add income_data[i, 3] to: income_hed;
			add income_data[i, 4] to: income_auf;
			add income_data[i, 5] to: income_konv;
			add income_data[i, 6] to: income_trad;
			add income_data[i, 7] to: income_heim;
			add income_data[i, 8] to: income_unt;
		}
		//CREATE LFT FROM Survey ##################################################################
		loop i from: 0 to: g_data.rows - 1 {
			add LFT_data[1, i] to: LFT;
		}

		//CREATE spec_visit_lft1_map ##################################################################
		loop i from: 0 to: g_data_spec_visit_lft.rows - 1 {
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[1, i] to: spec_visit_lft1_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[2, i] to: spec_visit_lft2_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[3, i] to: spec_visit_lft3_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[4, i] to: spec_visit_lft4_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[5, i] to: spec_visit_lft5_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[6, i] to: spec_visit_lft6_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[7, i] to: spec_visit_lft7_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[8, i] to: spec_visit_lft8_map;
			add g_data_spec_visit_lft[0, i]::g_data_spec_visit_lft[9, i] to: spec_visit_lft9_map;
		}

		write spec_visit_lft1_map;
		write spec_visit_lft2_map;
		write spec_visit_lft3_map;
		write spec_visit_lft4_map;

		//CREATE kb_config FROM Survey ##################################################################
		loop i from: 0 to: g_kb_data.rows - 1 {
		//add g_kb_data[1, i] to: kb_reach;
			add g_kb_data[2, i] to: kb_public_space;
			add g_kb_data[3, i] to: kb_threshold;
			add g_kb_data[4, i] to: kb_visitors;
		}

		//	write kb_reach;
		write kb_public_space;
		write kb_threshold;
		write kb_visitors;
		//END LFT
		create bezirk from: shape_bezirke {
			stadtbezirksname_plain <- read<shape>("STADTBEZIR");
			stadtbezirksname_uml <- read<shape>("NAME");
		}

		create building from: shape_buildings {
			name <- read<shape>("id");
			height <- 15.0 #m;
		}

		ask bezirk {
			stadtbezirkseinwohner <- people_map[stadtbezirksname_plain];
			write stadtbezirksname_plain + stadtbezirkseinwohner;
			LFT_kons_bez <- kons_map[stadtbezirksname_plain];
			write stadtbezirksname_plain + stadtbezirkseinwohner;

			//########### Anzahl Konservativ-Gehobener Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_kons_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_kons[0] : (stadtbezirksname_plain = "Birkach" ? LFT_kons[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_kons[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_kons[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_kons[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_kons[5] : (stadtbezirksname_plain = "Mitte" ? LFT_kons[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_kons[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_kons[8] : (stadtbezirksname_plain = "Münster" ? LFT_kons[9] : (stadtbezirksname_plain = "Nord" ? LFT_kons[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_kons[11] : (stadtbezirksname_plain = "Ost" ? LFT_kons[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_kons[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_kons[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_kons[15] : (stadtbezirksname_plain = "Süd" ? LFT_kons[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_kons[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_kons[18] : (stadtbezirksname_plain = "Wangen" ? LFT_kons[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_kons[20] : (stadtbezirksname_plain = "West" ? LFT_kons[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_kons[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_kons_bez + " % Konservativ-Gehobene");
			//########### Anzahl Liberal-Gehobener Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_lib_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_lib[0] : (stadtbezirksname_plain = "Birkach" ? LFT_lib[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_lib[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_lib[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_lib[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_lib[5] : (stadtbezirksname_plain = "Mitte" ? LFT_lib[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_lib[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_lib[8] : (stadtbezirksname_plain = "Münster" ? LFT_lib[9] : (stadtbezirksname_plain = "Nord" ? LFT_lib[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_lib[11] : (stadtbezirksname_plain = "Ost" ? LFT_lib[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_lib[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_lib[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_lib[15] : (stadtbezirksname_plain = "Süd" ? LFT_lib[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_lib[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_lib[18] : (stadtbezirksname_plain = "Wangen" ? LFT_lib[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_lib[20] : (stadtbezirksname_plain = "West" ? LFT_lib[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_lib[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_lib_bez + " % Liberal-Gehobene");
			//########### Anzahl Reflexive Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_ref_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_ref[0] : (stadtbezirksname_plain = "Birkach" ? LFT_ref[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_ref[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_ref[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_ref[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_ref[5] : (stadtbezirksname_plain = "Mitte" ? LFT_ref[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_ref[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_ref[8] : (stadtbezirksname_plain = "Münster" ? LFT_ref[9] : (stadtbezirksname_plain = "Nord" ? LFT_ref[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_ref[11] : (stadtbezirksname_plain = "Ost" ? LFT_ref[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_ref[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_ref[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_ref[15] : (stadtbezirksname_plain = "Süd" ? LFT_ref[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_ref[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_ref[18] : (stadtbezirksname_plain = "Wangen" ? LFT_ref[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_ref[20] : (stadtbezirksname_plain = "West" ? LFT_ref[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_ref[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_ref_bez + " % Reflexive");
			//########### Anzahl Hedonisten Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_hed_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_hed[0] : (stadtbezirksname_plain = "Birkach" ? LFT_hed[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_hed[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_hed[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_hed[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_hed[5] : (stadtbezirksname_plain = "Mitte" ? LFT_hed[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_hed[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_hed[8] : (stadtbezirksname_plain = "Münster" ? LFT_hed[9] : (stadtbezirksname_plain = "Nord" ? LFT_hed[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_hed[11] : (stadtbezirksname_plain = "Ost" ? LFT_hed[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_hed[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_hed[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_hed[15] : (stadtbezirksname_plain = "Süd" ? LFT_hed[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_hed[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_hed[18] : (stadtbezirksname_plain = "Wangen" ? LFT_hed[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_hed[20] : (stadtbezirksname_plain = "West" ? LFT_hed[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_hed[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_hed_bez + " % Hedonisten");

			//########### Anzahl Aufstiegsorientierte Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_auf_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_auf[0] : (stadtbezirksname_plain = "Birkach" ? LFT_auf[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_auf[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_auf[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_auf[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_auf[5] : (stadtbezirksname_plain = "Mitte" ? LFT_auf[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_auf[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_auf[8] : (stadtbezirksname_plain = "Münster" ? LFT_auf[9] : (stadtbezirksname_plain = "Nord" ? LFT_auf[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_auf[11] : (stadtbezirksname_plain = "Ost" ? LFT_auf[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_auf[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_auf[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_auf[15] : (stadtbezirksname_plain = "Süd" ? LFT_auf[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_auf[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_auf[18] : (stadtbezirksname_plain = "Wangen" ? LFT_auf[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_auf[20] : (stadtbezirksname_plain = "West" ? LFT_auf[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_auf[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_auf_bez + " % Aufstiegsorientierte");

			//########### Anzahl Liberal Gehobene Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_konv_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_konv[0] : (stadtbezirksname_plain = "Birkach" ? LFT_konv[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_konv[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_konv[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_konv[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_konv[5] : (stadtbezirksname_plain = "Mitte" ? LFT_konv[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_konv[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_konv[8] : (stadtbezirksname_plain = "Münster" ? LFT_konv[9] : (stadtbezirksname_plain = "Nord" ? LFT_konv[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_konv[11] : (stadtbezirksname_plain = "Ost" ? LFT_konv[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_konv[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_konv[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_konv[15] : (stadtbezirksname_plain = "Süd" ? LFT_konv[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_konv[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_konv[18] : (stadtbezirksname_plain = "Wangen" ? LFT_konv[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_konv[20] : (stadtbezirksname_plain = "West" ? LFT_konv[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_konv[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_konv_bez + " % Liberal Gehobene");

			//########### Anzahl Traditionelle Arbeiter Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_trad_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_trad[0] : (stadtbezirksname_plain = "Birkach" ? LFT_trad[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_trad[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_trad[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_trad[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_trad[5] : (stadtbezirksname_plain = "Mitte" ? LFT_trad[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_trad[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_trad[8] : (stadtbezirksname_plain = "Münster" ? LFT_trad[9] : (stadtbezirksname_plain = "Nord" ? LFT_trad[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_trad[11] : (stadtbezirksname_plain = "Ost" ? LFT_trad[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_trad[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_trad[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_trad[15] : (stadtbezirksname_plain = "Süd" ? LFT_trad[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_trad[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_trad[18] : (stadtbezirksname_plain = "Wangen" ? LFT_trad[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_trad[20] : (stadtbezirksname_plain = "West" ? LFT_trad[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_trad[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_trad_bez + " % Traditionelle Arbeiter");

			//########### Anzahl Heimzentrierte Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_heim_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_heim[0] : (stadtbezirksname_plain = "Birkach" ? LFT_heim[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_heim[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_heim[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_heim[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_heim[5] : (stadtbezirksname_plain = "Mitte" ? LFT_heim[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_heim[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_heim[8] : (stadtbezirksname_plain = "Münster" ? LFT_heim[9] : (stadtbezirksname_plain = "Nord" ? LFT_heim[10] : (stadtbezirksname_plain = "Obertürkheim" ?
			LFT_heim[11] : (stadtbezirksname_plain = "Ost" ? LFT_heim[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_heim[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_heim[14] : (stadtbezirksname_plain = "Stammheim" ? LFT_heim[15] : (stadtbezirksname_plain = "Süd" ? LFT_heim[16] : (stadtbezirksname_plain = "Untertürkheim" ?
			LFT_heim[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_heim[18] : (stadtbezirksname_plain = "Wangen" ? LFT_heim[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_heim[20] : (stadtbezirksname_plain = "West" ? LFT_heim[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_heim[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname_plain + ": " + self.LFT_heim_bez + " % Heimzentrierte");

			//########### Anzahl Unterhaltungssuchende Einwohner bezirksweise zuweisen (abhängig von Bezirksname) ###############
			LFT_unt_bez <- stadtbezirksname_plain = "Badcannstatt" ? LFT_unt[0] : (stadtbezirksname_plain = "Birkach" ? LFT_unt[1] : (stadtbezirksname_plain = "Botnang" ?
			LFT_unt[2] : (stadtbezirksname_plain = "Degerloch" ? LFT_unt[3] : (stadtbezirksname_plain = "Feuerbach" ? LFT_unt[4] : (stadtbezirksname_plain = "Hedelfingen" ?
			LFT_unt[5] : (stadtbezirksname_plain = "Mitte" ? LFT_unt[6] : (stadtbezirksname_plain = "Möhringen" ? LFT_unt[7] : (stadtbezirksname_plain = "Mühlhausen" ?
			LFT_unt[8] : (stadtbezirksname_plain = "Münster" ? LFT_unt[9] : (stadtbezirksname_plain = "Nord" ? LFT_unt[10] : (stadtbezirksname_plain = "Obertürkunt" ?
			LFT_unt[11] : (stadtbezirksname_plain = "Ost" ? LFT_unt[12] : (stadtbezirksname_plain = "Plieningen" ? LFT_unt[13] : (stadtbezirksname_plain = "Sillenbuch" ?
			LFT_unt[14] : (stadtbezirksname_plain = "Stammunt" ? LFT_unt[15] : (stadtbezirksname_plain = "Süd" ? LFT_unt[16] : (stadtbezirksname_plain = "Untertürkunt" ?
			LFT_unt[17] : (stadtbezirksname_plain = "Vaihingen" ? LFT_unt[18] : (stadtbezirksname_plain = "Wangen" ? LFT_unt[19] : (stadtbezirksname_plain = "Weilimdorf" ?
			LFT_unt[20] : (stadtbezirksname_plain = "West" ? LFT_unt[21] : (stadtbezirksname_plain = "Zuffenhausen" ? LFT_unt[22] : (20)))))))))))))))))))))));
			//write (self.stadtbezirksname + ": " + self.LFT_unt_bez + " % Unterhaltungssuchende");

			//##################################################################
			//##################################################################
			//#############################Konservativ-Gehobene erstellen####################

			//##############Konservativ-Gehobene mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_kons_bez / 100) * (income_kons[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 1;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Konservativ-Gehobene mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_kons_bez / 100) * (income_kons[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 1;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Konservativ-Gehobene mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_kons_bez / 100) * (income_kons[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 1;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Konservativ-Gehobene mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_kons_bez / 100) * (income_kons[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 1;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Konservativ-Gehobene mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_kons_bez / 100) * (income_kons[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 1;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Konservativ-Gehobene####################

			//##################################################################
			//##################################################################
			//#############################Liberal Gehobene erstellen####################

			//##############Liberal Gehobene mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_konv_bez / 100) * (income_konv[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 2;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Liberal Gehobene mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_konv_bez / 100) * (income_konv[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 2;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Liberal Gehobene mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_konv_bez / 100) * (income_konv[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 2;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Liberal Gehobene mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_konv_bez / 100) * (income_konv[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 2;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Liberal Gehobene mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_konv_bez / 100) * (income_konv[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 2;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Liberal Gehobene####################

			//##################################################################
			//##################################################################
			//#############################Traditionelle Arbeiter erstellen####################

			//##############Traditionelle Arbeiter mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_trad_bez / 100) * (income_trad[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 3;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Traditionelle Arbeiter mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_trad_bez / 100) * (income_trad[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 3;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Traditionelle Arbeiter mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_trad_bez / 100) * (income_trad[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 3;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Traditionelle Arbeiter mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_trad_bez / 100) * (income_trad[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 3;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Traditionelle Arbeiter mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_trad_bez / 100) * (income_trad[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 3;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Traditionelle Arbeiter####################

			//##################################################################
			//##################################################################
			//#############################Liberal Gehobene erstellen####################

			//##############Liberal Gehobene mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_lib_bez / 100) * (income_lib[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 4;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Liberal Gehobene mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_lib_bez / 100) * (income_lib[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 4;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Liberal Gehobene mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_lib_bez / 100) * (income_lib[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 4;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Liberal Gehobene mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_lib_bez / 100) * (income_lib[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 4;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Liberal Gehobene mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_lib_bez / 100) * (income_lib[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 4;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Liberal Gehobene####################

			//##################################################################
			//##################################################################
			//#############################Aufstiegsorientierte erstellen####################

			//##############Aufstiegsorientierte mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_auf_bez / 100) * (income_auf[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 5;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Aufstiegsorientierte mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_auf_bez / 100) * (income_auf[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 5;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Aufstiegsorientierte mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_auf_bez / 100) * (income_auf[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 5;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Aufstiegsorientierte mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_auf_bez / 100) * (income_auf[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 5;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Aufstiegsorientierte mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_auf_bez / 100) * (income_auf[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 5;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Aufstiegsorientierte####################

			//##################################################################
			//##################################################################
			//#############################Heimzentrierte erstellen####################

			//##############Heimzentrierte mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_heim_bez / 100) * (income_heim[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 6;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Heimzentrierte mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_heim_bez / 100) * (income_heim[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 6;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Heimzentrierte mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_heim_bez / 100) * (income_heim[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 6;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Heimzentrierte mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_heim_bez / 100) * (income_heim[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 6;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Heimzentrierte mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_heim_bez / 100) * (income_heim[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 6;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Heimzentrierte####################

			//##################################################################
			//##################################################################
			//#############################Reflexive erstellen####################

			//##############Reflexive mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_ref_bez / 100) * (income_ref[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 7;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Reflexive mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_ref_bez / 100) * (income_ref[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 7;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Reflexive mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_ref_bez / 100) * (income_ref[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 7;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Reflexive mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_ref_bez / 100) * (income_ref[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 7;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Reflexive mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_ref_bez / 100) * (income_ref[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 7;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Reflexive####################

			//##################################################################
			//##################################################################
			//#############################Hedonisten erstellen####################

			//##############Hedonisten mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_hed_bez / 100) * (income_hed[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 8;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Hedonisten mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_hed_bez / 100) * (income_hed[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 8;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Hedonisten mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_hed_bez / 100) * (income_hed[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 8;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Hedonisten mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_hed_bez / 100) * (income_hed[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 8;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Hedonisten mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_hed_bez / 100) * (income_hed[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 8;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Hedonisten####################

			//##################################################################
			//##################################################################
			//#############################Unterhaltungssuchende erstellen####################

			//##############Unterhaltungssuchende mit Income 450-1000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_unt_bez / 100) * (income_unt[0]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 9;
				location <- any_location_in(myself);
				income <- rnd(450.0, 999.9);
			}
			//##############Unterhaltungssuchende mit Income 1000-2000  im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_unt_bez / 100) * (income_unt[1]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 9;
				location <- any_location_in(myself);
				income <- rnd(1000.0, 1999.9);
			}
			//##############Unterhaltungssuchende mit Income 2000-3000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_unt_bez / 100) * (income_unt[2]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 9;
				location <- any_location_in(myself);
				income <- rnd(2000.0, 2999.9);
			}
			//##############Unterhaltungssuchende mit Income 3000-4000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_unt_bez / 100) * (income_unt[3]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 9;
				location <- any_location_in(myself);
				income <- rnd(3000.0, 3999.9);
			}
			//##############Unterhaltungssuchende mit Income 4000-10000 im Bezirk erstellen#################
			create mensch number: ((self.stadtbezirkseinwohner * ((self.LFT_unt_bez / 100) * (income_unt[4]) / 100) / factor_people)) {
				lebensfuehrungstyp <- 9;
				location <- any_location_in(myself);
				income <- rnd(4000.0, 10000.0);
			}
			//##################################################################
			//##################################################################
			//#############################Ende Unterhaltungssuchende####################


			//################Farbe nach LFT zuweisen##################
			ask mensch {
				typ_farbe <- lebensfuehrungstyp = 1 ? #plum : (lebensfuehrungstyp = 2 ? #lightgrey : (lebensfuehrungstyp = 3 ? #darkgrey : (lebensfuehrungstyp = 4 ?
				#tomato : (lebensfuehrungstyp = 5 ? #gamaorange : (lebensfuehrungstyp = 6 ? #royalblue : (lebensfuehrungstyp = 7 ? #orangered : (lebensfuehrungstyp = 8 ?
				#mediumvioletred : #forestgreen))))))); //Farbe LFT abhängig festlegen}
			}

		}

		create kulturbaustein from: shape_hochkultur {
			name <- read<shape>("Name");
		}

		create kulturbaustein from: shape_alltagsnah {
			name <- read<shape>("Name");
		}

		create kulturbaustein from: shape_freieszene {
			name <- read<shape>("Name");
		}

		create kulturbaustein from: shape_imstadtraum {
			name <- read<shape>("Name");
		}

		create kulturbaustein from: shape_temporaer {
			name <- read<shape>("Name");
		}

		create kulturbaustein from: shape_clubtanz {
			name <- read<shape>("Name");
		}

		ask kulturbaustein {
			reach_own <- kb_reach_map[name];
			public_space <- kb_public_space_map[name];
			threshold <- kb_threshold_map[name];
			visitors <- kb_visitors_map[name];
			//	lft_target_group <- visitors;
			culture_type <- one_of("hochkultur", "alltagsnah", "clubtanz");
		}

		ask kulturbaustein {
			create kb_name number: 1 with: [kb_name::string(self.name), location::(self.location + 0.2 #km)];
		}

		ask bezirk {
			create bezirksname number: 1 with: [stadtbezirksname_uml::string(self.stadtbezirksname_uml), location::self.location];
		}

		ask bezirksname {
			if (stadtbezirksname_uml = "West") {
				location <- self.location + {-1500, 0, 0};
			}

		}

		create kb_potential from: shape_wahlbezirke {
			name <- read<shape>("AWBEZ_T");
			potential <- 0.0;
		}

		ask kb_potential {
			location <- self.location + {0, 0, 10};
		}

		//############################################
		//############Map Layer Buttons "Art der Kultureinrichtung" (Modus 1 + 2) implementieren
		create map_layer_button_culture_type number: 1 with: [button_name::string("Hochkultur"), location::{world.shape.width * 0.9, world.shape.height * 0.05}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("alltagsnah"), location::{world.shape.width * 0.9, world.shape.height * 0.1}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("Freie Szene"), location::{world.shape.width * 0.9, world.shape.height * 0.15}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("Kunst im Stadtraum"), location::{world.shape.width * 0.9, world.shape.height * 0.2}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("Temporär"), location::{world.shape.width * 0.9, world.shape.height * 0.25}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("Club / Tanzveranstaltung"), location::{world.shape.width * 0.9, world.shape.height * 0.3}];
		create map_layer_button_culture_type number: 1 with: [button_name::string("Gesamt"), location::{world.shape.width * 0.9, world.shape.height * 0.35}];

		//############################################

		//############################################
		//############Map Layer Buttons "Lebensführungstyp" (Modus 3) implementieren
		create map_layer_button_lft number: 1 with: [button_name::int(1), location::{0, world.shape.height * 0.2}];
		create map_layer_button_lft number: 1 with: [button_name::int(2), location::{0, world.shape.height * 0.25}];
		create map_layer_button_lft number: 1 with: [button_name::int(3), location::{0, world.shape.height * 0.3}];
		create map_layer_button_lft number: 1 with: [button_name::int(4), location::{0, world.shape.height * 0.35}];
		create map_layer_button_lft number: 1 with: [button_name::int(5), location::{0, world.shape.height * 0.4}];
		create map_layer_button_lft number: 1 with: [button_name::int(6), location::{0, world.shape.height * 0.45}];
		create map_layer_button_lft number: 1 with: [button_name::int(7), location::{0, world.shape.height * 0.5}];
		create map_layer_button_lft number: 1 with: [button_name::int(8), location::{0, world.shape.height * 0.55}];
		create map_layer_button_lft number: 1 with: [button_name::int(9), location::{0, world.shape.height * 0.6}];

		//############################################


		//############ "Fuzzy Edge" – Stadtgrenzen ausgleichen mittels gekonten Bevölkerungsagenten im lokalen Umkreis von 4km
		do fuzzy_edge;
		//############################################
		ask bezirksname {
			location <- self.location + {0, 0, 50};
		}

		create cursor number: 1;
		ask cursor {
			write "hello";
		}

		//############################################
		//############Openness zuweisen
		ask mensch {
			if ([1, 2, 3] contains self.lebensfuehrungstyp) {
				openness <- 1;
			} else {
				if ([4, 5, 6] contains self.lebensfuehrungstyp) {
					openness <- 2;
				} else {
					if [7, 8, 9] contains self.lebensfuehrungstyp {
						openness <- 3;
					}

				}

			}

			//############################################
			//############Map für Besuchswahrscheinlichkeiten und Aktivitätsradius nach LFT hinterlegen
			spec_visit_lft <- lebensfuehrungstyp = 1 ? spec_visit_lft1_map : (lebensfuehrungstyp = 2 ? spec_visit_lft2_map : (lebensfuehrungstyp = 3 ?
			spec_visit_lft3_map : (lebensfuehrungstyp = 4 ? spec_visit_lft4_map : (lebensfuehrungstyp = 5 ? spec_visit_lft5_map : (lebensfuehrungstyp = 6 ?
			spec_visit_lft6_map : (lebensfuehrungstyp = 7 ? spec_visit_lft7_map : (lebensfuehrungstyp = 8 ? spec_visit_lft8_map : (lebensfuehrungstyp = 9 ?
			spec_visit_lft1_map : (spec_visit_lft9_map)))))))));
			dist_lft_culture <- spec_visit_lft[self.dist_tag];
			dist_lft_culture <- dist_lft_culture #km;
			write spec_visit_lft;
		}

		do calculate_public_init;
	}

	//##################################################################
	//##################################################################
	//End of Init// ######################################################

	

	//KB umziehen
	action leave_it {
		ask kulturbaustein {
			mobil <- false;
		}

		ask kb_name {
			do die;
		}

		ask kulturbaustein {
			create kb_name number: 1 with: [kb_name::string(self.name), location::(self.location + 0.2 #km)];
		}

		ask kb_potential {
			show_pot <- false;
		}

		interact_mode <- "Standortcheck";
	}
	//##################################################################
	//##################################################################
	//############ Submodell LFT-Kulturteilhabe
	action modus3_check_LFT {
		ask mensch {
			target_group_mensch <- false;
			//	size <- 30;
		}

		ask kb_potential closest_to #user_location {
			show_pot <- true;
		}

		ask mensch where (each.lebensfuehrungstyp = map_layer_lft) overlapping (circle(3000) at_location #user_location) {
			ask kulturbaustein overlapping (circle(self.dist_lft_culture, self.location)) {
				ask myself {
					spec_visit_temp <- spec_visit_lft[myself.culture_type];
					if (flip(spec_visit_temp) = true) {
						size <- 100;
						target_group_mensch <- true;
					} else {
						if (flip((coeff_openness * self.openness) + (coeff_threshold * (-1) * myself.threshold) + (coeff_public_space * myself.public_space)) = true) {
							add myself to: my_kb_possible;
							size <- 100;
							target_group_mensch <- true;
						}

					}

				}

			}

		}

		ask kb_name {
		//selected <- false;
		}

		ask (kb_name closest_to #user_location) {
		//selected <- true;
		}

		//public_temp <- mensch where (each.target_group_mensch = true);
		public_temp <- mensch where (each.target_group_mensch = true);
	}

	action move_it {
		if (interact_mode = "Standortcheck") {
			ask kulturbaustein {
				mobil <- false;
			}

			ask (kulturbaustein closest_to #user_location) {
				mobil <- true;
			}

			ask kb_potential {
				show_pot <- true;
			}

			ask (kb_name closest_to #user_location) {
				mobil <- true;
			}

		}

	}

	action umzug {
		ask (kulturbaustein) {
			if (mobil = true) {
				location <- #user_location;
			}

		}

		ask (kb_name) {
			if (mobil = true) {
				location <- #user_location;
			}

		}

		ask (kb_potential closest_to #user_location) {
			if (show_pot = true) {
				potential <- ((length(public_temp) / (length((kulturbaustein closest_to #user_location).public_init))) * 0.1 ^ sens_map);
			}

		}

	}
	//KB zur Parametereinstellung durch Click auswählen
	action select_kb {
		if (interact_mode = "Parameter KB anpassen") {
			ask kulturbaustein {
				selected <- false;
			}

			ask (kulturbaustein closest_to #user_location) {
				selected <- true;
			}

		}

	}

	action kb_umzug_remotemode {
		ask (kulturbaustein closest_to #user_location) {
			mobil <- true;
		}

		ask kb_potential {
			show_pot <- true;
		}

		ask kb_name {
			do die;
		}

		ask kulturbaustein {
			if (mobil = false) {
				do die;
			} else {
				do move;
			}

		}

		do layer_choice_culture_type;
	}
	//##################################################################
	//##################################################################
	//############ Schaltflächen Layerwahl Art der Kultureinrichtung (Modus 1 + 2)
	action layer_choice_culture_type {
		ask kulturbaustein {
			ask map_layer_button_culture_type overlapping (rectangle(3000, 1000) at_location #user_location) {
				ask map_layer_button_culture_type {
					active <- false;
				}

				active <- true;
				map_layer <- self.button_name;
				ask kulturbaustein {
					do die;
				}

				ask kb_name {
					do die;
				}

				ask kb_potential {
					potential <- 0.0;
					show_pot <- false;
				}

				public_temp <- nil;
				if (map_layer = "Hochkultur") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_hochkultur <- file("../includes/190403 hochkultur.shp");
					create kulturbaustein from: shape_hochkultur {
						name <- read<shape>("Name");
						culture_type <- "hochkultur";
					}

				}

				if (map_layer = "alltagsnah") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_alltagsnah <- file("../includes/190403 alltagsnah.shp");
					create kulturbaustein from: shape_alltagsnah {
						name <- read<shape>("Name");
						culture_type <- "alltagsnah";
					}

				}

				if (map_layer = "Freie Szene") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_freieszene <- file("../includes/190403 freieszene.shp");
					create kulturbaustein from: shape_freieszene {
						name <- read<shape>("Name");
						culture_type <- "freieszene";
					}

				}

				if (map_layer = "Kunst im Stadtraum") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_imstadtraum <- file("../includes/190403 imstadtraum.shp");
					create kulturbaustein from: shape_imstadtraum {
						name <- read<shape>("Name");
						culture_type <- "imstadtraum";
					}

				}

				if (map_layer = "Temporär") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_temporaer <- file("../includes/190403 temporaer.shp");
					create kulturbaustein from: shape_temporaer {
						name <- read<shape>("Name");
						culture_type <- "temporaer";
					}

				}

				if (map_layer = "Club / Tanzveranstaltung") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_clubtanz <- file("../includes/190403 clubtanz.shp");
					create kulturbaustein from: shape_clubtanz {
						name <- read<shape>("Name");
						culture_type <- "clubtanz";
					}

				}

				if (map_layer = "Gesamt") {
					ask kulturbaustein {
						do die;
					}

					file<geometry> shape_hochkultur <- file("../includes/190403 hochkultur.shp");
					create kulturbaustein from: shape_hochkultur {
						name <- read<shape>("Name");
						culture_type <- "hochkultur";
					}

					file<geometry> shape_alltagsnah <- file("../includes/190403 alltagsnah.shp");
					create kulturbaustein from: shape_alltagsnah {
						name <- read<shape>("Name");
						culture_type <- "alltagsnah";
					}

					file<geometry> shape_freieszene <- file("../includes/190403 freieszene.shp");
					create kulturbaustein from: shape_freieszene {
						name <- read<shape>("Name");
						culture_type <- "freieszene";
					}

					file<geometry> shape_imstadtraum <- file("../includes/181128Stuttgart_Konzert1750.shp");
					create kulturbaustein from: shape_imstadtraum {
						name <- read<shape>("Name");
						culture_type <- "imstadtraum";
					}

					file<geometry> shape_temporaer <- file("../includes/190403 temporaer.shp");
					create kulturbaustein from: shape_temporaer {
						name <- read<shape>("Name");
						culture_type <- "temporaer";
					}

					file<geometry> shape_clubtanz <- file("../includes/190403 clubtanz.shp");
					create kulturbaustein from: shape_clubtanz {
						name <- read<shape>("Name");
						culture_type <- "clubtanz";
					}

				}

				ask kulturbaustein {
					reach_own <- kb_reach_map[name];
					public_space <- kb_public_space_map[name];
					threshold <- kb_threshold_map[name];
					//visitors <- 4;
					//visitors <- kb_visitors_map[name];
					lft_target_group <- visitors;
					create kb_name number: 1 with: [kb_name::string(self.name), location::(self.location + 0.2 #km)];
				}

				ask kb_potential {
					location <- self.location + {0, 0, 0};
				}

			}

		}

	}
	//##################################################################

	//##################################################################
	//##################################################################
	//############ Schaltflächen Layerwahl Lebensführungstyp (Modus 3)
	action layer_choice_lft {
		ask map_layer_button_lft overlapping (rectangle(3000, 1000) at_location #user_location) {
			ask map_layer_button_lft {
				active <- false;
			}

			active <- true;
			map_layer_lft <- self.button_name;
		}

	}
	//##################################################################


	//##################################################################
	//############ "Fuzzy Edge" / Submodell Randausgleich – Stadtgrenzen ausgleichen mittels gekonten Bevölkerungsagenten im lokalen Umkreis von 4km
	action fuzzy_edge {
		ask bezirk {
			ask (mensch inside self) {
				mein_bezirk <- myself;
				create mensch number: 1 {
					size <- 30;
					is_copy <- true;
					lebensfuehrungstyp <- myself.lebensfuehrungstyp;
					typ_farbe <- #turquoise;
					income <- myself.income;
					dist_lft_culture <- myself.dist_lft_culture;
					my_kb <- myself.my_kb;
					target_group_mensch <- false;
					location <- any_location_in(4 #km around myself);
				}

			}

			write self.stadtbezirksname_plain;
		}

		ask bezirk {
			ask mensch inside self {
				if (is_copy = true) {
					do die;
				}

			}

			location <- self.location + {0, 0, -100};
		}

	}

	//Oper erstellen
	// action oper
	// {
	//  create kulturbaustein number: 1 with: [location::# user_location, lft_target_group::1, color::# green];
	// }
	//
	// //Museum erstellen
	// action museum
	// {
	//  create kulturbaustein number: 1 with: [location::# user_location, lft_target_group::2, color::# red];
	// }
	//
	// //Volksfest erstellen
	// action beer
	// {
	//  create kulturbaustein number: 1 with: [location::# user_location, lft_target_group::3, color::# blue];
	// }
	//
	// //Bar mit Live-Musik erstellen
	// action rock
	// {
	//  create kulturbaustein number: 1 with: [location::# user_location, lft_target_group::4, color::# yellow];
	// }
	action calculate_public_init {
		ask (kulturbaustein) {
			ask mensch at_distance self.reach_own #km {
				if (distance_to(self.location, myself.location) <= self.dist_lft_culture) {
					spec_visit_temp <- spec_visit_lft[myself.culture_type];
					if (flip(spec_visit_temp) = true) {
						my_kb <- myself;
						target_group_mensch <- true;
					} else {
						if (flip((0.1 * self.openness) + (0.5 / myself.threshold) + (0.1 * myself.public_space)) = true) {
							my_kb <- myself;
							target_group_mensch <- true;
						}

					}

				}

			}

			public_init <- length(mensch where (each.my_kb = myself));
		}

		ask kb_name {
			selected <- false;
		}

		ask mensch {
			target_group_mensch <- false;
		}

	}
	//##################################################################
	//##################################################################
	//############ Submodell LFT-Ansprache
	action show_public {
		ask mensch {
			target_group_mensch <- false;
		}

		ask (kulturbaustein closest_to #user_location) {
			ask mensch at_distance self.reach_own #km {
				if (distance_to(self.location, myself.location) <= self.dist_lft_culture) {
					spec_visit_temp <- spec_visit_lft[myself.culture_type];
					if (flip(spec_visit_temp) = true) {
						my_kb <- myself;
						target_group_mensch <- true;
					} else {
						if (flip((coeff_openness * self.openness) + (coeff_threshold * (-1) * myself.threshold) + (coeff_public_space * myself.public_space)) = true) {
							my_kb <- myself;
							target_group_mensch <- true;
						}

					}

				}

			}

		}

		ask kb_name {
			selected <- false;
		}

		ask (kb_name closest_to #user_location) {
			selected <- true;
		}

		public_temp <- mensch where (each.target_group_mensch = true);
	}

	action cursortracking {
		ask cursor {
			location <- #user_location;
		}

	}

}

species cursor {
	int size_own <- cursorsize update: cursorsize;

	aspect default {
		draw circle(size_own) color: rgb(205, 23, 25, 0.3);
	}

}

species bezirk {
	string stadtbezirksname_plain;
	string stadtbezirksname_uml;
	int stadtbezirkseinwohner;
	int LFT_kons_bez;
	int LFT_lib_bez;
	int LFT_ref_bez;
	int LFT_hed_bez;
	int LFT_auf_bez;
	int LFT_konv_bez;
	int LFT_trad_bez;
	int LFT_heim_bez;
	int LFT_unt_bez;

	aspect default {
		draw shape color: #black border: #white;
	}

}

species bezirksname {
	string stadtbezirksname_plain;
	string stadtbezirksname_uml;

	aspect default {
		draw string(stadtbezirksname_uml of self) color: #lightgrey font: font("FHP Sun Office", 18, #plain);
	}

}

species mensch skills: [moving] {
	bool is_copy <- false;
	int lebensfuehrungstyp;
	map spec_visit_lft;
	float spec_visit_temp;
	rgb typ_farbe;
	float income;
	float dist_lft_culture <- 11 #km;
	string dist_tag <- "dist_lft_culture";
	kulturbaustein my_kb;
	list<kulturbaustein> my_kb_possible;
	bool target_group_mensch;
	bezirk mein_bezirk update: (bezirk closest_to (self));
	int size <- 30;
	int openness <- 0;

	aspect default {
		draw square(size) color: typ_farbe;
		if (target_group_mensch = true) {
			if (my_kb.location != 0) {
				draw polygon([self.location, my_kb]) color: typ_farbe;
			}

		}

	}

}

species kulturbaustein skills: [moving] {
	float size <- 150.0;
	int lft_target_group;
	rgb typ_farbe_kb;
	string name;
	float reach_own;
	float public_space;
	float threshold;
	int visitors;
	int public_init;
	geometry connection_kb;
	bool mobil;
	bool selected;
	list my_target_group;
	bezirk mein_bezirk update: (bezirk closest_to (self));
	string culture_type;

	aspect default {
		draw circle(size) color: #white;
	}

	reflex scan {
		loop times: 800000 {
			if (mobil = true) {
				ask kb_potential closest_to self.location {
					loop times: 3 {
						potential <- ((length(public_temp) / (length((kulturbaustein closest_to #user_location).public_init))) * 0.1 ^ sens_map);
					}

					//Loop: more accurate results

				}

				location <- any(kb_potential where (each.potential = 0) closest_to (self.location));
			}

		}

	}

	user_command kb_umzug {
		mobil <- true;
		ask kb_name {
			do die;
		}

		ask kb_potential {
			potential <- 0;
			show_pot <- true;
		}

	}
	//KB-Parameter händisch einstellen
	user_command Konfiguration_uebernehmen {
		visitors <- visitors_general;
		reach_own <- dist_abs_culture;
		threshold <- threshold_general;
		public_space <- public_space_general;
		selected <- false;
	}

}

species kb_name {
	string kb_name;
	bool mobil <- false;
	bool selected;

	aspect default {
		if (selected = true) {
			color <- #white;
			draw string(kb_name of self) color: #white font: font("FHP Sun Office", 40, #plain);
		}

	}

}

species kb_potential {
	string name;
	float potential;
	bool show_pot;

	aspect default {
		draw shape color: rgb(66, 155, 225, potential * 2) border: #black;
	}

}

species map_layer_button_culture_type {
	string button_name;
	bool active;

	aspect default {
		if (active = false) {
			draw string(button_name) color: #grey font: font("FHP Sun Office", 24, #italic);
		} else {
			draw string(button_name) color: #white font: font("FHP Sun Office", 24, #italic);
		}

	}

}

species map_layer_button_lft {
	int button_name;
	bool active;

	aspect default {
		if (active = false) {
			draw string(button_name) color: #grey font: font("FHP Sun Office", 24, #italic);
		} else {
			draw string(button_name) color: #white font: font("FHP Sun Office", 24, #italic);
		}

	}

}

species building {
	float height;

	aspect default {
		draw shape color: #white border: #white depth: height;
	}

}

experiment Modus1_Uebersicht_Status_Quo type: gui {
	output {
		display modus1_Uebersicht_Status_Quo type: opengl {
			image ucim_background transparency: 0.2;
			//event [mouse_down] action: create_culture;
			event [mouse_move] action: show_public;
			event [mouse_move] action: umzug;
			event [mouse_down] action: leave_it;
			event [mouse_down] action: layer_choice_culture_type;
			species mensch;
			species kulturbaustein;
			species bezirksname;
			species kb_name;
			species kb_potential aspect: default;
			species map_layer_button_culture_type;
			graphics "Kulturbaustein" {
				draw (name of (kulturbaustein closest_to #user_location)) color: #white font: font("FHP Sun Office", 20, #bold) at: {0, world.shape.height * -0.03};
			}

			graphics "Zielgruppe" {
				draw string(length(public_temp) * factor_people) + " erreichbare Menschen" color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.0055};
			}

			graphics "Radius Impact" {
				draw "Reichweite: " + (kulturbaustein closest_to #user_location).reach_own color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.05};
			}

			graphics "Public Space" {
				draw "Bezug öffentlicher Raum: " + (kulturbaustein closest_to #user_location).public_space color: #white font: font("FHP Sun Office", 20, #plain) at:
				{0, world.shape.height * 0.075};
			}

			graphics "Schwellenwirkung" {
				draw "Schwellenwirkung: " + (kulturbaustein closest_to #user_location).threshold color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.1};
			}

		

		}

	}

}

// /* Insert your model definition here */
experiment Modus2_Analyse_Kulturbaustein type: gui {
	output {
		display modus2_Analyse_Kulturbaustein type: opengl refresh: every(0.2) {
			image ucim_background transparency: 0.2;
			//event [mouse_down] action: create_culture;
			event [mouse_move] action: show_public;
			event [mouse_down] action: kb_umzug_remotemode;
			event [mouse_down] action: umzug;
			species mensch;
			//species bezirk;
			species kulturbaustein;
			species bezirksname;
			species kb_name;
			species kb_potential aspect: default;
			species map_layer_button_culture_type;
			graphics "Kulturbaustein" {
				draw (name of (kulturbaustein closest_to #user_location)) color: #white font: font("FHP Sun Office", 20, #bold) at: {0, world.shape.height * 0.05};
			}

			graphics "Zielgruppe" {
				draw string(length(public_temp) * factor_people) + " erreichbare Menschen" color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.1};
			}

			graphics "Radius Impact" {
				draw "Reichweite: " + (kulturbaustein closest_to #user_location).reach_own color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.15};
			}

			graphics "Public Space" {
				draw "Bezug öffentlicher Raum: " + (kulturbaustein closest_to #user_location).public_space color: #white font: font("FHP Sun Office", 20, #plain) at:
				{0, world.shape.height * 0.175};
			}

			graphics "Schwellenwirkung" {
				draw "Schwellenwirkung: " + (kulturbaustein closest_to #user_location).threshold color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.2};
			}

			

		}

	}

}

experiment Modus3_Analyse_Lebensfuehrungstyp type: gui {
	output {
		display modus3_Analyse_Lebensfuehrungstyp type: opengl {
			event [mouse_move] action: modus3_check_LFT;
			event [mouse_down] action: layer_choice_culture_type;
			event [mouse_down] action: layer_choice_lft;
			species mensch aspect: default;
			species kulturbaustein;
			species bezirksname;
			species kb_potential aspect: default;
			species map_layer_button_lft;
			species map_layer_button_culture_type;
			species bezirk;
			graphics "Kulturbaustein" {
				draw (name of (kulturbaustein closest_to #user_location)) color: #white font: font("FHP Sun Office", 20, #bold) at: {0, world.shape.height * -0.03};
			}

			graphics "Zielgruppe" {
				draw string(length(public_temp) * factor_people) + " erreichbare Menschen" color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.0055};
			}

			graphics "Radius Impact" {
				draw "Reichweite: " + (kulturbaustein closest_to #user_location).reach_own color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.05};
			}

			graphics "Public Space" {
				draw "Bezug öffentlicher Raum: " + (kulturbaustein closest_to #user_location).public_space color: #white font: font("FHP Sun Office", 20, #plain) at:
				{0, world.shape.height * 0.075};
			}

			graphics "Schwellenwirkung" {
				draw "Schwellenwirkung: " + (kulturbaustein closest_to #user_location).threshold color: #white font: font("FHP Sun Office", 20, #plain) at: {0, world.shape.height * 0.1};
			}

			

		}

	}

}