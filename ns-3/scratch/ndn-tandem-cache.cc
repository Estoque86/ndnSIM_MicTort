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

// ndn-tree-cs-tracers.cc

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/ndnSIM-module.h"
#include "ns3/names.h"
#include "ns3/ndnSIM/utils/ndn-fw-hop-count-tag.h"

using namespace ns3;
using namespace ndn;
/**
 * This scenario simulates a tandem cache
 *
 *     /--------\      /--------\	   /--------\
 *     |consumer| <--> |  cache | <--> |producer|
 *     |    +   |      \--------/	   \--------/
 *     |  cache |
 *     \--------/
 *
 * To run scenario and see what is happening, use the following command:
 *
 *     ./waf --run=ndn-tandem-cache
 */


void HitTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Interest> interest, std::string nodeId);


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

    // **********   Composition of the scenario string   ***********
    std::string scenarioString;
    ss << "logs/SIM=NDNSIM" << "_T=" << simType << "_REQ=" << numReqTot << "_M="<< catalogCardinality << "_C=" << cacheToCatalogRatio << "_L=" << lambda << "_A=" << alpha << "_R=" << simRunOut << ".out";
    scenarioString = ss.str();
    ss.str("");

    // **********   Reading the topology   ***********
    AnnotatedTopologyReader topologyReader ("", 1);
    topologyReader.SetFileName ("src/ndnSIM/examples/topologies/tandem-cache.txt");
    topologyReader.Read ();
    
    Ptr<Node> consumer = Names::Find<Node> ("consumer");
    Ptr<Node> cache = Names::Find<Node> ("cache");
    Ptr<Node> producer = Names::Find<Node> ("producer");
    
    NodeContainer nonCachingNodes, cachingNodes;  // The cache size of the producer is supposed to be zero,
    											  // in order to simulate the presence of only a repository
    											  // where permanent copies are stored
    
    nonCachingNodes.Add(producer);
    cachingNodes.Add(consumer);
    cachingNodes.Add(cache);
    
    // ***********   Install CCNx stack on all nodes   **********
    ndn::StackHelper ndnHelper;
    ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::BestRoute");
    ndnHelper.SetContentStore ( "ns3::ndn::cs::Lru", "MaxSize", cacheSizeStr); // default ContentStore parameters
    //ndnHelper.InstallAll();
    ndnHelper.Install (cachingNodes);
    
    ndnHelper.SetContentStore ("ns3::ndn::cs::Lru", "MaxSize", "0"); // Consumer and Producer do not cache anything
    ndnHelper.Install (nonCachingNodes);
    
    // **********   Installing global routing interface on all nodes   **********
    ndn::GlobalRoutingHelper ccnxGlobalRoutingHelper;
    ccnxGlobalRoutingHelper.InstallAll ();
    
    // **********   Installing Application Layer   *********
    ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerZipfMandelbrot");
    consumerHelper.SetPrefix ("/root");
    consumerHelper.SetAttribute ("Frequency", StringValue (lambdaStr)); // lambda Interest per second
    consumerHelper.SetAttribute ("NumberOfContents", StringValue (catalogCardinalityStr));
    consumerHelper.SetAttribute ("Randomize", StringValue ("none"));
    consumerHelper.SetAttribute ("q", StringValue (plateauStr)); // q paremeter
    consumerHelper.SetAttribute ("s", StringValue (alphaStr)); // Zipf's exponent
    
    ApplicationContainer app = consumerHelper.Install (consumer);
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

    std::string ext = ".out";
    
    std::string hitTracingPath;   // HIT Tracing
    //ss << "tracing/" << simType << "/Hit/" << scenarioString << ext;
    //hitTracingPath = ss.str();
    hitTracingPath = scenarioString;
    const char* hitTracingPathChar = hitTracingPath.c_str();
    ss.str("");
    
    AsciiTraceHelper asciiTraceHelper;
	// **********   OUTPUT STREAM   ***************
    Ptr<OutputStreamWrapper> streamHit = asciiTraceHelper.CreateFileStream(hitTracingPathChar);

    //*streamHit->GetStream() << "Time\tNode\tEvent\tContentID\t#Hops" << std::endl;

    for (NodeList::Iterator node = NodeList::Begin (); node != NodeList::End (); node ++)
    {
   	  // **********   Association to the function that threats the event   **********
  	  (*node)->GetObject<ForwardingStrategy>()->TraceConnectWithoutContext("Hit", MakeBoundCallback(&HitTrace, streamHit));
    }

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
