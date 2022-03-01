# draft-jennings-game-state-over-rtp
Sending game state over RTP 

# building the draft 

```
docker run --rm --user=$(id -u):$(id -g) -v $(pwd):/rfc -v $HOME/.cache/xml2rfc:/var/cache/xml2rfc -w /rfc gse_rfctools make 
```

