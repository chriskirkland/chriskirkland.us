+++
date = "2017-05-11T16:06:56-05:00"
description = "Bash Customization for Fun and Profit"
draft = false
tags = []
title = "#!/bin/bash"
topics = ["bash"]

+++
## Motivation

My name is Chris, and I have a problem. _Hi, Chris._

In all seriousness, I'm not sure I would call it a _problem_ but I am (admittedly) obsessive when it comes to efficiency in my every day life.
Finding little ways to improve how quickly I can complete day-to-day tasks is a game that I constantly play.  I realized recently that my morning
routine of making breakfast follows the general principles of least-constrained optimization: toast starts first,
then tea, then coffee ([instant kettle FTW](https://www.amazon.com/Panasonic-NC-EH40PC-4-2-Quart-Temperature-Selector/dp/B0013O4DOG/ref=sr_1_4?ie=UTF8&qid=1494557570&sr=8-4&keywords=japanese+kettle+instant))
because tea has to steep and toast has to, well, toast which takes the longest.  If I mess up the order slightly, I don't go back and restart -- because that's even more inefficient --
but it _bothers_ me.  In general, I think this obsessive focus on efficiency is a positive trait for the average person; though, it does mean one has to be intentional about slowing down and enjoying
little things in life that aren't necessarily efficient or utilitarian.  On the other hand, I think it is an _extremely_ useful trait for software engineers.

Tasks that I have to do several times a day during work quickly get simplified, automated, or scripted in some way.  Typing the same command several times? Bash alias.  Need to pull down certs from
remote machines that change frequently? Ansible.  Wasting time moving from typing to navigating via arrow keys or mouse/track pad in an IDE?  Vim.  **Constantly checking for context about multiple
pieces of software you interact with?  Add context to your bash prompt.**

## My New Prompt

Here is what my bash prompt looks like these days:

<center>
<img src="/bash-customization/base-annotated.png" alt="bash prompt" />
</center>

I've had some of these "sections" for a while now but others are brand new, so I thought I'd break down why they are there and what they do.  You can check out all of my
[dotfiles](https://github.com/chriskirkland/dotfiles) on Github.

### \#1: Execution status

Whether it is running makefiles, automation scripts, or any command line utility, I like knowing the status of my previous command.  If I pipe some long combination of
`cut`, `awk`, and `xargs` into a `grep -q`, I have no visual indication of whether or not I found a match.  Sure, I can just `echo $?`, but that requires effort.
Instead, start my prompt with a &#x2714; if my last command succeeded and  &#x2718; if it failed:

```bash
# previous command exit code indicator
if [ "$?" -eq 0 ]; then
  PROMPT+="${Green}${CheckSym}${Color_Off} "  # CheckSym=\u2714
else
  PROMPT+="${Red}${ExSym}${Color_Off} "  # ExSym=\u2718
fi
```
_Note: this requires Bash >= 4.2._

Previously, I had the &#x2714; and &#x2718; with the previous command's index in my bash history, but that was extra information which crowded the prompt and I rarely ever used.

### \#2: Kubernetes context

As of a few months ago, I started in a new role at IBM working on the new Containers service based on Kubernetes.  What that means is, I regularly need to access
multiple Kubernetes clusters on a daily basis for testing, debugging, and monitoring.  The normal work flow is to log into some node in the cluster and do whatever
work you need; there are several problems with this:

1. The hosts I need to log into change fairly regularly -- new clusters are added, hosts are rotated in and out, etc.  This is minorly inconvenient, but we can solve the problem fairly easily with more automation.
2. My bash & vim customizations don't automatically come with me.  Again, this can be hacked through with automation, though things start to get more difficult.  But most importantly...
3. I either have to manually format a big kubeconfig to manage all of the environments or deal with multiple kubeconfigs.  Dealing with multiple kubeconfigs worked fine up until I was working
   on 3 or 4 different environments daily.  Then I wanted to combine all of those kubeconfigs into one file.  But managing that file got old quickly.  So I automated the pulling and organization of that
   all-in-one kubeconfig.  Problem solved.

But now I have the problem of context: I don't immediately know which cluster I'm targetting.  No problem!  Add it to the prompt, and I can immediately identify which cluster
I'm targetting:

```bash
local kubernetes_context=$(kubectl config current-context 2>&1)
if [[ "$kubernetes_context" =~ "error: current-context is not set" ]]; then
  PROMPT+="${Dim}${HelmSym} (${NullSym})${Color_Off} "  # HelmSym=\u2388; NullSym=\u2205
else
  PROMPT+="${LightBlue}${HelmSym} (${kubernetes_context})${Color_Off} "
fi
```

### \#3: Git context

Similar to the problem in section \#2 above, I hate manually checking which branch I have checked out locally and whether I have any staged/unstaged changes in my working directory.
This git context section of the prompt shows `git_repo_name:(branch_name)` where branch name is color coded based on the git status:

```bash
local git_status=$(git status -unormal 2>&1)
if [[ "$git_status" =~ nothing\ to\ commit ]]; then
  local Color_On=$Green
elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
  local Color_On=$Purple
else
  local Color_On=$Red
fi
local remote=$(git config --get remote.origin.url)
local repo=$(git config --get remote.origin.url | cut -d'/' -f2 | cut -d'.' -f1)  # default; ssh git source
if echo $remote | grep -q https; then  # https git source
  repo=$(git config --get remote.origin.url | cut -d'/' -f5 | cut -d'.' -f1)
fi

if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
  local branch=${BASH_REMATCH[1]}
else
  # Detached HEAD. (branch=HEAD is a faster alternative.)
  local branch=$(git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD)
fi
# add the result to prompt
PROMPT+="${repo}:(${Color_On}${branch}${Color_Off}) "
```

If my current directory isn't in a git repo, just show the path to my current working directory.

### \#4: Bash input mode

This last addition is probably the simplest, but also my favorite of the list.  As I've mentioned before, I do as much editing as possible in Vim.  I've been primarily developing
in Golang since started work my new role, and I wasn't able to bootstrap my Go-specific editing setup in Vim quickly enough to keep my development pace where I wanted it.
So I was forced to an IDE (_cringe_).  But all is not lost... [Gogland](https://www.jetbrains.com/go/) has a Vim mode!

Anyway, getting used to movement in Vim has completely spoiled me w.r.t. ever other form of editing.  In particular, moving around quickly on the command line in bash
has _always_ been a painful experience for me.  Here's how things usually go: You build up some long chain of `grep ... | awk ... | grep ... | xargs` etc.  Suddenly, you
realize you made a typo at the beginning of the line or you need to change some syntax slightly. What do you do?  Either mash the &#x2190; key or \<ESC\>+b until you get to where
you want. But there has be a better way!  It took me far to long to find out that bash has an editing-mode which accepts either vi(m) or emacs.  So you can use beautiful vim movement
commands or emacs death claws to jump wherever you want in the command.  In particular, you now get modal editing so I pretty-up the mode indicators to make them a bit more to my liking:

```bash
### ~/.inputrc
set editing-mode vi
set show-mode-in-prompt on
set vi-ins-mode-string "\1\e[0;96m\2(ins)\1\e[0m\2"
set vi-cmd-mode-string "\1\e[0;32m\2(cmd)\1\e[0m\2"
```

### Demo

Here is an example demonstrating behavior of the prompt with respect to all of the aforementioned sections:

<center>
<img src="/bash-customization/modes-demo.png" alt="bash prompt modes demo" />
</center>

Here is all the code for my prompt: https://gist.github.com/chriskirkland/7d78773618f26b4c7ff903887eb6c207

### Bonus: Alias "decorations"

One of the problems with having a highly customized terminal/editing environment is that others can have trouble following what you are executing or how you are performing particular actions.
This is particularly true when pair programming with less experienced developers or presenting to groups.  Practically, I could just type out any aliased commands in those contexts,
but I find myself forgetting more than 50% of the time and being annoyed the remainder of the time.  Solution?  Print the underlying command for an alias any time it's run.  There was actually an example imbedded in the
demo above where I ran aliases for `git status` and `git add`.

Code: https://gist.github.com/chriskirkland/940725485b6774751d714272bce42a52

The behavior of these decorations isn't where I'd like them to be.  For instances, above I typed `ga foo` which is actually running `git add foo`.  However, the decoration
only print the content of the alias, `git add`.  I prefer that it mimick _expanding_ the alias and print both the underlying alias content and the trailing positional args.
I've made a few attempts to get that working... but it's proven to be a little tricky.  Always room for improvement :-)


