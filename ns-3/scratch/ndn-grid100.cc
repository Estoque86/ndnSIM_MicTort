/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2011-2012 University of California, Los Angeles
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author: Alexander Afanasyev <alexander.afanasyev@ucla.edu>
 */

// ndn-grid100.cc

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/ndnSIM-module.h"
#include "ns3/names.h"
#include "ns3/ndnSIM/utils/ndn-fw-hop-count-tag.h"

using namespace ns3;
using namespace ndn;
/**
 * This scenario simulates a Grid network of 100 nodes
 *
 *
 * To run scenario and see what is happening, use the following command:
 *
 *     ./waf --run=ndn-grid100
 */


void HitTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Interest> interest, std::string nodeId);
void InterestTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Interest> interest, std::string nodeId, std::string event);
void DataTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Data> data, std::string nodeId, std::string event);

int
main (int argc, char *argv[9])
{
	uint64_t catalogCardinality = 0;          // Estimated Content Catalog Cardinality.
	double cacheToCatalogRatio = 0.01;        // Cache to Catalog Ratio per each node.
	uint32_t lambda = 1;                      // Request rate per each client.
	double alpha = 1;						  // Zipf's Exponent
	double plateau = 0;                       // q parameter for the ZipfMandelbrot distribution
	std::string simType = "";                 // Simulation Type Description
	uint32_t simDuration = 100;
	uint32_t numReqTot = 10000;		  // Total number of requests inside the simulation.

    CommandLine cmd;
    cmd.AddValue ("catalogCardinality", "Estimated Content Catalog Cardinality.", catalogCardinality);
    cmd.AddValue ("cacheToCatalogRatio", "Cache to Catalog Ratio per each node.", cacheToCatalogRatio);
    cmd.AddValue ("lambda", "Request rate per each client.", lambda);
    cmd.AddValue ("alpha", "Zipf's Exponent", alpha);
    cmd.AddValue ("plateau", "q parameter for the ZipfMandelbrot distribution", plateau);
    cmd.AddValue ("simType", "Simulation Type Description", simType);
    cmd.AddValue ("simDuration", "Length of the simulation, in seconds.", simDuration);
    cmd.AddValue ("numReqTot", "Total number of requests during the simulation", numReqTot);

    cmd.Parse (argc, argv);

    std::string catalogCardinalityStr, lambdaStr, alphaStr, plateauStr,reqStr;
    std::stringstream ss;
    ss << catalogCardinality;
    catalogCardinalityStr = ss.str();
    ss.str("");
    ss << lambda;
    lambdaStr = ss.str();
    ss.str("");
    ss << alpha;
    alphaStr = ss.str();
    ss.str("");
    ss << plateau;
    plateauStr = ss.str();
    ss.str("");
    ss << numReqTot;
    reqStr = ss.str();
    ss.str("");


    // **********   Getting the simulation run   **********
    uint64_t simRun = SeedManager::GetRun();
    uint64_t simRunOut = simRun - 1;
    std::string simRunStr;
    ss << simRun;
    simRunStr = ss.str();
    ss.str("");

    //NS_LOG_UNCOND("M=" << catalogCardinality << "\nC=" << cacheToCatalogRatio << "\nL=" << lambda
   // 		<< "\nT=" << simType << "\nA=" << alpha << "\nR=" << simRun);


    // **********   Calculate the Cache Size per each cache   ***********
    uint32_t cacheSize = round((double)catalogCardinality * cacheToCatalogRatio);
    ss << cacheSize;
    std::string cacheSizeStr = ss.str();
    ss.str("");


    // **********   Reading the topology   ***********
    AnnotatedTopologyReader topologyReader ("", 1);
    topologyReader.SetFileName ("src/ndnSIM/examples/topologies/topo-grid-100.txt");
    topologyReader.Read ();
    uint32_t numNodes = topologyReader.GetNodes().GetN();


    // Select a random Repo
    UniformVariable m_RngRepo (0, numNodes-1);
    uint32_t repoId = (uint32_t)round(m_RngRepo.GetValue());
    Ptr<Node> producer = topologyReader.GetNodes().Get(repoId);
    NodeContainer producers;
    producers.Add(producer);
    
    // Select 30 random Consumers
    uint32_t numConsumers = 30;
    UniformVariable m_RngConsumers (0, numNodes-1);;

    bool completeConsumers = false;
    uint32_t extractedConsumers = 0;
    uint32_t randConsumer = 0;

    std::vector<uint32_t>* consumersID = new std::vector<uint32_t>(numConsumers) ;
    for(uint32_t i=0; i<consumersID->size(); i++)
    {
  	  consumersID->operator[](i) = numNodes+1;
    }

    while(!completeConsumers)
    {
  	  bool already_extracted = false;
  	  while(!already_extracted)
  	  {

  		  randConsumer = (uint32_t)round(m_RngConsumers.GetValue());
  		  for(uint32_t i=0; i<consumersID->size(); i++)
  		  {
  			  if(consumersID->operator[](i)==randConsumer)
  			  {
  				already_extracted = true;
  				break;
  			  }
  		  }
  		  if(already_extracted==true)
  			already_extracted = false;        // It keeps going
  		  else {
  			  if (randConsumer==repoId)
  				  already_extracted = false;
  			  else
  				  already_extracted = true;
  		  }
  	  }
  	  consumersID->operator[](extractedConsumers) = randConsumer;
  	  NS_LOG_UNCOND("CHOSEN CONSUMER:\t" << consumersID->operator[](extractedConsumers));
  	  extractedConsumers = extractedConsumers + 1;
  	  if(extractedConsumers == consumersID->size())
  		completeConsumers = true;
    }

    NodeContainer consumers;
    for(uint32_t i=0; i<consumersID->size(); i++)
    {
    	Ptr<Node> nd = topologyReader.GetNodes().Get(consumersID->operator[](i));
    	consumers.Add(nd);
    }
    
    // Mark the remaining caches
    NodeContainer caches;
    bool already_marked;
    for(uint32_t i=0; i<numNodes; i++)
    {
    	already_marked = false;
    	for(uint32_t j=0; j<consumersID->size(); j++)
    	{
    		if(consumersID->operator[](j)==i)
    		{
    			already_marked = true;
    			break;
    		}
    	}
    	if(!already_marked)
    	{
    		if(i!=repoId)
    		{
    			Ptr<Node> cNd = topologyReader.GetNodes().Get(i);
    			caches.Add(cNd);
    		}
    	}
    } 
    
    // ***********   Install CCNx stack on all nodes   **********
    ndn::StackHelper ndnHelper;
    ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::BestRoute");
    ndnHelper.SetContentStore ( "ns3::ndn::cs::Probability::Lru", "MaxSize", cacheSizeStr, "CacheProbability", "0.02"); // default ContentStore parameters
    //ndnHelper.InstallAll();
    ndnHelper.Install (caches);
    
    for(uint32_t i=0; i<caches.GetN(); i++)
    {
    	uint32_t id = caches.Get(i)->GetId();
    	NS_LOG_UNCOND("CACHE:\t" << id);
    }

    for(uint32_t i=0; i<consumers.GetN(); i++)
    {
        	uint32_t id = consumers.Get(i)->GetId();
        	NS_LOG_UNCOND("CONSUMER:\t" << id);
    }

    for(uint32_t i=0; i<producers.GetN(); i++)
        {
        	uint32_t id = producers.Get(i)->GetId();
        	NS_LOG_UNCOND("PRODUCER:\t" << id);
        }

    ndnHelper.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "0"); // Consumer and Producer do not cache anything
    ndnHelper.Install (consumers);
    ndnHelper.Install (producers);
    
    // **********   Installing global routing interface on all nodes   **********
    ndn::GlobalRoutingHelper ccnxGlobalRoutingHelper;
    ccnxGlobalRoutingHelper.InstallAll ();
    
    // **********   Installing Application Layer   *********
    ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerZipfMandelbrot");
    consumerHelper.SetPrefix ("/root");
    consumerHelper.SetAttribute ("Frequency", StringValue (lambdaStr)); // lambda Interest per second
    consumerHelper.SetAttribute ("NumberOfContents", StringValue (catalogCardinalityStr));
    consumerHelper.SetAttribute ("Randomize", StringValue ("exponential"));
    consumerHelper.SetAttribute ("q", StringValue (plateauStr)); // q paremeter
    consumerHelper.SetAttribute ("s", StringValue (alphaStr)); // Zipf's exponent
    
    ApplicationContainer app = consumerHelper.Install(consumers);
    app.Start (Seconds (0.0));
    
    ndn::AppHelper producerHelper ("ns3::ndn::Producer");
    producerHelper.SetAttribute ("PayloadSize", StringValue("1024"));
    
    // **********   Register /root prefix with global routing controller and   **********
    // 				install producer that will satisfy Interests in /root namespace
    ccnxGlobalRoutingHelper.AddOrigins ("/root", producer);
    producerHelper.SetPrefix ("/root");
    producerHelper.Install (producer);
    
    // **********   Calculate and install FIBs   **********
    ccnxGlobalRoutingHelper.CalculateRoutes ();

    // **********   TRACING   ***********

    std::string aggrTraceStr, csTraceStr, appTraceStr;
    ss << "logs/SIM=NDNSIM" << "_T=" << simType << "_REQ=" << numReqTot << "_M="<< catalogCardinality << "_R=" << simRunOut << "aggregateTrace.txt";
    aggrTraceStr = ss.str();
    ss.str("");

    ss << "logs/SIM=NDNSIM" << "_T=" << simType << "_REQ=" << numReqTot << "_M="<< catalogCardinality << "_R=" << simRunOut << "csTrace.txt";
    csTraceStr = ss.str();
    ss.str("");

    ss << "logs/SIM=NDNSIM" << "_T=" << simType << "_REQ=" << numReqTot << "_M="<< catalogCardinality << "_R=" << simRunOut << "appTrace.txt";
    appTraceStr = ss.str();
    ss.str("");
    
    ndn::L3AggregateTracer::InstallAll(aggrTraceStr, Seconds(0.5));
    ndn::CsTracer::InstallAll(csTraceStr, Seconds(1));
    ndn::AppDelayTracer::InstallAll(appTraceStr);


    Simulator::Stop (Seconds (simDuration));
    
    //ndn::CsTracer::Install (cachingNodes, "cs-trace-single-cache-NEW.txt", Seconds (1));
    //ndn::CsTracer::InstallAll("cs-trace-single-cache-NEW.txt", Seconds (1));
    
    Simulator::Run ();
    Simulator::Destroy ();
    
    return 0;
}


void HitTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Interest> interest, std::string nodeId)
{
	//NS_LOG_UNCOND("Chiamata a Funzione di Trace!");
	FwHopCountTag hopCountTag;
	uint32_t distance = 10000;
	if (interest->GetPayload ()->PeekPacketTag (hopCountTag))
	{
	   distance = hopCountTag.Get();
	}

	*stream->GetStream() << Simulator::Now().GetMilliSeconds() << "\t" <<  nodeId << "\t" << "Hit_Event\t" << interest->GetName ().get (-1).toSeqNum () << "\t" << distance << std::endl;
}

void InterestTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Interest> interest, std::string nodeId, std::string event)
{
	//NS_LOG_UNCOND("Chiamata a Funzione di Trace!");
	*stream->GetStream() << Simulator::Now().GetMilliSeconds() << "\t" <<  nodeId << "\t" << event  << "\t" << interest->GetName ().get (-1).toSeqNum () << std::endl;
}

void DataTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Data> data, std::string nodeId, std::string event)
{
	//NS_LOG_UNCOND("Chiamata a Funzione di Trace!");
	*stream->GetStream() << Simulator::Now().GetMilliSeconds() << "\t" <<  nodeId << "\t" << event  << "\t" << data->GetName ().get (-1).toSeqNum () << std::endl;
}


