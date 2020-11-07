# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    2.6.6
* Dependencies
    bundle

# API V1 -> Example how to use Google and Bing Search Engines

## Development Environment Setup

### On localhost

For instructions on running Yello Enterprise via Docker, see [DOCKER.md](DOCKER.md)

1. Create a folder for the app and clone the repo: `mkdir -p ~/apps && cd ~/apps && git clone https://github.com/pollcaz/search_engine.git`

2. Go into the directory : `cd ~/apps/search_engine`

3. Install the gems `bundle install`

4. Rename search_engines_settings.yml.example to: `config/search_engines_settings.yml`

5. Edit and put your owns credentials for each Search Engine into search_engines_settings.yml

6. Start the server `rails s`

7. Open a window in your browser `http://localhost:3000/api-docs` to see the Api documentation.