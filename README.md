docker run --rm -itd -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl -c config.json

~/Downloads/maputnik --watch --file styles/basic.json