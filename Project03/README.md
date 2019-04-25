# Project03
## Introduction/Outline/Structure
My project contains 3 pages: user login page, user home page, and game page.
* Login page: user.html, user.elm
	* login
	* register
* Home page : userinfo.html, restpage.elm
	* logout
	* shows high record
	* start new game
	* resume game
* Game page: market.html, market.elm
	* fruit price
	* buy/sell
	* fruit basket
	* money
	* next day
	* save and quit
## How to
1. `cd ~/CS1XA3/`
2. `source pe/bin/activate`
3. `cd Project03/django_project/`
4. `python3 manage.py runserver localhost:10026`
5. go to [https://mac1xa3.ca/u/kanh3/project3.html](https://mac1xa3.ca/u/kanh3/project3.html)
6. 3 links are listed there. click any one to start
7. *alternative* to 5&6 : [login](https://mac1xa3.ca/e/kanh3/user.html), [home](https://mac1xa3.ca/e/kanh3/userinfo.html),[market](https://mac1xa3.ca/e/kanh3/market.html)
## Features
### client side
* buttons (11 in total)
* text field/form (4 in total)
* randomized price(combining generators)
* grid layout(rundis/elm-bootstrap package)

### server side
* get/post(only uses get to load a page, all other requests are post)
* json request(encode/decode to send/get data)
* database with OneToOne and ManyToMany relations
* get query, change and save
