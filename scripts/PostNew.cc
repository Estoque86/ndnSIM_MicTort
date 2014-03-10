#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <cstddef>
#include <cstdio>
#include <iostream>
#include <stdint.h>
#include <cstdlib>
#include <math.h>
#include <sstream>
#include <fstream>
#include <limits>
#include <vector>
#include <boost/tokenizer.hpp>


int
main (int argc, char *argv[13])
{
/*
	long double simDuration = 11500000000;  // [us]
	long double timeSlot = 10000000;
	long double slotMax = 900;
	long double numero_sim = 10;
	int num_par_mis = 9;
	std::string scenario = "";
	std::string bfScope = "";
	std::string bfType = "";
	double alpha = 1.0;
	int cellWidth = 3;
*/

	long double simDuration = (long double) std::atol(argv[1]);  // [us]
	long double timeSlot = (long double) std::atol(argv[2]);
	long double slotMax = (long double) std::atol(argv[3]);
	long double numero_sim = (long double) std::atol(argv[4]);
	uint32_t num_par_mis = (uint32_t) std::atoi(argv[5]);
	std::string scenario = argv[6];
	std::string bfScope = argv[7];
	std::string bfType = argv[8];
	int alpha = (int) std::atoi(argv[9]);              // 0.8 --> 08;  1.2 --> 12 ...
	int cellWidth = (int) std::atoi(argv[10]);
        uint32_t numeroNodi = (uint32_t) std::atoi(argv[11]);

std::cout << simDuration << "\n" << timeSlot << "\n" << slotMax << "\n" << numero_sim << "\n" << num_par_mis << "\n" << scenario << "\n" << bfScope << "\n" << bfType << "\n" << alpha << "\n" << cellWidth << "\n" << numeroNodi << "\n";



        long double numSlot = simDuration / timeSlot;  // 600

	std::string ALPHA;
	std::stringstream ss;
	std::string path;
	std::string inputSuffix;
	std::string outputSuffix;

	ss << alpha;
	ALPHA = ss.str();
	ss.str("");

	int numStringheInput = 5;
    std::vector<std::string> * stringheInput = new std::vector<std::string> (numStringheInput, "");

	if(scenario.compare("Flooding") == 0 || scenario.compare("BestRoute") == 0)
	{
		path = scenario;
		ss << scenario << "_alpha_" << ALPHA << "_";
		inputSuffix = ss.str();
		ss.str("");

		ss << scenario << "_alpha_" << ALPHA;
		outputSuffix = ss.str();
		ss.str("");


	}
	else if (scenario.compare("BloomFilter") == 0)
	{
		ss << scenario << "/" << bfScope << "/" << bfType;
		path = ss.str();
		ss.str("");

		ss << scenario << "_alpha_" << ALPHA << "_cell_" << cellWidth << "_run_";
		inputSuffix = ss.str();
		ss.str("");

		ss << scenario << "_" << bfType << "_cell_" << cellWidth << "_alpha_" << ALPHA;
		outputSuffix = ss.str();
		ss.str("");

	}
	else
	{
		std::cout << "Inserire scenario corretto!!" << scenario;
		exit(0);
	}


	ss << path << "/DATA/Data_Nodo_";
  	stringheInput->operator [](0) = ss.str();
    ss.str("");

	ss << path << "/INTEREST/Interest_Nodo_";
  	stringheInput->operator [](1) = ss.str();
    ss.str("");

  	ss << path << "/DATA/APP/DataRICEVUTI_APP_Nodo_";
  	stringheInput->operator [](2) = ss.str();
    ss.str("");

    ss << path << "/INTEREST/APP/Interest_APP_Nodo_";
    stringheInput->operator [](3) = ss.str();
    ss.str("");

    ss << path << "/DOWNLOAD/APP/DownloadTime_Nodo_";
    stringheInput->operator [](4) = ss.str();
    ss.str("");


	// STRINGHE OUTPUT
    std::vector<std::string> * stringheOutput = new std::vector<std::string> (num_par_mis, "");

    ss << path << "/MEDIE/Mean_DATA_INVIATI_";
    stringheOutput->operator [](0) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_INVIATI_CLIENT_";
    stringheOutput->operator [](1) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_INVIATI_CORE_";
    stringheOutput->operator [](2) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_INVIATI_REPO_";
    stringheOutput->operator [](3) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_RICEVUTI_";
    stringheOutput->operator [](4) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_RICEVUTI_CLIENT_";
    stringheOutput->operator [](5) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_RICEVUTI_CORE_";
    stringheOutput->operator [](6) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DATA_RICEVUTI_APP_";
    stringheOutput->operator [](7) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_INVIATI_";
    stringheOutput->operator [](8) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_INVIATI_CLIENT_";
    stringheOutput->operator [](9) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_INVIATI_CORE_";
    stringheOutput->operator [](10) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_INVIATI_APP_";
    stringheOutput->operator [](11) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_RICEVUTI_";
    stringheOutput->operator [](12) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_RICEVUTI_CLIENT_";
    stringheOutput->operator [](13) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_RICEVUTI_CORE_";
    stringheOutput->operator [](14) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_RICEVUTI_REPO_";
    stringheOutput->operator [](15) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_AGGREGATI_";
    stringheOutput->operator [](16) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_ELIMINATI_";
    stringheOutput->operator [](17) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_ELIMINATI_FILE_";
    stringheOutput->operator [](18) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_INTEREST_RITRASMESSI_";
    stringheOutput->operator [](19) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DISTANCE_";
    stringheOutput->operator [](20) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DISTANCE_FIRST_";
    stringheOutput->operator [](21) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_HIT_";
    stringheOutput->operator [](22) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DOWNLOAD_FILE_";
    stringheOutput->operator [](23) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DOWNLOAD_FILE_ALL_LOCAL_";
    stringheOutput->operator [](24) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DOWNLOAD_FIRST_";
    stringheOutput->operator [](25) = ss.str();
    ss.str("");

    ss << path << "/MEDIE/Mean_DOWNLOAD_FIRST_ALL_LOCAL_";
    stringheOutput->operator [](26) = ss.str();
    ss.str("");



    std::ifstream fin;
    std::ofstream fout;

    std::string line;
    const char* PATH;


    long double fileAperti = 0;
	long double fileApertiCLIENT = 0;
	long double fileApertiCORE = 0;
	long double fileApertiREPO = 0;

	bool repo = false;
	bool client = false;
	bool core = false;

    std::vector<long double>* ValoriInseritiFile_sl = new std::vector<long double> (numSlot, 0);         // Servirà per calcolare la media;
	std::vector<long double>* ValoriInseritiFirst_sl = new std::vector<long double> (numSlot, 0);

	// *** TRACING DEGLI INTEREST INVIATI A LIVELLO APPLICATIVO (escluse rtx) e dei DATA RICEVUTI a livello applicativo (compresi quelli provenienti dalla cache locale del consumer)
	// *** I classici INTEREST INVIATI e DATA RICEVUTI contengono solo gli interest inoltrati al di fuori del nodo (non soddisf localmente) comprese le rtx, e i DATA ricevuti dall'esterno, rispettivamente.


	// **** Matrice contenente i parametri medi misurati;
	std::vector<std::vector<std::vector<long double> > >  parametriMisurati; // = new std::vector<std::vector<long double> > (16,numSlot,0);

	parametriMisurati.resize(num_par_mis);
	for (uint32_t i = 0; i < num_par_mis; ++i)
	{
		parametriMisurati[i].resize(numero_sim);
		for (uint32_t j = 0; j < numero_sim; ++j)
		{
			parametriMisurati[i][j].resize(numSlot, 0);
		}
	}


	// ***********************

	std::vector<std::vector<long double> > dataInviatiCACHE;
	dataInviatiCACHE.resize(numero_sim);
	for (uint32_t i = 0; i < numero_sim; ++i)
	{
		dataInviatiCACHE[i].resize(numSlot, 0);
	}

	std::vector<std::vector<long double> > dataInviatiCACHE_CLIENT;
	dataInviatiCACHE_CLIENT.resize(numero_sim);
	for (uint32_t i = 0; i < numero_sim; ++i)
	{
		dataInviatiCACHE_CLIENT[i].resize(numSlot, 0);
	}

	std::vector<std::vector<long double> > dataInviatiCACHE_REPO;
	dataInviatiCACHE_REPO.resize(numero_sim);
	for (uint32_t i = 0; i < numero_sim; ++i)
	{
		dataInviatiCACHE_REPO[i].resize(numSlot, 0);
	}

	std::vector<std::vector<long double> > dataInviatiCACHE_CORE;
	dataInviatiCACHE_CORE.resize(numero_sim);
	for (uint32_t i = 0; i < numero_sim; ++i)
	{
		dataInviatiCACHE_CORE[i].resize(numSlot, 0);
	}

	// ******************



   	for(uint32_t k = 1; k <= numero_sim; k++)  // Ciclo for per le tre simulazioni fatte per ogni scenario
	{
   		// *************************************************************************************************************************
   		// ***** DATA ****  parametriMisurati[0]
		for(uint32_t z=1; z <= numeroNodi; z++)
		{
			ss << stringheInput->operator [](0) << z << "." << inputSuffix << k ;
			PATH = ss.str().c_str();
			ss.str("");

			fin.open(PATH);
			if(!fin){
			  	std::cout << "\n File non presente DATA!\n";
			   	fin.close();
			}
			else
			{
				fileAperti++;
				std::getline(fin, line);
				if (line.compare("client") == 0)
				{
					client = true;
					fileApertiCLIENT++;
				}
				else if (line.compare("producer") == 0)
				{
					repo = true;
					fileApertiREPO++;
				}
				else if (line.compare("core") == 0)
				{
					core = true;
					fileApertiCORE++;
				}
				else
				{
					std::cout << "Errore nella determinazione del tipo di nodo!";
					exit(0);
				}

			    while(std::getline(fin, line))
			    {
			    	boost::char_separator<char> sep("\t");
			        boost::tokenizer<boost::char_separator<char> > tokens(line, sep);
			        boost::tokenizer<boost::char_separator<char> >::iterator it = tokens.begin();

			        // Eliminazione del transitorio
			        std::string strTrans = (*it);
			        const char* valueTrans = strTrans.c_str();
			        long double checkTrans = (long double) std::atol(valueTrans);
			        uint32_t slot = floor(checkTrans/timeSlot);

			        if(slot <= slotMax)
			        {
			        	++it;  // Verifico se si tratta di Rx o Tx
			        	std::string eventType = (*it);
			        	if(eventType.compare("Tx") == 0)
			        	{
			        		parametriMisurati[0][k-1][slot]++;   // DATA INVIATI

			        		// Verifica sulla generazione locale del Data (va fatta solo per Tx)
				        	++it;
			        		++it;
			        		std::string stri = (*it);
			        		const char* value = stri.c_str();
			        		long double local = (long double) std::atoi(value);
			        		if(local == 1)
			        		{
			        			dataInviatiCACHE[k-1][slot]++;
			        			if (client)
			        			{
				        			dataInviatiCACHE_CLIENT[k-1][slot]++;
			        			}
			        			else if (core)
			        			{
				        			dataInviatiCACHE_CORE[k-1][slot]++;
			        			}
			        			else
			        			{
				        			dataInviatiCACHE_REPO[k-1][slot]++;
			        			}
			        		}
			        		else
			        		{
			        			if (client)
			        			{
			        				parametriMisurati[1][k-1][slot]++;   // DATA INVIATI CLIENT
			        			}
			        			else if (core)
			        			{
			        				parametriMisurati[2][k-1][slot]++;   // DATA INVIATI CORE
			        			}
			        			else
			        			{
			        				parametriMisurati[3][k-1][slot]++;   // DATA INVIATI REPO
			        			}
			        		}
			        	}

			        	else if (eventType.compare("Rx") == 0)
			        	{
			        		parametriMisurati[4][k-1][slot]++;   // DATA RICEVUTI

		        			if (client)
		        			{
		        				parametriMisurati[5][k-1][slot]++;   // DATA RICEVUTI CLIENT
		        			}
		        			else if (core)
		        			{
		        				parametriMisurati[6][k-1][slot]++;   // DATA RICEVUTI CORE
		        			}
			        	}
			        }
			        else
						break;
			    }
		        fin.close();
			}
			repo = false;
			client = false;
			core = false;
		}

		for(uint32_t i = 0; i < numSlot; i++)
		{
			parametriMisurati[0][k-1][i] /= (long double)(fileAperti);          // Data INVIATI
			parametriMisurati[1][k-1][i] /= (long double)(fileApertiCLIENT);    // Data INVIATI CLIENT
			parametriMisurati[2][k-1][i] /= (long double)(fileApertiCORE);      // Data INVIATI CORE
			parametriMisurati[3][k-1][i] /= (long double)(fileApertiREPO);      // Data INVIATI REPO

			dataInviatiCACHE[k-1][i] /= (long double)(fileAperti);				// Data INVIATI CACHE
			dataInviatiCACHE_CLIENT[k-1][i] /= (long double)(fileApertiCLIENT); // Data INVIATI CACHE CLIENT
			dataInviatiCACHE_CORE[k-1][i] /= (long double)(fileApertiCORE);		// Data INVIATI CACHE CORE
			dataInviatiCACHE_REPO[k-1][i] /= (long double)(fileApertiREPO);	 	// Data INVIATI CACHE REPO

			parametriMisurati[4][k-1][i] /= (long double)(fileAperti);          // Data RICEVUTI
			parametriMisurati[5][k-1][i] /= (long double)(fileApertiCLIENT);    // Data RICEVUTI CLIENT
			parametriMisurati[6][k-1][i] /= (long double)(fileApertiCORE);      // Data RICEVUTI CORE
		}

		fileAperti = 0;
		fileApertiCLIENT = 0;
		fileApertiCORE = 0;
		fileApertiREPO = 0;


		// *************************************************************************************************************************
		// ***** DATA RICEVUTI APP ****  parametriMisurati[7]

		for(uint32_t z=1; z <= numeroNodi; z++)
		{
			ss << stringheInput->operator [](2) << z << "." << inputSuffix << k ;
			PATH = ss.str().c_str();
			ss.str("");
			fin.open(PATH);
			if(!fin){
			  	std::cout << "\n File non presente DATA APP!\n";
			   	fin.close();
			}
			else
			{
				fileAperti++;
				std::getline(fin, line);
				if (line.compare("client") == 0)
				{
					client = true;
				}
				else
				{
					std::cout << "Tracing a livello applicativo (DATA RICEVUTI APP) solo presente nei client!";
					exit(0);
				}
				while(std::getline(fin, line))
				{
			    	boost::char_separator<char> sep("\t");
			        boost::tokenizer<boost::char_separator<char> > tokens(line, sep);
			        boost::tokenizer<boost::char_separator<char> >::iterator it = tokens.begin();

			        // Eliminazione del transitorio
			        std::string strTrans = (*it);
			        const char* valueTrans = strTrans.c_str();
			        long double checkTrans = (long double) std::atol(valueTrans);
			        uint32_t slot = floor(checkTrans/timeSlot);

			        if(slot <= slotMax)
			        {
		        		parametriMisurati[7][k-1][slot]++;   // DATA RICEVUTI APP
					}
			        else
			        	break;
				}
				fin.close();
			}
			client = false;
		}

		for(uint32_t i = 0; i < numSlot; i++)
		{
			parametriMisurati[7][k-1][i] /= (long double)(fileAperti);          // Data RICEVUTI APP
		}

		fileAperti = 0;


		// **********************************************************************************************************************
		// ******  INTEREST ******  parametriMisurati[8]

		for(uint32_t z=1; z <= numeroNodi; z++)
		{
			ss << stringheInput->operator [](1) << z << "." << inputSuffix << k ;
			PATH = ss.str().c_str();
			ss.str("");
			fin.open(PATH);
			if(!fin){
			  	std::cout << "\n File non presente INTEREST!\n";
			   	fin.close();
			}
			else
			{
				fileAperti++;
				std::getline(fin, line);
				if (line.compare("client") == 0)
				{
					client = true;
					fileApertiCLIENT++;
				}
				else if (line.compare("producer") == 0)
				{
					repo = true;
					fileApertiREPO++;
				}
				else if (line.compare("core") == 0)
				{
					core = true;
					fileApertiCORE++;
				}
				else
				{
					std::cout << "Errore nella determinazione del tipo di nodo!";
					exit(0);
				}

				while(std::getline(fin, line))
				{
					boost::char_separator<char> sep("\t");
				    boost::tokenizer<boost::char_separator<char> > tokens(line, sep);
				    boost::tokenizer<boost::char_separator<char> >::iterator it = tokens.begin();

				    // Eliminazione del transitorio
				    std::string strTrans = (*it);
				    const char* valueTrans = strTrans.c_str();
				    long double checkTrans = (long double) std::atol(valueTrans);
				    uint32_t slot = floor(checkTrans/timeSlot);

				    if(slot <= slotMax)
				    {
				    	++it;  // Verifico se si tratta di Rx o Tx
				        std::string eventType = (*it);
				        if(eventType.compare("Tx") == 0)
				        {
				        	parametriMisurati[8][k-1][slot]++;   // INTEREST INVIATI

				        	if (client)
			        		{
			        			parametriMisurati[9][k-1][slot]++;   // INTEREST INVIATI CLIENT
			        		}
			        		else if (core || repo)  // supponendo che i repo facciano parte della core network
			        		{
			        			parametriMisurati[10][k-1][slot]++;   // INTEREST INVIATI CORE
			        		}
				        }
				        else if(eventType.compare("Rx") == 0)
				        {
				        	parametriMisurati[12][k-1][slot]++;   // INTEREST RICEVUTI

				        	if (client)
			        		{
			        			parametriMisurati[13][k-1][slot]++;   // INTEREST RICEVUTI CLIENT
			        		}
			        		else if (core)
			        		{
			        			parametriMisurati[14][k-1][slot]++;   // INTEREST RICEVUTI CORE
			        		}
			        		else
			        		{
			        			parametriMisurati[15][k-1][slot]++;   // INTEREST RICEVUTI REPO
			        		}

				        }
				        else if(eventType.compare("Aggr") == 0)
				        {
				        	parametriMisurati[16][k-1][slot]++;   // INTEREST AGGREGATI
				        }
				    }
				    else
				        break;
				}
				fin.close();
			}

			client = false;
			repo = false;
			core = false;
		}

		for(uint32_t i = 0; i < numSlot; i++)
		{
			parametriMisurati[8][k-1][i] /= (long double)(fileAperti);          // Interest INVIATI
			parametriMisurati[9][k-1][i] /= (long double)(fileApertiCLIENT);    // Interest INVIATI CLIENT
			parametriMisurati[10][k-1][i] /= (long double)(fileApertiCORE);     // Interest INVIATI CORE

			parametriMisurati[12][k-1][i] /= (long double)(fileAperti);         // Interest RICEVUTI
			parametriMisurati[13][k-1][i] /= (long double)(fileApertiCLIENT);   // Interest RICEVUTI CLIENT
			parametriMisurati[14][k-1][i] /= (long double)(fileApertiCORE);     // Interest RICEVUTI CORE
			parametriMisurati[15][k-1][i] /= (long double)(fileApertiREPO);     // Interest RICEVUTI REPO

			parametriMisurati[16][k-1][i] /= (long double)(fileApertiCORE + fileApertiREPO);     // Interest AGGREGATI
		}

		fileAperti = 0;
		fileApertiCLIENT = 0;
		fileApertiCORE = 0;
		fileApertiREPO = 0;


		// ***********************************************************************************************************************
		// ******  INTEREST APP ******  (Inviati, Ritrasmessi, Eliminati, Eliminati File)

		for(uint32_t z=1; z <= numeroNodi; z++)
		{
			ss << stringheInput->operator [](3) << z << "." << inputSuffix << k ;
			PATH = ss.str().c_str();
			ss.str("");
			fin.open(PATH);
			if(!fin){
			  	std::cout << "\n File non presente INTEREST APP!\n";
			   	fin.close();
			}
			else
			{
				fileAperti++;
				std::getline(fin, line);
				if (line.compare("client") == 0)
				{
					client = true;
				}
				else
				{
					std::cout << "Tracing a livello applicativo (INTEREST APP) solo presente nei client!";
					exit(0);
				}

				while(std::getline(fin, line))
				{
					boost::char_separator<char> sep("\t");
				    boost::tokenizer<boost::char_separator<char> > tokens(line, sep);
				    boost::tokenizer<boost::char_separator<char> >::iterator it = tokens.begin();

				    // Eliminazione del transitorio
				    std::string strTrans = (*it);
				    const char* valueTrans = strTrans.c_str();
				    long double checkTrans = (long double) std::atol(valueTrans);
				    uint32_t slot = floor(checkTrans/timeSlot);

				    if(slot <= slotMax)
				    {
				    	++it;  // Verifico il tipo di evento
				        std::string eventType = (*it);
				        if(eventType.compare("Tx") == 0)
				        {
				        	parametriMisurati[11][k-1][slot]++;   // INTEREST INVIATI APP
				        }
				        else if(eventType.compare("El") == 0)
				        {
				        	// Si prende l'istante di invio dell'Interest
				        	++it;
					  		++it;
					  		std::string strTrans1 = (*it);
					  		const char* valueTrans1 = strTrans1.c_str();
					  		long double checkTrans1 = (long double) std::atol(valueTrans1);
				        	uint32_t slot1 = floor(checkTrans1/timeSlot);

				        	parametriMisurati[17][k-1][slot1]++;   // INTEREST ELIMINATI
				        }
				        else if(eventType.compare("ElFile") == 0)
				        {
				        	// Si prende l'istante di invio dell'Interest
				        	++it;
					  		++it;
					  		std::string strTrans1 = (*it);
					  		const char* valueTrans1 = strTrans1.c_str();
					  		long double checkTrans1 = (long double) std::atol(valueTrans1);
				        	uint32_t slot1 = floor(checkTrans1/timeSlot);

				        	parametriMisurati[18][k-1][slot1]++;   // INTEREST ELIMINATI FILE
				        }
				        else if(eventType.compare("Rtx") == 0)
				        {
				        	parametriMisurati[19][k-1][slot]++;   // INTEREST RITRASMESSI
				        }
				    }
				    else
				    	break;
				}
				fin.close();
			}

			client = false;
		}

		for(uint32_t i = 0; i < numSlot; i++)
		{
			parametriMisurati[11][k-1][i] /= (long double)(fileAperti);          // Interest INVIATI APP
			parametriMisurati[17][k-1][i] /= (long double)(fileAperti);          // Interest ELIMINATI
			parametriMisurati[18][k-1][i] /= (long double)(fileAperti);          // Interest ELIMINATI FILE
			parametriMisurati[19][k-1][i] /= (long double)(fileAperti);          // Interest ELIMINATI
		}

		fileAperti = 0;



		// ******************************************************************************************************************************************************
		// ***** DOWNLOAD *****

		for(uint32_t z=1; z <= numeroNodi; z++)
		{
			ss << stringheInput->operator [](4) << z << "." << inputSuffix << k ;
			PATH = ss.str().c_str();
			ss.str("");
			fin.open(PATH);
			if(!fin){
			  	std::cout << "\n File non presente DOWNLOAD!\n";
			   	fin.close();
			}
			else
			{
				fileAperti++;
				std::getline(fin, line);
				if (line.compare("client") == 0)
				{
					client = true;
				}
				else
				{
					std::cout << "Tracing a livello applicativo (INTEREST APP) solo presente nei client!";
					exit(0);
				}

				while(std::getline(fin, line))
				{
					boost::char_separator<char> sep("\t");
					boost::tokenizer<boost::char_separator<char> > tokens(line, sep);
			        boost::tokenizer<boost::char_separator<char> >::iterator it = tokens.begin();
			        // Eliminazione del transitorio
		        	++it;
		        	++it;
		        	++it; // Vado a posizionarmi in corrispondenza del tempo di invio

		        	std::string strTrans = (*it);
			        const char* valueTrans = strTrans.c_str();
			        long double checkTrans = (long double) std::atol(valueTrans);
			        uint32_t slot = floor(checkTrans/timeSlot);

			        if(slot <= slotMax)
			        {
					it = tokens.begin();
					++it;  // Verifico se si tratta di First o File
				        std::string eventType = (*it);
				        if(eventType.compare("File") == 0)
				        {
				        	++it;
				        	++it;
				        	++it;		// Mi posiziono in corrispondenza del tempo di download
			        		std::string stri = (*it);
			        		const char* value = stri.c_str();
			        		long double downloadTimeFile = (long double) std::atol(value);
			        		if(downloadTimeFile > 0)      // Vuol dire che l'Interest non è stato soddisfatto localmente.
			        		{
			        			parametriMisurati[23][k-1][slot] += downloadTimeFile;

			        			++it;    // Mi posiziono in corrispondenza della distanza media di recupero del file
			        			std::string striDist = (*it);
			        			const char* valueDist = striDist.c_str();
			        			long double checkDist = (long double) (std::atoi(valueDist)-1);      // Viene tolto 1 perchè l'HC viene incrementato sia dalle net-face che dalle app-face
			        			parametriMisurati[20][k-1][slot] +=checkDist;

			        			ValoriInseritiFile_sl->operator [](slot)++;
			        		}
			        		else
			        		{
			        			parametriMisurati[24][k-1][slot]++;
			        		}
				        }
				        else if (eventType.compare("First") == 0)
				        {
				        	++it;
				        	++it;
				        	++it;		// Mi posiziono in corrispondenza del tempo di download
			        		std::string stri = (*it);
			        		const char* value = stri.c_str();
			        		long double downloadTimeFirst = (long double) std::atol(value);
			        		if(downloadTimeFirst > 0)      // Vuol dire che l'Interest non è stato soddisfatto localmente.
			        		{
			        			parametriMisurati[25][k-1][slot] += downloadTimeFirst;

			        			++it;    // Mi posiziono in corrispondenza della distanza media di recupero del file
			        			std::string striDist = (*it);
			        			const char* valueDist = striDist.c_str();
			        			long double checkDist = (long double) (std::atoi(valueDist)-1);      // Viene tolto 1 perchè l'HC viene incrementato sia dalle net-face che dalle app-face
			        			parametriMisurati[21][k-1][slot] +=checkDist;

			        			ValoriInseritiFirst_sl->operator [](slot)++;
			        		}
			        		else
			        		{
			        			parametriMisurati[26][k-1][slot]++;
			        		}

				        }
			        }
			        else
						break;
				}
				fin.close();
			}
			client = false;
		}

		for(uint32_t i = 0; i < numSlot; i++)
		{
			parametriMisurati[23][k-1][i] /= (long double)(ValoriInseritiFile_sl->operator [](i));    // DOWNLOAD TIME FILE
			parametriMisurati[24][k-1][i] /= (long double)(fileAperti);						          // NUMERO FILE SCARICATI IN LOCALE
			parametriMisurati[25][k-1][i] /= (long double)(ValoriInseritiFirst_sl->operator [](i));   // SEEK TIME
			parametriMisurati[26][k-1][i] /= (long double)(fileAperti);								  // NUMERO PRIMI CHUNK SCARICATI IN LOCALE

			parametriMisurati[20][k-1][i] /= (long double)(ValoriInseritiFile_sl->operator [](i));	  // DISTANCE FILE
			parametriMisurati[21][k-1][i] /= (long double)(ValoriInseritiFirst_sl->operator [](i));   // DISTANCE FIRST
		}

		fileAperti = 0;
		for(uint32_t i = 0; i < numSlot; i++)
		{
			ValoriInseritiFile_sl->operator [](i) = 0;
			ValoriInseritiFirst_sl->operator [](i) = 0;
		}

	}


   	// *****************************************************************************************
   	// ***** CALCOLO DELLA HIT RATIO COME PARAMETRO DERIVATO *****

   	for(uint32_t t = 0; t < slotMax; t++)
   	{
   		for(uint32_t j = 0; j < numero_sim; j++)
   		{
   			parametriMisurati[22][j][t] = (long double)((dataInviatiCACHE[j][t])/(parametriMisurati[12][j][t]));   // Hit Ratio
		}
	}

   	// **** SCRITTURA SU FILE DEI RISULTATI *****
    for(uint32_t z = 0; z < num_par_mis; z++)
    {
    	ss << stringheOutput->operator [](z) << outputSuffix;
        PATH = ss.str().c_str();
        ss.str("");
        fout.open(PATH);
        if(!fout)
        {
        	std::cout << "\n Impossibile Aprire il File";
        	exit(1);
        }
        else
        {
        	for(uint32_t t = 0; t < slotMax; t++)
        	{
        		for(uint32_t j = 0; j < numero_sim; j++)
				{
        			if (j == numero_sim-1)
						fout << parametriMisurati[z][j][t] << "\n";
					else
						fout << parametriMisurati[z][j][t] << "\t";
				}
        	}
        }
        fout.close();
    }

}

