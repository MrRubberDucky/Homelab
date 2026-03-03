This runs as a log parser, not as a fully blown out daemon. Though you can tweak this behavior via envs so this can be reused as a base so ya.

It currently works somewhat like this:

```
                                                                                       
            VPS                                                                         
+--------------------------- +                                             OPNsense     
| nftables Firewall Bouncer  |                                         +---------------+
| Caddy bouncer (container)  | <---------> WireGuard Tunnel <--------> | CrowdSec LAPI |
| CrowdSec agent (container) |                                         +---------------+
+----------------------------+                                                          
                                                                                        
```
