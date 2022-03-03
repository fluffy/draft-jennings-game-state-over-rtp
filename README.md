# draft-jennings-game-state-over-rtp
Sending game state over RTP 

# building the draft 

First build the Docker container using the following command.

```
docker build -t gse_rfctools .
```

Once done, use the following to build the draft.

```
docker run --rm --user=$(id -u):$(id -g) -v $(pwd):/rfc -v $HOME/.cache/xml2rfc:/var/cache/xml2rfc -w /rfc gse_rfctools make 
```

