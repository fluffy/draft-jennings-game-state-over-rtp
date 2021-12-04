
# install xml2rfc with "pip install xml2rfc"
# install mmark from https://github.com/mmarkdown/mmark 
# install pandoc from https://pandoc.org/installing.html
# install lib/rr.war from https://bottlecaps.de/rr/ui or https://github.com/GuntherRademacher/rr

.PHONE: all clean lint format

all: gen/draft-jennings-game-state-over-rtp.txt 

clean:
	rm -rf gen/*

lint: gen/draft-jennings-game-state-over-rtp.xml
	rfclint gen/draft-jennings-game-state-over-rtp.xml

format:
	mkdir -p gen
	mmark -markdown draft-jennings-game-state-over-rtp..md >  gen/draft-jennings-game-state-over-rtp.md
	echo updated MD is in gen/draft-jennings-game-state-over-rtp.md

gen/draft-jennings-game-state-over-rtp.xml: draft-jennings-game-state-over-rtp.md
	mkdir -p gen
	mmark -w draft-jennings-game-state-over-rtp.md > gen/draft-jennings-game-state-over-rtp.xml

gen/draft-jennings-game-state-over-rtp.txt: gen/draft-jennings-game-state-over-rtp.xml
	xml2rfc --text --v3 gen/draft-jennings-game-state-over-rtp.xml

gen/draft-jennings-game-state-over-rtp.pdf: gen/draft-jennings-game-state-over-rtp.xml
	xml2rfc --pdf --v3 gen/draft-jennings-game-state-over-rtp.xml

gen/draft-jennings-game-state-over-rtp.html: gen/draft-jennings-game-state-over-rtp.xml
	xml2rfc --html --v3 gen/draft-jennings-game-state-over-rtp.xml

gen/game.pdf: abstract.md  game-spec.md contributors.md 
	mkdir -p gen 
	pandoc -s title.md abstract.md  game-spec.md contributors.md -o gen/game.pdf


game-gramar.html: game.ebnf
	mkdir -p gen 
	java -jar lib/rr.war -png -noinline -color:#FFFFFF -out:gen/digram.zip game.ebnf
	unzip -o gen/digram.zip
	mv index.html game-gramar.html


