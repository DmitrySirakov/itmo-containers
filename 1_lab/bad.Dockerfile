# использую latest как идиот 
FROM jupyterhub/jupyterhub:latest

# много слоев, большой образ, всё из-под рута 
RUN apt-get update
RUN apt-get install -y python3-dev
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y nano
RUN pip install pandas
RUN pip install numpy
RUN pip install yfinance
RUN pip install ta-lib

# без обозначения expose 
WORKDIR /jupyter

ENTRYPOINT jupyterhub --log-level=DEBUG
