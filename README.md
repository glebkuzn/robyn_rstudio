# robyn_rstudio
Docker with rstudio supports Robyn(Marketing Mix Modeling package) by Facebook Marketing Science

1. Docker build+run:

`sudo systemctl restart docker`

`docker build . -t rtest`

`docker run -p 8787:8787 -it rtest`

2. внутри контейнера запустить сервер:

`rstudio-server start`

3. В браузере открыть [http://127.0.0.1:8787/](http://127.0.0.1:8787/)

4. открыть и запустить файл `model.R`