# MY EPIC PERSONAL HOSTS LISTS!!!!!

Just a way for me to make internet a better place, even if it means blindly firing sometimes. Very, *very* opinionated hosts list.

They should be compatible with AdGuard Home.

## AllowLists.hosts

Unblocks essential domains for my home network.

- Google FCM domains (so notifications work for Android users)
- Epic Games Store tracking domain so Android EGS works
- quad9, dns.sb, joindns4.eu so HTTPS DNS can resolve for those domains
- `duckdns.org` so DDNS works and doesn't get blocked
- `izatcloud.net` is for Qualcomm Android-powered devices, that's the domain they will hit up to obtain A-GPS data, helping with device location.

## GarbageFilter.hosts

You know how we call an complex math formula an "AI" nowadays? Well, some idiots decided to use this piece of shit LLM technology to spam the web.

This also blocks other types of sites such as:

- Common LLM-generated websites based on my own criteria.
- Advice given is so good that it could cause total system or even organ failure. (meaning the advice is ill-advised, or downright shit and shouldn't be followed)
- Hidden advertisements for an repair service (or just any service really.)
- Sites that could be potentially malicious vectors are also blocked ex. softonic, 3p driver download software, DLL download sites (I mean come on guys, DLL files are just binaries... why risk it.) 

## PersonalBlocklist.hosts

Ripped out straight from my AdGuard Home instance and cleaned up a bit.

- Blocks all tracking & ad domains for LDPlayer9, Bluestacks, Nox (it will break those sites so install then add those domains yourself if you want to Custom Filters
- A lot of Microsoft tracking, reward, pointless AI crap and other blocklist. It may break some tools so best used if you don't rely on any 365 functionality. Speeds up MS Edge open up time by a tremendous amount.
- Every Nintendo domain is blocked, this is mostly for homebrew and ease of mind.
- Nonexistent local domains are rewritten to respond with NXDOMAIN, use-application-dns.net is rewritten to use NXDOMAIN (disables DoH in browsers so everything goes through your AGH instance
- Misc filters that are just random ass sites or things I've sniffed out that I couldn't figure out exact purpose for but blocking them doesn't cause much. Some blocks here are intended though, like yahoo blocks.
