# This project contains 2 parts:
1. A CV Webpage
2. A Simple Web App

## About The CV Webpage:
- What:
    - An **ugly-colorful** personal webpage.
    - Contains a navigation bar, a header, content, and a footer.
        - Nav bar
        - Header
        - Content
            - Left column
                - Basic infomation
                - Skills
            - Right column
                - About this page
                - Experience
                    - Education
                    - Work
                    - Other
                - Projects
        - Footer
- How it was created
    - Template
        - I use the scrolling nav bar template, and here is the [source](https://startbootstrap.com/templates/scrolling-nav/)
    - What I did
        - HTML:
            - make headings and paragraphs
            - fill in content
        - CSS/Bootstrap:
            - change the layout by making a grid
            - change the color
            - change spacing and padding
            - make the avatar image and flip card effect
            - make rounded borders
            - make the progress bar
            - add icons
    - Reference
        - [Here](https://www.w3schools.com) is the reference for CSS/Bootstrap
    - Stylesheets
        - [Here](https://use.fontawesome.com/releases/v5.7.0/css/all.css) and [here](https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css) are the source for icons
        - [Here](https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css) is the link for Bootstrap
        - [Here](http://michalsnik.github.io/aos/) is the animation stylesheet and javascript script
## About The Web App:
- A tictactoe game where two players, X and O, take turns to mark a 3*3 grid. Anyone who first marks all 3 positions of a 
horizontal, vertical, or diagonal line wins.
- At first, X and O get to choose their own color(default is tomato). This color will be showed when they win. If it is a
tie, white will be showed.
- Click on Start Game to start game.
- Click on grid to play.
- Text underneath the grid shows you whose turn it is, who wins the game, and how many rounds X/O wins.
- Click on New Game to start a new **game**, this will reset all records.
- Click on Play Again to start a new **round**, this will keep your record and color.
- If you click on a grid that has already been claimed, don't worry, it's still your turn, just click on another one.
- X and O take turns to play first in a game, but when a new game starts, X always plays first.(ie.X plays first on the first
round, O second round, X third round, etc.)
