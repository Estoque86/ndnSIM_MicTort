/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil -*- */
/*
 * Copyright (c) 2011 UCLA
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
 * Author: Xiaoyan Hu <x......u@gmail.com>
 *         Alexander Afanasyev <alexander.afanasyev@ucla.edu>
 */

#include "ndn-cs-tracer.h"
#include "ns3/node.h"
#include "ns3/packet.h"
#include "ns3/config.h"
#include "ns3/names.h"
#include "ns3/callback.h"

#include "ns3/ndn-app.h"
#include "ns3/ndn-interest.h"
#include "ns3/ndn-data.h"
#include "ns3/ndn-content-store.h"
#include "ns3/simulator.h"
#include "ns3/node-list.h"
#include "ns3/log.h"

#include <boost/lexical_cast.hpp>

#include <fstream>

#include "ns3/ndnSIM/utils/ndn-fw-hop-count-tag.h"

NS_LOG_COMPONENT_DEFINE ("ndn.CsTracer");

using namespace std;

namespace ns3 {
namespace ndn {

static std::list< boost::tuple< boost::shared_ptr<std::ostream>, std::list<Ptr<CsTracer> > > > g_tracers;

template<class T>
static inline void
NullDeleter (T *ptr)
{
}

void
CsTracer::Destroy ()
{
  g_tracers.clear ();
}

void
CsTracer::InstallAll (const std::string &file, Time averagingPeriod/* = Seconds (0.5)*/)
{
  using namespace boost;
  using namespace std;
  
  std::list<Ptr<CsTracer> > tracers;
  boost::shared_ptr<std::ostream> outputStream;
  if (file != "-")
    {
      boost::shared_ptr<std::ofstream> os (new std::ofstream ());
      os->open (file.c_str (), std::ios_base::out | std::ios_base::trunc);

      if (!os->is_open ())
        {
          NS_LOG_ERROR ("File " << file << " cannot be opened for writing. Tracing disabled");
          return;
        }

      outputStream = os;
    }
  else
    {
      outputStream = boost::shared_ptr<std::ostream> (&std::cout, NullDeleter<std::ostream>);
    }

  for (NodeList::Iterator node = NodeList::Begin ();
       node != NodeList::End ();
       node++)
    {
      Ptr<CsTracer> trace = Install (*node, outputStream, averagingPeriod);
      tracers.push_back (trace);
    }

  if (tracers.size () > 0)
    {
      // *m_l3RateTrace << "# "; // not necessary for R's read.table
      tracers.front ()->PrintHeader (*outputStream);
      *outputStream << "\n";
    }

  g_tracers.push_back (boost::make_tuple (outputStream, tracers));
}

void
CsTracer::Install (const NodeContainer &nodes, const std::string &file, Time averagingPeriod/* = Seconds (0.5)*/)
{
  using namespace boost;
  using namespace std;

  std::list<Ptr<CsTracer> > tracers;
  boost::shared_ptr<std::ostream> outputStream;
  if (file != "-")
    {
      boost::shared_ptr<std::ofstream> os (new std::ofstream ());
      os->open (file.c_str (), std::ios_base::out | std::ios_base::trunc);

      if (!os->is_open ())
        {
          NS_LOG_ERROR ("File " << file << " cannot be opened for writing. Tracing disabled");
          return;
        }

      outputStream = os;
    }
  else
    {
      outputStream = boost::shared_ptr<std::ostream> (&std::cout, NullDeleter<std::ostream>);
    }

  for (NodeContainer::Iterator node = nodes.Begin ();
       node != nodes.End ();
       node++)
    {
      Ptr<CsTracer> trace = Install (*node, outputStream, averagingPeriod);
      tracers.push_back (trace);
    }

  if (tracers.size () > 0)
    {
      // *m_l3RateTrace << "# "; // not necessary for R's read.table
      tracers.front ()->PrintHeader (*outputStream);
      *outputStream << "\n";
    }

  g_tracers.push_back (boost::make_tuple (outputStream, tracers));
}

void
CsTracer::Install (Ptr<Node> node, const std::string &file, Time averagingPeriod/* = Seconds (0.5)*/)
{
  using namespace boost;
  using namespace std;

  std::list<Ptr<CsTracer> > tracers;
  boost::shared_ptr<std::ostream> outputStream;
  if (file != "-")
    {
      boost::shared_ptr<std::ofstream> os (new std::ofstream ());
      os->open (file.c_str (), std::ios_base::out | std::ios_base::trunc);

      if (!os->is_open ())
        {
          NS_LOG_ERROR ("File " << file << " cannot be opened for writing. Tracing disabled");
          return;
        }

      outputStream = os;
    }
  else
    {
      outputStream = boost::shared_ptr<std::ostream> (&std::cout, NullDeleter<std::ostream>);
    }

  Ptr<CsTracer> trace = Install (node, outputStream, averagingPeriod);
  tracers.push_back (trace);

  if (tracers.size () > 0)
    {
      // *m_l3RateTrace << "# "; // not necessary for R's read.table
      tracers.front ()->PrintHeader (*outputStream);
      *outputStream << "\n";
    }

  g_tracers.push_back (boost::make_tuple (outputStream, tracers));
}


Ptr<CsTracer>
CsTracer::Install (Ptr<Node> node,
                   boost::shared_ptr<std::ostream> outputStream,
                   Time averagingPeriod/* = Seconds (0.5)*/)
{
  NS_LOG_DEBUG ("Node: " << node->GetId ());

  Ptr<CsTracer> trace = Create<CsTracer> (outputStream, node);
  trace->SetAveragingPeriod (averagingPeriod);

  return trace;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

CsTracer::CsTracer (boost::shared_ptr<std::ostream> os, Ptr<Node> node)
: m_nodePtr (node)
, m_os (os)
{
  m_node = boost::lexical_cast<string> (m_nodePtr->GetId ());

  Connect ();

  string name = Names::FindName (node);
  if (!name.empty ())
    {
      m_node = name;
    }
}

CsTracer::CsTracer (boost::shared_ptr<std::ostream> os, const std::string &node)
: m_node (node)
, m_os (os)
{
  Connect ();
}

CsTracer::~CsTracer ()
{
};


void
CsTracer::Connect ()
{
  Ptr<ContentStore> cs = m_nodePtr->GetObject<ContentStore> ();
  cs->TraceConnectWithoutContext ("CacheHits",   MakeCallback (&CsTracer::CacheHits,   this));
  cs->TraceConnectWithoutContext ("CacheMisses", MakeCallback (&CsTracer::CacheMisses, this));

  Reset ();  
}


void
CsTracer::SetAveragingPeriod (const Time &period)
{
  m_period = period;
  m_printEvent.Cancel ();
  m_printEvent = Simulator::Schedule (m_period, &CsTracer::PeriodicPrinter, this);
}

void
CsTracer::PeriodicPrinter ()
{
  Print (*m_os);
  Reset ();
  
  m_printEvent = Simulator::Schedule (m_period, &CsTracer::PeriodicPrinter, this);
}

void
CsTracer::PrintHeader (std::ostream &os) const
{
  os << "Time" << "\t"

     << "Node" << "\t"

     << "Type" << "\t"

     << "Packets" << "\t"

     << "InterestIDs" << "\t"

     << "Distances" << "\t";
}

void
CsTracer::Reset ()
{
  m_stats.Reset();
}

#define PRINTER(printName, fieldName_1, fieldType)           \
  os << time.ToDouble (Time::S) << "\t"         \
  << m_node << "\t"                             \
  << printName << "\t"                          \
  << m_stats.fieldName_1 << "\t"       \
  << PrintIntNames(fieldType) << "\t"	\
  << PrintDistances(fieldType) << "\n"	;


void
CsTracer::Print (std::ostream &os) const
{
  Time time = Simulator::Now ();

  if(m_stats.m_cacheHits!=0)
  PRINTER ("CacheHits",   m_cacheHits, "hit");
  //PRINTER ("CacheMisses", m_cacheMisses, "miss");
}

std::string
CsTracer::PrintIntNames(std::string fieldType) const
{
	std::stringstream ss;
	std::string output;
	if(fieldType.compare("hit")==0)
	{
		std::multimap<uint32_t, uint32_t>::const_iterator it = m_stats.m_intStatsHits.begin();
		for(; it != m_stats.m_intStatsHits.end(); it++)
		  	ss << (*it).first << ",";
	}
	else if(fieldType.compare("miss")==0)
	{
		std::multimap<uint32_t, uint32_t>::const_iterator it = m_stats.m_intStatsMisses.begin();
		for(; it != m_stats.m_intStatsMisses.end(); it++)
		  	ss << (*it).first << ",";
	}
	else
	{
		std::cout << "Event not Recognized! (Hit ot Miss?)" << std::endl;
		exit(1);
	}
	output = ss.str();
	return output;
}

std::string
CsTracer::PrintDistances(std::string fieldType) const
{
	std::stringstream ss;
	std::string output;
	if(fieldType.compare("hit")==0)
	{
		std::multimap<uint32_t, uint32_t>::const_iterator it = m_stats.m_intStatsHits.begin();
		for(; it != m_stats.m_intStatsHits.end(); it++)
		  	ss << (*it).second << ",";
	}
	else if(fieldType.compare("miss")==0)
	{
		std::multimap<uint32_t, uint32_t>::const_iterator it = m_stats.m_intStatsMisses.begin();
		for(; it != m_stats.m_intStatsMisses.end(); it++)
		  	ss << (*it).second << ",";
	}
	else
	{
		std::cout << "Event not Recognized! (Hit ot Miss?)" << std::endl;
		exit(1);
	}
	output = ss.str();
	return output;
}


void 
CsTracer::CacheHits (Ptr<const Interest> interest, Ptr<const Data> data)
{
  m_stats.m_cacheHits ++;
  FwHopCountTag hopCountTag;
  uint32_t distance;
  if (interest->GetPayload ()->PeekPacketTag (hopCountTag))
    {
      distance = hopCountTag.Get();
    }
  m_stats.m_intStatsHits.insert(std::pair<uint32_t,uint32_t>(interest->GetName ().get (-1).toSeqNum (),distance));
}

void 
CsTracer::CacheMisses (Ptr<const Interest> interest)
{
  m_stats.m_cacheMisses ++;
  FwHopCountTag hopCountTag;
  uint32_t distance;
  if (interest->GetPayload ()->PeekPacketTag (hopCountTag))
    {
      distance = hopCountTag.Get();
    }
  m_stats.m_intStatsMisses.insert(std::pair<uint32_t,uint32_t>(interest->GetName ().get (-1).toSeqNum (),distance));

}


} // namespace ndn
} // namespace ns3
