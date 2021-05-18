# prompt.sh

Only tested on MacOS because I'm a sad little consumer.

My use for this is to copy `prompt.sh` to `~/bash.d/prompt.sh` and then in my
bash profile file (usually `~/.bash_profile` or `~/.bashrc`), add this line:

      source ~/bash.d/prompt.sh

Be prepared! This does some opinionated things to your command line interface
that you may not like. I **strongly** recommend editing this before using.
Some specific things you may not like (note: this is also the entire feature set
of this script):

* Read up on the HISTTIMEFORMAT, histappend, etc. stuff. I like all of my
  terminals to feed into the same history file, and use `<ctrl>-r` a lot to find
  specific commands.
* The `set -o vi` is going to make your command line accept VIM keyboard
  shortcuts, which can be really confusing. If you didn't read the previous
  sentence and think "OH JOY," I recommend deleting that line (line 10 as of
  this writing).
* It's gonna make your prompt look like my prompt:

      tweigel@medusa ~ $  # home directory, just chillin
      tweigel@medusa Documents $  # in a directory called Documents
      p3dev║tweigel@medusa ~ $  # when using a python virtual env
      tweigel@medusa proj║master $  # master branch of a git repo
      p3║tweigel@medusa proj║test $  # test branch with p3 virtual env


# git.sh

Only tested on MacOS because I'm a sad little consumer.

My use for this is to copy `git.sh` to `~/bash.d/git.sh` and then in my
bash profile file (usually `~/.bash_profile` or `~/.bashrc`), add this line:

      source ~/bash.d/git.sh

This makes a simple function called `git.lastmodified` available to my bash
shell. This returns the last git log date for a directory (or the current
directory by default). For example, you can do something like this:

      $ cd ~/myrepos/
      $ git.lastmodified kit/
      2021-05-17


# pip.sh

Only tested on MacOS because I'm a sad little consumer.

My use for this is to copy `pip.sh` to `~/bash.d/pip.sh` and then in my
bash profile file (usually `~/.bash_profile` or `~/.bashrc`), add this line:

      source ~/bash.d/pip.sh

This adds a simple tab autocomplete to pip. It's silly, but it makes me happier
to have.

It also adds a shortcut for updating everything in your current pip install
library.

  pip.updateall  # checks and updates everything in your pip install


# python.sh

Only tested on MacOS because I'm a sad little consumer. Works best with ripgrep
(`https://github.com/BurntSushi/ripgrep`) installed.

My use for this is to copy `python.sh` to `~/bash.d/python.sh` and then in my
bash profile file (usually `~/.bash_profile` or `~/.bashrc`), add this line:

      source ~/bash.d/python.sh

This lets you call `py.outline` at the command line, which gives you an outline
of all classes and functions defined in the current directory (recursive).

If you have ripgrep installed, you can also pass in the argument `--docs` to get
any docstrings as well. `py.outline --docs`

If you have ripgrep installed, you can also pass in a specific directory or file
to outline, instead. `py.outline foo.py`


# venv.sh

Only tested on MacOS because I'm a sad little consumer.

My use for this is to copy `venv.sh` to `~/bash.d/venv.sh` and then in my bash
profile, add this line:

      source ~/bash.d/venv.sh

This manages python virtual environments for you, in a hidden home directory
(`.venv`), and provides a small handful of command line functions:

      venv NAME         # switches into managed NAME virtualenv
      venv.mk NAME      # creates a managed Python3 virtualenv as NAME
      venv.repair NAME  # repairs managed Homebrew-broken virtualenvs
      venv.rm NAME      # deletes the managed NAME virtualenv
      venv.ls           # lists all managed virtualenvs


# aws.sh

Only tested on MacOS because I'm a sad little consumer.

My use for this is to copy `aws.sh` to `~/bash.d/aws.sh` and then in my bash
profile, add this line:

      source ~/bash.d/aws.sh

A growing collection of shortcut commands for the specific AWS CLI environment
I'm in at the moment. Possibly more of an example of the work-in-progress than
an actual tool for general use.

      aws.ls-ec2-names  # finds all EC2 Name tags in your current configured profile
      aws.ec2-by-name   # returns the EC2 instance-id from a Name tag
      aws.ssm           # connects via SSM SSH to an EC2 instance by Name tag

      aws.ls            # lists profiles for `aws configure`
      aws.profile       # sets AWS_PROFILE for you; can be used with '--sso'

