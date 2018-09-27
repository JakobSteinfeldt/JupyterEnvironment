# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/minimal-notebook

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"
USER root

# ffmpeg for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'conda-forge::blas=*=openblas' \
    'ipywidgets=7.2*' \
    'pandas=0.23*' \
    'numexpr=2.6*' \
    'matplotlib=2.2*' \
    'scipy=1.1*' \
    'seaborn=0.8*' \
    'scikit-learn=0.19*' \
    'scikit-image=0.14*' \
    'sympy=1.1*' \
    'cython=0.28*' \
    'patsy=0.5*' \
    'statsmodels=0.9*' \
    'cloudpickle=0.5*' \
    'dill=0.2*' \
    'numba=0.38*' \
    'bokeh=0.12*' \
    'sqlalchemy=1.2*' \
    'hdf5=1.10*' \
    'h5py=2.7*' \
    'vincent=0.4.*' \
    'beautifulsoup4=4.6.*' \
    'protobuf=3.*' \
    'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^0.35 && \
    jupyter labextension install jupyterlab_bokeh@^0.5.0 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install facets which does not have a pip or conda package at the moment
RUN cd /tmp && \
    git clone https://github.com/PAIR-code/facets.git && \
    cd facets && \
    jupyter nbextension install facets-dist/ --sys-prefix && \
    cd && \
    rm -rf /tmp/facets && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda config --add channels conda-forge && \
    conda config --add channels blaze && \
    conda config --add channels rdonnellyr && \
    conda config --add channels bioconda 

RUN conda install --quiet --yes \
    'rpy2=2.8*' \
    'r-base=3.4.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.1*' \
    'r-shiny=1.0*' \
    'r-rmarkdown=1.8*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.0*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.2*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.7*' \
    'r-htmlwidgets=1.0*' \
    #'r-cowplot=0.92*' \
    'r-ggpubr=0.1.7*' \
    'r-bayesfactor=0.9.12_2*'\
    'r-gridextra=2.3*'\
    'r-hexbin=1.27*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# install nbextensions-configurator
RUN conda install --quiet --yes \
    'jupyter_nbextensions_configurator' \
    "jupyter_contrib_nbextensions" && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


USER root
# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libmysqlclient-dev && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local





#RUN Rscript 
# install python-bioformats
# Install OpenJDK-8
#RUN apt-get update && \
#    apt-get install -y openjdk-11-jdk && \
#    apt-get install -y ant && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

# Fix certificate issues
#RUN apt-get update && \
#    apt-get install ca-certificates-java && \
#    apt-get clean && \
#    update-ca-certificates -f && \
#    rm -rf /var/lib/apt/lists/*

# Setup JAVA_HOME -- useful for docker commandline
#ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
#RUN export JAVA_HOME
#RUN java -version

#RUN pip install git+https://github.com/CellProfiler/python-javabridge.git --no-cache-dir
#RUN pip install git+https://github.com/CellProfiler/python-bioformats.git

USER $NB_UID