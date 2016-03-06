# Bark Spider

A web interface for Sixty North's software process simulation tools.

## Quickstart with Vagrant

The suggested way to install (and develop) bark-spider is with
[Vagrant](https://www.vagrantup.com/). This will take care of creating an
isolated development environment with all of the necessary dependencies like
Python, Elm, and so forth.

1. If you don't already have it, first [install Vagrant] (https://www.vagrantup.com/downloads.html).

  Vagrant requires a virtual machine system, so you'll also need one of these. A
  simple, free suggestion is [VirtualBox](https://www.virtualbox.org/).

2. Switch to the directory holding this README and initialize your vagrant
   environment:

    $ vagrant up

  This might take a while the first time you run it since it has to download a
  relatively large virtual machine image. This image is cached locally, though,
  so you should only experience this inconvenience once.

3. If you have access to any extra *interventions*, you need to install those
   into your vagrant VM:

       $ vagrant ssh
       # You're now in the vagrant VM
       $ cd ~/
       $ git clone <repository of interventions>
       $ cd <repository you just cloned>
       $ sudo python3 setup.py install # or whatever
       $ exit

4. Now start up the pyramid server:

       $ vagrant ssh
       $ cd /vagrant
       $ nohup pserve development.ini --reload &
       $ exit

At this point bark-spider's pyramid server will be running on your vagrant VM on port 6543. This port is forwarded to your localhost's port 6543, so you can point a browser at localhost:6543 to run the tool.

## Quickstart without Vagrant

1. Create a virtual environment with Python 3.4:

        $ mkvirtualenv bark-spider --python=python3.4

2. Clone this Git repository:

        $ git clone git@github.com:sixty-north/bark-spider.git

3. Install the dependencies (the simulator and interventions are installed in development mode direct from GitHub):

        $ cd bark-spider/
        $ pip install -r requirements.txt

4. Start the server:

        $ pserve development.ini

5. Visit <http://0.0.0.0:6543> in your browser

6. Run rings around the competition with your new-found insight into
   software processes.


## Testing

To run the JSON API approval tests:

    python -m unittest bark_spider.tests

More tests coming soon...
