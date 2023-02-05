Akash VPN deploy

Usage
1) [Download](https://github.com/maxmaxlabs/cloudmos-deploy/releases) Cloudmos Deploy 
2) Create account and send some AKT. You can buy AKT [here](https://coinmarketcap.com/currencies/akash-network/markets)
3) Deploy deploy.yml with needed parameters and USER, USERPASS
4) Download certificate from URL from LEASES in Cloudmos and port from Forwarded Ports. 

For example:

    URI a5nqf2rn26k.ingress.d3akash.cloud
    
    Forwarded Ports 22:30504 80:31800 443:32058
    
    Download from browser a5nqf2rn26k.ingress.d3akash.cloud:31800
5) Change remote line (3rd) from certificate in format remote URI PORT, where PORT mapped port to 443, 32058 in example above
6) Import certificate to OpenVPN in Windows or Android

    Have a fun!
    Thanks to [Akash](https://github.com/akash-network) and [Dimokus!](https://github.com/Dimokus88)
