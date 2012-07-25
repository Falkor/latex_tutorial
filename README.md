-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-
`README.md`

Copyright (c) 2012 [Sebastien Varrette](mailto:<Sebastien.Varrette@uni.lu>) [[www](http://varrette.gforge.uni.lu)]

        Time-stamp: <Thu 2012-07-26 01:08 svarrette>

-------------------

# Synopsis

Tutorial to the use of the LaTeX document markup language, yet __in French__. 

This repository holds the LaTeX sources of the tutorial as the best way to learn LaTeX is probably to check how people are writting documents in LaTeX. 
You can view the different versions of the PDF generated from these sources [here](https://github.com/Falkor/latex_tutorial/downloads)

# Installation

The sources of the LaTeX tutorial are hosted as a Git repository on [GitHub](https://github.com/Falkor/latex_tutorial)
You should therefore first clone this repository as follows:

	$> git clone git://github.com/Falkor/latex_tutorial.git

Once cloned, simply run `make` to generate the PDF file. 
For most of the users, that's sufficient. 

Feel free to browse the LaTeX sources of the document to check how a given piece
of LaTeX code is rendered. 

# Advanced information

## Git Branching Model

The Git branching model for this repository follows the guidelines of [gitflow](http://nvie.com/posts/a-successful-git-branching-model/). 
In particular, the central repository holds two main branches with an infinite lifetime: 

* `production`: the branche holding tags of the successive releases of the LaTeX tutorial
* `master`: the main branch where the sources are in a state with the latest delivered development changes for the next release. This is the *default* branch you get when you clone the repo, and teh one on which developments will take places. 

You should therefore install [git-flow](https://github.com/nvie/gitflow), and probably also its associated [bash completion](https://github.com/bobthecow/git-flow-completion). 
Also, to facilitate the tracking of remote branches, you probably wants to install [grb](https://github.com/webmat/git_remote_branch) (typically via ruby gems). 

Then, to make your local copy of the repository ready to use my git-flow workflow, you have to run the following commands once you cloned it for the first time:

      $> make setup

Note that it assumes you have installed `grb`

## Releasing mechanism

The operation consisting of releasing a new version of this repository is automated by a set of task within the `Makefile`. 

The version number have the following format: 

      <major>.<minor>.<patch>-b<build>
      
where:

* `<major>` corresponds to the major version number
* `<minor>` corresponds to the minor version number
* `<patch>` corresponds to the patching version number
* `<build>` states the build number _i.e._ the total number of commits within the `master`branch. 
      
Example: `1.0.0-b28`

The current version number is stored in the file `VERSION`. __/!\ NEVER MAKE ANY MANUAL CHANGE TO THIS FILE__

For more information on the version, run:

     $> make versioninfo

If a new  version number such be bumped, you simply have to run:

      $> make start_bump_{major,minor,patch}

This will start the release process for you using `git-flow`. Probably after that, the first things to do is to change within the main LaTeX document the version number and commit this change. 
Then, to make the release effective, just run: 

      $> make release

it will finish the release using `git-flow`, create the appropriate tag in the `production` branch and merge all things the way they should be. 
Also, you will have the generated PDF for the freshly released version as a file named `Tutorial_Latex_v<major>.<minor>.<patch>-b<build>.pdf`.


# Licence

This tutorial is released under the
[Creative Commons Attribution-Noncommercial-Share Alike 2.0 France](http://creativecommons.org/licenses/by-nc-sa/2.0/fr/deed.en_US)
licence. 
In particular:

### You are free:

 * __to Share__: to copy, distribute and transmit the work
 * __to Remix__:  to adapt the work

### Under the following conditions:

 * ![Attribution](http://creativecommons.org/images/deed/by.png) __Attribution__:
   You must attribute the work in the manner specified by the author or licensor
   (but not in any way that suggests that they endorse you or your use of the
   work).  

 * ![Noncommercial](http://creativecommons.org/images/deed/nc-eu.png)
    __Noncommercial__: You may not use this work for commercial purposes. 

 * ![Share Alike](http://creativecommons.org/images/deed/sa.png) __Share Alike__:
    If you alter, transform, or build upon this work, you may distribute the
    resulting work only under the same or similar license to this one. 

### With the understanding that:

 * __Waiver__: Any of the above conditions can be __waived__ if you get permission
    from the copyright holder. 
    
 * __Public Domain__: Where the work or any of its elements is in the __public
   domain__ under applicable law, that status is in no way affected by the
   license. 
   
 * __Other Rights__: In no way are any of the following rights affected by the
   license: 
   
   * Your fair dealing or __fair use__ rights, or other applicable copyright
        exceptions and limitations; 
   * The author's __moral__ rights;
   * Rights other persons may have either in the work itself or in how the work
    is used, such as publicity or privacy rights. 
    
 * __Notice__: For any reuse or distribution, you must make clear to others the
   license terms of this work. The best way to do this is with a link to this
   web page. 


