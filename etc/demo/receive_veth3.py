#!/usr/bin/env python

import sys
import struct

from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet
from scapy.all import IP, UDP, Raw
from scapy.layers.inet import _IPOption_HDR

def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        if "veth1" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find veth1 interface"
        exit(1)
    return iface

def handle_pkt(pkt):
    print "got a packet"
    pkt.show()
    hexdump(pkt)
    sys.stdout.flush()
    print "-------------------------"
    print(type(pkt[0][0]))

def main():
    iface = 'veth3'
    print "sniffing on %s" % iface
    sys.stdout.flush()
    sniff(iface = iface, filter="ether dst 02:40:00:08:00:04",
          prn = lambda x: handle_pkt(x))


if __name__ == '__main__':
    main()
