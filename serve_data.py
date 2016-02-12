#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Offline simulator that listens on a port and spews flight records out to
# any client that connects, just like dump1090
# Usage: serve_data.py [filename]
# If no filename is supplied, uses stdin
#-------------------------------------------------------------------------------

import sys, socket, time

def main(argv):

    HOST = None
    PORT = 30001

    f = open(argv[1], 'r') if len(argv) > 1 else sys.stdin

    for res in socket.getaddrinfo(HOST, PORT, socket.AF_UNSPEC, socket.SOCK_STREAM, 0, socket.AI_PASSIVE):
        af, socktype, proto, canonname, sa = res
        try:
            s = socket.socket(af, socktype, proto)
        except socket.error as msg:
            s = None
            continue
        try:
            s.bind(sa)
            s.listen(1)
        except socket.error as msg:
            s.close()
            s = None
            continue
        break
    if s is None:
        print >> sys.stderr, 'could not open socket'
        sys.exit(1)
    print >> sys.stderr, 'Waiting for client'
    conn, addr = s.accept()
    print >> sys.stderr, 'Connected by', addr
    for line in f:
        conn.sendall(line)
        time.sleep(1)

    if f is not sys.stdin:
        f.close()
    conn.close()

#-------------------------------------------------------------------------------
if __name__ == "__main__":
    main(sys.argv)
    sys.exit(0)

