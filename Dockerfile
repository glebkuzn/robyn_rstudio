FROM ubuntu:focal
ENV TZ=UTC
# установить питон и R
RUN apt update \
&& apt -y install dirmngr gnupg apt-transport-https ca-certificates software-properties-common \
&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
&& add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' \
&& apt update \
&& apt -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 \
    libasound2 libxi6 libxtst6 wget python3 python3-dev python3-pip python3-venv libcurl4-openssl-dev \
    libv8-dev r-base gdebi-core curl
## установить r-server
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.1-372-amd64.deb \
&& gdebi --n rstudio-server-2021.09.1-372-amd64.deb \
&& rm rstudio-server-*-amd64.deb
## создать рабочее пространство
WORKDIR /home/rstudio
ENV HOME=/home/rstudio
## установить nevergrad и Robyn
RUN pip install nevergrad
COPY install_packages.R .
RUN Rscript install_packages.R \
&& Rscript / \
# копирование файлов и создание учетки
COPY . .
RUN mkdir "out_data"
RUN useradd rstudio \
&& chown -R rstudio $HOME \
&& echo "rstudio:rstudio" | chpasswd
