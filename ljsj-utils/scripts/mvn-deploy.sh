#! /bin/bash
#
# This script builds and deploys the wayang/server project
# using maven and tomcat.
#
# This script assumes maven is installed and a local
# installation of tomcat is already running. It also
# assumes that the user executing this script has
# placed the necessary tomcat manager configuration
# in ~/.m2/settings.xml
#

# The user with the subversion local copy
USER=ldc

# The path to the subversion repository
# relative to the user's home directory
BASEPATH=Documents/svn/ldc/wayang/server

#################################
## DO NOT EDIT BELOW THIS LINE ##
#################################
FORCEBUILD=0
QUIETBUILD=0

case $1 in
  -f)
    FORCEBUILD=1
    case $2 in
      trunk)
        BUILDPATH=/home/$USER/$BASEPATH/trunk
      ;;
      branch)
        BUILDPATH=/home/$USER/$BASEPATH/branches/$3
      ;;
      tag)
        BUILDPATH=/home/$USER/$BASEPATH/tags/$3
      ;;
    esac
  ;;
  trunk)
    BUILDPATH=/home/$USER/$BASEPATH/trunk
  ;;
  branch)
    BUILDPATH=/home/$USER/$BASEPATH/branches/$2
  ;;
  tag)
    BUILDPATH=/home/$USER/$BASEPATH/tags/$2
  ;;
  list)
    case $2 in
      branches)
        ls /home/$USER/$BASEPATH/branches
      ;;
      tags)
        ls /home/$USER/$BASEPATH/tags
      ;;
      *)
        echo "Usage: mvn-deploy.sh list {branches|tags}"
      ;;
    esac
    exit 0
  ;;
  help)
    echo "mvn-deploy.sh  Version 1.0"
    echo
    echo "Usage: mvn-deploy.sh [OPTIONS] trunk"
    echo "       mvn-deploy.sh [OPTIONS] {branch|tag} VERSION"
    echo "       mvn-deploy.sh list {branches|tags}"
    echo
    echo "OPTIONS:"
    echo
    echo "    -f  forces a build even if there are no new files"
#    echo "    -q  outputs minimal information upon execution"
    echo "    -v  outputs the version information for this script"
    echo
    exit 0
  ;;
  -v)
    echo "mvn-deploy.sh  Version 1.0"
    echo "Copyright (C) 2008 University of Southern California"
    echo "Author: Jean-Philippe Steinmetz <steinmet@isi.edu>"
    exit 0
  ;;
  *)
    echo "Usage: mvn-deploy.sh [OPTIONS] trunk"
    echo "       mvn-deploy.sh [OPTIONS] {branch|tag} VERSION"
    echo "       mvn-deploy.sh list {branches|tags}"
    echo "Try mvn-deploy.sh help for more information"
    exit 0
  ;;
esac

if !([ -d $BUILDPATH ])
then
  echo "Invalid version or build path does not exist."
  exit 1
fi

# Move to build path
pushd $BUILDPATH > /dev/null

# Update subversion
if [ `svn update | wc -l` -le 1 ]
then
  echo "Build is already up to date."

  if [ $FORCEBUILD -eq 0 ]
  then
    exit 0
  fi
fi

# Clean up target directory
mvn clean

# Undeploy existing build
mvn tomcat:undeploy

# Deploy new build
mvn tomcat:deploy

# Move back to original directory
popd > /dev/null

