###################################################################################################################################
#Program Copyright, 2020, Mark J. Lamias, The Stochastic Group, Inc.
#Version 1.0 - Initial Update
#Last Updated:  03/25/2020 6:09 PM EDT
#
#Terms of Service
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
#
#About this Program:  This program simply pushes all changes in a git repository to github
#
#Frequency of Update & Uses:
#This program is executed as called by other programs
#
#Inputs/Global Variables Set by User:
#DATA_DIRECTORY:  A valid R pathname to a local git repository
#COMMIT_MESSAGE:  A github repository commit message
#
#
#Outputs:
#This function returns "working directory clean" if the commits occur without error.
#
###################################################################################################################################

library(git2r)

git_upload<-function(DATA_DIRECTORY, COMMIT_MESSAGE){
  
  #git2r::config(user.name = "mlamias",user.email = "mlamias@yahoo.com")
  repo <- repository(DATA_DIRECTORY)

  #Specify SSH key to github repository
  cred<-cred_ssh_key(publickey = ssh_path("id_rsa.pub"),
                   privatekey = ssh_path("id_rsa"), passphrase = character(0))

  add(repo, "")
  commit(repo, message=COMMIT_MESSAGE, all=TRUE)
  push(repo, credentials = cred)
  status_message<-status(repo)
  return(status_message)
  
}
