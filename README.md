# Kubug!
Kubug! is a Kubernetes debugging tool that allows you to use commands like tcpdump, ss, and dig from the worker node, even if the Pod does not have Linux networking tools installed or host privileged access.

## Example
if you want to know about nginx pod's NIC, you can put the command 'ip' as like

- In your bastion host or worker node
```sh
./kubebug.sh -c "ip -br addr" -p nginx
POD: nginx
Node: ip-192-168-2-135.ap-northeast-2.compute.internal
Image: nginx
coomand: crictl
Using PID: 3427
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if3         UP             192.168.2.140/32 fe80::4871:ebff:feb1:447e/64 
```

## Tcpdump
You can use tcpdump even if the Pod does not contain tcpdump itself and does not have host or privileged access.

```sh
./kubebug.sh -c "tcpdump -i any"  -p nginx
Running command: tcpdump -i any
POD: nginx
Namesapce: default
Node: ip-192-168-2-135.ap-northeast-2.compute.internal
Image: nginx
coomand: ctr
Using PID: 3427
tcpdump: data link type LINUX_SLL2
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes


16:09:33.199334 lo    In  IP localhost.33782 > localhost.webcache: Flags [S], seq 2831365897, win 65495, options [mss 65495,sackOK,TS val 2028840618 ecr 0,nop,wscale 7], length 0
16:09:33.199341 lo    In  IP localhost.webcache > localhost.33782: Flags [R.], seq 0, ack 2831365898, win 0, length 0
16:09:33.199394 lo    In  IP6 localhost6.52424 > localhost6.webcache: Flags [S], seq 3584934935, win 65476, options [mss 65476,sackOK,TS val 1693046605 ecr 0,nop,wscale 7], length 0
16:09:33.199400 lo    In  IP6 localhost6.webcache > localhost6.52424: Flags [R.], seq 0, ack 3584934936, win 0, length 0
16:10:50.331321 eth0  Out IP ip-192-168-2-140.ap-northeast-2.compute.internal.58032 > localhost.webcache: Flags [S], seq 4074257905, win 62727, options [mss 8961,sackOK,TS val 4164751622 ecr 0,nop,wscale 7], length 0
16:10:50.378807 eth0  Out IP ip-192-168-2-140.ap-northeast-2.compute.internal.50011 > ip-192-168-0-2.ap-northeast-2.compute.internal.domain: 36571+ PTR? 140.2.168.192.in-addr.arpa. (44)
16:10:50.380571 eth0  B   ARP, Request who-has ip-192-168-2-140.ap-northeast-2.compute.internal tell ip-192-168-2-135.ap-northeast-2.compute.internal, length 28
16:10:50.380582 eth0  Out ARP, Reply ip-192-168-2-140.ap-northeast-2.compute.internal is-at 4a:71:eb:b1:44:7e (oui Unknown), length 28
```