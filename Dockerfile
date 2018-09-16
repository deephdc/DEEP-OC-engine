FROM ubuntu:18.04
LABEL maintainer="Alvaro Lopez Garcia <aloga@ifca.unican.es>"
LABEL version="0.1"
LABEL description="DEEP as a Service Generic Container"

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
        python-setuptools \
        python-pip

# We could shrink the dependencies, but this is a demo container, so...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         build-essential \
         python-dev \
         python-wheel \
         python-numpy \
         python-scipy \
         python-tk

RUN pip install --upgrade https://github.com/Theano/Theano/archive/master.zip
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

WORKDIR /srv

RUN apt-get install -y nano

RUN git clone https://github.com/indigo-dc/plant-classification-theano -b package && \
    cd plant-classification-theano && \
    pip install -e . && \
    cd ..

RUN git clone https://github.com/indigo-dc/phytoplankton-classification-theano -b package  && \
    cd phytoplankton-classification-theano && \
    pip install -e . && \
    cd ..


RUN git clone https://github.com/indigo-dc/seeds-classification-theano -b package  && \
    cd seeds-classification-theano && \
    pip install -e . && \
    cd ..

# TODO(aloga): use PyPi whenever possible
RUN git clone https://github.com/indigo-dc/deepaas && \
    cd deepaas && \
    pip install -U . && \
    cd ..

#Plants

ENV SWIFT_CONTAINER https://cephrgw01.ifca.es:8080/swift/v1/Plants/
ENV THEANO_TR_WEIGHTS resnet50_6182classes_100epochs.npz
ENV THEANO_TR_JSON resnet50_6182classes_100epochs.json
ENV SYNSETS synsets_binomial.txt
ENV INFO info.txt


RUN curl -o ./plant-classification-theano/plant_classification/training_weights/${THEANO_TR_WEIGHTS} \
    ${SWIFT_CONTAINER}${THEANO_TR_WEIGHTS}

RUN curl -o ./plant-classification-theano/plant_classification/training_info/${THEANO_TR_JSON} \
    ${SWIFT_CONTAINER}${THEANO_TR_JSON}

RUN curl -o ./plant-classification-theano/data/data_splits/synsets_binomial.txt \
    ${SWIFT_CONTAINER}${SYNSETS}

#Phytoplankton

ENV SWIFT_CONTAINER_PHYTOPLANKTON https://cephrgw01.ifca.es:8080/swift/v1/plankton/
ENV THEANO_TR_WEIGHTS_PHYTOPLANKTON resnet50_53classes_30epochs.npz
ENV THEANO_TR_JSON_PHYTOPLANKTON resnet50_53classes_30epochs.json
ENV SYNSETS_PHYTOPLANKTON synsets.txt
ENV INFO_PHYTOPLANKTON info.txt


RUN curl -o ./phytoplankton-classification-theano/phytoplankton_classification/training_weights/${THEANO_TR_WEIGHTS_PHYTOPLANKTON} \
    ${SWIFT_CONTAINER_PHYTOPLANKTON}${THEANO_TR_WEIGHTS_PHYTOPLANKTON}

RUN curl -o ./phytoplankton-classification-theano/phytoplankton_classification/training_info/${THEANO_TR_JSON_PHYTOPLANKTON} \
    ${SWIFT_CONTAINER_PHYTOPLANKTON}${THEANO_TR_JSON_PHYTOPLANKTON}

RUN curl -o ./phytoplankton-classification-theano/data/data_splits/synsets.txt \
    ${SWIFT_CONTAINER_PHYTOPLANKTON}${SYNSETS_PHYTOPLANKTON}

#Seeds

ENV SWIFT_CONTAINER_SEEDS https://cephrgw01.ifca.es:8080/swift/v1/seeds/
ENV THEANO_TR_WEIGHTS_SEEDS resnet50_493classes_30epochs.npz
ENV THEANO_TR_JSON_SEEDS resnet50_493classes_30epochs.json
ENV SYNSETS_SEEDS synsets.txt
ENV INFO_SEEDS info.txt


RUN curl -o ./seeds-classification-theano/seeds_classification/training_weights/${THEANO_TR_WEIGHTS_SEEDS} \
    ${SWIFT_CONTAINER_SEEDS}${THEANO_TR_WEIGHTS_SEEDS}

RUN curl -o ./seeds-classification-theano/seeds_classification/training_info/${THEANO_TR_JSON_SEEDS} \
    ${SWIFT_CONTAINER_SEEDS}${THEANO_TR_JSON_SEEDS}

RUN curl -o ./seeds-classification-theano/data/data_splits/synsets.txt \
    ${SWIFT_CONTAINER_SEEDS}${SYNSETS_SEEDS}




EXPOSE 5000

RUN apt-get install nano
#CMD deepaas-run
